=begin

= rice - Ruby Irc interfaCE, Proxy Mix-in

  $Id: proxy.rb,v 1.3 2001/06/05 03:33:30 akira Exp $

  Copyright (c) 2001 akira yamada <akira@ruby-lang.org>
  You can redistribute it and/or modify it under the same term as Ruby.

=end

require 'rice/irc'

module RICE
  class Proxy
    def initialize(conn, host, port)
      @conn = conn
      @clients = []

      @nick = nil

      @register_process = nil  #!!!
      @greetings = nil
      @joined = nil #!!!

      @cmd_cache = nil #!!!
      @mutex = Mutex.new

      # a queue for writing to server
      @write_q = Queue.new

      @conn.regist(true, @write_q, @clients) do |srq, swq, wq, clients|
	begin
	  Thread.stop
	  c_to_s_th(srq, swq, clients, wq)

	rescue Connection::Closed
	  # server connection closed
	  @nick = nil
	  retry
	end
      end

      th = @conn.regist(true, @clients) do |srq, swq, clients|
	begin
	  Thread.stop
	  s_to_c_th(srq, swq, clients)

	rescue Connection::Closed
	  # server connection closed
	  retry
	end
      end

      tcps = TCPServer.new(host, port)

      @accept_th = Thread.new(tcps, th, @write_q) do |tcps, th, write_q|
	loop do
	  s = tcps.accept
	  c = Client.new(s, write_q)
	  @clients << c
	end
      end
    end

    def c_to_s_th(srq, swq, clients, wq)
      if @nick
	# re-connected
	@nick = nil
	if @register_process.include?(Command::PASS)
	  swq.push @register_process[Command::PASS]
	end
	if @register_process.include?(Command::NICK)
	  swq.push @register_process[Command::NICK]
	end
	if @register_process.include?(Command::USER)
	  swq.push @register_process[Command::USER]
	end
      end

      loop do
	m = wq.pop
	$stderr.puts 's<-c: ' + m.inspect if $DEBUG

	# intercepts PASS, NICK, USER, QUIT
	if m.kind_of?(Command::PASS)
	  next if @nick
	  @register_process[Command::PASS] = m

	elsif m.kind_of?(Command::NICK) && m.params[0] == @nick
	  next if @nick
	  @register_process[Command::NICK] = m

	elsif m.kind_of?(Command::USER)
	  if @nick
	    clients.select {|x| !x.registerd}.each do |c|
	      @greetings.each do |x|
		c.push x
	      end
	      @joined.each do |m, r|
		next unless r
		c.push r
		swq.push Command::names(r.params[0])
	      end
	    end
	    next

	  else
	    @register_process[Command::USER] = m
	  end

	elsif m.kind_of?(Command::JOIN)
	  @joined[m] = nil

	elsif m.kind_of?(Command::QUIT)
	  next
	end

	$stderr.puts 's<=c: ' + m.inspect if $DEBUG
	swq.push m
      end
    end
    private :c_to_s_th

    def s_to_c_th(srq, swq, clients)
      loop do
	m = srq.pop
	$stderr.puts 's->c: ' + m.to_s.inspect if $DEBUG

	if m.kind_of?(Reply::CommandResponse)
	  # @server = m.prefix
	  @nick = m.params[0]
	  if @greetings.empty? &&
	      (m.kind_of?(Reply::RPL_WELCOME)  ||
	       m.kind_of?(Reply::RPL_YOURHOST) ||
	       m.kind_of?(Reply::RPL_CREATED)  ||
	       m.kind_of?(Reply::RPL_MYINFO))
	    @greetings << m
	  end

	elsif m.kind_of?(Command::NICK)
	  @nick = m.params[0]

	elsif m.kind_of?(Command::JOIN) &&
	    m.prefix[0 .. @nick.size] == @nick + '!'
	  x = @joined.keys.find {|x| x.kind_of?(Command::JOIN)}
	  @joined[x] = m

	elsif m.kind_of?(Command::PART) &&
	    m.prefix[0 .. @nick.size] == @nick + '!'
	  x = @joined.keys.find {|x| x.kind_of?(Command::PART)}
	  @joined.delete(x)

	elsif m.kind_of?(Command::PING)
	  swq.push Command::pong x.params[0]
	end

	dead = []
	clients.dup.each do |c|
	  if c.alive?
	    $stderr.puts 's=>c: ' + m.to_s.inspect if $DEBUG
	    c.push m.dup
	    c.registerd = true if m.kind_of?(Reply::RPL_WELCOME)

	  else
	    c.close
	    dead << c
	  end
	end
	dead.each do |d|
	  clients.delete(d)
	end
      end
    end
    private :s_to_c_th

    def inspect
      '#<%s:%x>'%[self.type, self.id]
    end

    class Client
      def initialize(conn, write_to_server_q)
	@write_q = Queue.new

	@registerd = false

	# read from client and write to server
	@read_th = Thread.new(conn, write_to_server_q) do |conn, swq|
	  begin
	    while l = conn.gets
	      # $stderr.puts 's<c: ' + l.inspect if $DEBUG
	      begin
		m = Message.parse(l)
		swq.push m
	      rescue InvalidMessage, UnknownCommand
		$stderr.puts '- -: ' + l.inspect if $DEBUG
	      end
	      break if m.kind_of?(Command::QUIT)
	    end

	  rescue IOError
	  ensure
	    conn.close
	  end
	end

	# write to client
	@write_th = Thread.new(conn, @write_q) do |conn, write_q|
	  begin
	    loop do
	      l = write_q.pop
	      # $stderr.puts 's>c: ' + l.to_s.inspect if $DEBUG
	      conn.print l.to_s
	    end

	  rescue IOError
	  ensure
	    conn.close
	  end
	end
      end
      attr :registerd, true

      def push(m)
	if alive?
	  @write_q.push m
	else
	  nil
	end
      end

      def alive?
	@read_th.alive? && @write_th.alive?
      end

      def close
	@read_th.exit
	@write_th.exit
      end

      def inspect
	'#<%s:%x alive=%s>'%[self.type, self.id, alive?]
      end
    end # Client

  end # Proxy
end # RICE
