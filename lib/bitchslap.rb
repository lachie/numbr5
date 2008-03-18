
class BitchSlap
 
  def self.bitchslap(nick, from)
    "#{from}: bitchslaps #{nick}!"
  end
end

if __FILE__ == $0
  puts BitchSlap.bitchslap('nick','martin')
end


