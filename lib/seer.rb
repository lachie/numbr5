require 'yaml'

class Seer
  def initialize
    @seen = {}
    read
  end
  
  def self.strip_nick(nick)
    nick.gsub(/^[\W_]+/,'').gsub(/[\W_]+$/,'')
  end
  
  def add_seen(nick,note,at=Time.now)
    return if nick.blank?
    @seen[Seer.strip_nick(nick)] = {:at => at, :note => note}
    write
  end
  
  def [](nick)
    @seen[Seer.strip_nick(nick)]
  end
  
  protected
  def seer_file
    File.dirname(__FILE__)+'/seen.yml'
  end
  
  def read
    if File.exist?(seer_file)
      @seen = YAML.load_file(seer_file)
    else
      @seen = {}
    end
  end
  
  def write
    open(seer_file,'w') {|f| f << @seen.to_yaml}
  end
    
    
end