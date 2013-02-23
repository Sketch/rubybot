
class Currency
  def Currency.help
    %q{Convert between currencys.

currency
currency <amount> <from currency> to <to currency>

Currency without arguments returns date the rates were updated.
Currency conversion rates are current up to the day.
Rates provided by e-mail from xe.com.
Popular names ('buck', 'quid', 'dollar') are known.
You can use either the 3 letter code or part of the name.

Popular currency: USD, GBP, JPY, MXN, EUR, CAD.
}
  end
  def Currency.examples
    %q{currency 10 USD to JPY
currency 10 bucks to quid
currency 100 japan yen to canada dollars}
  end
  def Currency.pstart
    @bfname = RubyBot.datfile("currency.bak")
    @fname = RubyBot.datfile("currency.txt")
    @mapname = RubyBot.datfile("currencymaps.txt")
    @maps = Hash.new(nil)
    @rates = Hash.new(nil)
    @ratesasof = "Never"
    Currency.refresh
    Plugins.register("currency") { |args|
      Currency.exchange(args)
    }
    Timer.add("currency",60) {
      Currency.refresh
    }
  end
  def Currency.exchange(args)
    str = args.downcase.delete('^a-z0-9 ')
    case
    when (m = /^\s*(\d+)\s+([\s\w]+)\s+to\s+([\s\w]+)\s*$/.match(args))
      amt = m[1].to_i
      fromwhat = getcode(m[2])
      towhat  = getcode(m[3])
      case
      when fromwhat.nil?
        return "Unknown currency: #{m[2]}"
      when towhat.nil?
        return "Unknown currency: #{m[3]}"
      when amt == 0
        return "A big fat zero"
      when fromwhat == towhat
        return "Exactly what you already have"
      else
        fromname,fromusdper,fromperusd = @rates[fromwhat]
        toname,tousdper,toperusd = @rates[towhat]
        amount = amt*fromusdper*toperusd
        return "#{amt} #{fromname} (#{fromwhat.upcase}) makes #{amount} #{toname} (#{towhat.upcase})"
      end
    when args == ""
      "Currency is dated #{@ratesasof}"
    else
      "Convert what to what?"
    end
  end
  def Currency.getcode(name)
    name = name.strip.downcase.delete('^a-z ')
    case
    when ! @maps[name].nil?
      return @maps[name]
    when ! @rates[name].nil?
      return name
    else
      @rates.each do |code,val|
        curname, usdper, usdfrom = val
        if curname.match(name)
          return code
        end
      end
    end
    return nil
  end
  def Currency.refresh
    status = 0
    linematch = /^\s*([A-Z][A-Z][A-Z]) (.+?)(\d+\.\d+)\s+(\d+\.\d+)\s*$/
    [@bfname,@fname].each do |fname|
      IO.foreach(fname) do |line|
        if (m = /^\s*Rates as of (.*)\s+Base currency is USD.\s*/.match(line))
          @ratesasof = m[1]
          status = 1
        end
        next unless (m = linematch.match(line))
        code, name, usdperunit, unitsperusd = m[1].strip, m[2].downcase.strip, m[3].to_f, m[4].to_f
        @rates[code.downcase] = [name.downcase,usdperunit,unitsperusd]
      end if File.exists?(fname)
    end
    IO.foreach(@mapname) do |line|
      next unless (m = /(\w+):\s*([A-Za-z][A-Za-z][A-Za-z])\s*$/.match(line))
      @maps[m[1]] = m[2].downcase.strip
    end if File.exists?(@mapname)
    File.open(@bfname,"w") do |f|
      f.puts "Rates as of #{@ratesasof} Base currency is USD."
      @rates.each do |code,val|
        name,usdper,unitsper = val
        f.puts "#{code.upcase} #{name} #{usdper} #{unitsper}"
      end
    end
  end
  def Currency.pclose
    Plugins.unregister("currency")
  end
end

Plugins.add(__FILE__,Currency)
