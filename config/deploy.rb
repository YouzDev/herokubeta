require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/rvm"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"


# config valid only for current version of Capistrano
lock '3.4.0'

set :rvm_ruby_version, '2.2.2@portage'

set :default_stage,   'staging'
set :stages,          %w(staging production)

set :application, 'testapp'
set :repo_url, 'https://github.com/YouzDev/capistranotest.git'
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

set :user,   'vagrant'
set :use_sudo,        false

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch,    fetch(:branch, "master")

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/apps/#{fetch(:full_app_name)}"

# Default value for :scm is :git
 set :scm, :git
set :ssh_options, {
  forward_agent: true
}
# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, %w{config/database.yml config/.env config/unicorn_init.sh config/unicorn.rb log/session.secret}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, %w{log tmp/pids}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5
 # '--deployment --quiet' is the default


set :rvm_map_bins, %w{gem rake ruby bundle}
set :bundle_bins, %w{gem rake ruby}

set(:config_files, %w(
  nginx.conf
  database.example.yml
  unicorn.rb
  unicorn_init.sh
))

set(:executable_config_files, %w(
  unicorn_init.sh
))

set(:symlinks, [
  {
    source: "nginx.conf",
    link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
  },
  {
    source: "unicorn_init.sh",
    link: "/etc/init.d/unicorn_#{fetch(:full_app_name)}"
  }
])

# set :linked_dirs, %w(public/system log tmp)
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp', 'vendor/bundle', 'public/system')

namespace :deploy do


  task :start do ; end
  task :stop do ; end
  desc "Start unicorn"
  task :start do
    on roles(:app) do
      within current_path do
        with RAILS_ENV: fetch(:rails_env) do
          within current_path do
            execute :bundle, :exec, "#{current_path}/config/unicorn_init.sh start"
          end
        end
      end
    end
  end

  desc "Stop unicorn"
  task :stop do
    on roles(:app) do
      within current_path do
        execute "#{current_path}/config/unicorn_init.sh stop"
      end
    end
  end

  desc "restart of Unicorn"
  task :restart do
    on roles(:app) do
      within current_path do
         execute "#{current_path}/config/unicorn_init.sh stop"
         execute "#{current_path}/config/unicorn_init.sh start"
      end
    end
  end

  task :launch_migrate do
    on roles(:app) do
      within current_path do
        with RAILS_ENV: fetch(:rails_env) do
          execute :rake,  "db:migrate"
        end
      end
    end
  end

  task :bundle_install do
    on roles(:app) do
      within current_path do
        execute :bundle, :install
      end
    end
  end

  task :precompile_assets do 
    on roles(:app) do
      within current_path do
        with RAILS_ENV: fetch(:rails_env) do
          execute :rake,  "assets:precompile"
        end
      end
    end
  end



  after "finishing", "deploy:bundle_install"
  # after "finishing", "deploy:restart"
  after "finishing", "deploy:launch_migrate"
  # after "finishing", "deploy:precompile_assets"

end
