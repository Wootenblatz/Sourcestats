# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  FLASH_NAMES = [:notice, :warning, :error].freeze unless self.class.const_defined? "FLASH_NAMES"
  MONTH = {1 => 'Jan.',
           2 => 'Feb.',
           3 => 'March',
           4 => 'April',
           5 => 'May',
           6 => 'June',
           7 => 'July',
           8 => 'Aug.',
           9 => 'Sept.',
           10 => 'Oct.',
           11 => 'Nov.',
           12 => 'Dec.'
           }.freeze unless self.class.const_defined? "MONTH"


  def stylesheet_tag(name, html_options = {})

    uri = "/stylesheets/#{name}.css"

    html_options = {
      'href'  => uri,
      'type'  => "text/css",
      'media' => "screen, projection",
      'rel'   => "stylesheet"
      }.merge(html_options.stringify_keys)
    tag("link", html_options)
   end

  def javascript_tag(*names)
    html_options = names.last.is_a?(Hash) ? names.pop.stringify_keys : { }
    names.collect { |name|
      uri = "/javascripts/#{name}.js"
      src = uri
      content_tag("script", "", { "type" => "text/javascript", "src" => src }.merge(html_options))
    }.join("\n")
   end  

   def flash_messages
     message_string = ""
     for name in FLASH_NAMES
       if flash[name]
           message_string += "<br /><div id=\"flash#{name}\">#{flash[name]}</div><br />"
       end
       flash[name] = nil
     end
     return message_string
   end

   def ap_time(date)
     hour = date.hour
     minute = sprintf("%02.f", date.min)
     if hour > 11
       hour = hour-12
       hour = 12 if hour == 0
       hour.to_s+":"+minute.to_s+" p.m."
     else
       hour = 12 if hour == 0
       hour.to_s+":"+minute.to_s+" a.m."
     end
   end

   def ap_date(date)
     if date
       if date.day.to_i == 1
         MONTH[date.month].to_s+" "+date.year.to_s
       else
         MONTH[date.month].to_s+" "+date.day.to_s+", "+date.year.to_s
       end
     end
   end

   def ap_date_time(date)
     ap_date(date)+" "+ap_time(date)
   end
end
