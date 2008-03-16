class AddExceptionTable < ActiveRecord::Migration
  def self.up
    create_table :logged_exceptions do |t|
      t.string    :exception_class, :controller_name, :action_name
      t.text      :message, :backtrace, :environment, :request
      t.datetime  :created_at
    end
  end

  def self.down
    drop_table :logged_exceptions
  end
end
