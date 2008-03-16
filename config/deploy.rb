set :application, "jdclayton"

set :user, 'jclayton'
set :deploy_to, "/users/home/#{user}/apps/#{application}"

set :scm, :git

set :repository,  "git@github.com:joshuaclayton/jdclayton.git"
# set :deploy_vid, :remote_cache

set :server, "coloma.joyent.us"
set :mongrel_port, 4011
set :mongrel_servers, 1

role :app, "#{server}"
role :web, "#{server}"
role :db,  "#{server}", :primary => true