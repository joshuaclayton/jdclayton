namespace :svn do
  desc "Configure Subversion for Rails"
  task :configure do
    # Configure tmp
    `svn propset svn:ignore "*" tmp/sessions`
    `svn propset svn:ignore "*" tmp/sockets`
    `svn propset svn:ignore "*" tmp/cache`
    `svn propset svn:ignore "*" tmp/pids`
    
    # Configure log
    `svn remove log/*`
    `svn propset svn:ignore "*" log/`
    `svn update log/`
    
    # Configure db
    `(echo "*.db"; echo "schema.rb") > ignore.svn`
    `svn propset svn:ignore -F ignore.svn db/`
    `rm ignore.svn`
    `svn update db/`
    
    # Configure public
    `svn remove public/index.html`
    `svn propset svn:ignore "engine_files" public/`
    `svn propset svn:ignore "plugin_assets" public/`
    `svn update public/`
    
    # Configure config
    `svn mv config/database.yml config/database.example.yml`
    `(echo "database.yml"; echo "settings.yml"; echo "gmaps_api_key.yml"; echo "lighttpd.conf") > ignore.svn`
    `svn propset svn:ignore -F ignore.svn config/`
    `rm ignore.svn`
    `svn update config/`
    
    # Set executable properties
    `svn propset svn:executable ON public/dispatch.*`
    `svn propset svn:executable ON script/* > /dev/null 2>&1` # suppress complaining about script/performance being a dir
    `svn propset svn:executable ON script/performance/*`
    
    # Commit
    `svn commit -m "configure_for_svn:  Configured project for subversion"`
  end
   
  desc "Add new files to subversion"
  task :add do
     `svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add`
  end
end

desc "Print directories managed by Piston." 
task :pistoned do
  puts Dir['**/.svn/dir-props'].select { |file| File.read(file) =~ /piston/ }.map { |file| file.split('.svn').first }
end