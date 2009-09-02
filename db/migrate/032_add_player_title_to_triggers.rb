class AddPlayerTitleToTriggers < ActiveRecord::Migration
  def self.up
    add_column :triggers, :player_title, :string, :limit => 40
  end

  def self.down
    remove_column :triggers, :player_title
  end
end
