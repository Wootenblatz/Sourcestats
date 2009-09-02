class CreateActivePlayers < ActiveRecord::Migration
  def self.up
    create_table "active_players" do |t|
      t.column "steam_id", :string, :limit => 40, :default => "none"
      t.column "slot", :integer, :default => 0
      t.column "ip", :string, :limit => 15, :default => "000.000.000.000"
      t.column "name", :string, :limit => 60, :default => "Player"
      t.column "team", :string, :limit => 40, :default => "Unassigned"
      t.column "role", :string, :limit => 20, :default => "None"
      t.column "kills", :integer, :default => 0
      t.column "deaths", :integer, :default => 0
      t.column "suicides", :integer, :default => 0
      t.column "team_kills", :integer, :default => 0
      t.column "connect_time", :datetime
      t.timestamps
    end
    add_index :active_players, :steam_id
    add_index :active_players, :slot
    add_index :active_players, :name
  end

  def self.down
    drop_table "active_players"
  end
end
