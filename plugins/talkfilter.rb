
class Talkfilter
  TALKFILTER_PATH ||='/usr/bin'
  TALKFILTERS    ||= %w{
        b1ff brooklyn chef cockney drawl fudd funetak
        jethro jive kraut pansy postmodern valspeak warez
    }
  def Talkfilter.help
    %q{Make your sentence wacky

talkfilter <filter> <text>

Runs <text> through <filter> to get funky speak.
talkfilter with invalid or no filter returns list of filters}
  end
  def Talkfilter.examples
    %q{talkfilter cockney What are you doing, you foolish american?
talkfilter warez I got some apps you might want}
  end
  def Talkfilter.pstart
    Plugins.register("talkfilter") { |args|
      Talkfilter.filter(args)
    }
  end
  def Talkfilter.filter(args)
    arg = args.gsub("="," ").delete('&;[]*^\'"')
    talkfilter,what = arg.split(" ",2)
    if TALKFILTERS.include?(talkfilter)
      tfilter = IO.popen("#{TALKFILTER_PATH}/#{talkfilter}","r+")
      tfilter.puts what
      tfilter.close_write
      result = tfilter.readlines.join().strip
      Process.wait
      return result
    else
      return "Available talk filters: #{TALKFILTERS.join(", ")}"
    end
  end
  def Talkfilter.pclose
    Plugins.unregister("talkfilter")
  end
end

Plugins.add(__FILE__,Talkfilter)
