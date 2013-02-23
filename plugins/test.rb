
class Test
  def Test.help
    %q{This is just a test plugin. Yay.

test <text>

Will echo <text> back at you.}
  end
  def Test.examples
    %q{test you are stupid
test I voted for the other guy}
  end
  def Test.pstart
    Plugins.register("test") { |args|
      "Test suceeded! You typed: #{args}"
    }
  end
  def Test.pclose
    Plugins.unregister("test")
  end
end

Plugins.add(__FILE__,Test)
