#!/bin/env ruby

# 
def Object.const_missing(sym)
  nil
end

# pwd
RBOT_DIR = File.expand_path(File.dirname(__FILE__))

# add lib/ to require path.
$: << File.join(RBOT_DIR,'lib')

class RubyBot
  PASSPHRASE="COMMAND"
  HOST="localhost"
  PORT="4201"
  LOGIN="1234"
end

require 'pcall'
require 'logger'
require 'timer'
require 'mushsocket'
require 'plugins'

class RubyBot
  # config.rb attributes.

  @accounts = Hash.new(nil)
  @datpath = File.join(RBOT_DIR,"dats")
  def RubyBot.datfile(filename)
    File.join(@datpath,filename)
  end
  def RubyBot.read_dat(filename)
    IO.readlines(File.join(@datpath,filename)).join
  end
  def RubyBot.save_dat(filename,what)
    File.open(File.join(@datpath,filename),'w') { |f|
      f.puts what
    }
  end
  def RubyBot.handle(command,user,args)
    begin
      result = Plugins.call(command,args)
      @socket.send("respond/#{command} #{user}=#{result}")
    rescue Exception => er
      puts "Error: #{er}"
      puts "  " + er.backtrace.join("\n  ")
    end
  end
  def RubyBot.init
    rx = /^<#{PASSPHRASE}:([^>:]+):(#\d+)>(.*)$/
    puts "Passphrase: #{PASSPHRASE}"
    puts "host: #{HOST}:#{PORT} with #{LOGIN}"
    @socket = MushSocket.new(HOST,PORT,LOGIN) { |line|
      line.strip!
      if (ma = rx.match(line))
        Thread.new(ma) { |m|
          command, user, args = m[1,3]
          args.strip!
          command.downcase!
          command.delete!('^a-z0-9')
          handle(command,user,args)
	}
      end
    }
  end
end

# Now we include 'config'
require 'config'

if File.basename($0) == File.basename(__FILE__)
  l = Logger.new("mudbot.log")
  STDOUT = l
  STDERR = l
  Plugins.load_all
  RubyBot.init
  Timer.run
end
