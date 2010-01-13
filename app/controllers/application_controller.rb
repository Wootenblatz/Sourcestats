class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  def check_admin_access
    ip = request.env["REMOTE_ADDR"]
    is_admin = false
    if ip =~ /^192\.168\./ or ip =~ /^10\./ or ip =~ /^172\.16\./ # or ip =~ /^your\.ip\.address\.here/
      is_admin = true
    end
    return is_admin
  end
end
