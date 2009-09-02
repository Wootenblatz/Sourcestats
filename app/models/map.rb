class Map < ActiveRecord::Base
  has_many :player_events
  has_many :server_events
  has_many :team_events
  def self.find_by_name(server_id,map_name)
    map = Map.find(:first,:conditions => ["server_id = ? and name = ?", server_id, map_name])
    if not map or map.id.size == 0
      map = Map.new
      map.server_id = server_id
      map.name = map_name
      map.save
    end
    return map
  end
end
