# frozen_string_literal: true

require_relative 'component'

module Rudder
  module DSL
    ##
    # Concourse job
    #
    # Defines a plan of work that may share state
    # in an explicit manner.
    #
    # == DSL Usage:
    #
    # {Rudder::DSL::Job} are defined by a +name+ and a +plan+ of work.
    #
    # @example
    #   # Name's are set during initializtion, and may not be nil
    #   job :awesome_job # => job.name = :awesome_job
    #
    #   job nil # => Raises ArgumentError
    #
    # @example
    #   # The plan is set after construction
    #   job :awesome_job do
    #     plan << { get: :some_resource   }
    #     plan << { get: :another_resource }
    #   end # => plan.source = [{get: :some_resource}, {get: :another_resource}]
    #
    class Job < Rudder::DSL::Component
      ##
      # All Jobs require:
      #
      # - A name
      # - A plan of work
      #
      # Plans are defined after initialization
      #
      # @param name [String, Symbol] name of this Concourse job. Must not be +nil+
      # @raise [ArgumentError] when +name+ is nil
      #
      def initialize(name)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        @job = { name: name, plan: [] }
      end

      def _inner_hash
        @job
      end

      ##
      # @return [Hash] YAML friendly +Hash+ representation of this resource
      #
      # @raise [RuntimeError] if +name+ is +nil+ or +plan+ is empty
      #
      def to_h
        raise 'Name must be set for Concourse Jobs' if @job[:name].nil?
        raise 'Plan must be set for Concourse Jobs' if @job[:plan].empty?

        super.to_h
      end
    end
  end
end
