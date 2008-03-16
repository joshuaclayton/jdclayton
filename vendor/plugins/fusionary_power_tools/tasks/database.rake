namespace :db do

  namespace :schema do
    desc "Report the current version of the database schema. Send RAILS_ENV to check a specific database."
    task :version => :environment do
      r = ActiveRecord::Base.connection.execute "SELECT version FROM schema_info LIMIT 1"
      puts "SCHEMA VERSION: #{r.fetch_hash['version']}"
    end
  end

  namespace :sessions do
    desc "Clear database-stored sessions older than two weeks"
    task :clear => :environment do
      CGI::Session::ActiveRecordStore::Session.delete_all ["updated_at < ?", 2.weeks.ago ] 
    end

    desc "Count database sessions"
    task :count => :environment do
      puts "Currently storing #{CGI::Session::ActiveRecordStore::Session.count} sessions"
    end      
  end
  
  namespace :fixtures do
    # Defaults to development database. Set RAILS_ENV to override.
    desc 'Create YAML test fixtures from data in an existing database.'
    task :extract => :environment do
      if ENV['FIXTURES'] 
        skip_tables = ['schema_info']
        tables = ActiveRecord::Base.connection.tables - skip_tables
        tables =  [ENV['FIXTURES']] if ENV['FIXTURES'] != 'all'

        sql = 'SELECT * FROM %s'
        ActiveRecord::Base.establish_connection
        tables.each do |table_name|
          i = '000'
          File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
            data = ActiveRecord::Base.connection.select_all(sql % table_name)
            file.write data.inject({}) { |hash, record|
              hash["#{table_name}_#{i.succ!}"] = record
              hash
            }.to_yaml
          end
        end
      else
        puts "ERROR: Must specify which table to extract using FIXTURES=name or use FIXTURES=all"
      end
    end
  end
  
end