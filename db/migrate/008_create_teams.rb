class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table "teams" do |t|
      t.column "server_id", :integer
      t.column "name", :string, :limit => 80
      t.timestamps
    end
    
    add_index :teams, :server_id
    add_index :teams, :name
  end

  def self.down
    drop_table "teams"
  end
end
