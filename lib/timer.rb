# timer.rb
#
# For a wee timer class
#

require 'thread'

class Timer
  @triggers = Hash.new(nil)
  def Timer.triggers
    @triggers
  end
  def Timer.minutes
    @minutes
  end
  def Timer.add(name,period,&blck)
    return unless period.to_i > 0
    if block_given?
      @triggers[name] = [period.to_i,blck]
    else
      @triggers.delete(name) if @triggers.has_key?(name)
    end
  end
  def Timer.delete(name)
      @triggers.delete(name) if @triggers.has_key?(name)
  end
  def Timer.pcall
    begin
      return yield
    rescue Exception => er
      puts "Error in Timer: #{er}"
      puts '  ' + er.backtrace[0]
      return nil
    end
  end
  def Timer.run
    Thread.current[:name] = 'Timer thread'
    @minutes = 1
    loop do
      sleep 60
      @triggers.each do |key,val|
        period,blck = val
        pcall { blck.call } if ((@minutes%period) == 0)
      end
      @minutes = @minutes + 1
    end
  end
end
