class LastFM < FeedItem
  attr_accessor :streamable, :mbid
  
  def name=(n)
    self.song = n
  end
  
  def url=(path)
    self.link = path
  end
  
  before_save do |item|
    item.guid = "#{item.artist}/#{item.album}/#{item.song}/#{item.published_at.to_s}"
    item.description = item.link
    item.valid?
  end
end