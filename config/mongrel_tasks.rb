require 'yaml'
# mongrel-based overrides of the default tasks

namespace :deploy do
  namespace :mongrel do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the mongrel appserver"
      task t, :roles => :app do
        root = `pwd`.to_s.strip
        settings = YAML::load(File.new(File.join(root, "config", "mongrel_cluster.yml")).read)
        #invoke_command checks the use_sudo variable to determine how to run the mongrel_rails command
        invoke_command "mongrel_rails #{t.to_s} -P #{settings["pid_file"]}#{" -C #{mongrel_conf}" if t == :start}", :via => run_method
      end
    end
  end

  desc "Custom restart task for mongrel cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.mongrel.restart
  end

  desc "Custom start task for mongrel cluster"
  task :start, :roles => :app do
    deploy.mongrel.start
  end

  desc "Custom stop task for mongrel cluster"
  task :stop, :roles => :app do
    deploy.mongrel.stop
  end
end
