set :application, "jdclayton"

set :user, 'jclayton'
set :deploy_to, "/users/home/#{user}/web"

set :scm, :git
set :repository,  "git@github.com:joshuaclayton/jdclayton.git"
set :deploy_vid, :remote_cache

set :server, "coloma.joyent.us"
set :mongrel_port, 4011
set :mongrel_servers, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:



# If you aren't using Subversion to manage your source code, specify
# your SCM below:

role :app, server
role :web, server
role :db,  server, :primary => true