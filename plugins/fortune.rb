# Fortune.rb
#

class Fortune
  FORTUNE     ||= '/usr/bin/fortune'
  FORTUNESDIR ||= '/usr/share/fortune'
  def Fortune.help
    %q{Unix /usr/games/fortune program.

fortune
fortune <file>

fortune alone picks a random fortune.
With an argument it picks from a specific fortune file.
'fortune list' will get you the available files.}
  end
  def Fortune.examples
    %q{fortune
fortune homer
fortune dubya
fortune SP}
  end
  def Fortune.pstart
    Plugins.register("fortune") { |args|
      Fortune.givefortune(args)
    }
  end
  def Fortune.pclose
    Plugins.unregister("fortune")
  end
  def Fortune.fortunes
    @fortunes    ||= Dir.glob(File.join(FORTUNESDIR,"*.dat")).collect do |fn|
      File.basename(fn,".dat")
    end
    @fortunes
  end
  def Fortune.find(string)
    return "someoldrandomfortune" unless string
    return "someoldrandomfortune" if string == ""
    return "what" if ["what","list"].include?(string)
    return string if fortunes.include?(string)
    fortunes.each do |i|
      return i if string == i[0,string.length]
    end
    return "what"
  end
  def Fortune.givefortune(string)
    string.delete!('^a-zA-Z\-:')
    if string.downcase == 'list'
      return fortunes.join(", ")
    else
      if m = /^\s*(-l|-s)?\s*([a-zA-Z\-]+)?$/.match(string)
        cmdarg = ""
        case m[1]
        when "-l"
          cmdarg = "-l"
        when "-s"
          cmdarg = "-s"
        else
          cmdarg = ""
        end unless m.nil?
        string = find((m[2]||"").downcase)
      else
        string = "someoldrandomfortune"
      end
      qotd = case
      when string == "what"
        return fortunes.join(" ")
      when fortunes.include?(string)
        return "\n"+%x[#{FORTUNE} #{cmdarg} #{string}]
      else
        return "\n"+%x[#{FORTUNE} #{cmdarg}]
      end
    end
  end
end

Plugins.add(__FILE__,Fortune)
