module PlayerHelper
  def steam_link(player)
    "<a href='#{steam_profile_url(player)}' target='_NEW'>#{player.steam_id}</a>"
  end
  
  def steam_profile_url(player)
    "http://steamcommunity.com/profiles/#{player.steam_2_friend}"
  end
  
  def role_information(role)
    count = role.uses.to_i
    if count == 2 
      count = "twice"
    elsif count == 1 
      count = "once"
    end
    if role.id != @player.roles.last.id
      "a #{role.name} #{count.class.name != "String" ? count.to_s + " times" : count}, "
    else
      " and a #{role.name} #{count}"
    end
  end
  
  def role_icon(role, height = 32)
    if role and role.name and role.name != "None"
      image_tag("/images/roles/#{role.name}_icon.png", :border => 0, :alt => "Picked #{role.name} #{role.uses} #{role.uses.to_i > 1 ? "times" : "time"}", :height => height, :style => "margin-right: 4px; vertical-align: middle")      
    else
      ""
    end
  end
  
end
