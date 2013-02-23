require 'socket'

class PennVersion
  VERSIONS=[
      ['Stable','1.7.6'],
      ['Development','1.7.7']
    ]
  def PennVersion.help
    %q{pennversion returns the latest development and stable versions
of PennMUSH.}
  end
  def PennVersion.examples
    %q{pennversion}
  end
  def PennVersion.pstart
    Plugins.register("pennversion") { |args|
      PennVersion.getversions
    }
  end
  def PennVersion.getversions
    begin
      res = VERSIONS.map do |i,j|
        hostinfo = Socket.gethostbyname("#{j}.patchlevel.pennmush.org")
        ip = hostinfo[3]
        if (ip.length > 4)
          ip = ip[4,4]
        end
        "#{i.rjust(12)}: #{ip[0]}.#{ip[1]}.#{ip[2]}p#{ip[3]}"
      end
      return res.join("\n")
    rescue Exception => er
      return "Unable to query server"
    end
  end
  def PennVersion.pclose
    Plugins.unregister("pennversion")
  end
end

Plugins.add(__FILE__,PennVersion)
