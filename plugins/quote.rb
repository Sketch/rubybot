
require 'sql'

class Quote
  def Quote.help
    %q{Fun quotes
M*U*S*H and other quotes

quote
quote <number>
makequote <phrase>

quote without args returns a random quote
quote with a numeric arg returns a specific quote
makequote adds a quote to the database}
  end
  def Quote.examples
    %q{whatis lethalcows
quote
quote 1
makequote This stinks}
  end
  def Quote.pstart
    Plugins.register("quote") { |args|
      Quote.is(args)
    }
    Plugins.register("makequote") { |args|
      if args.nil? or args.strip.length < 1
        "makequote <quote>"
      else
        Quote.define(args)
      end
    }
    Plugins.register("delquote") { |args|
      Quote.undefine(args)
    }
  end
  def Quote.undefine(what)
    args = SQL.escape(what)
    res = SQL.query("DELETE FROM quotes WHERE quoteid = '#{args}'")
    return 'Quote undefined' if res
    return 'SQL Error'
  end
  def Quote.define(what)
    args = SQL.escape(what)
    SQL.synchronize do
      SQL.query("INSERT INTO quotes (quote) VALUES ('#{args}')")
      SQL.query("SELECT LAST_INSERT_ID()");
    end
  end
  def Quote.is(args)
    res = nil
    if (m = /^(\d+)$/.match((args||"").strip))
      res = SQL.query("SELECT quoteid, quote FROM quotes WHERE quoteid = '#{m[1]}'")
    else
      res = SQL.query("SELECT quoteid, quote FROM quotes ORDER BY RAND() LIMIT 1")
    end
    res.each do |term,definition|
      return "Quote #{term}:\n  #{definition.gsub("\n","\n  ")}\n"
    end if res
    return "Quote #{args}: No such quoteid"
  end
  def Quote.pclose
    Plugins.unregister("quote")
    Plugins.unregister("makequote")
    Plugins.unregister("delquote")
  end
end

Plugins.add(__FILE__,Quote)
