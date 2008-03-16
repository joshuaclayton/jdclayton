require 'fileutils'
require 'tempfile'
require File.join(RAILS_ROOT, 'vendor/plugins/fusionary_power_tools/lib/fusionary/util/text')
include Fusionary::Util::Text


def get_svn_tag
  tags = ["trunk"]
  IO.popen("svn ls http://svn.fusionary.com/svn/fusionary/plugins/cms_engine/tags").each {|l| tags << l.gsub(/\W$/, '')}
  puts "Please choose which CMS plugin version to install:"
  tags.each_with_index {|tag, index| puts "#{index+1}) #{tag}"}
  tags[STDIN.gets.chomp.to_i - 1] rescue nil
end

namespace :cms do 
  
  desc "Create a new CMS installation"
  task :install do
    Rake::Task["cms:install_plugins"].invoke
    Rake::Task["cms:configure"].invoke
    Rake::Task["svn:configure"].invoke
  end
  
  desc "Upgrade CMS from old 3 part engine to newer, unified engine"
  task :upgrade => [:environment] do
    Rake::Task["cms:remove_old_cms"].invoke
    Rake::Task["cms:install_plugins"].invoke
    Rake::Task["cms:force_engine_migration"].invoke
    sh "svn commit -m 'Final commit in the CMS upgrade phase'"
  end
  
  desc "Install engines plugin and cms engine"
  task :install_plugins do
    cms_ver = get_svn_tag
    raise "Invalid choice for CMS version" unless cms_ver
    cms_url = (cms_ver == "trunk" ? "http://svn.fusionary.com/svn/fusionary/plugins/cms_engine/trunk" : 
      "http://svn.fusionary.com/svn/fusionary/plugins/cms_engine/tags/#{cms_ver}")
    plugins = {
      "mail_logger"            => "http://svn.fusionary.com/svn/fusionary/plugins/mail_logger",
      "engines"                => "http://svn.fusionary.com/svn/fusionary/third_party/new_cms/engines",
      "cms_engine"             => cms_url,
      "restful_authentication" => "http://svn.techno-weenie.net/projects/plugins/restful_authentication",
      "rails_rcov"             => "http://svn.fusionary.com/svn/fusionary/third_party/rails_rcov",
      "rspec"                  => "http://svn.fusionary.com/svn/fusionary/third_party/rspec",
      "rspec_on_rails"         => "http://svn.fusionary.com/svn/fusionary/third_party/rspec_on_rails"
    }
    
    plugins.each do |plugin, repo|
      plugin_dir = "vendor/plugins/#{plugin}"
      unless File.exists? File.join(RAILS_ROOT, plugin_dir)
        # this seems really stupid but it is necessary for piston to work correctly
        sh "svn update"
        puts "## Installing #{plugin} plugin"
        sh "piston import #{repo} #{plugin_dir}"
      end
    end
  end
  
  desc "Force plugin_schema_info to reflect engines plugins migration version"
  task :force_engine_migration => [:environment] do
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[RAILS_ENV]) 
    puts '## Forcing plugin_schema_info to reflect correct version since we already have the correct tables'
    create_sql = "CREATE TABLE plugin_schema_info( plugin_name VARCHAR(255), version INTEGER )"
    ins_sql    = "INSERT INTO plugin_schema_info (plugin_name, version) VALUES ('cms_engine', 9)"
    ActiveRecord::Base.connection.execute(create_sql)
    ActiveRecord::Base.connection.execute(ins_sql)
  end
  
  desc "Create authenticated user"
  task :create_authenticated_user do
    puts '## Creating default user'
    ruby %{script/generate authenticated user -c}
  end
  
  desc "Bootstrap the database"
  task :bootstrap do 
    
    puts '## Bootstrapping RSspec'
    ruby %{script/generate rspec -c}
    
    ml_src  = File.join(RAILS_ROOT, "vendor", "plugins", "mail_logger", "db")
    ml_dest = File.join(RAILS_ROOT, "db", "migrate")
    
    unless File.exists?(ml_dest)
      sh %{svn mkdir #{ml_dest}}
    end
    
    unless File.exists?(File.join(ml_dest, "001_create_mail_logs.rb"))
      FileUtils.cp(File.join(ml_src, "001_create_mail_logs.rb"), ml_dest)
      sh %{svn add #{File.join(ml_dest, "001_create_mail_logs.rb")}}
    end
    
    Rake::Task["cms:create_authenticated_user"].invoke
    
    puts '## Creating engine migration'
    ruby %{script/generate plugin_migration -c}
    
    sh %{svn add db/migrate/003_cms_engine_to_version_9.rb}
    
    puts '## Migrating database'
    Rake::Task["db:migrate"].invoke
    
    puts '## Creating admin user'
    Rake::Task["create_admin_user"].invoke
    
    sh %{svn commit -m "Project created"}
    
  end
  
  desc "Configure routes and enviroment for cms_engine plugin"
  task :configure do
    puts '### Configuring routes and environment'
    
    add_text "  map.from_plugin :cms_engine",
      :to => File.join(RAILS_ROOT, "config", "routes.rb"),
      :before => /^  # Allow downloading Web Service WSDL as a file with an extension$/
    
    add_text %Q{  config.plugins = ["engines", "*"]\n},
      :to => File.join(RAILS_ROOT, "config", "environment.rb"),
      :after => /^  # config.active_record.default_timezone = :utc$/
    
  end
  
  desc "Remove old engine plugins and engines"
  task :remove_old_cms do
    puts '## Removing old Engines plugin and CMS'
    
    sh "svn propdel svn:externals vendor/engines"
    sh "svn commit -m 'removing externals props from old engines for CMS upgrade'"
    
    sh "svn rm --force vendor/engines"
    sh "svn commit -m 'Remove old engines directory from CMS'"
    
    sh "svn update"
    
    sh "piston convert"
    sh "svn commit -m 'Converted SVN externals to piston for CMS upgrade'"
    
    sh "svn rm --force vendor/plugins/engines"
    sh "svn commit -m 'remove old engines plugin for CMS upgrade'"
    
  end
  
  desc "Dump all of the documents stored in dbfile to the filesystem storage"
  task :convert_dbfile_to_fs => :environment do
    
    # Need to reopen to get dbfile funcionality back and re-add a couple of 
    # methods from fs backend.
    class Document < ActiveRecord::Base
      acts_as_attachment
      
      def full_filename(thumbnail = nil)
        File.join(RAILS_ROOT, attachment_options[:file_system_path], id.to_s, thumbnail_name_for(thumbnail))
      end

      def public_filename(thumbnail = nil)
        full_filename(thumbnail).gsub %r(^#{Regexp.escape(File.join(RAILS_ROOT, 'public'))}), ''
      end
      
    end
    
    Document.find(:all).each do |doc|
      fn = File.join(RAILS_ROOT, 'public', doc.public_filename)
      unless File.exists?(fn)
        if doc.db_file
          FileUtils.mkdir_p(File.dirname(fn))
          File.new(fn, 'w').syswrite(doc.db_file.data)
        end
      end
    end
  end
  
end