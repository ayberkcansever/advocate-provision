name              "advocate-server"
maintainer        "Tony Pitale"
maintainer_email  "tpitale@gmail.com"
license           "MIT"
description       "Installs and configures our web server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"

depends 'ufw'
depends 'sudo'
depends 'logrotate'
depends 'postgresql'
depends 'nginx'
depends 'chruby_install'
depends 'ruby-install'
depends 'puma'
depends 'systemd'
