# frozen_string_literal: true

require_relative 'component'

module Rudder
  module DSL
    ##
    # Concourse Resource Type
    #
    # ResourceTypes specify how Concourse Resources
    # operate and may be user or community defined.
    #
    # == DSL Usage:
    #
    # {Rudder::DSL::ResourceType} are defined by a +name+, +type+, and +source+.
    #
    # @example
    #   # Name's are set during initialization, and may not be nil.
    #   resource_type :awesome_resource_type # => resource_type.name = :awesome_resource_type
    #
    # @example
    #   resource_type nil # => Raises ArgumentError
    #
    # @example
    #   # Type's are typically set during initialization
    #   resource_type :awesome_resource_type, :git # => resource_type.type = :git
    #
    #   # but it may be set in the +resource_type+ block
    #   resource_type :awesome_resource_type do
    #     type :git
    #   end # => resource_type.type = :git
    #   # this is useful when definining +ResourceTypes+ to be included in multiple pipelines,
    #   # where the type does not change but the name may
    #
    # @example
    #   # Source is set after construction
    #   resource_type :awesome_resource_type, :docker-image do
    #     source[:repository] = 'some_docker/repo'
    #     source[:tag]        = 'latest'
    #   end
    #
    class ResourceType < Rudder::DSL::Resource
    end
  end
end
