# google.rb
#
# The 'google' plugin
#

require 'google'

class Googleplug
  KEYFILE ||= '~/.google_key'
  KEY     ||= File.open(File.expand_path(KEYFILE)) {|kf| kf.readline.chomp}
  def Googleplug.help
    %q{Get the 5 top results of a google search

google <search words>

It returns: Page title, Url, and search synopsis}
  end
  def Googleplug.examples
    %q{google putty download
google tinyfugue
google weapons of mass destruction}
  end
  def Googleplug.pstart
    Plugins.register('google') { |args|
      if (m = /^(.*) v\.?s (.*)$/.match(args))
        Googleplug.fight(m[1],m[2])
      else
        Googleplug.searchforit(args)
      end
    }
    @proxy_host = nil
    @proxy_port = nil

    if (ENV['http_proxy'])
      if (ENV['http_proxy'] =~ /~http:\/\/(.+):(\d+)$/)
        @proxy_host = $1
	@proxy_port = $2
      end
    end
  end
  def Googleplug.fight(left,right)
    google = Google::Search.new(KEY)

    q = google.search(left)
    l = q.estimatedTotalResultsCount

    q = google.search(right)
    r = q.estimatedTotalResultsCount

    str = []
    str << ""
    str << "Google Fight!"
    if (l > r)
      str << "#{left} beats #{right}!"
    elsif (r > l)
      str << "#{right} beats #{left}!"
    else
      str << "#{right} and #{left} draw! :-|"
    end
    len = left.length
    len = right.length if (right.length > len)
    len += 2
    str << left.rjust(len) + ": #{l}"
    str << right.rjust(len) + ": #{r}"
    str << ""
    return str.join("\n")
  rescue Exception => er
    puts "Google: #{er}"
    "Unable to query Google"
  end
  def Googleplug.searchforit(query)
    google = Google::Search.new(KEY)

    q = google.search(query)
    count = 0
    str = []
    q.resultElements.each do |result|
      count += 1
      s =<<EOF
#{count.to_s.rjust(3)}: #{result.send('title')}
Url: #{result.send('url')}
#{result.send('snippet')}"
EOF
      str << s
      break if count >= 2
    end
    str << "  #{count} of approximately #{q.estimatedTotalResultsCount} results.\n" +
           "  Your query took #{q.searchTime} seconds.\n" 
    return str
  rescue Exception => er
    puts "Google: #{er}"
    "Unable to query Google"
  end
  def Googleplug.pclose
    Plugins.unregister("google")
  end
end

Plugins.add(__FILE__,Googleplug)
