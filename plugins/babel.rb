require 'net/http'
require 'uri/common'
Net::HTTP.version_1_2

class Babel
  SYMBOLS= {
    "english"=>"en",
    #"chinese"=>"zh",
    "german"=>"de",
    "dutch"=>"nl",
    "greek"=>"el",
    "italian"=>"it",
    "french"=>"fr",
    #"japanese"=>"ja",
    #"korean"=>"ko",
    "portuguese"=>"pt",
    "spanish"=>"es"
    }
  TRANSLATORS = [
    #"en_zh",
    "en_fr",
    "en_de",
    "en_it",
    "en_nl",
    "en_el",
    #"en_ja",
    #"en_ko",
    "en_pt",
    "en_es",
    "el_en",
    "el_fr",
    "nl_en",
    "nl_fr",
    #"zh_en",
    "fr_en",
    "fr_de",
    "de_en",
    "de_fr",
    "it_en",
    #"ja_en",
    #"ko_en",
    "pt_en",
    "ru_en",
    "es_en"
    ]
  ENGRISH=["en_ja","ja_en"]
  def Babel.help
    %q{Translate text using babelfish.altavista.com

translate [from-language] to [to-language]:<text to translate>
translate [to-language] from [from-language]:<text to translate>
engrish <text>

Fairly self explanatory usage. -
At least one language (to or from) is required.
If a language is not given, english is assumed.
'engrish' translates the given text to japanese and back.}
  end
  def Babel.examples
    %q{translate to spanish: have a nice day
translate from spanish: tenga un dias agradable
translate french to spanish: ayez un jour plaisant
engrish all your base are belong to us}
  end
  def Babel.urltext(lang,args)
    "http://babelfish.altavista.com/babelfish/tr?tt=urltext&doit=done&intl=1&lp=#{lang}&urltext=#{args}"
  end
  def Babel.pstart
    @mutex = Mutex.new
    unless ENV['http_proxy'].nil?
      if m = /^http:\/\/(.+):(\d+)$/.match(ENV['http_proxy'])
        @proxy_host = $1
        @proxy_port = $2
      end
    end
    Plugins.register("translate") { |args|
      Babel.translate(args)
    }
    Plugins.register("engrish") { |args|
      Babel.engrish(args)
    }
  end
  def Babel.translate(args)
    @mutex.synchronize do
      from="en"
      to="en"
      what=""
      case
      when m = /^([a-zA-Z]+)\s+to\s+([a-zA-Z]+):(.*)$/.match(args)
        return "Unrecognized language" if (SYMBOLS[m[1]].nil? or SYMBOLS[m[2]].nil?)
        from=SYMBOLS[m[1]]
        to=SYMBOLS[m[2]]
        what = m[3]
      when m = /^\s*to\s+([a-zA-Z]+):(.*)$/.match(args)
        return "Unrecognized language" if SYMBOLS[m[1]].nil?
        from="en"
        to=SYMBOLS[m[1]]
        what = m[2]
      when m = /^\s*from\s+([a-zA-Z]+):(.*)$/.match(args)
        return "Unrecognized language" if SYMBOLS[m[1]].nil?
        from=SYMBOLS[m[1]]
        to="en"
        what = m[2]
      else
        return "Translate from or to what?"
      end
      lang = "#{from}_#{to}"
      if TRANSLATORS.include?(lang)
        return real_translate(lang,what)
      elsif from == to
        return "It already IS that language!"
      else
        return real_translate("en_#{to}",real_translate("#{from}_en",what))
      end
    end
  end
  def Babel.real_translate(lang,string)
    from,to = lang.split("_")
    query = urltext(lang, URI.escape(string))
    http = Net::HTTP.new("babelfish.altavista.com",80,@proxy_host,@proxy_port)

    http.start do |q|
      resp = q.get(query)
      if resp.code == "200"
        rexp = /<div style=padding:10px;( lang=\w+)?>([^<]*)<\/div>/i
        resp.body.each_line do |line|
	  if m = rexp.match(line)
	    return m[2]
	  end
	end
        return "Babelfish error"
      else
        return "Unable to connect to babelfish"
      end
    end
  end
  def Babel.engrish(args)
    @mutex.synchronize do
      return real_translate("nl_en",real_translate("en_nl",args))
    end
  end
  def Babel.pclose
    Plugins.unregister("translate")
    Plugins.unregister("engrish")
  end
end

Plugins.add(__FILE__,Babel)
