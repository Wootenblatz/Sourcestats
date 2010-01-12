class AddServerType < ActiveRecord::Migration
  def self.up
    add_column :servers, :server_type, :string, :limit => 40
    add_index :servers, :server_type
  end

  def self.down
    remove_index :servers, :server_type
    remove_column :servers, :server_type
  end
end
