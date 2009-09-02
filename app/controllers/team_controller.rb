class TeamController < PublicController
  before_filter :parse_server_id
  caches_page :list
  def list
    @teams = @server.teams.paginate :page => params[:page] || 1
  end  
end
