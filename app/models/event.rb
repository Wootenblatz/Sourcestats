class Event < ActiveRecord::Base
  belongs_to :server
  has_many :player_events
  has_many :server_events
  has_many :team_events
  has_many :players, :through => :player_events
  has_many :weapons, :through => :player_events
  
  def self.find_by_name(server_id,event_name)
    # This will reassign event names from players who have a double quote at the start of their name
    if event_name =~ /say/ and event_name != "say_team"
      event_name = "say"
    elsif event_name =~ /killed /
      event_name = "killed"
    end
    
    # Load our event
    event = Event.find(:first,:conditions => ["server_id = ? and name = ?", server_id, event_name])
    if not event or event.id.size == 0
      event = Event.new
      event.server_id = server_id
      event.name = event_name
      event.save
    end
    return event
  end
  
  def find_top_players(start)
    Player.find(:all,
                :select => "players.*, count(player_events.id) as total",
                :conditions => ["player_events.event_id = ? and player_events.occurred_at >= ?",id, start],
                :joins => "inner join player_events on player_events.player_id = player.id",
                :order => "total desc",
                :group => "player.id",
                :limit => Player.per_page)
  end
end
