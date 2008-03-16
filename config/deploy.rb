set :application, "jdclayton"

set :user, 'jclayton'
set :deploy_to, "/users/home/#{user}/apps/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

set :scm, :git
set :repository,  "git@github.com:joshuaclayton/jdclayton.git"
# set :deploy_vid, :remote_cache

set :server, "coloma.joyent.us"
set :mongrel_port, 4011
set :mongrel_servers, 1

set :use_sudo, false

role :app, "coloma.joyent.us"
role :web, "coloma.joyent.us"
role :db,  "coloma.joyent.us", :primary => true

task :update_config, :roles => [:app] do
  run "cp -r #{shared_path}/config/. #{release_path}/config/"
end

task :symlink_logs, :roles => [:app] do
  run "rm -rf #{release_path}/log"
  run "ln -s #{shared_path}/log #{release_path}"
end

task :symlink_cache, :roles => [:app] do
  run "ln -s #{shared_path}/cache #{release_path}/public"
end

task :symlink_web, :roles => [:app] do 
  run "rm -f /users/home/#{user}/web"
  run "ln -s #{current_path} /users/home/#{user}/web"
end

after "deploy:update_code", :update_config
after "deploy:update_code", :symlink_logs
after "deploy:update_code", :symlink_cache
after "deploy:update_code", :symlink_web  