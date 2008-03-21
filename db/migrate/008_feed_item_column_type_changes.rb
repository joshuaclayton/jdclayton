class FeedItemColumnTypeChanges < ActiveRecord::Migration
  def self.up
    change_column :feed_items, :description, :text
    change_column :feed_items, :data, :text
  end

  def self.down
    change_column :feed_items, :description, :string
    change_column :feed_items, :data, :string
  end
end
