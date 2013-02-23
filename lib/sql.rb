# sql.rb
#

require 'mysql'

class Mutex
  def rec_synchronize
    @rec_threads = [] if @rec_threads.nil?
    begin
      if (@rec_threads.empty? || @rec_threads[0] != Thread.current)
        lock
      end
      @rec_threads.push Thread.current
      yield
    ensure
      @rec_threads.pop
      unlock if @rec_threads.empty?
    end
  end
end

class SQL
  @mutex  = Mutex.new
  def SQL.synchronize
    @mutex.rec_synchronize do
      yield
    end if block_given?
  end
  def SQL.escape(x)
    Mysql.escape_string(x)
  end
  def SQL.query(q)
    @mutex.rec_synchronize do
      myretry = false
      begin
        res = @m.query(q)
        return res
      rescue Exception => er
        @m = Mysql.new(HOST,USER,PASS,DB)
        myretry = !myretry
        retry if myretry
        return nil
      end
    end
  end
end
