class Player < ActiveRecord::Base
  @player_r = Regexp.new('^(.+)<(\d+)><(.+?)><(.*)>')
  #Coach<4><BOT><Survivor><Coach><ALIVE><100+0><setpos_exact 831.96 5457.06 2718.03; setang 8.73 201.79 0.00><Area 12063>
  @player_extended_r = Regexp.new('^(.+)<(\d+)><([^>]*)><([^>]+)><([^>]+)><([^>]+)><([^>]+)><([^>]+)>')

  belongs_to :server
  has_many :aliases
  has_many :player_events
  has_many :weapons, :through => :player_events
  has_many :events, :through => :player_events
  has_many :roles, :through => :player_events, :select => "roles.*,count(player_events.id) as uses", :group => "roles.id", :order => "uses desc"
  has_many :triggers, :through => :player_events, :select => "triggers.*,count(player_events.id) as uses", :group => "triggers.id", :order => "uses desc"

  def self.per_page
    10
  end
  
  def display_name
    if name and name.size > 0
      "#{name}"
    else
      "No name"
    end 
  end
  
  def favorite_role
    roles.first
  end

  def steam_2_friend
    tokens = steam_id.split ':'
    type = tokens[1].to_i
    id = tokens[2].to_i
    base = 76561197960265728
    (id*2) + type + base
  end

  def self.get_player_info(player_string)
    player_info = Hash.new
    player_info['name'] = ""
    player_info['slot'] = ""
    player_info['steam_id'] = ""
    player_info['team_name'] = ""
    
    if values = player_string.scan(@player_extended_r)[0]
      #Coach<4><BOT><Survivor><Coach><ALIVE><100+0><setpos_exact 831.96 5457.06 2718.03; setang 8.73 201.79 0.00><Area 12063>
      player_info['name'] = values[0].gsub(/"/,"")
      player_info['slot'] = values[1]
      if not values[2]
        values[2] = "BOT"
      end
      player_info['steam_id'] = values[2]
      player_info['team_name'] = values[3]      
      player_info['model'] = values[4]
      player_info['state'] = values[5]
      player_info['health'] = values[6]
      player_info['position'] = values[7]
      player_info['arena'] = values[8]
    elsif values = player_string.scan(@player_r)[0]
      player_info['name'] = values[0].gsub(/"/,"")
      player_info['slot'] = values[1]
      player_info['steam_id'] = values[2]
      player_info['team_name'] = values[3]
    end
    
    return player_info
  end
  
  def bot?
    return false    
  end

  def self.find_by_steam_id(server_id,player_info)
    player = nil
    if player_info["steam_id"] != "BOT" and player_info["steam_id"] != ""
      player = Player.find(:first,:conditions => ["server_id = ? and steam_id = ?", server_id,player_info['steam_id']])
      if not player or player.id.size == 0
        player = Player.new
        player.server_id = server_id
        player.name = player_info['name']
        player.steam_id = player_info['steam_id']
        player.kills = 0
        player.deaths = 0
        player.skill = 1000.0
        player.last_connect = Time.new
        player.save
      end
    else
      player = Bot.load_bot(server_id,player_info)
    end
    return player
  end  
  
  def compute_skill(victim,weapon)
    player_skill = skill
    if not player_skill or player_skill =~ /\D/ or player_skill < 1000
      player_skill = 1000.0
    end

    skills = Array.new
    bonus = 1.0
    if weapon.bonus > 0.0
      bonus = weapon.bonus
    end

    if victim.bot?
      skills[0] = (victim.bonus * bonus)
      skills[1] = 0
    else
      if id > 0 and victim and victim.id > 0 and id != victim.id 
        if not victim.skill or victim.skill =~ /\D/ or victim.skill < 1000
          victim.skill = 1000.0
        end

        skills[0] = sprintf("%02.2f", (((victim.skill / player_skill) * bonus) * 10.0)).to_f
        skills[1] = sprintf("%02.2f", (((player_skill / victim.skill) * bonus) * 10.0)).to_f
      end      
    end
    return skills
  end
  
  def efficiency(num_kills,num_deaths)
    if num_deaths > 0
      sprintf("%0.2f", num_kills.to_f / num_deaths.to_f)
    else
      sprintf("%0.2f", num_kills.to_f)
    end
  end
  
  def player_id
    "#{id}-#{name.gsub(/\W/,"_")}"
  end
  
  def victims(kill_event_id, page = 1)
    Player.paginate(:page => page, :select => "players.*, count(player_events.id) as deaths", :conditions => ["player_events.player_id = ? and player_events.bot_victim = 0", id], :joins => "inner join player_events on player_events.victim_id = players.id", :group => "player_events.victim_id", :order => "deaths desc")
  end
  
  def bot_victims(kill_event_id, page = 1)
    Bot.paginate(:page => page, :select => "bots.*, count(player_events.id) as deaths", :conditions => ["player_events.player_id = ? and bot_victim = 1", id], :joins => "inner join player_events on player_events.victim_id = bots.id", :group => "player_events.victim_id", :order => "deaths desc")
  end
  
  def victim_kills(kill_event_id, victim_id)
    PlayerEvent.count(:conditions => ["event_id = ? and player_id = ? and victim_id = ?", 
                                       kill_event_id, id, victim_id]) 
  end
  
  def calculate_skill_for_period(start)
    total_skill = 0.0
    positive = Player.find_by_sql("select sum(skill_change) as skill_change from player_events where player_id = #{id} group by player_id limit 1")[0]
    negative = Player.find_by_sql("select sum(victim_skill_change) as skill_change from player_events where victim_id = #{id} group by victim_id limit 1")[0]
    if positive
      total_skill += positive.attributes["skill_change"].to_f
    end
    if negative
      total_skill += negative.attributes["skill_change"].to_f
    end
    return total_skill
  end
  
  def kills_for_period(start)
    kill_count = Player.find_by_sql("select count(p.id) as kills from player_events p, events e where e.id = p.event_id and e.name = 'killed' and p.player_id = #{id} and p.occurred_at > '#{start}'")
    return kill_count[0].kills
  end

  def deaths_for_period(start)
    death_count = Player.find_by_sql("select count(p.id) as deaths from player_events p, events e where e.id = p.event_id and e.name = 'killed' and p.victim_id = #{id} and p.occurred_at > '#{start}'")
    return death_count[0].deaths
  end
end
