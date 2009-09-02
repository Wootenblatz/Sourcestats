class AddServerIdToActivePlayers < ActiveRecord::Migration
  def self.up
    add_column "active_players", "server_id", :integer, :default => 0
  end

  def self.down
    remove_column "active_players", "server_id"
  end
end
