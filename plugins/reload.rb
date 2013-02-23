# This is the reload plugin. It provides 2 'bot administration' commands:
# 
# reload <file.rb> - reload plugins/<file.rb> plugin.
# reload all - Load all plugins in the plugins/ dir
#
# threads - List all threads, named or not. If you're writing a plugin,
#           use Thread.current['name'] to name it.

class Reloader
  def Reloader.pstart
    Plugins.register("reload") { |args|
      args.delete!("^a-zA-Z0-9.")
      if args == "all"
        Plugins.load_plug("plugins")
        "Plugins reloaded"
      elsif File.file?(File.join("plugins",args))
        Plugins.load_plug(File.join("plugins",args))
	"Plugin loaded"
      else
        "That plugin doesn't exist"
      end
    }
    Plugins.register("threads") {
      str = []
      str << "Threads:"
      Thread.current['name'] = 'This thread!'
      Thread.list.each do |thread|
        if thread['name'].nil?
          str << "   (unnamed)"
	else
          str << "   #{thread['name'].to_s unless thread['name'].nil?}"
	end
      end
      str << ""
      str.join("\n")
    }
  end
  def Reloader.pclose
    Plugins.unregister("reload")
    Plugins.unregister("threads")
  end
end

Plugins.add(__FILE__,Reloader)
