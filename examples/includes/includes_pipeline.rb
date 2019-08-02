# frozen_string_literal: true

include_component 'resources/rudder_git.rb', :resource, :rudder_git

job = include_component 'jobs/log.rb', :job, :log_rudder_git
job.plan.insert(0, get: :rudder_git, trigger: true)
