class CreateBotsTable < ActiveRecord::Migration
  def self.up
    create_table :bots do |t|
      t.integer :server_id, :default => 0
      t.string :name, :limit => 40, :null => false
      t.float :bonus, :default => 0.01
      t.timestamps
    end
    add_index :bots, :server_id
    add_index :bots, :name
    
    add_column :player_events, :bot_victim, :integer, :default => 0
    add_index :player_events, :bot_victim
  end

  def self.down
    remove_index :player_events, :bot_victim
    remove_column :player_events, :bot_victim
    drop_table :bots
  end
end
