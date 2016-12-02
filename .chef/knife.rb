# require 'librarian/chef/integration/knife'

cookbook_path    ["cookbooks", "site-cookbooks"]
node_path        "nodes"
role_path        "roles"
environment_path "environments"
data_bag_path    "data_bags" # TODO: move outside repo, document configuration required
#encrypted_data_bag_secret "data_bag_key"

Chef::Config[:ssl_verify_mode] = :verify_peer if defined? ::Chef
