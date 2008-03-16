desc "Bootstrap the whole she-bang"
task :bootstrap do
  # Copy database.yml.example to database.yml if none exists
  Rake::Task["bootstrap:db:config"].invoke
  Rake::Task["bootstrap:settings"].invoke
  
  unless ENV['FORCE'] == "force"
    connection_worked = false
    # Wait until now to load the environment (and database.yml)
    begin
      Rake::Task["environment"].invoke
      ActiveRecord::Base.establish_connection(:development)
      if ActiveRecord::Base.connection
        connection_worked = true
      end
    rescue
    end
    
    if connection_worked
      raise "Error:  Your development database already exists.  To delete it anyway, add FORCE=force to the command."
    end
  end
  
  Rake::Task["log:clear"].invoke
  Rake::Task["tmp:clear"].invoke

  Rake::Task["bootstrap:db:create"].invoke

  # Purge them -- just to be sure
  Rake::Task["bootstrap:db:purge"].invoke
  Rake::Task["db:test:purge" ].invoke

  ActiveRecord::Base.establish_connection(:development)
  
  # Migrate engines, if possible
  puts '## MIGRATING'
  puts '#### MIGRATING ENGINES'
  Rake::Task["db:migrate:engines"].invoke rescue false
  puts '#### MIGRATING APP'
  Rake::Task["db:migrate"].invoke

  puts '## LOADING FIXTURES'
  puts '#### LOADING APP FIXTURES'
  Rake::Task["db:fixtures:load"].invoke
  puts '#### LOADING ENGINE FIXTURES'
  Rake::Task["bootstrap:fixtures:files"].invoke

  puts '## CLONING DB STRUCTURE TO TEST'
  ActiveRecord::Base.establish_connection(:test)
  puts '#### CONNECTION ESTABLISHED'
  Rake::Task["db:test:clone"].invoke
  puts '#### ...DONE'

end

namespace :bootstrap do
  namespace :db do
    
    desc "Empty the development database"
    task :purge => :environment do
      abcs = ActiveRecord::Base.configurations
      case abcs["development"]["adapter"]
        when "mysql"
          ActiveRecord::Base.establish_connection(:development)
          ActiveRecord::Base.connection.recreate_database(abcs["development"]["database"])
        when "postgresql"
          ENV['PGHOST']     = abcs["development"]["host"] if abcs["development"]["host"]
          ENV['PGPORT']     = abcs["development"]["port"].to_s if abcs["development"]["port"]
          ENV['PGPASSWORD'] = abcs["development"]["password"].to_s if abcs["development"]["password"]
          enc_option = "-E #{abcs["development"]["encoding"]}" if abcs["development"]["encoding"]
          `dropdb -U "#{abcs["development"]["username"]}" #{abcs["development"]["database"]}`
          `createdb #{enc_option} -U "#{abcs["development"]["username"]}" #{abcs["development"]["database"]}`
        when "sqlite","sqlite3"
          dbfile = abcs["development"]["database"] || abcs["development"]["dbfile"]
          File.delete(dbfile) if File.exist?(dbfile)
        when "sqlserver"
          dropfkscript = "#{abcs["development"]["host"]}.#{abcs["development"]["database"]}.DP1".gsub(/\\/,'-')
          `osql -E -S #{abcs["development"]["host"]} -d #{abcs["development"]["database"]} -i db\\#{dropfkscript}`
          `osql -E -S #{abcs["development"]["host"]} -d #{abcs["development"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
        when "oci"
          ActiveRecord::Base.establish_connection(:development)
          ActiveRecord::Base.connection.structure_drop.split(";\n\n").each do |ddl|
            ActiveRecord::Base.connection.execute(ddl)
          end
        else
          raise "Task not supported by '#{abcs["development"]["adapter"]}'"
      end
    end
    
    
    desc "Create development and testing databases"
    task :create => :environment do
      abcs = ActiveRecord::Base.configurations
      dbs = ["development", "test"]

      for db in dbs
        if (abcs[db]["host"].nil? or ["127.0.0.1", "localhost"].include?(abcs[db]["host"])) and (abcs[db]["adapter"] == "mysql")
          `echo 'DROP DATABASE #{abcs[db]["database"]};' | mysql -h localhost -u #{abcs[db]["username"]}`
          `echo 'CREATE DATABASE #{abcs[db]["database"]};' | mysql -h localhost -u #{abcs[db]["username"]}`
        end
     end
    end
    
    desc "Copy database.example.yml into config/database.yml"
    task :config do
      unless File.exists?(File.join(RAILS_ROOT, 'config', 'database.yml'))
        if File.exists?(File.join(RAILS_ROOT, 'config', 'database.example.yml'))
          FileUtils.cp(File.join(RAILS_ROOT, 'config', 'database.example.yml'), File.join(RAILS_ROOT, 'config', 'database.yml'))
        end
      end
    end
    
  end
  
  desc "Copy settings.example.yml into config/settings.yml"
  task :settings do
    unless File.exists?(File.join(RAILS_ROOT, 'config', 'settings.yml'))
      if File.exists?(File.join(RAILS_ROOT, 'config', 'settings.example.yml'))
        FileUtils.cp(File.join(RAILS_ROOT, 'config', 'settings.example.yml'), File.join(RAILS_ROOT, 'config', 'settings.yml'))
      end
    end
  end
  
  namespace :fixtures do
    desc "Copy test/fixtures/files to RAILS_ROOT/files"
    task :files do
      if File.exists?(File.join(RAILS_ROOT, 'test', 'fixtures', 'files'))
        if File.exists?(File.join(RAILS_ROOT, 'files'))
          FileUtils.rm_rf(File.join(RAILS_ROOT, 'files'))
        end
        FileUtils.cp_r(File.join(RAILS_ROOT, 'test', 'fixtures', 'files'), RAILS_ROOT)
      end
    end
  end
  
end