class Team < ActiveRecord::Base
  belongs_to :server
  
  def self.find_by_name(server_id,team_name)
    team = Team.find(:first,:conditions => ["server_id = ? and name = ?",server_id,team_name])
    if not team or team.id < 1
      team = Team.new
      team.name = team_name
      team.server_id = server_id
      team.save
    end
    return team
  end
end
