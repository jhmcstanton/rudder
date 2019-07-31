# frozen_string_literal: true

require 'rudder/dsl/resource'
require 'spec_helper'

RSpec.describe Rudder::DSL::Resource do
  let(:resource) { described_class.new :test, :test_type }

  describe '.initialize' do
    it 'asserts the name is not nil' do
      expect { described_class.new nil, 'test' }.to raise_error(ArgumentError)
    end
  end

  describe 'dsl' do
    it 'includes access to all the resource details' do
      resource.instance_exec self do |spec|
        spec.expect(@resource).to spec.eq(name: :test, type: :test_type, source: {})
      end
    end

    context '#to_h' do
      it 'asserts that type is not nil' do
        resource = described_class.new :test_resource
        resource.instance_exec do
          source[:anything] = :whatever
        end
        expect { resource.to_h }.to raise_error(RuntimeError)
      end

      it 'asserts that the source is not empty' do
        expect { resource.to_h }.to raise_error(RuntimeError)
      end

      it 'returns the YAML friendly resource hash' do
        resource.instance_exec do
          source[:anything] = :whatever
        end
        expect(resource.to_h).to eq(
          'name' => 'test',
          'type' => 'test_type',
          'source' => { 'anything' => 'whatever' }
        )
      end
    end
  end
end
