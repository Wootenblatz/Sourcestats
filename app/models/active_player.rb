class ActivePlayer < ActiveRecord::Base
  def self.connect(server_id,player_info,event_datetime,ip)
    player = ActivePlayer.find(:first,:conditions => ["server_id = ? and steam_id = ?", server_id, player_info["steam_id"]])
    if not player and player_info["steam_id"]
      player = ActivePlayer.new
      player.server_id = server_id
      player.steam_id = player_info["steam_id"]
      player.name = player_info["name"]
      player.slot = player_info["slot"]
      player.team = player_info["team_name"]      
      player.kills = 0
      player.deaths = 0
      player.suicides = 0
      player.team_kills = 0
      player.connect_time = event_datetime
      player.save
    end
    if ip != 0
      player.ip = ip
    end
    return player
  end
  
  def self.find_by_steam_id(server_id,player_info,event_datetime)
    player = self.load_player(server_id,player_info,event_datetime)
    player.update_info(player_info["steam_id"],player_info["team_name"])
    return player
  end
  
  def enter_map(player_info,event_datetime)
    join_team(player_info,event_datetime)
  end

  def join_team(player_info,event_datetime)
    update_info(player_info["steam_id"],player_info["team_name"])
  end
    
  def update_info(my_steam_id,my_team_name)
    steam_id = my_steam_id
    team_name = my_team_name
  end

  def self.load_player(server_id,player_info,event_datetime)
    player = ActivePlayer.find(:first,:conditions => ["server_id = ? and steam_id = ?", server_id, player_info["steam_id"]])
    if not player
      player = ActivePlayer.connect(server_id,player_info,event_datetime,0)        
    end
    if not player.connect_time or player.connect_time == nil or player.connect_time.to_s.size < 1
      player.connect_time = event_datetime
      player.team = player_info["team_name"]
      player.save
    end
    return player    
  end
end
