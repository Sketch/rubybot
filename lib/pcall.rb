# timer.rb
#
# For a wee timer class
#

class Object
  def pcall
    begin
      return yield
    rescue Exception => er
      puts "pcall: #{er}"
      puts '  ' + er.backtrace[0]
      return nil
    end
  end
end
