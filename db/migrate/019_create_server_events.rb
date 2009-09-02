class CreateServerEvents < ActiveRecord::Migration
  def self.up
    create_table "server_events" do |t|
      t.column "event_id", :integer, :default => 0
      t.column "server_id", :integer, :default => 0
      t.column "victim_id", :integer, :default => 0
      t.column "victim_team_id", :integer, :default => 0
      t.column "map_id", :integer, :default => 0
      t.column "occurred_at", :datetime
      t.timestamps
    end
    
    add_index :server_events, :event_id
    add_index :server_events, :server_id
    add_index :server_events, :victim_id
    add_index :server_events, :victim_team_id
    add_index :server_events, :map_id
    add_index :server_events, :occurred_at
  end

  def self.down
    drop_table "server_events"
  end
end
