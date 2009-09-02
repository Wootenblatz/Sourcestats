class AddMapIdToServers < ActiveRecord::Migration
  def self.up
    add_column "servers", "current_map_id", :integer, :default => 0
  end

  def self.down
    remove_column "servers", "current_map_id"
  end
end
