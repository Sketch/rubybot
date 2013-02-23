
require 'dict'

class Dictionary
  SERVERS ||= ['dict.org','alt0.dict.org']
  def Dictionary.help
    %q{Lookup definitions from dict.org servers.

Usage: define <word>

Self explanatory.}
  end
  def Dictionary.examples
    %q{define iron pyrite
define coldfoot
define sasquatch}
  end
  def Dictionary.pstart
    @database = DICT::ALL_DATABASES
    @strategy = 'exact'
    @match_strategy = DICT::DEFAULT_MATCH_STRATEGY
    @port = DICT::DEFAULT_PORT
    @mutex = Mutex.new
    @thread = Thread.new {
      Thread.current["name"] = "Dictionary thread"
      @mutex.synchronize do
        connect
      end
    }
    Plugins.register("define") { |args|
      Dictionary.define(args)
    }
    Plugins.register("dictionary") { |args|
      Dictionary.define(args)
    }
  end
  def Dictionary.connect
    begin
      @dict = DICT.new(SERVERS,@port,false,false)
      @dict.client("%s v%s" % [ "Dictionary", "1.0" ])
    rescue Exception => er
      puts "Dictionary: #{er}"
      puts "  " + er.backtrace.join("\n  ")
    end
  end
  def Dictionary.define(word)
    @mutex.synchronize do
      doretry = true
      begin
        s = []
        m = @dict.match(@database,@strategy,word)
	if m
	  m.each do |db,words|
	    words.each do |w|
	      defs = @dict.define(db,w)
              str = []
	      defs.each do |d|
	        str << "Definition of '#{w}' #{d.description}"
		d.definition.each do |line|
		  str << "   #{line.strip}"
		end
		s << str.join("\n")
	      end
	    end
	  end
	else
	  s << "No Dictionary definitions found"
	end
        return s
      rescue Exception => er
        if doretry
          doretry = false
	  connect
	  retry
	end
      end
    end
  end
  def Dictionary.pclose
    Plugins.unregister("define")
    Plugins.unregister("dictionary")
  end
end

Plugins.add(__FILE__,Dictionary)
