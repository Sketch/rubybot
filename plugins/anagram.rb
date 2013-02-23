
class Anagram
  ANAGRAMMER=RubyBot.datfile("anagram/anafinder") + " " + RubyBot.datfile("anagram/words")
  def Anagram.help
    %q{Create an anagram from a set of scrabble tiles. Usage:
anagram <tiles>[:required][:minlength[.maxlength]]

required:
 tiles is a set of alphabetic characters, and '?' for a blank.
optional:
 required is a string of alphabetic characters that is needed.
 minlength and maxlength determine the size of the anagrams returned.}
  end
  def Anagram.examples
    %q{anagram fetgchs
anagram qwe:rty
anagram mth?er
anagram mat?ef:he:4.6}
  end
  def Anagram.pstart
    Plugins.register("anagram") { |args|
      Anagram.mkanagram(args)
    }
  end
  def Anagram.mkanagram(args)
    if m = /^([\?a-z]+)(:([a-z]+))?(:(\d+)(\.(\d+))?)?$/.match(args.downcase)
      tiles = m[1]
      incl = (m[3] || "")
      minlen = (m[5] || "0").to_i
      maxlen = (m[7] || "0").to_i
      maxsize = tiles.size + incl.size
      minlen = maxsize if minlen < 1
      maxlen = maxsize if maxlen < 1 
      cmd = "#{ANAGRAMMER} #{tiles}#{incl} #{minlen}"
      if incl.size > 0
        cmd = "#{cmd} | grep #{incl}"
      end
      text = `#{cmd}`
      words = text.split("\n")
      words.reject! do |i|
        i.length > maxlen
      end unless words.nil?
      if words.size == 0
        return "No anagrams found"
      else
        return "Anagrams: #{words.join(", ")}"
      end
    else
      return "Anagram usage: tiles[:include][:minlength[.maxlength]]"
    end
  end
  def Test.pclose
    Plugins.unregister("anagram")
  end
end

Plugins.add(__FILE__,Anagram)
