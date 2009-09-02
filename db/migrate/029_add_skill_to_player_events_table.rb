class AddSkillToPlayerEventsTable < ActiveRecord::Migration
  def self.up
    add_column :player_events, :player_skill, :float, :default => 1000.0
    add_column :player_events, :victim_skill, :float, :default => 1000.0
    add_column :player_events, :player_kills, :integer, :default => 0
    add_column :player_events, :victim_kills, :integer, :default => 0
    add_column :player_events, :player_deaths, :integer, :default => 0
    add_column :player_events, :victim_deaths, :integer, :default => 0
  end

  def self.down
    remove_column :player_events, :player_skill
    remove_column :player_events, :victim_skill
    remove_column :player_events, :player_kills
    remove_column :player_events, :victim_kills
    remove_column :player_events, :player_deaths
    remove_column :player_events, :victim_deaths
  end
end
