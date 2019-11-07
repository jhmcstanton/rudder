# frozen_string_literal: true

require 'rudder'
require 'spec_helper'
require 'tempfile'

examples = Dir['examples/**/*_pipeline.rb']

##
# Integration tests that simply assert
# that our examples remain compiling
# and setting withing Concourse without error
#

raise 'Unable to log into concourse' unless system('fly login -t local -u admin -p admin')

RSpec.describe Rudder do
  examples.each do |example|
    context "Pipeline #{example}" do
      it 'sets without error in Concourse' do
        vars_name = File.join(File.dirname(example), 'vars.yml')
        vars = {}
        vars = YAML.load_file(vars_name) if File.file? vars_name
        pipeline = Rudder.compile example, vars: vars
        example_name = File.basename example
        output = Tempfile.new(example_name)
        puts "output_path: #{output.path}"
        Rudder.dump(pipeline, output)
        output_path = output.path
        output.close

        pipeline_name = example_name.split('.').first
        success = system "fly -t local sp -p #{pipeline_name} -c #{output_path} -n"
        raise 'Failed to fly pipeline' unless success
      end
    end
  end
end
