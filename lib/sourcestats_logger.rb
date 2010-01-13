
require 'socket'

class SourcestatsLogger
  @regexps = {
    "datetime" => Regexp.new('^(.*)L (\d\d\/\d\d\/\d\d\d\d - \d\d:\d\d:\d\d:) '),
    "r1" => Regexp.new('^"([^"]+)" ([^"\(]+) "([^"]+)" ([^"\(]+) "([^"]+)"(.*)'),
    "r2" => Regexp.new('^"([^"]+)" ([^"\(]+) "([^"]+)"(.*)'),
    "r3" => Regexp.new('^"([^"]+)" ([^\(]+)(.*)'),
    "r4" => Regexp.new('^Team "([^"]+)" ([^"\(]+) "([^"]+)"(.*)'),
    "r5" => Regexp.new('^([^"\(]+) "([^"]+)"(.*)'),
    "properties" => Regexp.new('^\s*\((\S+)(?: "([^"]+)")?\)')
  }
  
  @key_orders = {
    "_master_list" => ["player","event1","noun1","event2","noun2","properties","team","label"],
    "r1" => ["player","event1","noun1","event2","noun2","properties"],
    "r2" => ["player","event1","noun1","properties"],
    "r3" => ["player","event1","properties"],
    "r4" => ["team","event1","noun1","properties"],
    "r5" => ["event1","noun1","properties"],
  }

  def self.listen
    socket = UDPSocket.new
    puts "Binding to UDP port 20808 ..."
    socket.bind("", 20808)

    puts "Setting MySQL database timeout to one week"
    sql = ActiveRecord::Base.connection();    
  	sql.execute "SET wait_timeout = 604800";
    
    puts "Listening for log address data..."
    loop do
      msg, sender = socket.recvfrom(8096)
      remote_ip = sender[3]
      remote_port = sender[1]
      # Remove leading and trailing whitespace
      msg.strip!
      msg.chomp!

      # Test line to see if it is from the sourcestats logfile processor
      sourcestat_log = msg.split("||",4)
      if sourcestat_log[0] == "sourcestats.log"
        md5 = sourcestat_log[1]
        remote_ip = sourcestat_log[2].split(":")[0]
        remote_port = sourcestat_log[2].split(":")[1]
      end

      server = Server.find(:first,:conditions => ["ip = ? and port = ?", remote_ip, remote_port])
      if not server 
        server = Server.new
        server.ip = remote_ip
        server.port = remote_port
        server.description = "New Source Server."
        server.status = "active"
        server.timeframe = 30
        server.save(false)
      end
      
      if md5
        msg = sourcestat_log[3]
        @logfile = LogRecord.find(:first,:conditions => ["md5 = ?", md5])
        if @logfile
          if @logfile.status != "closed"
            if msg =~ /Log file closed/
              @logfile.status = "closed"
              @logfile.save
              msg = ""
            end
          end
        else
          @logfile = LogRecord.new
          @logfile.md5 = md5
          @logfile.status = "open"
          @logfile.server_id = server.id
          @logfile.line_one = msg
          @logfile.save
        end
      else
        @logfile = nil
      end
      
      if msg and msg.size > 0
        # Strip the date off, we'll just use our database time
        event_datetime = msg.scan(@regexps["datetime"])
        if event_datetime[0] and event_datetime[0][1]
          event_datetime = Time.parse(event_datetime[0][1])
          msg.gsub!(@regexps["datetime"],"")

          results = Hash.new
          player = Array.new
          properties = Hash.new
          
          # Check to see if this includes a L4D style log prefix
          if msg =~ /^\(([^\)]+)\)/
            msg.gsub!(/^\(([^\)]+)\)/,"")
          end
          results = self.parse(msg)
          self.store_result(server,results,event_datetime)
        end
      end
    end
  end  
  
  def self.get_properties(properties_string)
    properties = Hash.new
    properties_string.sub(@regexps["properties"],'').each do |p|
      if (p[0][2])
        properties["#{p[0][1]}"] = p[0][2]
      else
        properties["#{p[0][1]}"] = p[0][1]
      end
    end
    return properties
  end

  def self.parse(log_line)
    results = Hash.new
    index = 0
    @key_orders["_master_list"].each { |key| results["#{key}"] = nil }
    1.upto(5) do |x|
      if index == 0 and values = log_line.scan(@regexps["r#{x}"])[0]
        @key_orders["r#{x}"].each do |key|
          results["#{key}"] = values[index]
          index += 1
        end
      end
    end
    return results
  end
  
  def self.store_result(server,results,event_datetime)
    map_id = server.current_map_id
    event_id = 0
    weapon_id = 0
    trigger_id = 0
    role_id = 0
    event_type = "player"
    save = 1
    trigger_id = 0
    trigger = nil
    trigger_team_players = Array.new

    if server.status == "active"
      Time.zone = server.timezone
      team = results['team']
      player_str = results['player']
      event1 = results['event1']
      noun1 = results['noun1']
      event2 = results['event2']
      noun2 = results['noun2']
      properties = results['properties']
      disconnect = 0

      if player_str 
        player = self.player_details(server.id,player_str)
      end
      if not player or player["bot"]
        return
      end
      
      if event1 and event1.size > 1            
        if player_str and player_str.size > 0
            active_player = ActivePlayer.find_by_steam_id(server.id,player["info"],event_datetime)
        end
                
        if not team and player_str and noun1 and event2 and noun2 and player and player["object"].id   > 0          
          if event1 == "killed" or event1 == "attacked" or event1 == "was incapped by"
            victim = self.player_details(server.id,noun1)
            active_victim = ActivePlayer.find_by_steam_id(server.id,victim["info"],event_datetime)
            
            weapon = Weapon.find_by_name(server.id,noun2)
            weapon_id = weapon.id
            if player["id"] == victim["object"].id
              player["object"].suicides += 1
              active_player.suicides += 1
              player["object"].skill -= 25
              player["skill_change"] = -25
            elsif victim["object"].id != player["object"].id and victim["team"].id == player["team"].id
              active_player.team_kills += 1
              player["object"].skill -= 25
              player["skill_change"] = -25
            elsif victim and victim["object"].id > 0 
              skills = player["object"].compute_skill(victim["object"],weapon)
              player["skill_change"] = skills[0]
              puts player.inspect
              player["object"].skill += skills[0]

              if not victim["bot"]
                player["object"].kills += 1
                victim["skill_change"] = -1 * skills[1]
                victim["object"].skill -= skills[1]
                victim["object"].deaths += 1
                active_victim.deaths += 1
              else
                player["object"].bot_kills += 1
              end
              #puts "Skill delta #{skills[0]} / #{skills[1]} || Results #{player["object"].skill} / #{victim["object"].skill}"
              active_player.kills += 1
              
              # Check for the custom kill property
              if event1 == "killed"
                properties = results["properties"].scan(/\((.+?)\)/)
                for property in properties
                  if property[0] =~ /customkill \"(\w+?)\"/ or property[0] =~ /headshot/
                    trigger = Trigger.find_by_name(server.id,($1||"headshot"))
                    if trigger.bonus != 0
                      player["object"].skill += trigger.bonus
                      player["skill_change"] += trigger.bonus
                    end
                  end
                end
              end
            end
          elsif event1 == "triggered" and event2 == "against"            
            victim = self.player_details(server.id,noun2)
            trigger = Trigger.find_by_name(server.id,noun1)
            if trigger.bonus != 0
              player["object"].skill += trigger.bonus
              player["skill_change"] += trigger.bonus
            end
            
            #puts "#{player["object"].name} -#{event1}- \"#{noun1}\" -#{event2}-  \"#{noun2}\""
            #puts properties.to_s
          else
            #puts "--- Unhandled Event ---"
            #puts "#{player["object"].name} -#{event1}- \"#{noun1}\" -#{event2}-  \"#{noun2}\""
            #puts properties.to_s
            save = 0 
          end
        elsif not team and player_str and noun1 and not event2 and not noun2
          if event1 =~ /connected/
            ip_port = noun1.split(":")
            active_player = ActivePlayer.connect(server.id,player["info"],event_datetime,ip_port[0])
            #server.prune_inactive_players
            save = 0
          elsif event1 == "changed name"
            noun1.gsub!(/"/,"")
            player["object"].name = noun1
            active_player.name = noun1
            Alias.use_alias(server.id,player["object"].id,noun1)
          elsif event1 == "joined team" and not player["bot"]
            active_player.team = noun1
          elsif event1 == "committed suicide with" and not player["bot"]
            weapon = Weapon.find_by_name(server.id,noun1)
            weapon_id = weapon.id
            if player["object"] and player["object"].skill > 1025
              player["object"].skill -= 25
              player["skill_change"] = -25
              
            elsif player["object"] and player["object"].skill > 0
              player["object"].skill -= 1  
              player["skill_change"] = -1
            end
            player["object"].suicides += 1            
            active_player.suicides += 1
          elsif event1 == "triggered"  and not player["bot"]and player["object"] and player["object"].id > 0
            trigger = Trigger.find_by_name(server.id,noun1)
            if trigger.bonus != 0
              player["object"].skill += trigger.bonus
              player["skill_change"] = trigger.bonus
            end
          elsif event1 == "changed role to" and not player["bot"]
            role = Role.find_by_name(server.id,noun1)
            role_id = role.id              
            active_player.role = noun1
          end
        elsif not team and player_str and not noun1 and not event2 and not noun2
          if event1 == "entered the game" and not player["bot"]
            Alias.use_alias(server.id,player["id"],player["info"]['name'])
            slot = player["info"]['slot']
            active_player.enter_map(player["info"],event_datetime)
            player["object"].ip = active_player.ip
          elsif event1 =~ /disconnected/
            disconnect = 1
          end          
        elsif not team and not player_str and noun1 and not event2 and not noun2
          if event1 == "World Triggered"
            player_id = -1
            event_type = "server"
            save = 0
          elsif event1 == "Started map"
            map = Map.find_by_name(server.id,noun1)
            map_id = map.id
            server.current_map = map.name
            server.current_map_id = map.id
            server.save
            event_type = "server"
          end
        elsif team and not player_str and noun1 and not event2 and not noun2
          properties = results["properties"].scan(/\((.+?)\)/)
          if properties and properties.size > 0
            trigger = Trigger.find_by_name(server.id,noun1)
            for property in properties
              if property[0] =~ /player(\d+?) \"(.+?)\"/
                team_player = self.player_details(server.id,$2)
                trigger_team_players.push(team_player)
                if trigger.bonus
                  team_player["skill_change"] += trigger.bonus
                  team_player["object"].skill += trigger.bonus
                end
              end
            end            
            event_type = "player"
            save = 1
          else
            event_type = "team"
            save = 0
          end
        else
          save = 0
        end   
      else
        save = 0   
      end
    else 
      save = 0
    end   

    if save > 0 
      event1.gsub!(/"/, '')
      if event1 !~ /=/
        event = Event.find_by_name(server.id,event1)
        if event_type == "player"    
          if player and player["object"] and player["object"].id > 0            
            if not role_id
              if not active_player
                active_player = ActivePlayer.find_by_steam_id(server.id,player["info"],event_datetime)                                
              end
              role_id = Role.find_by_name(server.id, active_player.role).id
            end
            if not player["bot"]
              player_event = self.save_player_event(event,event_datetime,player,active_player,victim,active_victim,weapon_id,map_id,role_id,trigger)
              if player and player["object"] and player["object"].changed?
                player["object"].save
              end
              if victim and not victim["bot"] and victim["object"] and victim["object"].changed?
                victim["object"].save
              end
            end
          elsif trigger_team_players.size > 0
            for player in trigger_team_players
              active_player = ActivePlayer.find_by_steam_id(server.id,player["info"],event_datetime)     
              role_id = Role.find_by_name(server.id, active_player.role).id                         
              player_event = self.save_player_event(event,event_datetime,player,active_player,nil,nil,nil,map_id,role_id,trigger)
            end
          end
        elsif event_type == "team"          
          team_event = TeamEvent.new
          team_event.occurred_at = event_datetime
          team_event.event_id = event.id
          team_event.team_id = player["team"].id
          team_event.player_id = player["object"].id
          team_event.map_id = map_id
          team_event.save
        elsif event_type == "server"
          server_event = ServerEvent.new
          server_event.occurred_at = event_datetime
          server_event.event_id = event.id
          server_event.server_id = server.id
          if victim and victim["object"] and victim["object"].id > 0
            server_event.victim_id = victim["object"].id
            server_event.victim_team_id = victim["team"].id
          else
            server_event.victim_id = 0
          end
          server_event.map_id = map_id
          server_event.save
        end
      end
    end 
    if disconnect == 1 and active_player
      SourcestatsLogger.player_disconnect(active_player,event_datetime)
    else
      if active_player and active_player.changed?
        active_player.save
      end
      if active_victim and active_victim.changed?
        active_victim.save
      end
    end
    
    #puts "\n\n\n"
  end

  def self.player_disconnect(player,event_datetime)
    if event_datetime and player and player.connect_time and event_datetime > player.connect_time
      connected_for = (event_datetime - player.connect_time)
    else
      connected_for = 0
    end
  	sql = "update players set total_time = total_time + #{connected_for} where server_id = #{player.server_id} and steam_id = '#{player.steam_id}'"
  	ActiveRecord::Base.connection.execute(sql)

    sql = "delete from active_players where id = #{player.id}"
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def self.player_details(server_id,info)
    player = Hash.new
    if info and info.size > 0
      player["skill_change"] = 0
      player["info"] = Player.get_player_info(info)
      player["object"] = Player.find_by_steam_id(server_id,player["info"])
      if player["object"]
        player["bot"] = player["object"].bot?
        if not player["bot"] and player["info"]["team_name"] and player["info"]["team_name"].size > 0
          player["team"] = Team.find_by_name(server_id,player["info"]["team_name"])
        else
          player["team"] = Team.new
        end
      end
    end
    return player
  end
  
  def self.save_player_event(event,event_datetime,player,active_player,victim,active_victim,weapon_id,map_id,role_id,trigger)
    player_event = PlayerEvent.new
    player_event.occurred_at = event_datetime
    player_event.role_id = role_id
    if trigger
      player_event.trigger_id = trigger.id
    else
      player_event.trigger_id = 0
    end
    player_event.event_id = event.id
    player_event.player_id = player["object"].id
    player_event.player_team_id = player["team"].id
    player_event.player_skill = player["object"].skill
    player_event.skill_change = player["skill_change"]
    if active_player and active_player.id > 0
      player_event.player_kills = active_player.kills
      player_event.player_deaths = active_player.deaths
    end
    if victim and victim["object"] and victim["object"].id > 0
      player_event.victim_skill = victim["object"].skill
      player_event.victim_skill_change = victim["skill_change"]
      if victim["bot"]
        player_event.bot_victim = 1        
      end
      if active_victim and active_victim.id > 0
        player_event.victim_kills = active_victim.kills
        player_event.victim_deaths = active_victim.deaths
        player_event.victim_role_id = Role.find_by_name(active_victim.server_id, active_victim.role).id || 0
      end
      
      player_event.victim_id = victim["object"].id
      player_event.victim_team_id = victim["team"].id
    else
      player_event.victim_kills = 0
      player_event.victim_deaths = 0
      player_event.victim_skill = 0
      player_event.victim_id = 0
      player_event.victim_team_id = 0
    end
    player_event.weapon_id = weapon_id || 0
    player_event.map_id = map_id || 0
    player_event.save    
    
    return player_event
  end
  
end
