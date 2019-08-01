# frozen_string_literal: true

require_relative 'component'

module Rudder
  module DSL
    ##
    # Concourse Resource
    #
    class Resource < Rudder::DSL::Component
      ##
      # All resources require:
      #
      # - Name of the resource. Must be unique across resources (not enforcable here).
      # - The concourse resource type. Not verified until rendered to a Hash.
      #
      # @param name [String, Symbol] name of this Concourse resource. Must not be nil.
      # @param type [String, Symbol] of this Concoure Resource.
      #        May be nil here, must be set at compile time.
      #
      def initialize(name, type = nil)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        @resource = { name: name, type: type, source: {} }
      end

      ##
      # @return [String] the child_path prefixed by this resource's +name+
      #
      # Useful for creating the full path to a file in a +Resource+
      # without knowing it's underlying concourse name.
      #
      def sub_path(child_path)
        File.join(@resource[:name].to_s, child_path)
      end

      ##
      # @return [Hash] YAML friendly +Hash+ representation of this resource
      #
      # @raise [RuntimeError] if +type+ is +nil+ or +source+ is empty
      #
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
