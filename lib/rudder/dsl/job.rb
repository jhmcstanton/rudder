# frozen_string_literal: true

require_relative 'component'

module Rudder
  module DSL
    #
    # Concourse job
    #
    class Job < Rudder::DSL::Component
      def initialize(name)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        @job = { name: name, plan: [] }
      end

      def _inner_hash
        @job
      end

      def to_h
        raise 'Plan must be set for Concourse Jobs' if @job[:plan].empty?

        super.to_h
      end
    end
  end
end
