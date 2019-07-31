# frozen_string_literal: true

require 'rudder/dsl/job'
require 'spec_helper'

RSpec.describe Rudder::DSL::Job do
  let(:job) { described_class.new(:test) }

  describe '.initialize' do
    it 'asserts the name is not nil' do
      expect { described_class.new nil }.to raise_error(RuntimeError)
    end
  end

  describe 'dsl' do
    it 'includes access to all the job details' do
      job.instance_exec self do |spec|
        spec.expect(@job).to spec.eq(name: :test, plan: [])
      end
    end

    it 'includes access to the plan directly' do
      job.instance_exec self do |spec|
        spec.expect(@plan).to spec.eq([])
      end
    end
  end
end
