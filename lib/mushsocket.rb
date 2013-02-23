# mudsocket

require 'reconnectingsocket'

class MushSocket < ReconnectingSocket
  def initialize(host,port,connect_string,&block)
    @connect_string = connect_string
    super(host,port,&block)
  end
  def on_connect
    send @connect_string
  end
  def get_input
    unescape(@socket.gets)
  end
  def unescape(str)
    res = str.gsub("<br>","\n")
    res.gsub!("<t>","\t")
    res.gsub!("&lt;","<")
    res.gsub!("&gt;",">")
    res.gsub!("&amp;","&")
    res
  end
  def get_output(what)
    escape(what) + "\n"
  end
  def escape(str)
    res = str.gsub('&#39;','\'')
    res.gsub!('&quot;','\'')
    res.gsub!(/[\\\}\,\{\]\(\)\[\;\%\{\}]/,'\\\\\&')
    res.gsub!(/        /,'%t')
    res.gsub!("\n",'%r')
    res.gsub!(/  /,' %b')
    res.gsub!(/<b>(.+?)<\/b>/,"[ansi(h,\\1)]")
    res.gsub!(/<br.*?>/,"%r")
    res
  end
end
