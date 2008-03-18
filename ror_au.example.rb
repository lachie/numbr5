require 'hpricot'
require 'open-uri'
require 'pp'
require 'insult'
require 'ri'
require 'bitchslap'
require 'active_support'
require 'seer'


module Numbr5
  module Commands
    
    extend TimeHelper
    
    def tumblr_client
      t = Tumblr::Client.new
      t.signin($config.tumblr_user, $config.tumblr_pass)
      t
    end
    
    # pinched from erb
    def h(s)
      s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end
    
    help "get a snippet of ancient unix wisdom"
    C :f do |client,text,nick,chan|
      f = $debug ? "no fortune :'(" : `fortune`.split($/)
      f[0] = "#{nick}: #{f[0]}"
      f
    end
    
    help "[to_nick] insult to_nick, old skool (default to_nick=you)"
    C :i do |client,text,nick,chan|
      Insulter.insult(text.blank? ? nick : text)
    end
    
    C :s do |client,text,nick,chan|
      cooked = (text || '').gsub(/^[\W_]+/,'').gsub(/[\W_]+$/,'')
      
      return if cooked.blank?
      
      if seen = client.seer[cooked]
        msg = "last saw #{text} #{seen[:note]}"
        msg << " #{distance_of_time_in_words(seen[:at].getlocal,Time.now)} ago" if seen[:at]
        
        [ msg ]
      else
        text.strip == $config.nick ? 'myself' : text
        ["I've nevah seen #{text}"]
      end
    end
    
    help "ri [method]"
    C :ri do |client,text,nick,chan|
      blurb = Ri.find(text)
      ["ri for #{text} sent to #{nick}",privmsg(nick.strip, blurb)]
    end
    
    help "bs [to_nick]"
    C :bs do |client,text,nick,chan|
      BitchSlap.bitchslap(text.blank? ? nick : text, nick)
    end
    
    def parse_quote(text)

      if text[/(\d+),(\d+)(.*?)$/]
        lines = $1
        back  = $2
        title = $3
      elsif text[/(\d+)(.*?)$/]
        back  = 0
        lines = $1
        title = $2
      end
      
      [
        (lines.to_i rescue 0),
        (back.to_i  rescue 0),
        (title.lstrip rescue '')
      ]
    end
    
    help "quote your peeps (no args)"
    C :q do |client,text,nick,chan|
      client.make_session(nick,Sessions::Quoting,text,chan)
    end
    
    help "num_lines[,back] [title] - quote n lines, starting m lines back"
    C :qx do |client,text,nick,chan|
      begin
        lines,back,title = parse_quote(text)
        conversation = client.messages[back,lines].reverse.map {|l| l * ': '} * $/
        
        unless $offline
          post_link = tumblr_client.create_tumble('conversation',{
                 'conversation' => conversation,
                 'title' => "#{title} (quoted by #{nick} on #{chan})"
                })
              
          "#{nick}: posted to #{post_link}"
        else
          "no intarweb :'( ... #{nick} posted #{conversation}"
        end
      rescue
        "#{nick}: failed to post your quote: #{$!}"
      end
    end
    
    
    
    help "who is that? - ?w [nick]"
      C :w do |client,text,nick,chan|
        begin
          f = Faces::Client.new
          f.url_for_nick(text)
        rescue
          puts "?w failed: #{$!}"
          ["#{text} not found.",privmsg(text.strip,"hey, #{text}, sign up to http://faces.rubyonrails.com.au so ppl can find out who you are, owe you beers etc.")]
        end
    end
    
    help "post: I can understand some different kinds of input - http://link [caption] (flickr photo pages," +
      "youtube video pages, just a link)" +
      " - quotes (you quoting someone else, you quoting you)"
    C() do |client,text,nick,chan|
      return "unknown command #{text}" if text.strip[0] == ??
      
      begin
        
        unless $offline
          t = tumblr_client
          post_link = t.create_automatic_tumble(text,nick,chan)
          "#{nick}: posted to #{post_link}"
        else
          "no intarweb :'("
        end
      rescue
        "#{nick}: I couldn't post your tumble :( #{$!}"
      end
    end
    
  end
  
  module Actions
    
    OWE_RE = /^
      (thanks|owes)
      \s+
      ([\w_\^]+)
      \s+
      for
      \s+
      (.*?)
    $/x
    A(OWE_RE) do |client,text,nick,chan|
      begin
        f = Faces::Client.new
        text[OWE_RE]

        response = f.thank(nick,$2,$3)

        "#{nick}: #{response}"
      rescue
        "#{nick}: i couldn't owe your beer: #{$!}"
      end
    end
  end
