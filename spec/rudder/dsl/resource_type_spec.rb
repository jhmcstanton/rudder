# frozen_string_literal: true

require 'rudder/dsl/resource_type'
require 'spec_helper'

RSpec.describe Rudder::DSL::ResourceType do
  let(:resource) { described_class.new :test, :test_type }

  describe '.initialize' do
    it 'asserts the name is not nil' do
      expect { described_class.new nil, 'test' }.to raise_error(ArgumentError)
    end
    it 'asserts the type is not nil' do
      expect { described_class.new 'test', nil }.to raise_error(ArgumentError)
    end
  end

  describe 'dsl' do
    it 'includes access to all the resource details' do
      resource.instance_exec self do |spec|
        spec.expect(@resource).to spec.eq(name: :test, type: :test_type, source: {})
      end
    end

    it 'includes access to the source directly' do
      resource.instance_exec self do |spec|
        spec.expect(@source).to spec.eq({})
      end
    end
  end
end
