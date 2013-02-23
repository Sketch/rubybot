# plugins.rb
#

PLUGIN_DIR = File.join(RBOT_DIR,'plugins')

module Plugs
end

class Plugin
  def Plugin.puts(args)
    Plugins.puts(args)
  end
  def puts(args)
    Plugins.puts(args)
  end
end

class Plugins
  def Plugins.setup
    @plugins  ||= Hash.new(nil)
    @commands ||= Hash.new(nil)
    @log ||= STDOUT
    Kernel.at_exit {
      shutdown
    }
  end
  def Plugins.puts(args)
    unless @log.nil?
      @log.puts args
    end
  end
  def Plugins.log=(log)
    @log = log
  end
  def Plugins.plugins
    @plugins
  end
  def Plugins.add(name,plug)
    @plugins[File.basename(name,".rb")] = plug
    pcall {
      plug.pstart if plug.respond_to?(:pstart)
    }
  end
  def Plugins.load_plug(fname)
    fname = File.basename(fname,'.rb')
    fn = File.join(PLUGIN_DIR,fname) + '.rb'
    if (File.file?(fn))
      # Unload the previous plugin if it already exists.
      pcall {
        if (plug = @plugins[fname] && plug.respond_to?(:pclose))
          puts "Unloading plugin #{fname}"
          plug.pclose
        end
      }
      # Load the file.
      pcall {
        puts "Loading plugin #{fname}"
        load(fn)
      }
      return true
    else
      return false
    end
  end
  def Plugins.load_all
    d = Dir.new(PLUGIN_DIR)
    d.each do |f|
      next unless f =~ /\.rb$/
      load_plug(f)
    end
  end
  def Plugins.register(name,&block)
    raise "No block given" unless block_given?
    @commands[name.downcase] = block
  end
  def Plugins.call(cmd,args="")
    return 'Unknown command' unless @commands.has_key?(cmd.downcase)
    pcall {
      return @commands[cmd.downcase].call(args)
    }
    return "Error with command: #{cmd}"
  end
  def Plugins.unregister(cmd)
    @commands[cmd.downcase] = nil
  end
  def Plugins.shutdown
    @plugins.each do |key,plug|
      pcall {
        plug.pclose if plug.respond_to?(:pclose)
      }
    end
  end
end
Plugins.setup
