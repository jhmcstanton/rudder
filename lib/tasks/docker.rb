# frozen_string_literal: true

task :docker_up do
  puts 'Starting concourse in background, this will take a minute..'
  Process.spawn('docker-compose up', out: '/dev/null', err: '/dev/null')
  sleep 20 # Just give it a chance to start
end

task :docker_down do
  system('docker-compose down')
end
