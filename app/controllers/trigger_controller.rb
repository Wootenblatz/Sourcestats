class TriggerController < PublicController
  before_filter :parse_server_id
  before_filter :check_admin_access, :only => [:edit]
  
  caches_page :list
  def list
    @triggers = @server.triggers.paginate :page => params[:page] || 1
  end  
  
  def edit    
    @trigger = Trigger.find(params[:id])
    @server = Server.find(@trigger.server_id)
    if request.post?
      @trigger.update_attributes(params[:trigger])
      if @trigger.save
        flash[:notice] = "#{@trigger.name} updated."
        redirect_to :action => "list", :server_id => @server.server_id, :page => 1
      end
    end
  end
  
end
