set :application, 'dineros'
set :repo_url, 'http://repo.hackcoop.com.ar/dineros.git'

set :linked_dirs, %w{db gnupg}
set :linked_files, %w{.env public/dineros.asc}

set :rbenv_type, :user
set :rbenv_ruby, '2.2.1'

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

namespace :deploy do
  desc "Genera la llave gpg remota"
  task :gpg_generate do
    on primary :app do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'gpg:generate'
        end
      end
    end
  end

  desc "Migra la base de datos"
  task :mr_migrate do
    on primary :db do
      within release_path do
        with padrino_env: fetch(:rails_env) do
          execute :rake, 'mr:migrate'
        end
      end
    end
  end
end
