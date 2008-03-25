require 'rubygems'
require 'metaid'
require 'rice/irc'
require 'rice/observer'
require 'pp'
require File.dirname(__FILE__)+'/seer'


BYEBYE  = 'byebye > '

class RICE::Message
  def nick
    prefix ? prefix.scan(/^[^!]+/o)[0] : nil
  end
end

module Numbr5
  Thread.abort_on_exception = true
  
  def self.root
    @root ||= File.expand_path(File.dirname(__FILE__)+'/../')
  end
  def self.root_path(*parts)
    File.join(root,*parts)
  end

  class << self
    def mk_observer(config)
      o = RICE::SimpleClient.new(config.nick, config.user, config.real, config.password, config.channel)
      class << o
        include RICE::Command
        include RICE::Reply

        #def response_for_rpl_welcome(subject, message)
        #  subject.push join('channel_name', 'password')
          # add as many channels as you want here.
        #end
        
        # responders

        def response_for_join(subject, message)
          
          nick = message.prefix.scan(/^[^!]+/o)[0]
          
          # I logged on
          if nick == $config.nick
            puts "I joined"
            p message
            chan = message.params[0]
            log_message(chan,'server',"joined #{chan}")
            
          # someone else logged on
          else
          
            # raise "moo" if nick == 'lachie'
            if Faces::Client.new.bother?(nick)
              puts "bothering..."
              subject.push privmsg(nick, "Hi #{nick}, I'm numbr5, the #roro bot. Check http://wiki.rubyonrails.com.au/railsoceania/show/Numbr5 for how to talk to me.")
              subject.push privmsg(nick, "Please consider signing up to the http://faces.rubyonrails.com.au for extra fun in #roro !")
            else
              puts "not bothering..."
            end
          
            self.add_seen(nick,'coming online')
            
          end
        end
        

        def response_for_privmsg(subject, message)
          if $debug
            puts "got a message"
            p subject
            p message
          end
          
          nick = message.prefix.scan(/^[^!]+/o)[0]
          chan = message.params[0]
          text = message.params[1..-1].join(' ')
          
          log_message(chan,nick,text)
          
          
          # private message sessions
          if chan == $config.nick
            puts "connected" if nick == 'freenode-connect'
            
            if session = priv_sessions[nick]
              response = session.process(self,text,nick,chan)
              
              [response].flatten.compact.each do |r|
                subject.push( (RICE::Command::PRIVMSG === r) ? r : privmsg(nick,r) )
              end
            end
          
          else
          
            case text
            when BYEBYE
              subject.push(quit) if nick == 'lachie' # ownage
            when /^#{@nick}[:,]\s+(.*)/, /^(\?[a-zA-Z]+.*)/
              args = $1.strip
              puts "someone addressed me: #{nick}, args: #{args}"
            
              response = Numbr5::Commands.process(self,args,nick,chan)
              
              [response].flatten.compact.each do |r|
                subject.push( (RICE::Command::PRIVMSG === r) ? r : privmsg(chan,r) )
              end
            
            when /^\001ACTION\s+(.*?)\001/
              response = Numbr5::Actions.process(self,$1,nick,chan)
              
              [response].flatten.compact.each do |r|
                subject.push( (RICE::Command::PRIVMSG === r) ? r : privmsg(chan,r) )
              end
            
            else
              if chan == $config.channel
                messages = self.messages
                messages.shift if messages.size > 100
                messages.push [nick,text]
              end
            end
          end
          
        rescue
          puts "something went wrong: #{$!}"
          puts $!.backtrace * "\n    "
        end
        
        
        def response_for_rpl_welcome(subject,message)
          puts "welcomed"
          super
        end
        
        def response_for_rpl_namreply(subject,message)
          if arg = message.params[3]
            arg.split(/\s+/).each do |name|
              next if name == $config.nick
              add_seen(name,'when I woke up')
            end
          end
        end
        
        def response_for_quit(subject, message)
          add_seen(message.nick,'quit')
        end
        
        def response_for_nick(subject, message)
          new_nick = message.params.first
          
          add_seen(message.nick, "metamorphosing into #{new_nick}")
          add_seen(new_nick    , "switching from #{message.nick}"  )
        end
        
        
        # support
        
        def seer
          @seer ||= Seer.new
        end
        
        def add_seen(nick,note)
          seer.add_seen(nick,note)
        end
        
        def messages
          @messages ||= []
        end
        
        def log_message(*args)
          unless @log
            @log = File.open(Numbr5.root_path('data','messages.tab'),'a')
            at_exit {
              if @log
                @log.flush
                @log.close
              end
            }
          end
          @log.puts args.join("\t")
          @log.flush
        end
        
        # make_session(nick,Sessions::Quoting,text)
        def make_session(nick,cls,text,chan)
          unless priv_sessions[nick]
            s = priv_sessions[nick] = cls.new(self,nick,text,chan)
            s.do_start
          end
        end
        
        def priv_sessions
          @priv_sessions ||= {}
        end
        
        def remove_session(nick)
          priv_sessions.delete(nick.to_s)
        end
          
        
        def update(subject, type, message)
          return super
          return super unless $debug
          
          puts "got an update: #{type}"
          puts "subject"
          pp subject
          puts "message"
          pp message
          puts

          super
        end
        
        def uped(subject,message)
          return super
          return super unless $debug
          
          puts "upped, subject"
          pp subject
          puts "message"
          pp message
          super
        end


        def message(subject, message)
          return super unless $debug
          
          puts "subject"
          p subject
          puts "message"
          p message
          
          puts
           
          super
        end

        def downed(subject, message)
        end
      end
      o
    end

    def connect(config)
      o = mk_observer(config)
      c = RICE::Connection.new(config.irc_server, 6667)
      c.add_observer(o)
      c
    end
  end
  
  module TimeHelper
    # from rails
    def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      distance_in_minutes = (((to_time - from_time).abs)/60).round
      distance_in_seconds = ((to_time - from_time).abs).round

      case distance_in_minutes
        when 0..1
          return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
          case distance_in_seconds
            when 0..4   then 'less than 5 seconds'
            when 5..9   then 'less than 10 seconds'
            when 10..19 then 'less than 20 seconds'
            when 20..39 then 'half a minute'
            when 40..59 then 'less than a minute'
            else             '1 minute'
          end

        when 2..44           then "#{distance_in_minutes} minutes"
        when 45..89          then 'about 1 hour'
        when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
        when 1440..2879      then '1 day'
        when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
        when 43200..86399    then 'about 1 month'
        when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
        when 525600..1051199 then 'about 1 year'
        else                      "over #{(distance_in_minutes / 525600).round} years"
      end
    end
  end
  
  module Commands
    class Base
      include Commands
      include TimeHelper
      
      def self.match(text)
        unless self.cmd
          return nil if text[/^\s*\?/]
          return text
        end
        $1 if text[/^\?#{self.cmd.to_s}\s*(.*)$/]
      end
      
      def self.help_text
        "    #{self.cmd ? "?#{self.cmd}" : '(default)'} #{self.help rescue '(no help)'}"
      end
      
      def initialize()
      end
      
      def privmsg(to,text)
        RICE::Command::privmsg(to,text)
      end
    end
    
    @commands = []
    @current_help = nil
    
    class << self
      def commands
        @commands
      end
      
      def help(help_text)
        @current_help = help_text
      end
      
      def choose(text)
        commands.sort_by do |c|
          p = c.priority || 0
          p == :fallback ? commands.size : p
          
        end.each do |c|
          matched = c.match(text) and return [c,matched]
        end
        
        [Usage,text]
      end
      
      def process(client,text,nick,chan)
        puts "processing: #{text}, #{nick}, #{chan}"
         
        c,rem = self.choose(text)
        c.new.process(client,rem,nick,chan)
      end

      
      def C(cmd=nil,priority=nil,&block)
        
        priority ||= commands.size
        if ch = @current_help
          @current_help = nil
        end
        
        @commands << Class.new(Base) do
          meta_def(:help     ) {ch} if ch
          meta_def(:cmd      ) { cmd    }
          meta_def(:priority ) { priority   }
          class_def(:process,&block)
        end
      end
      
    end
    
    help "help"
    Usage = C :h do |client,text,nick,chan|
      ["numbr5 is here to help!","usage: http://wiki.rubyonrails.com.au/railsoceania/show/Numbr5"]
    end
    
  end
  
  module Actions
    class Base
    end
    
    @actions = []
    class << self
      def actions
        @actions
      end
      
      def choose(text)
        @actions.each do |a|
          return a if text[a.pattern]
        end
        return nil
      end
      
      def process(client,text,nick,chan)
        c = self.choose(text)
        c.new.process(client,text,nick,chan)
      end
      
      def A(pattern,&block)
        @actions << Class.new(Base) do
          meta_def(:pattern) {pattern}
          class_def(:process,&block)
        end
      end
    end
  end

  module Sessions
    class Base
      def initialize(client,nick,text,chan)
        @client,@nick,@text,@chan = client,nick,text,chan
      end
    
      def msg(text)
        RICE::Command::privmsg(@nick,text)
      end
      
      def chan_msg(text)
        RICE::Command::privmsg(@chan,text)
      end
            
      def start_msg
        "hello, #{@nick}, please #{self.class.name}"
      end
      
      def do_start
        msg(start_msg)
      end
      
      def quit!
        @client.remove_session(@nick)
      end
      
      def tumblr_client
        t = Tumblr::Client.new
        t.signin($config.tumblr_user, $config.tumblr_pass)
        t
      end
    end
  end
end