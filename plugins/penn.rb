
class Penn
  def Penn.help
    %q{This bot needs 2 objects.

1) The Globals object.
  - If your rubybot is to be hidden, you might want to power this see all.
  - Place this in your globals room.
  - Use the code on 'examples penn' if you wish:
  - @pemit *<rubybot>=<COMMAND:help:%#>penn
  - Commands are called via u(call,commandname,arguments)
  - The "+rbot" generic command, which can call any command, is provided
  - The example for the 'fortune' command is also provided.
  - For more help, type: +rbot help

2) Response object
  - Rubybot answers all queries with the command:
    respond/<commandname> <dbref>=<text>
  - The code given will only forward all responses in raw format.
  - I will soon write a better method that uses a template response
    method so you can change the output format of the commands.
}
  end
  def Penn.examples
    %q{@create Rubybot Globals
@desc rubybot globals = This object contains global $-commands for use by players.

&available rubybot globals=if(gt(conn(%vb,0),1,0[pemit(%#,%vn not available)])
&call rubybot globals=pemit(%vb,<COMMAND:[u(format,%0)]:%#>[u(format,%1)]
@vb rubybot globals=SET THIS TO THE DBREF OF THE BOT CHARACTER
@vn rubybot=Rubybot
&cmd.rbot globals=$+rbot *:th if(u(available),u(call,before(%0,=),after(%0,=))
@set rubybot globals=!no_command

@create Rubybot Response
@desc rubybot response=This is the response object with which rubybot gives all it's responses.
&cmd.respond rubybot response=$respond/* *=*:@pemit %1=%2
@set rubybot response=!no_command
}
  end
  def Penn.pstart
  end
  def Penn.pclose
  end
end

Plugins.add(__FILE__,Penn)
