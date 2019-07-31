# frozen_string_literal: true

@parent_dir = File.dirname(__FILE__)
def relative_files(p)
  Dir[File.join(@parent_dir, p)]
end

# Load all the resources
relative_files('resources/*').each do |path|
  # Pipline#load includes always loads files relative to where itself, so
  # we need to remove the parent directory from this path
  res = load path.sub(@parent_dir, '')
  @resources.merge! res.resources
end

# Load all the jobs and stick them in groups by directory
relative_files('jobs/*').each do |group_dir|
  group_name = File.basename group_dir
  group group_name do |pipeline|
    Dir[File.join(group_dir, '*')].each do |job_path|
      parent_dir = File.dirname __FILE__
      job_pipe = pipeline.load(job_path.sub(parent_dir, ''), resources: pipeline.resources)
      pipeline.jobs.merge! job_pipe.jobs
      job_pipe.jobs.keys.each { |job_name| @jobs << job_name }
    end
  end
end

# Add all of the jobs to a super group
group :all do |pipeline|
  pipeline.jobs.keys.each do |job_name|
    @jobs << job_name
  end
end
