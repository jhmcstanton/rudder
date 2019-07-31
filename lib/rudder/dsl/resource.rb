# frozen_string_literal: true

require_relative 'component'

module Rudder
  module DSL
    #
    # Concourse Resource
    #
    class Resource < Rudder::DSL::Component
      #
      # All resources require:
      #
      # - Name of the resource. Must be unique across resources (not enforcable here).
      # - The concourse resource type. Not verified until rendered to a Hash.
      #
      def initialize(name, type = nil)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        # @source here just provides a handy hook when running instance_eval
        @source   = {}
        @type     = type
        @resource = { name: name, type: type, source: @source }
      end

      #
      # Returns the child_path prefixed by this resources' name
      #
      def sub_path(child_path)
        File.join(@resource[:name].to_s, child_path)
      end

      def to_h
        raise 'Type must be set for Concourse Resources' if @type.nil?

        super.to_h.merge('type' => @type.to_s)
      end

      def _inner_hash
        @resource
      end
    end
  end
end
