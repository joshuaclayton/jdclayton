require 'rake/clean'

# output goes to subdirectories of this one
RCOV_OUT = "tmp/coverage"

# "rake clobber" to remove output directory (along with other generated stuff)
CLOBBER.include(RCOV_OUT)

# don't report coverage on these files
RCOV_EXCLUDE = %w(boot.rb routes.rb schema.rb environment.rb test_helper.rb _test.rb lib vendor).join(',')

# RCOV command, run as though from the commandline.  Amend as required or perhaps move to config/environment.rb?
RCOV = "rcov --no-color"

namespace :test do
  
  desc "Alias for test:coverage:all"
  task :coverage do
    Rake::Task["test:coverage:all"].invoke
    system("open #{RCOV_OUT}/all/index.html") if PLATFORM['darwin']
  end
  
  namespace :coverage do
    
    desc "generate a unit test coverage report in coverage/unit; see coverage/unit/index.html afterwards"
    task :units do
      RCOV_EXCLUDE += "," + %w(controllers helpers).join(",")
      sh "#{RCOV} --exclude #{RCOV_EXCLUDE} --output #{RCOV_OUT}/unit test/unit/*.rb"
    end

    desc "generate a functional test coverage report in coverage/functional; see coverage/functional/index.html afterwards"
    task :functional do
      RCOV_EXCLUDE += "," + %w(models helpers).join(",")
      sh "#{RCOV} --exclude #{RCOV_EXCLUDE} --output #{RCOV_OUT}/functional test/functional/*.rb"
    end

    desc "generate a coverage report for unit and functional tests together in coverage/all; see coverage/all/index.html afterwards"
    task :all do
      sh "#{RCOV} --exclude #{RCOV_EXCLUDE} --output #{RCOV_OUT}/all test/unit/*.rb test/functional/*.rb"
    end

  end
end