class PlayerController < PublicController
  before_filter :parse_server_id
  before_filter :check_admin_access, :only => [:edit]

  caches_page :list
  def list
    if params[:search]
      add_to_seo("Player Search",params[:search],"Player search for: #{params[:search]}.")
      @players = @server.players.paginate :page => params[:page] || 1, :conditions => ["kills > ? and name like ?", 0, "%#{params[:search]}%"],:order => "skill desc, kills desc, deaths asc"      
    else
      add_to_seo("Player Listing","","")
      @players = @server.players.paginate :page => params[:page] || 1, 
                                          :select => "players.*, count(player_events.id) as kill_events, sum(player_events.skill_change) as skill_change",
                                          :conditions => ["events.name = ? and events.server_id = ? and player_events.occurred_at > ?", "killed", @server.id, @server.start],
                                          :joins => "inner join player_events on players.id = player_events.player_id inner join events on events.id = player_events.event_id",
                                          :order => "skill_change desc, kills desc",
                                          :group => "players.id"
                                          
    end
  end
  
  def show    
    @player = @server.players.find(params[:player_id].split("-")[0])
    @aliases = @player.aliases.find(:all,:order => "uses asc", :limit => 10)
    @kill_event = Event.find(:first,:conditions => ["server_id = ? and name = ?", @server.id, "killed"])
    if @kill_event
      @victims = @player.victims(@kill_event.id, params[:page])
      @bot_victims = @player.bot_victims(@kill_event.id, params[:page])
    end
    @triggers = @player.triggers
    add_to_seo("#{@player.display_name}'s Player Page",@player.display_name,"#{@player.display_name}'s Player Page.")
    
  end
  
  protected
    def parse_server_id
      if params[:server_id] =~ /-/
        @server_id = params[:server_id].split("-")[0]
      else
        @server_id = params[:server_id]
      end
      @server = Server.find(@server_id,:conditions => ["status = ?","active"])
      add_to_seo("#{@server.name}",@server.name,@server.description.gsub(/\W/, " "))      
    end
end
