class Ri
  
  def self.find(target, lines=10)
    `ri #{target}`.split("\n")[0...lines]
  end
end

if __FILE__ == $0
  puts Ri.find('Array')
end
