class ImproveBotSupport < ActiveRecord::Migration
  def self.up
    add_column :players, :bot_kills, :integer, :default => 0
    add_column :players, :incapped, :integer, :default => 0
    add_column :servers, :bot_label, :string, :limit => 40, :default => "Infected"
  end
  
  def self.down
    remove_column :players, :bot_kills, :incapped
    remove_column :servers, :bot_label
  end
  
end