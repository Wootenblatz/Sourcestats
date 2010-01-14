class PlayerState < ActiveRecord::Base
  belongs_to :server
  has_many :player_events
  
  def self.load(server_id,name)
    state = find(:first,:conditions => ["server_id = ? and name = ?", server_id, name])
    if not state
      state = PlayerState.new
      state.server_id = server_id
      state.name = name
      state.save
    end
    return state
  end
end
