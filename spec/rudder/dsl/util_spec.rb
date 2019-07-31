# frozen_string_literal: true

require 'rudder/dsl/util'
require 'spec_helper'

RSpec.describe Rudder::DSL::Util do
  let(:dummy) { Class.new { include Rudder::DSL::Util }.new }

  describe '#_deep_to_h' do
    context 'when provided an empty hash' do
      it 'returns an empty hash' do
        expect(dummy._deep_to_h({})).to eq({})
      end
    end

    context 'when provided a populated hash' do
      it 'converts the keys and values to YAML friendly types' do
        test = { a: 1, b: :test, c: { d: [:last] } }
        expected = { 'a' => 1, 'b' => 'test', 'c' => { 'd' => ['last'] } }
        expect(dummy._convert_h_val(test)).to eq(expected)
      end
    end
  end

  describe '#_convert_h_val' do
    context 'when provided a string' do
      it 'returns the string' do
        input = 'test'
        expect(dummy._convert_h_val(input)).to eq(input)
      end
    end

    context 'when provided a symbol' do
      it 'returns the string of the symbol' do
        expect(dummy._convert_h_val(:test)).to eq(:test.to_s)
      end
    end

    context 'when provided an array' do
      it 'converts all elements of the array' do
        xs = [:a, :b, 1]
        expect(dummy._convert_h_val(xs)).to eq(['a', 'b', 1])
      end
    end

    context 'when provided a hash' do
      it 'converts all keys and values' do
        test = { a: 1, b: :test, c: { d: [:last] } }
        expected = { 'a' => 1, 'b' => 'test', 'c' => { 'd' => ['last'] } }
        expect(dummy._convert_h_val(test)).to eq(expected)
      end
    end

    context 'when provided an integer' do
      it 'returns the same integer' do
        expect(dummy._convert_h_val(1)).to eq(1)
      end
    end
  end
end
