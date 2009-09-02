class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table "players" do |t|
        t.column "server_id", :integer
        t.column "clan_id", :integer, :default => 0
        t.column "total_time", :float, :default => 0
        t.column "steam_id", :integer
        t.column "kills", :integer, :default => 0
        t.column "deaths", :integer, :deafult => 0
        t.column "name", :string, :limit => 255, :default => "Player"
        t.column "ip", :string, :limit => 15, :default => "000.000.000.000"
        t.column "skill", :float, :default => 1000
        t.column "last_connect", :datetime
        t.timestamps
    end
    
    add_index :players,:server_id
    add_index :players,:steam_id
    add_index :players,:skill
    add_index :players,:ip
    add_index :players,:name
  end

  def self.down
    drop_table "players"
  end
end

