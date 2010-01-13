class ImproveWeaponSupport < ActiveRecord::Migration
  def self.up
    add_column :weapons, :highlight, :string, :limit => 3, :default => "No"
    add_column :weapons, :player_title, :string, :limit => 40
  end
  
  def self.down
    remove_column :weapons, :highlight, :player_title
  end
  
end