class AddMapNameToServers < ActiveRecord::Migration
  def self.up
    add_column "servers", "current_map", :string, :limit => 40, :default => "none"
  end

  def self.down
    remove_column "servers", "current_map"
  end
end
