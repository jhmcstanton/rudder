# frozen_string_literal: true

task = {
  task: 'git log', config: {
    # input still needed
    platform: 'linux',
    image_resource: { type: 'docker-image', source: { repository: 'alpine/git' } },
    run: {
      path: 'find',
      args: ['.', '-iname', '*.git', '-exec',
             'git', '--git-dir', '{}', '--no-pager', 'log', ';']
    }
  }
}
@plan << task
