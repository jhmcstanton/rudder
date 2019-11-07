# frozen_string_literal: true

vals = vars[:some_values]

resource :timer, :time do
  # The source field can also be assigned via a method
  source(interval: '5m')
end

vals.each do |val|
  job "echo #{val}" do
    plan << { get: :timer, trigger: true }
    plan << { task: 'print', config: {
      platform: 'linux',
      image_resource: { type: 'docker-image', source: { repository: 'busybox' }},
      run: {
        path: 'echo',
        args: ['Value: ', val]
      }
      }
    }
  end
end
