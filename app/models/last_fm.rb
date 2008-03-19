class LastFM < FeedItem
  attr_accessor :streamable, :mbid
  
  def name=(song_name)
    self.song = song_name
  end
  
  def url=(path)
    self.link = path
  end
  
  def body
    "Listened to #{self.song} by #{self.artist}"
  end
  
  before_save do |item|
    item.guid = "#{item.artist}/#{item.album}/#{item.song}/#{item.published_at.to_s}"
    item.published_at = item.published_at.advance(:hours => -4)
    item.description = item.link
    item.valid?
  end
end