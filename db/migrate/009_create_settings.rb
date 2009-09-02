class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table "settings" do |t|
      t.column "var", :string, :limit => 80
      t.column "val", :text
      t.timestamps
    end
    
    add_index :settings, :var
  end

  def self.down
    drop_table "settings"
  end
end
