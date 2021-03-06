# frozen_string_literal: true

resource :rudder_git, :git do
  # The source field dictionary is available to be directly interacted with
  source[:uri]    = 'https://github.com/jhmcstanton/rudder.git'
  source[:branch] = 'master'
end

resource :timer, :time do
  # The source field can also be assigned via a method
  source(interval: '5m')
end

job :getter do
  plan [in_parallel: [{ get: :rudder_git }, { get: :timer, trigger: true }]]
end

job :hello_world do
  # Plan array can be hooked into directly
  plan << { get: :timer, trigger: true, passed: [:getter] }
  plan << { task: 'print_hello', config: {
    platform: 'linux',
    image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
    run: {
      path: 'echo',
      args: ['Hello', 'World!']
    }
  } }
end

# pipeline here allows access to previously defined pipeline components
job :cat_self do |pipeline|
  # The plan can also be appended to as a method
  plan({ get: :rudder_git, trigger: true, passed: [:getter] },
       task: 'cat this pipeline', config: {
         inputs: [name: :rudder_git],
         platform: 'linux',
         image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
         run: {
           path: 'cat',
           args: [pipeline.rudder_git.sub_path('examples/hello_world.rb')]
         }
       })
end
