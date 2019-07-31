# frozen_string_literal: true

require 'rudder/dsl/component'
require 'spec_helper'

class Dummy < Rudder::DSL::Component
  def initialize(hash)
    @hash = hash
  end

  def _inner_hash
    @hash
  end
end

RSpec.describe Rudder::DSL::Component do
  let(:inner)     { {} }
  let(:component) { Dummy.new inner }

  describe '#_inner_hash' do
    it 'raises a Runtime error' do
      expect { described_class.new._inner_hash }.to raise_error(RuntimeError)
    end
  end

  describe '#respond_to?' do
    it 'always returns true' do
      expect(component.respond_to?(:anything)).to be true
    end
  end

  describe '#method_missing' do
    context 'when provided no arguments' do
      it 'returns the value of the method key' do
        expect(component.test).to be nil
        inner[:test] = 10
        expect(component.test).to eq(10)
      end
    end

    context 'when provided a single argument' do
      it 'sets a single value as using the method key' do
        component.test 1
        expect(component.test).to eq(1)
      end
    end

    context 'when provided multiple arguments' do
      it 'sets the array of arguments as the value of the method key' do
        component.test :a, 1
        expect(component.test).to eq([:a, 1])
      end
    end

    context 'when provided keyword arguments' do
      it 'stores the entire hash' do
        component.test a: 1, b: 2
        expect(component.test).to eq(a: 1, b: 2)
      end
    end

    context 'when provided both arguments and keyword arguments' do
      it 'stores the list of all arguments and keyword arguments at the method key' do
        component.test 1, 2, 3, a: 1, b: 2
        expect(component.test).to eq([1, 2, 3, { a: 1, b: 2 }])
      end
    end
  end
end
