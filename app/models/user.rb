require 'digest/sha1'
class User < ActiveRecord::Base
  include AuthenticatedBase
  
  def full_name
    (self.first_name.blank? || self.last_name.blank?) ? self.login : "#{self.first_name} #{self.last_name}"
  end
end
