require_relative 'component'

module Rudder
  module DSL
    class Resource < Rudder::DSL::Component

      #
      # All resources require:
      #
      # - Name of the resource. Must be unique across resources (not enforcable here).
      # - The concourse resource type
      #
      def initialize(name, type)
        raise ArgumentError "Type cannot be nil"    if type.nil?
        # @source here just provides a handy hook when running instance_eval
        @source   = {}
        @resource = { name: name, type: type, source: @source }
      end

      #
      # Returns the child_path prefixed by this resources' name
      #
      def sub_path(child_path)
        File.join(@resource[:name].to_s, child_path)
      end

      def _inner_hash
        @resource
      end
    end
  end
end
