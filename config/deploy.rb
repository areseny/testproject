require 'erb'
require 'yaml'

# config valid only for current version of Capistrano
lock '3.4.1'

set :application, 'ink-api'
set :repo_url, 'git@gitlab.coko.foundation:INK/ink-api.git'

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/ink_api.yml', '.env')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

set :bundle_binstubs, nil

set :verbosity, :error

desc "Check if agent forwarding is working"
task :forwarding do
  on roles(:all) do |h|
    if test("env | grep SSH_AUTH_SOCK")
      info "Agent forwarding is up to #{h}"
    else
      error "Agent forwarding is NOT up to #{h}"
    end
  end
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

set :migration_role, :app

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

  desc 'Invoke a rake command on the remote server'
  task :invoke, [:command] => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake args[:command]
        end
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  task :check_secrets do
    on roles(:app), in: :sequence do |host|
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake :check_secrets
        end
      end
    end
  end

  desc "deploy app for the first time (expects pre-created but empty DB)"
  task :cold do
    before 'deploy:migrate', 'deploy:initdb'
    invoke 'deploy'
  end

  desc "initialize a brand-new database (db:schema:load, db:seed)"
  task :initdb do
    on primary :web do |host|
      within release_path do
        with :rails_env => fetch(:rails_env) do
          # if test(:psql, 'portal_production -c "SELECT table_name FROM information_schema.tables WHERE table_schema=\'public\' AND table_type=\'BASE TABLE\';"|grep schema_migrations')
          #   puts '*** THE DATABASE IS ALREADY INITIALIZED! ***'
          # else
          #   execute :rake, 'db:environment:set RAILS_ENV=demo'
            execute :rake, 'db:drop'
            execute :rake, 'db:create'
            execute :rake, 'db:schema:load'
            # execute :rake, 'db:seed RAILS_ENV=demo'
          # end
        end
      end
    end
  end

  # desc 'Deploy app for first time'
  # task :cold do
  #   invoke 'deploy:starting'
  #   invoke 'deploy:started'
  #   invoke 'deploy:updating'
  #   invoke 'bundler:install'
  #   invoke 'deploy:db_load_schema' # This replaces deploy:migrations
  #   invoke 'deploy:compile_assets'
  #   invoke 'deploy:normalize_assets'
  #   invoke 'deploy:publishing'
  #   invoke 'deploy:published'
  #   invoke 'deploy:finishing'
  #   invoke 'deploy:finished'
  # end
  #
  # desc 'Setup database'
  # task :db_load_schema do
  #   on roles(:db) do
  #     within release_path do
  #       with rails_env: (fetch(:rails_env) || fetch(:stage)) do
  #         execute :rake, 'db:schema:load'
  #       end
  #     end
  #   end
  # end

  # before :publishing, 'deploy:check_secrets'
  after :publishing, 'deploy:restart'
  # after :publishing, 'deploy:custom_symlinks'
  after :finishing, 'deploy:cleanup'

end

