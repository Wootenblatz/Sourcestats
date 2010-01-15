class Bot < ActiveRecord::Base
  has_many :events, :foreign_key => "victim_id", :conditions => ["bot_victim = ?", 1]
  belongs_to :server

  def self.load_bot(server_id,player_info)
    # Left for dead style games can bring in bots before the last one is totally "disconnected"
    # Lets strip off the auto-rename prefix just in case.
    player_info["name"].gsub!(/^\((\d+?)\)/,"")
    
    # Use the bot's name to look it up on this server
    bot = find(:first,:conditions => ["server_id = ? and name = ?", server_id, player_info["name"]])    
    if player_info["name"] and player_info["name"].size > 0
      if not bot
        bot = Bot.new
        bot.name = player_info["name"]
        bot.server_id = server_id
        bot.save
      end
    end
    return bot
  end
  
  def skill
    1
  end
  
  def victim_kills(kill_event_id, victim_id)
    PlayerEvent.count(:conditions => ["event_id = ? and player_id = ? and victim_id = ? and bot_victim = 1", 
                                       kill_event_id, id, victim_id]) 
  end
    
  def victim_triggers(trigger_id, victim_id)
    PlayerEvent.count(:conditions => ["trigger_id = ? and player_id = ? and victim_id = ?", 
                                       trigger_id, id, victim_id])     
  end
  
  def display_name
    if name and name.size > 0
      "#{name.capitalize}"
    else
      "#{model.capitalize}"
    end 
  end
  
  def bot?
    return true
  end
end
