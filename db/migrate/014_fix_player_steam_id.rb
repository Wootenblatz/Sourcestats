class FixPlayerSteamId < ActiveRecord::Migration
  def self.up
    change_column(:players,:steam_id,:string,:limit=>40,:default=>"")
  end

  def self.down
    change_column(:players,:steam_id,:integer,:default=>0)
  end
end
