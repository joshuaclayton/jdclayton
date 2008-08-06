require 'net/http'

module Feeds
  module Parsing
    def self.included(base)
      base.send :include, Feeds::Parsing::InstanceMethods
      base.extend Feeds::Parsing::ClassMethods
    end

    module InstanceMethods
      def feed
        self.body_from(self.url)
      end

      def parse_feed
        rss = Hash.from_xml(self.feed)
        feed_items = self.source == "LastFM" ? rss["recenttracks"]["track"] : rss["rss"]["channel"]["item"]
        feed_items.each do |feed_item|
          item = initialize_feed_item(feed_item)
          item.save if item.valid?
          item.save_without_validation if item.is_a?(LastFM)
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
    module ClassMethods
      def parse_all
        Feed.all.map(&:parse_feed)
      end
    end
  end
end

class Feed < ActiveRecord::Base
  include Feeds::Parsing
  
  SOURCES = %w(Twitter LastFM Tumblr Flickr)
  
  has_many :feed_statuses
  has_many :feed_items
  
  validates_uniqueness_of :url
end