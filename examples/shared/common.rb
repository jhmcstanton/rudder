# frozen_string_literal: true

resource :rudder_git, :git do
  @source[:uri]    = 'https://github.com/jhmcstanton/rudder.git'
  @source[:branch] = 'master'
end

get_rudder = { get: :rudder_git, trigger: true }

print_hello = {
  task: 'print_hello', config: {
    platform: 'linux',
    image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
    run: {
      path: 'echo',
      args: ['Hello', 'World!']
    }
  }
}

def mk_name(job_index)
  "Yo #{job_index}"
end

num_jobs = 3
(1..num_jobs).each do |i|
  name = mk_name i
  job name do |p|
    get = get_rudder.dup
    get[:passed] = [p.mk_name(i - 1)] if i > 1
    @plan << get
    @plan << print_hello
  end
end
