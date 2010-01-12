class WeaponController < PublicController
  before_filter :parse_server_id
  caches_page :list
  def list
    @weapons = @server.weapons.paginate :page => params[:page] || 1
  end  
  def edit    
    @weapon = Weapon.find(params[:id])
    @server = Server.find(@weapon.server_id)
    if request.post?
      @weapon.update_attributes(params[:weapon])
      if @weapon.save
        flash[:notice] = "#{@weapon.name} updated."
        redirect_to :action => "list", :server_id => @server.server_id, :page => 1
      end
    end
  end
end
