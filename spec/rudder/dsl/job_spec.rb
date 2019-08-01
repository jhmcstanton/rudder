# frozen_string_literal: true

require 'rudder/dsl/job'
require 'spec_helper'

RSpec.describe Rudder::DSL::Job do
  let(:job) { described_class.new(:test) }

  describe '.initialize' do
    it 'asserts the name is not nil' do
      expect { described_class.new nil }.to raise_error(ArgumentError)
    end
  end

  describe 'dsl' do
    it 'includes access to all the job details' do
      job.instance_exec self do |spec|
        spec.expect(@job).to spec.eq(name: :test, plan: [])
      end
    end

    context '#to_h' do
      it 'asserts that the job plan is not empty' do
        expect { job.to_h }.to raise_error(RuntimeError)
      end

      it 'asserts that the name is not nil' do
        job.instance_exec do
          @job[:name] = nil
          @job[:plan] = [:job1]
        end
        expect { job.to_h }.to raise_error(RuntimeError)
      end

      it 'returns the YAML friendly hash' do
        job.instance_exec do
          plan << :job1
          plan << :job2
        end

        expect(job.to_h).to eq('name' => 'test', 'plan' => %w[job1 job2])
      end
    end
  end
end
