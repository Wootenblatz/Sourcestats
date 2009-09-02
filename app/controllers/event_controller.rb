class EventController < PublicController
  before_filter :parse_server_id
  caches_page :list
  def list
    @events = @server.events.paginate :page => params[:page] || 1
  end  
end
