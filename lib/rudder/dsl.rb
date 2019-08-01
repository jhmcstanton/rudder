# frozen_string_literal: true

require_relative 'dsl/pipeline.rb'

module Rudder
  ##
  # DSL for configuring and manipulating Concourse Pipelines
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
