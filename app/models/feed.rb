class Feed < ActiveRecord::Base
  has_many :feed_statuses
  has_many :feed_items
  
  validates_uniqueness_of :url
  
  def feed; self.body_from(self.url); end
  
  def parse_feed
    rss = Hash.from_xml(self.feed)
    feed_items = self.source == "LastFM" ? rss["recenttracks"]["track"] : rss["rss"]["channel"]["item"]
    feed_items.each do |feed_item|
      item = initialize_feed_item(feed_item)
      item.save if item.valid?
      item.save_with_validation(false) if item.is_a?(LastFM)
    end
  end

  class << self
    def sources; %w(Twitter LastFM Tumblr Flickr); end
    def parse_all
      Feed.find(:all).map(&:parse_feed)
    end
  end
  
  protected
  
  def body_from(u)
    url = URI.parse(u)
    req = Net::HTTP::Get.new("#{url.path}?#{url.query}")
    res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
    FeedStatus.create(:response_code => res.code.to_i, :feed => self)
    res.body
  end
  
  private
  
  def initialize_feed_item(feed_item)
    item = Object.const_get(self.source).new(feed_item)
    item.feed, item.data = self, feed_item
    item
  end
end