end

module Tumblr
  module Interpreters
    
    # pinched from erb
    def h(s)
      s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end
    
    FLICKR_RE = /
      ^
      http:\/\/
      (?:\w+\.|)
      flickr\.com\/photos\/
      \w+
      \/
      (\d+)
    /x
    
    help ""
    I FLICKR_RE do |client,text,nick,chan|
      url,caption = text.split(/\s+/,2)
      
      url[FLICKR_RE]
      photo_id = $1
      
      doc = Hpricot(open("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{$config.flickr_api_key}&photo_id=#{photo_id}"))
      source = (doc % "size[3]")['source']
      
      ['photo',{
        :source => source,
        :caption => "<a href='#{url}'>#{h(caption)}</a> (#{nick} on #{chan})"
      }]
    end
    
    YOUTUBE_RE = /
      ^
      http:\/\/
      .*?
      youtube\.com
    /x 
    I YOUTUBE_RE do |client,text,nick,chan|
      url,caption = text.split(/\s+/,2)
      ['video',{
        :embed => url,
        :caption => "<a href='#{url}'>#{h(caption)}</a> (#{nick} on #{chan})"
      }]
    end
    
    IMAGE_EXT_RE = /(png|jpe?g|gif)$/
    
    I /^http:\/\// do |client,text,nick,chan|
      url,caption = text.split(/\s+/,2)
      
      if url[IMAGE_EXT_RE]
        ['photo', {
          'source' => url,
          'description' => "#{h(caption)} (#{nick} on #{chan})" }]
      else
        ['link', {
          'url' => url,
          'description' => "#{h(caption)} (#{nick} on #{chan})" }]
      end
    end
    
    I(/^([\w_]+): /) do |client,text,nick,chan|
      text[pattern]
      quoted = $1
      text.sub!(pattern,'')
      
      ['quote',{
        'quote' => h(text),
        'source' => "#{quoted} quoted by #{nick} on #{chan}"
      }]
    end
    
    I() do |client,text,nick,chan|
      ['quote',{
        'quote' => h(text),
        'source' => "#{nick} on #{chan}"
      }]
    end
  end
end

module Numbr5
  module Sessions

    class Quoting < Base
      
      attr_accessor :start, :end
      
      def initialize(*args)
        super
        @messages = @client.messages.dup
        
        @start ||= 1
        @end   ||= max_span
      end
      
      def prompt
        # "quotr: n-m to set start and end lines, [s]how n to show window of 10 lines at offset #, [p]ost, [q]uit"
        "quotr: n-m to set start and end lines, [s]how the lines, [r]eset the span, [p]ost, [q]uit"
      end
      
      def max_span
        [10,@messages.size].min
      end
      
      def span_start
        @messages.length - max_span
      end
      
      def window_end
        span_start + @end - 1
      end
      
      def window_start
        span_start + @start - 1
      end
      
      def start=(start)
        @start = start < 1 ? 1 : start
      end
      
      def end=(e)
        @end = e > max_span ? max_span : e
      end
      
      def span
        @messages[window_start..window_end]
      end
      
      def window_messages
        i = 0
        span.compact.map do |m|
          i += 1
          "#{i} #{m * ' '}"
        end
      end
      
      def do_start
        puts "calling start"
        [ "quotr", window_messages(), prompt ].flatten.map {|m| msg(m)}
      end
      
      def post
        conversation = span.map {|l| l * ': '} * $/
        
        post_link = tumblr_client.create_tumble('conversation', {
          'conversation' => conversation,
          'title' => "(quoted by #{@nick} on #{@chan})"
        })
      end
    
      def process(client,text,nick,chan)
        case text
        when /^q/
          quit!
          "bye..."
          
        when /^s/
          [window_messages,prompt].flatten
          
        when /(\d+)\s*-\s*(\d+)/
          @start = $1.to_i
          @end   = $2.to_i
          [window_messages,prompt].flatten
        
        when /^r/
          @start ||= 0
          @end   ||= max_span
          [window_messages,prompt].flatten
          
        when /^p/
          link = self.post
          quit!
          ["posted to #{link}, bye...",chan_msg("#{@nick}: posted quote to #{link}")]
          
        end 
      end
    end
  end
end
