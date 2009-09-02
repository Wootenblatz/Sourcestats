class CreateClans < ActiveRecord::Migration
  def self.up
    create_table "clans" do |t|
      t.column "server_id", :integer
      t.column "tag", :string, :default => 15
      t.column "kills", :integer, :default => 0
      t.column "deaths", :integer, :default => 0
      t.timestamps
    end
    
    add_index :clans, :server_id
    add_index :clans, :tag
  end

  def self.down
    drop_table "clans"
  end
end
