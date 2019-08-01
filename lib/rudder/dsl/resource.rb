# frozen_string_literal: true

require_relative 'component'

module Rudder
  module DSL
    ##
    # Concourse Resource, defines inputs and outputs of a Concourse Job
    #
    # DSL Usage:
    #
    # -------------------------------------------------------
    # {Rudder::DSL::Resource} are defined by a +name+, +type+, and +source+.
    #
    # @example
    #   # Name's are set during initialization, and may not be nil.
    #   resource :awesome_resource # => resource.name = :awesome_resource
    #
    #   resource nil # => Raises ArgumentError
    #
    # @example
    #   # Type's are typically set during initialization
    #   resource :awesome_resource, :git # => resource.type = :git
    #
    #   # but it may be set in the +resource+ block
    #   resource :awesome_resource do
    #     type :git
    #   end # => resource.type = :git
    #   # this is useful when definining +Resources+ to be included in multiple pipelines,
    #   # where the type does not change but the name may
    #
    # @example
    #   # Source is set after construction
    #   resource :awesome_resource, :git do
    #     source[:uri]    = 'https://github.com/jhmcstanton/rudder.git'
    #     source[:branch] = 'master'
    #   end
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
