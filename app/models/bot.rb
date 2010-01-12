class Bot < ActiveRecord::Base
  has_many :events, :foreign_key => "victim_id", :conditions => ["bot_victim = ?", 1]
  belongs_to :server

  def self.load_bot(server_id,player_info)
    bot = find(:first,:conditions => ["server_id = ? and name = ?", server_id, player_info["name"]])    
    if not bot
      bot = Bot.new
      bot.name = player_info["name"]
      bot.model = player_info["model"]
      bot.server_id = server_id
      bot.save
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
    
  def display_name
    if name and name.size > 0
      "#{name}"
    else
      "#{model}"
    end 
  end
  
  def bot?
    return true
  end
end
