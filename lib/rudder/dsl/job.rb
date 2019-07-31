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

        # @plan here is just a handy hook to access the
        # plan quickly inside instance_eval
        @plan       = []
        @job        = { name: name, plan: @plan }
      end

      def _inner_hash
        @job
      end
    end
  end
end
