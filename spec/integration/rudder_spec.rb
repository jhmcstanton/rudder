# frozen_string_literal: true

require 'rudder'
require 'spec_helper'
require 'tempfile'

examples = [
  'hello_world.rb',
  'shared/common.rb',
  'shared/wrapper.rb',
  'shared/borrows.rb',
  'includes/includes.rb',
  'groups/groups.rb'
].map{ |p| File.join('examples', p)}

##
# Integration tests that simply assert
# that our examples remain compiling
# and setting withing Concourse without error
#
RSpec.describe Rudder do
  examples.each do |example|
    context "Pipeline #{example}" do
      it 'sets without error in Concourse' do
        pipeline = Rudder.compile example
        example_name = File.basename example
        output = Tempfile.new(example_name, tmpdir = '.')
        puts "output_path: #{output.path}"
        Rudder.dump(pipeline, output)
        output_path = output.path
        output.close

        pipeline_name = example_name.split('.').first
        success = system "fly -t local sp -p #{pipeline_name} -c #{output_path} -n"
        unless success
          raise 'Failed to fly pipeline'
        end
      end
    end
  end
end
