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

        @resource = { name: name, type: type, source: {} }
      end

      #
      # Returns the child_path prefixed by this resources' name
      #
      def sub_path(child_path)
        File.join(@resource[:name].to_s, child_path)
      end

      def to_h
        raise 'Type must be set for Concourse Resources'   if @resource[:type].nil?
        raise 'Source must be set for Concourse Resources' if @resource[:source].empty?

        super.to_h
      end

      def _inner_hash
        @resource
      end
    end
  end
end
