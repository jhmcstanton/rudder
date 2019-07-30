common = load 'common.rb'

resource :timer, :time do
  @source[:interval] = '30m'
end

# Borrow any git resources defined in common
git_resources = common.resources.select{ |name, r| r.type == :git}
@resources.merge! git_resources

job 'Just borrowing the git resource' do
  git_names = git_resources.keys
  gets = git_names.map { |name| { get: name } }
  gets << { get: :timer, trigger: true }
  plan [in_parallel: gets]

  task = {
    task: 'ls all the gits', config: {
      platform: 'linux',
      image_resource: {type: 'docker-image', source: {repository: 'busybox'}},
      run: {
        path: 'ls',
        args: git_names
      }
    }
  }
  @plan << task
end