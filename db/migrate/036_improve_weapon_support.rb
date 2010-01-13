class ImproveWeaponSupport < ActiveRecord::Migration
  def self.up
    add_column :weapons, :highlight, :string, :limit => 3, :default => "No"
  end
  
  def self.down
    remove_column :weapons, :highlight
  end
  
end