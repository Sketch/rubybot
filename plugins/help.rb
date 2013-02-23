
class Help
  def Help.help
    %q{Obtain help on a plugin

help
help list
help <plugin>
examples <plugin>

Without args, this text is returned.
With 'list', a list of avaible plugins is given.
'help' obtains help from the plugin.
'examples' gets examples.}
  end
  def Help.examples
    %q{help dictionary
help list
examples scrabble}
  end
  def Help.pstart
    Plugins.register("help") { |args|
      Help.get_help(args,:help)
    }
    Plugins.register("examples") { |args|
      Help.get_help(args,:examples)
    }
  end
  def Help.get_help(args,symbol=:help)
    onwhat = args.downcase.delete('^a-z')
    plugs = []
    Plugins.plugins.each do |key,plug|
      plugs << key if plug.respond_to?(symbol)
    end
    plugs.sort!
    case
    when onwhat == "list"
      return "Available plugins that will respond: #{plugs.join(", ")}"
    when onwhat.empty?
      return "Plugin: help.\n" + help
    when (plug = Plugins.plugins[onwhat]).nil?
      return "That plugin does not exist"
    when plug.respond_to?(symbol)
      return "Plugin: #{onwhat}.\n" + plug.send(symbol)
    else
      return "Plugin '#{onwhat}' does not have #{symbol} associated with it."
    end
  end
  def Help.pclose
    Plugins.unregister("help")
    Plugins.unregister("examples")
  end
end

Plugins.add(__FILE__,Help)
