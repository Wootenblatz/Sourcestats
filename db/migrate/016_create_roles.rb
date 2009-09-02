class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table "roles" do |t|
      t.column "server_id", :integer, :null => false, :deafault => 0
      t.column "name", :string, :limit => "40"
      t.timestamps
    end
    add_index :roles, :server_id
    add_index :roles, :name
  end

  def self.down
    drop_table "roles"
  end
end
