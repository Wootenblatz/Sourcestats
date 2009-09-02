class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table "events" do |t|
      t.column "server_id", :integer
      t.column "name", :string, :limit => 255
      t.timestamps
    end
    
    add_index :events, :server_id
    add_index :events, :name
  end

  def self.down
    drop_table "events"
  end
end
