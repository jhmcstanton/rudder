rudder_git = load_component 'resources/rudder_git.rb', :resource, :rudder_git, :git

job = load_component 'jobs/log.rb', :job, :log_rudder_git
job.plan.insert(0, {get: :rudder_git, trigger: true})
