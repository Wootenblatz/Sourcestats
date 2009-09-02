class Weapon < ActiveRecord::Base
  belongs_to :server
  has_one :event, :through => :player_events
  
  def self.find_by_name(server_id, name)
    weapon = Weapon.find(:first,:conditions => ["server_id = ? and name = ?",server_id,name])    
    if not weapon or weapon.id < 1
      weapon = Weapon.new
      weapon.server_id = server_id
      weapon.name = name
      weapon.save
    end
    return weapon
  end
end
