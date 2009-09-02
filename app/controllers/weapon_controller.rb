class WeaponController < PublicController
  before_filter :parse_server_id
  caches_page :list
  def list
    @weapons = @server.weapons.paginate :page => params[:page] || 1
  end  
end
