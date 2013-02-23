
require 'sql'

class What
  def What.help
    %q{Fun definitions
Acronyms from the 'wtf' database are also included.

wtf [is] <phrase>
whatis <phrase>
mkwhatis <phrase>:<definition>

whatis returns a definition, if one exists.
mkwhatis sets the dfinition for the phrase.
wtf is an alias for whatis. 'is' is optional and ignored.}
  end
  def What.examples
    %q{whatis lethalcows
whatis rit
whatis ruby
mkwhatis coke:A soft drink that's better than pepsi
whatis coke}
  end
  def What.pstart
    Plugins.register("whatis") { |args|
      What.is(args)
    }
    Plugins.register("wtf") { |args|
      What.is(args)
    }
    Plugins.register("mkwhatis") { |args|
      what,to = args.split(":",2)
      if to.nil?
        "mkwhatis #{what}:(definition)"
      else
        What.define(what,to)
      end
    }
    Plugins.register("unwhatis") { |args|
      What.undefine(args)
    }
  end
  def What.undefine(what)
    args = SQL.escape(what.downcase.delete(%Q[^a-z0-9 '",.<>/?\\|+=_-)]))
    res = SQL.query("DELETE FROM definitions WHERE term = '#{args}'")
    return "mkwhatis: #{args} undefined" if res
    return "SQL error"
  end
  def What.define(what,to)
    args = SQL.escape(what.downcase.delete(%Q[^a-z0-9 '",.<>/?\\|+=_-)]))
    to = SQL.escape(to)
    res = SQL.query("REPLACE INTO definitions SET term = '#{args}', definition = '#{to}'")
    return "mkwhatis: #{args} defined" if res
    return "SQL error"
  end
  def What.is(args)
    args.gsub!(/^\s*is\s+/,"")
    args = SQL.escape(args.downcase.delete(%Q[^a-z0-9 '",.<>/?\\|+=_-)]))
    res = SQL.query("SELECT term, definition FROM definitions WHERE term = '#{args}'")
    res.each do |term,definition|
      return "Whatis #{term}:\n  #{definition}"
    end if res
    return "SQL error"
  end
  def What.pclose
    Plugins.unregister("whatis")
    Plugins.unregister("wtf")
    Plugins.unregister("mkwhatis")
  end
end

Plugins.add(__FILE__,What)
