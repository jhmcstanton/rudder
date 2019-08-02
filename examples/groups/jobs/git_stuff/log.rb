# frozen_string_literal: true

git_resources = resources.values.select { |r| r.type == :git }

git_resources.each do |r|
  job "git log #{r.name}" do
    plan << { get: r, trigger: true }
    task = {
      task: "git log #{r.name}", config: {
        inputs: [name: r],
        platform: 'linux',
        image_resource: { type: 'docker-image', source: { repository: 'alpine/git' } },
        run: {
          path: 'git',
          args: ['--git-dir', File.join(r.name.to_s, '.git'),
                 '--no-pager', 'log']
        }
      }
    }
    plan << task
  end
end
