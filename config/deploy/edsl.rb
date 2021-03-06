set :deploy_user, 'app'
set :deploy_to, '/srv/http/dineros.endefensadelsl.org'
set :branch, 'develop'

set :rails_env, 'production'

# en Parabola /tmp está montado noexec
set :tmp_dir, "#{fetch :deploy_to}/tmp"

# Las gemas se comparten con otras apps
set :bundle_path, '/srv/http/gemas'
# Evitar compilar nokogiri
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :default_env, path: '/usr/lib/passenger/bin/:$PATH'

set :passenger_restart_with_sudo, false
set :passenger_environment_variables, path: '/usr/lib/passenger/bin/:$PATH'
set :passenger_restart_command, 'sudo passenger-config restart-app'

# IP del VPS
server 'lainventoria.com.ar',
       port: 22,
       user: fetch(:deploy_user),
       roles: %w(app web db)
