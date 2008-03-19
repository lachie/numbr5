CHANNEL = '#roro'

def each_line(&block)
  IO.foreach('data/messages.tab') do |line|
    chan,user,message = line.chomp.split("\t")
    next if chan != CHANNEL or user == 'server'
    user = user.sub(/^[\W_]+/,'').sub(/[\W_]+$/,'')
    yield user,message
  end
end

task :get_messages do
  system 'scp lachie.info:numbr5/data/messages.tab data/messages.tab'
end

task :graph do
  dot = open('graph.dot','w')
  dot.puts %{digraph people \{
    ratio=auto;
    size="12,12";
    overlap=scale;
    splines=true;
    sep=.1;
    margin=".1,.1";
    

  	node [shape = circle, fixedsize=true, fontcolor=red, fontname=Helvetica, fontsize=10, color=blue];
  	edge [arrowsize=0.35, len=2.0, color=gray];
  	}
  
  users   = Hash.new {|h,k| h[k] = 0}
  user_to = Hash.new {|h,k| h[k] = Hash.new {|hh,kk| hh[kk] = 0}}
  total   = 0
  
  each_line do |user,message|
    users[user] += 1
    total       += 1
  end
  
  everyone_re = %r!(#{users.keys.join('|')})!
  
  each_line do |user,message|
    message.scan(everyone_re).each do |other|
      user_to[user][other.first] += 1
    end
  end
  
  scale = 4.0
  max = 2.0
  min = 0.1
  users.each do |(from,count)|
    width = ((count / total.to_f) * (max-min)) + min
    dot.puts "\t#{from} [width=#{width}];"
        
    tos = user_to[from] || {}
    
    tos.each do |(to,weight)|
      dot.puts "\t#{from} -> #{to} [weight=#{weight*scale}];"
    end
  end
  
  dot.puts "}"
  dot.close
  
  puts `neato -v -s100 -Tpng graph.dot -O`
end