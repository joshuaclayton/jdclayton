class CreateFeedItems < ActiveRecord::Migration
  def self.up
    create_table :feed_items do |t|
      t.string :type, :title, :description, :guid, :link, :data
      t.datetime :published_at
      t.belongs_to :feed
      
      # LastFM model
      t.string :song, :artist, :album
      
      # Flickr
      t.string :content_url
      
      t.timestamps
    end
    
    %w(feed_id type guid published_at artist album).each do |col|
      add_index :feed_items, col.to_sym
    end
  end

  def self.down
    drop_table :feed_items
  end
end
