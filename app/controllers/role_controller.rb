class RoleController < PublicController
  before_filter :parse_server_id
  before_filter :check_admin_access, :only => [:edit]
  
  caches_page :list
  def list
    @roles = @server.roles.paginate :page => params[:page] || 1
  end  
end
