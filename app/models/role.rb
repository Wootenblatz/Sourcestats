class Role < ActiveRecord::Base
  
  belongs_to :server
  has_many :player_events
  
  def switch_count
    player_events.find(:all,:conditions => ["events.name = ?", "changed role to"], :joins => "inner join events on event.id = player_events.event_id")
  end
  
  def self.find_by_name(server_id, name)
    role = Role.find(:first,:conditions => ["server_id = ? and name = ?",server_id,name])
    if not role or role.id < 1
      role = Role.new
      role.server_id = server_id
      role.name = name
      role.save
    end
    return role
  end
end
