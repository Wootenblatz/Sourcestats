class CreateWeapons < ActiveRecord::Migration
  def self.up
    create_table "weapons" do |t|
      t.column "server_id", :integer
      t.column "name", :string, :limit => 80
      t.column "bonus", :float, :default => 1.0
      t.timestamps
    end
    
    add_index :weapons, :server_id
  end

  def self.down
    drop_table "weapons"
  end
end
