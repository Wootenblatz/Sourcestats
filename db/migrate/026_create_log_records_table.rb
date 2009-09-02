class CreateLogRecordsTable < ActiveRecord::Migration
  def self.up
    create_table :log_records, :force => true do |t|
      t.integer :server_id
      t.string :md5, :limit => 40
      t.string :status, :limit => 20
      t.text :line_one
      t.timestamps
    end
    add_index :log_records, :status
    add_index :log_records, :md5
    add_index :log_records, :server_id
  end

  def self.down
    drop_table :log_records
  end
end
