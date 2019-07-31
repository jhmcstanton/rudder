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
  end
end
