resource :rudder_git, :git do
  @source[:uri]    = 'https://github.com/jhmcstanton/rudder.git'
  @source[:branch] = 'master'
end

get_rudder = { get: :rudder_git, trigger: true }

print_hello = {
  task: 'print_hello', config: {
    platform: 'linux',
    image_resource: {type: 'docker-image', source: {repository: 'busybox'}},
    run: {
      path: 'echo',
      args: ['Hello', 'World!']
    }
  }
}

def mk_name(i)
  "Yo #{i}"
end

num_jobs = 3
(1..num_jobs).each do |i|
  name = mk_name i
  job "Yo #{i}" do |p|
    get = get_rudder.dup
    if i > 1
      get[:passed] = [p.mk_name(i - 1)]
    end
    @plan << get
    @plan << print_hello
  end
end
