# frozen_string_literal: true

time_resources = resources.values.select { |r| r.type == :time }

time_resources.each do |r|
  job :hello do
    plan << { get: r.name, trigger: true }
    plan << { task: 'print_hello', config: {
      platform: 'linux',
      image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
      run: {
        path: 'echo',
        args: ['Hello']
      }
    } }
  end
end
