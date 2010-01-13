class BotController < PublicController
  before_filter :parse_server_id
  caches_page :list
  def list
    @bots = @server.bots.paginate :page => params[:page] || 1, :order => "name asc"
  end  

  def edit    
    @bot = Bot.find(params[:id])
    @server = Server.find(@bot.server_id)
    if request.post?
      @bot.update_attributes(params[:bot])
      if @bot.save
        flash[:notice] = "#{@bot.name} updated."
        redirect_to :action => "list", :server_id => @server.server_id, :page => 1
      end
    end
  end
  
end
