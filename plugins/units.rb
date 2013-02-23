# Units conversion plugin
#

class Units
  UNITS ||= '/usr/bin/units -q'
  def Units.help
    %q{Conversion from one unit to the other

units <from> to <what>
units <amount> <from> to <what>

Returns the conversion rate, or the amount of 'what' it makes.}
  end
  def Units.examples
    %q{units 40 rods per hogshead to mpg
units 10 km to miles
units 10 liters to gallons}
  end
  def Units.pstart
    Plugins.register("units") { |args|
      Units.unite(args)
    }
  end
  def Units.unite(args)
    arg = args.delete('^a-z/A-Z0-9() ')
    from,to = arg.split(/\s+to\s+/,2)
    str = ""
    begin
      value = 0
      str = []
      IO.popen(UNITS,'r+') do |units|
        units.puts from
        units.puts to
        units.close_write
        str = units.readlines.join
      end
      return "Units: #{from} to #{to}\n#{str}"
    rescue Exception => er
      return "Invalid unit specification"
    end
    return result
  end
  def Units.pclose
    Plugins.unregister("units")
  end
end

Plugins.add(__FILE__,Units)
