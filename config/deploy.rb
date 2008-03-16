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