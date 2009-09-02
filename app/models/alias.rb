class Alias < ActiveRecord::Base
  belongs_to :player
  
  def self.use_alias(server_id,player_id,name)
    player_alias = Alias.find(:first,:conditions => ["server_id = ? and player_id = ? and name = ?",server_id,player_id,name])
    if not player_alias 
      player_alias = Alias.new
      player_alias.uses = 0
      player_alias.player_id = player_id
      player_alias.server_id = server_id      
      player_alias.name = name            
    end
    player_alias.uses += 1
    player_alias.save
  end
end
