class CreateTriggers < ActiveRecord::Migration
  def self.up
    create_table "triggers" do |t|
      t.column "server_id", :integer
      t.column "bonus", :float, :default => 1.0
      t.column "name", :string, :limit => 255
      t.timestamps
    end
    
    add_index :triggers, :server_id
    add_index :triggers, :name
  end

  def self.down
    drop_table "triggers"
  end
end
