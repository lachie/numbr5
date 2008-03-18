=begin

= rice - Ruby Irc interfaCE, DRb support

  $Id: drb.rb,v 1.1 2001/06/05 09:04:31 akira Exp $

  Copyright (c) 2001 akira yamada <akira@ruby-lang.org>
  You can redistribute it and/or modify it under the same term as Ruby.

=end

require 'rice/irc'
require 'rice/observer'
require 'drb/drb'
require 'thread'

module RICE

=begin

== RICE::DRb

=end

  module DRb

=begin

== RICE::DRb::Front

=end

    class Front
      include ::DRb::DRbUndumped

=begin

--- RICE::DRb::Front::new(read_q, conn)

=end

      def initialize
	@read_q = Queue.new
	@conn = nil
      end
      attr :conn, true

=begin

--- RICE::DRb::Front#push(message)

=end

      def push(message)
	if @conn # XXX
	  @conn.push message
	else
	  nil
	end
      end

=begin

--- RICE::DRb::Front#pop

=end

      def pop
	@read_q.pop
      end

      def read_q_push(message)
	@read_q.push message
      end
    end # Front

    class Server < SimpleClient
      def initialize(uri, acl, nick, user, username, pass, *channels)
	@front = Front.new
	@drb = ::DRb.start_service(uri, @front, acl)
	super(nick, user, username, pass, *channels)
      end

      def uped(subject, message)
	super

	@front.conn = subject
	@drb.thread.run unless @drb.alive?
      end

      def message(subject, message)
	@front.read_q_push(message)
      end

      def downed(subject, message)
	@front.conn = nil
      end
    end

    def start_service(conn, uri, acl = nil, raise_on_close = false, *args)
      conn.regist(raise_on_close, args) do |rq, conn, *args|
	loop do
	  begin
	  rescue Connection::Closed
	  end
	  Thread.stop
	end
      end
    end
  end # DRb

end # RICE

