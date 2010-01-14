class CreatePlayerStateTable < ActiveRecord::Migration
  def self.up
    create_table :player_states do |t|
      t.string :name
      t.integer :server_id
    end
    add_index :player_states, :server_id
    add_index :player_states, :name
    add_column :player_events, :player_state_id, :integer, :default => 0
    add_column :events, :bonus, :float, :default => 0.0
  end
  
  def self.down
    remove_column :player_events, :player_state_id
    remove_column :events, :bonus
    drop_table :player_states
  end
  
end