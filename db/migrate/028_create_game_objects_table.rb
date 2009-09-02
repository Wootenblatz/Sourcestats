class CreateGameObjectsTable < ActiveRecord::Migration
  def self.up
    create_table :game_objects, :force => true do |t|
      t.string :name, :limit => 20
      t.string :label, :limit => 40
      t.timestamps
    end
    add_index :game_objects, :name
  end

  def self.down
    drop_table :game_objects
  end
end
