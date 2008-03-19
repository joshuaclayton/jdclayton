class Twitter < FeedItem
  REPLY = /^\@\w/
  
  def body
    desc = self.description
    parsed_text = if (users = self.description.scan(/\@[\w\_]+/)).any?
      users.each {|user| desc = desc.gsub(user, "<a href='http://twitter.com/#{user.gsub(/\@/, '')}'>#{user}</a>") }
    else
      desc
    end
    parsed_text
  end
  
  before_save do |item|
    item.description = item.description.gsub(/#{item.feed.username}\: +/, '')
    item.description = nil if item.description =~ REPLY
    item.valid?
  end
end