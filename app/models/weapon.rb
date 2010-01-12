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
  
  def top_players_for_period(start)
    Player.find(:all,
                :select => "players.*, count(player_events.id) as times",
                :joins => "inner join player_events on player_events.player_id = players.id",
                :conditions => ["player_events.occurred_at > ? and player_events.weapon_id = ?", start, id],
                :order => "times desc",
                :group => "player_events.player_id", 
                :limit => 3)
  end

end
