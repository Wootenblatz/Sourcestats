class CreateServers < ActiveRecord::Migration
  def self.up
    create_table "servers" do |t|
      t.column "name", :string, :limit => 80, :default => "Source Dedicated Server"
      t.column "description", :text
      t.column "ip", :string, :limit => 15
      t.column "port", :string, :limit => 6, :default => "20715"
      t.column "status", :string, :limit => 8, :default => "inactive"
      t.column "max_players", :integer, :default => 24
      t.column "timezone", :string, :limit => 40, :default => "Central Time (US & Canada)"
      t.timestamps
    end    
  end

  def self.down
    drop_table "servers"
  end
end
