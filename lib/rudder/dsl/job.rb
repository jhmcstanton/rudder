require_relative 'component'

module Rudder
  module DSL
    class Job < Rudder::DSL::Component

      def initialize(name)
        raise ArgumentError "Name cannot be nil" if name.nil?
        @job        = {}
        @job[:name] = name
      end

      def _inner_hash
        @job
      end
    end
  end
end
