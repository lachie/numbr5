#!/usr/bin/env ruby
require 'rubygems'
require 'curb'
require 'curb_core'
require 'active_support'
require 'cgi'

module Tumblr
  class Client
    attr_accessor :c
    
    def initialize
      @host = "www.tumblr.com"
      @c = Curl::Easy.new("#{@host}/api/write") do |c|
            c.enable_cookies = true
            c.cookiejar = "/tmp/tumblr.cookie"
            c.verbose = true # turn off
      end
      @c
    end

    def signin(username, password)
      @email = username
      @password = password
    end

    def grab_dashboard # as a test
      @c.url = "#{@host}/dashboard"
      @c.http_get
    end

    def create_tumble(type, attr_hash)
      @c.url = "#{@host}/api/write"
      args = [
        Curl::PostField.content('email', @email), 
        Curl::PostField.content('password', @password), 
        Curl::PostField.content('generator', 'numbr5 bot'),
        Curl::PostField.content('type', type)
      ]
      attr_hash.each do |k,v|
        args.push Curl::PostField.content(k.to_s, v)
      end
      @c.http_post "#{@host}/api/write", args
      "http://roro.tumblr.com/post/#{@c.body_str}"
    end

    def create_automatic_tumble(text, nick, chan)
      kind,details = Interpreters.interpret(self,text,nick,chan)
      
      puts "creating a tumble: #{kind}, #{details.inspect}"
      
      create_tumble(kind,details) if kind and details
    end
  end

  module Interpreters
    
    class Base
      include Interpreters
      
      def initialize()
      end
      
      def match(text)
        self.class.match(text)
      end
    end
    
    @current_help = nil
    @interpreters = []
    class << self
      def interpreters; @interpreters; end
      
      def help(help_text)
        @current_help = help_text
      end
    
      def choose(text,nick,chan)
        interpreters.each do |i|
          return i if i.match(text,nick,chan)
        end
        nil
      end
      
      
      def interpret(client,text,nick,chan)
        i = choose(text,nick,chan)
        return i.new.interpret(client,text,nick,chan) rescue nil
      end
    
      def I(pattern=nil,&block)
        if ch = @current_help
          @current_help = nil
        end
        
        @interpreters << Class.new(Base) do
          class_def(:interpret,&block)
          meta_def(:help) {ch}
          if pattern
            meta_def(:match) {|text,_,_| text[pattern] }
            class_def(:pattern) {pattern}
          else
            meta_def(:match) {|_,_,_| true }
          end
        end
      end
    end
    

    
  end

end