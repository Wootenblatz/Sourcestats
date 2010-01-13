class Server < ActiveRecord::Base
  has_many :events
  has_many :roles
  has_many :player_events
  has_many :team_events
  has_many :triggers
  has_many :players
  has_many :server_events
  has_many :teams
  has_many :maps
  has_many :weapons
  has_many :bots
  
  validates_numericality_of :max_players
  validates_presence_of :name
  validates_numericality_of :timeframe
  validates_presence_of :description
  validates_format_of :ip, :with => /^(\d{1,3}\.){3}\d{1,3}$/
  validates_numericality_of :port
  
  def is_admin?(remote_ip)
    flag = false
    # Strip out carriage returns and then split on new-lines
    admin_ip_list.gsub!(/\r/,"")  
    admin_ip_list.split(/\n/).each do |ip|
      # Make sure any white space or special characters are on the IP
      ip.chomp!
      ip.strip!
      if not flag and remote_ip =~ /#{ip}/
        flag = true
      end
    end
    return flag
  end
  
  def server_id
    "#{id}-#{name.gsub(/\W/,"_")}"
  end
  
  def prune_inactive_players
    sql = ActiveRecord::Base.connection();    
    slots = ActivePlayer.find(:all,:conditions =>["server_id = ?", id], :order => "connect_time desc")

    if slots.size > (max_players * 3)
      puts "Server ActivePlayer table has #{slots.size} records (max_players is #{max_players})"
      for slot in slots[(max_players * 3)..slots.size]
        slot.destroy
      end
    end
  end
  
  def start
    timeframe.to_i.days.ago
  end
end