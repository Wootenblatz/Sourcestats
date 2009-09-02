class AddSuicidesToPlayersTable < ActiveRecord::Migration
  def self.up
    add_column :players, :suicides, :integer, :default => 0
    add_column :players, :team_kills, :integer, :default => 0
  end

  def self.down
    remove_column :players, :suicides
    remove_column :players, :team_kills
  end
end
