class CreateFeedStatuses < ActiveRecord::Migration
  def self.up
    create_table :feed_statuses do |t|
      t.integer :response_code
      t.belongs_to :feed
      t.datetime :created_at
    end
    
    %w(response_code feed_id created_at).each do |col|
      add_index :feed_statuses, col.to_sym
    end
  end

  def self.down
    drop_table :feed_statuses
  end
end
