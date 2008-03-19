class FeedStatus < ActiveRecord::Base
  acts_as_archivable
  belongs_to :feed
end
