namespace :feeds do
  desc "Load feeds"
  task :load => :environment do
    Feed.create(:source => "Twitter", :url => "http://twitter.com/statuses/user_timeline/10293122.rss", :username => "joshuaclayton")
    Feed.create(:source => "Tumblr", :url => "http://jdclayton.tumblr.com/rss", :username => "jdclayton")
    Feed.create(:source => "LastFM", :url => "http://ws.audioscrobbler.com/1.0/user/joshuaclayton/recenttracks.xml", :username => "joshuaclayton")
  end
end