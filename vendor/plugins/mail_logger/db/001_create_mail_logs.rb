class CreateMailLogs < ActiveRecord::Migration
  def self.up
    create_table :mail_logs do |t|
      t.column :message,          :text, :default => '', :null => false
      t.column :created_at,       :datetime
      t.column :form_name,        :string
    end
  end

  def self.down
    drop_table :mail_logs
  end
end
