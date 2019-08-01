# frozen_string_literal: true

common = load('common_pipeline.rb')

resource :timer, :time do
  source[:interval] = '5m'
end

# Add a timer to the first job
get_timer_task = { get: :timer, trigger: true }
start_plan = common.jobs.values.first.plan
start_plan << get_timer_task

resources.merge! common.resources
jobs     .merge! common.jobs

job 'An extra job that the wrapper pipeline requires' do
  plan << get_timer_task
  date = {
    task: 'print the date', config: {
      platform: 'linux',
      image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
      run: {
        path: 'date'
      }
    }
  }
  plan << date
end

job 'Goodbye from the Wrapper Pipeline' do |_pipeline|
  # Get the last job defined in the previous pipeline
  # so that we can depend on it in this job
  last_job = common.jobs.values.last
  last_job.plan.select { |task| task.key? :get }.each do |task|
    task = task.dup
    task[:passed] = [last_job.name]
    plan << task
  end
  task = {
    task: 'print_outer', config: {
      platform: 'linux',
      image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
      run: {
        path: 'echo',
        args: ['This is the outer pipeline. Good bye!']
      }
    }
  }
  plan << task
end
