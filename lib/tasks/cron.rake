namespace :cron do
  desc "Update all feeds"
  task :parse_feeds => :environment do
    Feed.find(:all).map(&:parse_feed)
  end
end