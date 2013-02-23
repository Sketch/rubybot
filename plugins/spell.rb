
require 'raspell'

class Spell
  DICT ||= "en_US"
  def Spell.help
    %q{Check your spelling

spell <sentence>
spel <sentence>

"spel" will check, but will not return suggestions.
"Spell" will spell check the sentence and return suggestions.}
  end
  def Spell.examples
    %q{spell this sentence is good
spell ths setence is veyr bad
spel I donnt want suggestins for ths bad setence}
  end
  def Spell.pstart
    dicts = Aspell.list_dicts
    puts "No Dictionary installed." if dicts.empty?
    dcode, jargon, size = nil
    dicts.each do |dict|
      if dict.name == DICT
        dcode, jargon, size = dict.code, dict.jargon, dict.size
      end
    end
    puts "No such dictionary #{DICT}" unless dcode
    @aspell = Aspell.new(dcode, jargon, size.to_s)
    @aspell.suggestion_mode = Aspell::FAST
    @mutex = Mutex.new

    Plugins.register("spell") { |args|
      Spell.check(args,true)
    }
    Plugins.register("spel") { |args|
      Spell.check(args,false)
    }
  end
  def Spell.check(string,dosuggs=true)
    @mutex.synchronize do
      misspelled = @aspell.list_misspelled([string])
      if (misspelled && !misspelled.empty?)
        badwords = []
        suggs = []
	str = []
	misspelled.uniq.each do |word|
	  badwords << word
	  goodwords = @aspell.suggest(word)
          unless (goodwords.nil? or goodwords.empty?)
	    str << "#{word}: #{goodwords.join(", ")}"
	  end if dosuggs
	end
	str.unshift "Misspelled words: #{badwords.join(", ")}"
	return str
      else
        return "Spell: '#{string}' is good."
      end
    end
  end
  def Spell.pclose
    Plugins.unregister("spel")
    Plugins.unregister("spell")
  end
end

Plugins.add(__FILE__,Spell)
