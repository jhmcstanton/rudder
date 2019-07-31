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
        spec.expect(@jobs.to_a).to spec.eq([])
      end
    end

    it 'includes access to the group name directly' do
      group.instance_exec self do |spec|
        spec.expect(@name).to spec.eq(:test)
      end
    end

    context '#add' do
      it 'adds all arguments to the jobs list' do
        group.add :job1, :job2, :job3
        expect(group.jobs.to_a).to eq(%i[job1 job2 job3])
      end
    end
  end

  describe '#to_h' do
    it 'returns the name and jobs list as strings' do
      group.add :job1, :job2
      expect(group.to_h).to eq('name' => 'test', 'jobs' => %w[job1 job2])
    end
  end
end
