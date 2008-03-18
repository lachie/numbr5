require 'curb'
require 'curb_core'
require 'hash_hasher'
require 'hpricot'
require 'open-uri'
require 'yaml'

module Faces
  class Client
    def initialize
      @host = $config.faces_url
      
      @c = Curl::Easy.new("#{@host}/thankyous") do |c|
        c.enable_cookies = true
        c.cookiejar = "/tmp/faces.cookie"
        c.verbose = true # turn off
      end
    end
    
    #def self.client 
    #end
    
    def thank(from,to,reason)
      @c.url = "#{@host}/thankyous"

      params = {:from => from, :to => to, :reason => reason}
      params[:hash] = HashHasher.mk_hash($config.faces_secret,params)
      
      args = params.inject([]) {|args,(k,v)| args << Curl::PostField.content(k.to_s,v) }
      @c.http_post args
      
      @c.body_str
    end
    
    def bother?(nick)
      begin
        search(nick)
      rescue
        if should_bother?(nick)
          bothered(nick)
          true
        else
          false
        end
        
      else
        false
      end
      
    end
    
    def botherfile
      @botherfile ||= Numbr5.root_path('data','bothers.yml')
    end
    
    def bothers
      @bothers ||= (YAML.load_file(botherfile) rescue {})
    end
    
    def should_bother?(nick)
      ! bothers[nick]
    rescue
      true
    end
    
    def bothered(nick)
      bothers[nick] = true
      open(botherfile,"w") {|f| f << bothers.to_yaml}
    end
    
    def search(nick)
      open("#{@host}/users?nick=#{URI.escape(nick.strip)}")
    end
    
    def url_for_nick(nick)
      ror = Hpricot.XML(search(nick))
      user_id = ror.search("//user/id").first.inner_text.to_s
      "#{@host}/users/" + user_id
    end
  end
end
    
    