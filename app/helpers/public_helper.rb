module PublicHelper
  def admin_link_to(link)
    # Relies on application controller to enforce security
    link
  end

  def percent(x,y)
    value = "0"
    if x.to_f > 0.0
      value = sprintf("%0.1f", (y.to_f / x.to_f) * 100)
    end
    return value + "%"
  end
  
end