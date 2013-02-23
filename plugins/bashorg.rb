require 'open-uri'
require 'cgi'

class Bashorg < Plugin
  def Bashorg.help
    <<EOF
This is the Bashorg plugin. It will only do one thing:

bash # To get a random quote above score 1
bash <num> # To get a specific quote
EOF
  end
  def Bashorg.examples
    <<EOF
bash
bash  11397
EOF
  end
  def Bashorg.pstart
    Plugins.register('bash') { |cmd,args,user|
      get_quote(args)
    }
    @quotes ||= Hash.new
  end
  def Bashorg.get_quote(quote = nil)
    quote ||= ''
    quote.delete!('^0-9')

    if quote.size.nonzero? and @quotes.has_key?(quote)
      return @quotes[quote]
    end

    quote = 'random1' if quote.size.zero?

    # Pull it off the server
    rss = open("http://bash.org/?#{quote}").read
    subj,quote = rss.scan(/<p class="quote">(.*?)<\/p>.*?<p class="qt">(.*?)<\/p>/m)[0]

    quote = CGI.unescapeHTML(quote).gsub(/&nbsp;/,' ')
    quote.delete!("\r")
    quote.gsub!(/<br \/>/,'')

    subj =~ /#(\d+)/
    title = $1

    subj =~ /\((\d+)\)/
    score = $1

    quote.gsub!(/\n+/,"\n  ")

    s = "  http://bash.org/?#{title} - (#{score})\n\n  #{quote}\n"
    @quotes[title] = s
  rescue Exception => er
    "err: #{er.message}"
  end
  def Bashorg.pclose
    Plugins.unregister('bash')
  end
end

Plugins.add(__FILE__,Bashorg)
