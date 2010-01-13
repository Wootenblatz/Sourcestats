class PublicController < ApplicationController
  layout "public"
  before_filter :seo
  
  def seo
    @pagetitle = "Source Stats"
    @metakeywords = "Source Stats, Ruby on Rails, VALVe, Team Fortress 2 Stats, Counterstrike Source Stats, Zach Karpinski, halfStats"
    @metadescription = "Source Stats is a VALVe logging standard stats program written with Ruby on Rails by Zach Karpinski."
  end

  def add_to_seo(add_to_pagetitle,add_to_keywords,add_to_description)
    if add_to_pagetitle.size > 0
      @pagetitle += " - " + add_to_pagetitle
    end
    if add_to_keywords.size > 0
      @metakeywords += ", " + add_to_keywords
    end
    if add_to_description.size > 0
      @metadescription += " " + add_to_description
    end
    @ip = request.env["REMOTE_ADDR"]
  end
  def parse_server_id
    @server = nil
    if params[:server_id]
      if params[:server_id] =~ /-/
        @server_id = params[:server_id].split("-")[0]
      else
        @server_id = params[:server_id]
      end
      @server = Server.find(@server_id,:conditions => ["status = ?","active"])
      add_to_seo("#{@server.name}",@server.name,@server.description.gsub(/\W/, " "))      
    end
  end
  
  def check_admin_access
    if not @server.is_admin?(request.env["REMOTE_ADDR"])
      flash[:error] = "Admin access required to view this page"
      redirect_to "/"
    end
  end
end