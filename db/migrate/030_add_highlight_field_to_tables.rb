class AddHighlightFieldToTables < ActiveRecord::Migration
  def self.up
    add_column :servers, :timeframe, :string, :limit => 40, :default => "one week"
    add_column :events, :highlight, :string, :limit => 3, :default => "No"
    add_index :events, :highlight
    add_column :triggers, :highlight, :string, :limit => 3, :default => "No"
    add_index :triggers, :highlight
    add_column :team_events, :highlight, :string, :limit => 3, :default => "No"
    add_index :team_events, :highlight
    add_column :player_events, :role_id, :integer, :default => 0
    add_index :player_events, :role_id
  end

  def self.down
    remove_column :servers, :timeframe
    remove_column :events, :highlight
    remove_column :triggers, :highlight
    remove_column :team_events, :highlight
    remove_column :player_events, :role_id
  end
end
