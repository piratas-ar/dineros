set :deploy_user, 'app'
set :deploy_to, '/srv/http/dineros.partidopirata.com.ar'
set :branch, ENV.fetch('branch', 'develop')

set :rails_env, 'production'

# en Parabola /tmp está montado noexec
set :tmp_dir, "#{fetch :deploy_to}/tmp"

# Las gemas se comparten con otras apps
set :bundle_path, '/srv/http/gemas.partidopirata.com.ar'
# Evitar compilar nokogiri
set :bundle_env_variables, { nokogiri_use_system_libraries: 1 }

# IP del VPS
server 'partidopirata.com.ar', port: 1863, user: fetch(:deploy_user), roles: %w{app web db}
