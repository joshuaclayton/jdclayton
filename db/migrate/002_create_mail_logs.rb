class CreateMailLogs < ActiveRecord::Migration
  def self.up
    create_table :mail_logs do |t|
      t.text      :message,  :default => '', :null => false
      t.datetime  :created_at
      t.string    :form_name
    end
  end

  def self.down
    drop_table :mail_logs
  end
end
