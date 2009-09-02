class CreateAliases < ActiveRecord::Migration
  def self.up
    create_table "aliases" do |t|
      t.column "server_id", :integer
      t.column "player_id", :integer
      t.column "uses", :integer, :default => 0
      t.column "name", :string, :default => "Player"
      t.timestamps
    end
    
    add_index :aliases, :server_id
    add_index :aliases, :player_id
    add_index :aliases, :name
  end

  def self.down
    drop_table "aliases"
  end
end
