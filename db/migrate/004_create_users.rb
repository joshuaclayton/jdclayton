class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :login, :email, :remember_token, :first_name, :last_name
      t.string :crypted_password, :salt, :limit => 40
      t.datetime :remember_token_expires_at
      t.timestamps
    end
    %w(login email).each do |col|
      add_index :users, col.to_sym
    end
  end

  def self.down
    drop_table :users
  end
end