module PublicHelper
  def admin_link_to(link)
    ip = request.env["REMOTE_ADDR"]
    if check_admin_access()
      link
    else
      ""
    end
  end
  
end