class Feed < ActiveRecord::Base
  has_many :feed_statuses
  has_many :feed_items
  
  validates_uniqueness_of :url
  
  def feed
    self.body_from(self.url)
  end
  
  def parse_feed
    rss = Hash.from_xml(self.feed)
    unless self.source == "LastFM"
      rss["rss"]["channel"]["item"].each do |feed_item|
        item = Object.const_get(self.source).new(feed_item)
        item.feed = self
        item.data = feed_item
        item.save if item.valid?
      end
    else
      rss["recenttracks"]["track"].each do |feed_item|
        item = Object.const_get(self.source).new(feed_item)
        item.feed = self
        item.data = feed_item
        item.save_with_validation(false)
      end
    end
  end
    
  class << self
    def sources
      %w(Twitter LastFM Tumblr Flickr)
    end
    
    def formats
      ["RSS 1.0", "RSS 2.0", "ATOM"]
    end
    
    def parse_all
      Feed.find(:all).map(&:parse_feed)
    end
  end
  
  protected
  
  def body_from(u)
    url = URI.parse(u)
    req = Net::HTTP::Get.new("#{url.path}?#{url.query}")
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    FeedStatus.create(:response_code => res.code.to_i, :feed => self)
    res.body
  end
end
