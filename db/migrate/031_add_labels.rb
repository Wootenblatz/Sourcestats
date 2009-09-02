class AddLabels < ActiveRecord::Migration
  def self.up
    add_column :weapons, :label, :string, :limit => 40
    add_column :triggers, :label, :string, :limit => 40
    add_column :roles, :label, :string, :limit => 40
    add_column :events, :label, :string, :limit => 40
    add_column :player_events, :skill_change, :float, :default => 0.0
    add_column :player_events, :victim_skill_change, :float, :default => 0.0
    add_column :player_events, :trigger_id, :integer, :default => 0
    add_column :player_events, :victim_role_id, :integer, :default => 0
  end

  def self.down
    remove_column :weapons, :label
    remove_column :triggers, :label
    remove_column :roles, :label
    remove_column :events, :label
    remove_column :player_events, :skill_change
    remove_column :player_events, :victim_skill_change
    remove_column :player_events, :trigger_id
    remove_column :player_events, :victim_role_id
  end
end
