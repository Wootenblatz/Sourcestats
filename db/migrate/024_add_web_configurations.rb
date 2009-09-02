class AddWebConfigurations < ActiveRecord::Migration
  def self.up
    create_table "web_configurations" do |t|
      t.column "variable", :string, :limit => 80, :default => ""
      t.column "value", :text
    end
  end

  def self.down
    drop_table "web_configurations"
  end
end
