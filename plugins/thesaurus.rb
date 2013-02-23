require 'open-uri'

class Thesaurus
  def Thesaurus.help
    %q{Fetch synonyms for a word from www.m-w.com

synonyms <word1>[ word2]

Fairly self explanatory usage.
Returns synonyms for all words given.
And wouldn't you know it}
  end
  def Thesaurus.examples
    %q{synonyms pedestrian
synonyms power
synonyms cat spear}
  end
  def Thesaurus.pstart
    @mutex = Mutex.new
    Plugins.register("synonyms") { |args|
      Thesaurus.synonymize(args)
    }
    @reg = /<b>Synonyms <\/b>(.+?)<br>/
  end
  def Thesaurus.synonymize(args)
    @mutex.synchronize do
      words = args.downcase.delete('^a-z ').split
      synonyms = []
      words.each do |word|
        str = open('http://www.m-w.com/cgi-bin/thesaurus?book=Thesaurus&va=' + word).read
        str.scan(@reg) do |mtch|
          syns = mtch[0]
          syns.gsub!(/<(.*?)>/,"")
          syns.gsub!(/ \d+/,"")
          syns.gsub!(/\|+/,"")
          syns.downcase!
          synonyms << "#{word}: #{syns}"
        end
      end
      return synonyms.join("\n") if synonyms.length > 0
      return "No synonyms found"
    end
  end
  def Thesaurus.pclose
    Plugins.unregister("synonyms")
  end
end

Plugins.add(__FILE__,Thesaurus)
