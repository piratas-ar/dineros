set :application, 'dineros'
set :repo_url, 'https://github.com/piratas-ar/dineros'

set :linked_dirs, %w(db gnupg)
set :linked_files, %w(.env public/dineros.asc)

namespace :deploy do
  desc 'Genera la llave gpg remota'
  task :gpg_generate do
    on primary :app do
      within release_path do
        with padrino_env: fetch(:rails_env) do
          execute :rake, 'gpg:generate'
        end
      end
    end
  end

  desc 'Hace un backup de la base de datos antes de migrarla'
  task :backup, [:set_rails_env] do
    on primary :db do
      within release_path do
        with padrino_env: fetch(:rails_env) do
          # https://gist.github.com/rsutphin/9010923
          resolved_release_path = capture(:pwd, '-P')
          set(:release_name, resolved_release_path.split('/').last)
          execute :cp,
                  "db/dineros_#{fetch(:rails_env)}.db db/dineros_pre_#{fetch(:release_name)}.db"
        end
      end
    end
  end

  desc 'Migra la base de datos'
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

before 'deploy:mr_migrate', 'deploy:backup'
before 'deploy:restart', 'deploy:mr_migrate'
