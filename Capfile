# load 'deploy' if respond_to?(:namespace) # cap2 differentiator
# load 'config/deploy'

role :app, "lachie.info"

set :app_path, "/home/lachie/numbr5"

desc "deploy n5"
task :deploy do
  update_code
  copy_implementation
  restart
end

desc "git pull"
task :update_code do
  run "cd #{app_path} ; git pull"
end

desc "copies the example implementation to the real implementation"
task :copy_implementation do
  run "cd #{app_path} ; cp ror_au.example.rb ror_au.rb"
end

def cmd(cmd)
  "cd #{app_path} ; ./bin/numbr5 #{cmd} -- -n numbr5rc -f ror_au.rb"
end

desc "restart"
task :restart do
  run cmd('stop') + " && " + cmd('start')
end

desc "status"
task :status do
  run cmd('status')
end

desc "start"
task :start do
  run cmd('start')
end

desc "stop"
task :stop do
  run cmd('stop')
end

desc "cold"
task :cold do
  run cmd('start')
end