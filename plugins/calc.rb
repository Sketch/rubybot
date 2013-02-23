require 'calculator'

class Calculator
  def Calculator.help
    %q{Do math.

Usage: calc <expression>

Do a quick mathematical expression}
  end
  def Calculator.examples
    %q{calc 3+2*(4^2)
calc PI*3^2
calc E^10}
  end
  def Calculator.pstart
    Plugins.register("calc") { |args|
      args.gsub!("PI",Math::PI.to_s)
      args.gsub!("E",Math::E.to_s)
      begin
        args.calculate.gsub(/\.0+$/,'')
      rescue Exception => er
        "That is not a valid math string"
      end
    }
    Plugins.register("math") { |args|
      args.gsub!("PI",Math::PI.to_s)
      args.gsub!("E",Math::E.to_s)
      begin
        args.calculate.gsub(/\.0+$/,'')
      rescue Exception => er
        "That is not a valid math string"
      end
    }
  end
  def Calculator.pclose
    Plugins.unregister("calc")
    Plugins.unregister("math")
  end
end

Plugins.add(__FILE__,Calculator)
