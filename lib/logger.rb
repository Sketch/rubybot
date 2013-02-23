#!/bin/env ruby
# logger

class Logger
  def initialize(logname)
    @file = File.open(logname,"w")
    @mutex = Mutex.new
  end
  def puts(args)
    @mutex.synchronize do
      @file.puts(args)
      @file.flush
    end
  end
end
