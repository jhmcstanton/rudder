require_relative 'component'

module Rudder
  module DSL
    class Resource < Rudder::DSL::Component

      #
      # All resources require:
      #
      # - A name. If whitespace is included these will be converted to dashes.
      # - A type. Indicates the concourse resource type.
      #
      def initialize(name, type)
        raise ArgumentError "Name must be a symbol" if !name.is_a? Symbol
        raise ArgumentError "Type cannot be nil"    if type.nil?
        @resource          = {}
        @resource[:name  ] = name.to_s
        @resource[:type  ] = type

        # @source here just provides a handy hook when running instance_eval
        @source            = {}
        @resource[:source] = @source
      end

      #
      # Returns the child_path prefixed by this resources' name
      #
      def sub_path(child_path)
        File.join(@resource[:name], child_path)
      end

      def _inner_hash
        @resource
      end
    end
  end
end
