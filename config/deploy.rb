set :application, "jdclayton"

set :user, 'jclayton'
set :deploy_to, "/users/home/#{user}/apps/#{application}"

set :scm, :git

set :repository,  "git@github.com:joshuaclayton/jdclayton.git"
# set :deploy_vid, :remote_cache

set :server, "coloma.joyent.us"
set :mongrel_port, 4011
set :mongrel_servers, 1

role :app, "coloma.joyent.us"
role :web, "coloma.joyent.us"
role :db,  "coloma.joyent.us", :primary => true

task :update_config, :roles => [:app] do
  run "cp -Rf #{shared_path}/config/* #{release_path}/config/"
end

task :symlink_logs, :roles => [:app] do 
  run "ln -s #{release_path}/log #{shared_path}/log"
end

task :symlink_web, :roles => [:app] do 
  run "ln -s /users/home/#{user}/web #{release_path}"
end

after "deploy:update_code", :update_config
after "deploy:update_code", :symlink_logs
after "deploy:update_code", :symlink_web  