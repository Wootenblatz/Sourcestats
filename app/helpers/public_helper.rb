module PublicHelper
  def admin_link_to(link)
    ip = request.env["REMOTE_ADDR"]
    if ip =~ /^192\.168\./ or ip =~ /^10\./ or ip =~ /^172\.16\./ 
      link
    else
      ""
    end
  end
  
end