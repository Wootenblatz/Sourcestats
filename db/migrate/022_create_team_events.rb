class CreateTeamEvents < ActiveRecord::Migration
  def self.up
    create_table :team_events do |t|
      t.column "event_id", :integer, :default => 0
      t.column "team_id", :integer, :default => 0
      t.column "player_id", :integer, :default => 0
      t.column "map_id", :integer, :default => 0
      t.column "occurred_at", :datetime
      t.timestamps
    end    
    add_index :team_events, :event_id
    add_index :team_events, :team_id
    add_index :team_events, :player_id
    add_index :team_events, :map_id
    add_index :team_events, :occurred_at
  end

  def self.down
    drop_table :team_events
  end
end
