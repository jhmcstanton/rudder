# frozen_string_literal: true

require 'rudder/dsl/resource_type'
require 'spec_helper'

RSpec.describe Rudder::DSL::Group do
  let(:group) { described_class.new :test }
  describe '.initialize' do
    it 'asserts the name is not nil' do
      expect { described_class.new nil }.to raise_error(ArgumentError)
    end
  end

  describe 'dsl' do
    it 'includes access to the jobs directly' do
      group.instance_exec self do |spec|
        spec.expect(jobs.to_a).to spec.eq([])
      end
    end

    it 'includes access to the group name directly' do
      group.instance_exec self do |spec|
        spec.expect(name).to spec.eq(:test)
      end
    end

    context '#jobs' do
      it 'adds all arguments to the jobs list' do
        group.instance_exec self do |spec|
          jobs :job1, :job2, :job3
          spec.expect(jobs.to_a).to spec.eq(%i[job1 job2 job3])
        end
      end

      it 'returns the current list of jobs' do
        group.instance_exec self do |spec|
          jobs :job1
          spec.expect(jobs.to_a).to spec.eq(%i[job1])
        end
      end
    end

    context '#job' do
      it 'adds the job to the job list' do
        group.instance_exec self do
          job :job1
        end
        expect(group.jobs.to_a).to eq(%i[job1])
      end
    end

    context '#to_h' do
      it 'asserts that the job list is not empty' do
        expect { group.to_h }.to raise_error(RuntimeError)
      end

      it 'asserts that the job name is not nil' do
        expect { group.to_h }.to raise_error(RuntimeError)
      end

      it 'returns the name and jobs list as strings' do
        group.instance_exec self do
          jobs :job1, :job2
        end
        expect(group.to_h).to eq('name' => 'test', 'jobs' => %w[job1 job2])
      end
    end
  end
end
