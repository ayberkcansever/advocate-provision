%w(git-core curl build-essential python-software-properties zlibc zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev emacs libxml2 libxml2-dev libxslt1.1 libxslt1-dev libyaml-dev).each do |name|
  package name do
    action :install
  end
end

## Users ##

public_keys = data_bag_item('public_keys', 'keys')

user_id = node['advocate-server']['user']['id']
home_dir = "/home/#{user_id}"
database_name = node['advocate-server']['database']['name']

group user_id # create group if it does not exist

user user_id do
  shell '/bin/bash'
  group user_id
  supports :manage_home => true
  home home_dir
end

sudo user_id do
  group user_id
  nopasswd true

  commands [
    '/usr/sbin/service advocate-puma start',
    '/usr/sbin/service advocate-puma stop',
    '/usr/sbin/service advocate-puma restart'
    # '/usr/sbin/service advocate-workers start',
    # '/usr/sbin/service advocate-workers stop',
    # '/usr/sbin/service advocate-workers restart'
  ]
end

directory home_dir+'/.ssh' do
  owner user_id
  group user_id
  mode '0700'
end

directory home_dir+'/.bundle' do
  owner user_id
  group user_id
  mode '0700'
end

file "#{home_dir}/.bundle/config" do
  owner user_id
  group user_id
  mode '0700'
  content <<-EOF
    BUNDLE_BIN: bin
    BUNDLE_SHEBANG: chruby-exec
    BUNDLE_DISABLE_SHARED_GEMS: '1'
    BUNDLE_PATH: vendor
  EOF
end

template "#{home_dir}/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  owner user_id
  group user_id
  mode '0600'
  variables :keys => public_keys['values']
end

## Postgresql (default 9.4) ##
postgresql_users = Chef::EncryptedDataBagItem.load('passwords', 'postgresql')['users']
# node.override['postgresql']['password']['postgres'] = postgresql_users['postgres']['password']

include_recipe 'postgresql::libpq'
include_recipe 'postgresql::server_dev'
include_recipe 'postgresql::server'
include_recipe 'postgresql::client'
include_recipe 'postgresql::contrib'

postgresql_users.each do |id, u|
  pg_user id do
    password u['password']
    privileges({
      superuser: u['superuser'],
      createdb: true,
      login: true
    })
  end
end

pg_database database_name do
  owner user_id
  encoding "UTF-8"
  template "template0"
  locale "en_US.UTF-8"
end

## Application ##
include_recipe "chruby_install"
include_recipe "ruby-install::install"

v = {
  :app_root => "/u/apps/advocate",
  :name => "advocate"
}

directory v[:app_root] do
  owner user_id
  group user_id
  recursive true
end

directory v[:app_root] + "/shared/" do
  owner user_id
  group user_id
  recursive true
end

%w(config log tmp sockets pids).each do |dir|
  directory(v[:app_root] + "/shared/" + dir) do
    owner user_id
    group user_id
    recursive true
    mode 0755
  end
end

# find the db user which matches the application user id
application_db_user = postgresql_users[user_id]

template v[:app_root] + "/shared/config/database.yml" do
  mode 0750
  owner user_id
  group user_id
  source "database.yml.erb"

  db_settings = {
    db_name: database_name,
    db_user: user_id,
    db_password: application_db_user['password'],
    host: 'localhost'
  }

  variables db_settings
end

puma_config v[:name] do
  owner user_id
  directory v[:app_root]
  upstart false
  monit false
  logrotate true # the default
  thread_min 0
  thread_max 16
  workers 2
end

# template "/etc/init/advocate-workers.conf" do
#   user "root"
#   group "root"
#   cookbook "advocate-server"
#   source "upstart.workers.conf.erb"
#   mode "0644"
# end

## nginx ##

apt_repository 'nginx-ppa' do
  uri 'http://ppa.launchpad.net/nginx/stable/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver "keyserver.ubuntu.com"
  key 'C300EE8C'
end

include_recipe 'nginx'

nginx_config_path = "/etc/nginx/sites-available/#{v[:name]}"

template nginx_config_path do
  mode 0644
  source "nginx.conf.erb"
  variables v.merge(:server_names => "advocatehq.com")
  notifies :reload, "service[nginx]"
end

nginx_site v[:name] do
  config_path nginx_config_path
  enable true
end

nginx_site :default do
  enable false
end

# cron "upcoming" do
#   action :create
#   user "deploy"
#   # mailto

#   shell "/bin/bash"
#   path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

#   minute "0"
#   hour "*/6"

#   command 'cd /u/apps/advocate/current && chruby-exec 2.2.2 -- bin/rails runner -e production "Episode.load_all_from_upcoming"'
# end

systemd_service 'advocate-puma' do
  description 'Advocate Puma Server'

  after %w( network.target )

  install do
    wanted_by 'multi-user.target'
  end

  systemd_service do
    type "simple"
    user user_id
    group user_id
    working_directory "#{v[:app_root]}/current"

    # environment 'LANG' => 'C'
    # exec_start "chruby-exec 2.3.1 bundle exec puma -C #{config_path}"

    # kill_signal 'SIGWINCH'
    # kill_mode 'mixed'
    # private_tmp true
  end

  only_if { ::File.open('/proc/1/comm').gets.chomp == 'systemd' } # systemd
end

service 'advocate-puma' do
  action [:enable]
end
