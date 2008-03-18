class FeedItem < ActiveRecord::Base
  acts_as_archivable :on => :published_at
  
  belongs_to :feed
  validates_uniqueness_of :guid
  
  validates_presence_of :description
  
  def pubDate=(time)
    self.published_at = Time.parse(time) rescue Time.now
  end
  
  def date=(time)
    self.published_at = Time.parse(time) rescue Time.now
  end
  
  class << self
    def types
      Feed.sources
    end
  end
end
