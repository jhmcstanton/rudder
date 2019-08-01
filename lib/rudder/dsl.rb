# frozen_string_literal: true

require_relative 'dsl/pipeline.rb'

module Rudder
  ##
  # DSL for configuring and manipulating Concourse Pipelines
  #
  # The building blocks of the DSL are:
  # - {Rudder::DSL::Pipeline}, the top level definition containg all other definitions.
  #   See {https://concourse-ci.org/pipelines.html Concourse Pipeline}
  # - {Rudder::DSL::Resource}, representing inputs and outputs of jobs.
  #   See {https://concourse-ci.org/resources.html Concourse Resource}
  # - {Rudder::DSL::Job}, units of work.
  #   See {https://concourse-ci.org/jobs.html Concourse Job}
  # - {Rudder::DSL::ResourceType}, defines how a {Rudder::DSL::Resource} operates.
  #   See {https://concourse-ci.org/resource-types.html Concourse Resource Type}
  # - {Rudder::DSL::Group}, logically groups together Concourse Jobs in the UI.
  #   See {https://concourse-ci.org/pipeline-groups.html Concourse Grouping Jobs}
  #
  module DSL
    ##
    # Entry to the DSL. Creates a new pipeline
    # instance to evaluate user defined pipelines
    #
    # @return [Rudder::DSL::Pipeline] new, and unevaluated
    #
    def self.pipeline(*args, **kwargs)
      Rudder::DSL::Pipeline.new(*args, **kwargs)
    end

    ##
    # Load a pipeline from a definition file
    # at the +path+
    #
    # @param path [String] to the {Rudder::DSL::Pipeline} definition
    # @return [Rudder::DSL::Pipeline] from +path+, unevaluated
    #
    def self.from_file(path)
      Rudder::DSL::Pipeline.new path
    end

    ##
    # Load and evaluate a pipeline from a definition file
    # at the +path+
    #
    # @param path [String] to the {Rudder::DSL::Pipeline} definition
    # @return [Rudder::DSL::Pipeline] from +path+, fully evaluated
    #
    def self.eval_from_file(path)
      Rudder::DSL::Pipeline.new(path).eval
    end
  end
end
