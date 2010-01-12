class Trigger < ActiveRecord::Base
  belongs_to :server
  has_many :player_events
  
  def self.find_by_name(server_id,trigger_name)
    trigger = Trigger.find(:first,:conditions => ["server_id = ? and name = ?", server_id, trigger_name])
    if not trigger or trigger.id.size == 0
      trigger = Trigger.new
      trigger.server_id = server_id
      trigger.name = trigger_name
      trigger.label = trigger_name
      trigger.save
    end
    return trigger
  end
  
  def top_players_for_period(start)
    Player.find(:all,
                :select => "players.*, count(player_events.id) as times",
                :joins => "inner join player_events on player_events.player_id = players.id",
                :conditions => ["player_events.occurred_at > ? and player_events.trigger_id = ?", start, id],
                :order => "times desc",
                :group => "player_events.player_id", 
                :limit => 3)
  end
  
end
