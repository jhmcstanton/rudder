# frozen_string_literal: true

git_resources = resources.values.select { |r| r.type == :git }

git_resources.each do |r|
  job "ls #{r.name}" do
    plan << { get: r, trigger: true }
    task = {
      task: "ls #{r.name}", config: {
        inputs: [name: r],
        platform: 'linux',
        image_resource: { type: 'docker-image', source: { repository: 'alpine/git' } },
        run: {
          path: 'ls',
          args: [r]
        }
      }
    }
    plan << task
  end
end
