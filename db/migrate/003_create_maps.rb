class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table "maps" do |t|
      t.column "server_id", :integer
      t.column "name", :string, :limit => 80
      t.timestamps
    end
  
    add_index :maps, :server_id
  end

  def self.down
    drop_table "maps"
  end
end


