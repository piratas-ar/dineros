set :application, 'dineros'
set :repo_url, 'http://repo.hackcoop.com.ar/dineros.git'

set :rbenv_type, :user
set :rbenv_ruby, '2.2.0'

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

namespace :deploy do
  desc "Genera la llave gpg remota"
  task :gpg_generate do
    run :rake, 'gpg:generate'
  end
end
