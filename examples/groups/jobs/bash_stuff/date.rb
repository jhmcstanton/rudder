time_resources = @resources.values.select{ |r| r.type == :time}

time_resources.each do |r|
  job :date do
    @plan << { get: r.name, trigger: true}
    @plan << {task: 'print_date', config: {
                platform: 'linux',
                image_resource: {type: 'docker-image', source: {repository: 'busybox'}},
                run: {
                  path: 'date',
                }
              }
    }
  end
end
