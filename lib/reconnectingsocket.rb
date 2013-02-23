require 'socket'
require 'thread'

class ReconnectNow < Exception
end

class ReconnectingSocket
  attr_reader :port, :host, :socket
  attr_reader :isup
  attr_accessor :block
  attr_accessor :timeout
  attr_accessor :log
  def initialize(host,port,&block)
    @log = false
    @host = host
    @port = port
    @timeout = 15
    @socket = nil
    @mutex = Mutex.new
    @isup = false
    @block = block if block_given?
    @reconnecting = false
    @thread = Thread.new {
      Thread.current[:name] = "#{self.class}: #{@host}"
      process
    }
  end
  def debug(*args)
    if @log.respond_to?(:puts)
      args.join("\n").split(/\n/).each do |i|
        @log.puts "#{self.class}: #{i}"
      end
    elsif @log
      args.join("\n").split(/\n/).each do |i|
        STDOUT.puts "#{self.class}: #{i}"
      end
    end
  end
  def get_input
    @socket.gets
  end
  def get_output(text)
    text.strip + "\n"
  end
  def process
    @reconnecting = true
    @isup = false
    timeout = 0
    @socket = nil
    debug "Reconnecting to #{@host} #{@port}"
    begin
      @socket = TCPSocket.new(@host,@port)
      debug "Connected to #{@host} #{@port}"
      timeout = 0
      @isup = true
      @reconnecting = false
      on_connect if respond_to?(:on_connect)

      loop do
        line = get_input
	raise ReconnectNow if line.nil?

	line.strip!
	@mutex.synchronize do
	  begin
	    Thread.new(line) { |l|
	      Thread.current[:name] = "#{self.class} incoming"
	      @block.call(l) if @block
	    }
	  rescue Exception => er
	  end
	end
      end
    rescue Exception => er
      debug "Error: #{er.to_s}"
      sleep timeout
      timeout = timeout + @timeout
      timeout = 600 if timeout > 1800 # 30 minutes max
      retry
    end
    debug "Ho hum ..."
  ensure
    @reconnecting = false
  end
  def send(text)
    return unless @isup
    begin
      str = get_output(text)
    rescue Exception => er
      debug "Error: #{err.to_s}"
      debug "  " + err.backtrace.join("\n  ")
    end
    @socket.write(str)
  rescue Exception => er
    debug "Error: #{er.to_s}"
    debug "  " + er.backtrace.join("\n  ")
    debug "Unable to send. Attempting to reconnect."
    @thread.raise ReconnectNow unless @reconnecting
  end
  alias_method :puts, :send
end
