=begin

= rice - Ruby Irc interfaCE, Observer Mix-in

  $Id: observer.rb,v 1.4 2001/06/05 03:33:30 akira Exp $

  Copyright (c) 2001 akira yamada <akira@ruby-lang.org>
  You can redistribute it and/or modify it under the same term as Ruby.

=end

require 'observer'
require 'rice/irc'

module RICE

  class Connection
    include Observable

    ESTABLISHED = :ESTABLISHED
    CLOSED      = :CLOSED
    def add_observer(obj)
      super(obj)

      unless @subject_th
	@subject_th = regist(true) do |rq, wq|
	  begin
	    Thread.stop

	    changed
	    notify_observers(self, ESTABLISHED, nil)

	    loop do
	      x = rq.pop
	      changed
	      notify_observers(self, nil, x)
	    end

	  rescue Closed
	    changed
	    notify_observers(self, CLOSED, nil)
	    retry
	  end
	end
      end
    end # add_observer

  end # Connection

=begin

== RICE::Observer

=end

  class Observer
    def update(subject, type, message)      
      if !type
	      if message.kind_of?(Command::PRIVMSG)
      	  func = :response_for_privmsg
      	else
      	  func = 'response_for_' + message.class.to_s.sub(/^.*::/o, '').downcase
      	end
      	
      	puts "looking for #{func}"
      	
      	if respond_to?(func)
      	  send(func, subject, message)
      	else
      	  message(subject, message)
      	end
      elsif type == Connection::ESTABLISHED
      	uped(subject, message)
      elsif type == Connection::CLOSED
      	downed(subject, message)
      end
    end

    def uped(subject, message)
      raise NotImplementedError
    end

    def message(subject, message)
      raise NotImplementedError
    end

    def downed(subject, message)
      raise NotImplementedError
    end
  end # Observer

=begin

== RICE::SimpleClient

=end

  class SimpleClient < Observer
    include RICE::Command
    include RICE::Reply

    def initialize(nick, user, username, pass, *channels)
      @nick = nick
      @pass = pass
      @user = user
      @username = username
      @channels = [channels].flatten
    end

    def uped(subject, message)
      subject.push pass(@pass) if @pass
      subject.push nick(@nick)
      subject.push user(@user, '0', '*', @username)
    end

    def response_for_rpl_welcome(subject, message)
      if @channels.size > 0
	@channels.each do |ch|
	  subject.push join(ch)
	end
      end
    end

    def response_for_ping(subject, message)
      subject.push pong(message.params[0])
    end

    def message(subject, message)
      # noop
    end

    def downed(subject, message)
      # noop
    end
  end

end # RICE
