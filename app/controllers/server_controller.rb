class ServerController < PublicController
  caches_page :list, :show
   
  def list
    @servers = Server.paginate :page => params[:page] || 1, :conditions => ["status = ?","active"], :order => "name asc"
  end
  
  def show
    @server = Server.find(params[:id])
    @events = @server.events.find(:all, :conditions => ["highlight = ?", "Yes"])
    
    # Load our triggers and count how many times they happened
    @triggers = @server.triggers.find(:all, 
                                      :select => "triggers.*, count(player_events.id) as uses",
                                      :joins => "inner join player_events on triggers.id = player_events.trigger_id",
                                      :conditions => ["player_events.occurred_at > ? and triggers.highlight = ?", @server.start, "Yes"],
                                      :order => "uses desc",
                                      :group => "triggers.id")

    # Load the roles and count how many times someone switched to each one
    @roles = @server.roles.find(:all, 
                                :select => "roles.*, count(player_events.id) as uses",
                                :joins => "inner join player_events on roles.id = player_events.role_id inner join events on events.id = player_events.event_id",
                                :conditions => ["player_events.occurred_at > ? and events.name = ?", @server.start, "changed role to"],
                                :order => "uses desc",
                                :group => "roles.id")
    
    # Find the top 10 players
    @top10 = @server.players.find(:all,
                                  :select => "players.*, sum(player_events.skill_change) as skill_change",
                                  :conditions => ["player_events.occurred_at > ? and player_events.victim_id != player_events.player_id", @server.start],
                                  :joins => "inner join player_events on player_events.player_id = players.id inner join events on events.id = player_events.event_id",
                                  :order => "skill_change desc",
                                  :group => "players.id",
                                  :limit => 10)
    
    # Find the most frequently played maps
    @maps = @server.maps.find(:all,
                              :select => "maps.*, count(server_events.id) as uses", 
                              :conditions => ["server_events.occurred_at > ?",@server.start],
                              :joins => "inner join server_events on maps.id = server_events.map_id",
                              :order => "uses desc",
                              :group => "maps.id")
                              
    # Find the most popular weapons
    @weapons = @server.weapons.find(:all,
                              :select => "weapons.*, count(player_events.id) as uses", 
                              :conditions => ["player_events.occurred_at > ? and highlight = ?",@server.start, "Yes"],
                              :joins => "inner join player_events on weapons.id = player_events.weapon_id",
                              :order => "uses desc",
                              :group => "weapons.id")
    add_to_seo(@server.name,@server.name,@server.description.gsub(/\W/, " "))
  end
  
  def edit
    @server = Server.find(params[:id])
    if request.post?
      @server.update_attributes(params[:server])
      if @server.save
        flash[:notice] = "#{@server.name} updated."
        redirect_to :action => "list"
      end
    end
  end
  
end
