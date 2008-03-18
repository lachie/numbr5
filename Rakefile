CHANNEL = '#roro'

def each_line(&block)
  IO.foreach('data/messages.tab') do |line|
    chan,user,message = line.chomp.split("\t")
    next if chan != CHANNEL or user == 'server'
    user = user.sub(/^[\W_]+/,'').sub(/[\W_]+$/,'')
    yield user,message
  end
end

task :graph do
  dot = open('graph.dot','w')
  dot.puts %{digraph people \{
  	rankdir=LR;
  	size="8,5"
  	node [shape = circle, fixedsize=true];}
  
  users   = Hash.new {|h,k| h[k] = 0}
  user_to = Hash.new {|h,k| h[k] = Hash.new {|hh,kk| hh[kk] = 0}}
  
  each_line do |user,message|
    users[user] += 1
  end
  
  everyone_re = %r!(#{users.keys.join('|')})!
  
  each_line do |user,message|
    message.scan(everyone_re).each do |other|
      user_to[user][other.first] += 1
    end
  end
  
  (users.keys - user_to.keys).each do |name|
    user_to[name] = {}
  end
  
  user_to.each do |(from,tos)|
    if tos.empty?
      dot.puts "\t#{from};"
    else
      tos.each do |(to,weight)|
        dot.puts "\t#{from} -> #{to} [weight=#{weight}];"
      end
    end
  end
  
  dot.puts "}"
  dot.close
  
  `dot -Tpng graph.dot -O`
end