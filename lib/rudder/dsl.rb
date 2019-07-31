# frozen_string_literal: true

require_relative 'dsl/pipeline.rb'

module Rudder
  #
  # DSL for configuring and manipulating Concourse Pipelines
  #
  module DSL
    #
    # Entry to the DSL. Creates a new pipeline
    # instance to evaluate user defined pipelines
    #
    def self.pipeline(*args, **kwargs)
      Rudder::DSL::Pipeline.new(*args, **kwargs)
    end

    #
    # Load a pipeline from a definition file
    #
    # Returned pipeline is not evaluated
    #
    def self.from_file(path)
      Rudder::DSL::Pipeline.new path
    end

    #
    # Load and evaluate a pipeline from a definition file
    #
    def self.eval_from_file(path)
      Rudder::DSL::Pipeline.new(path).eval
    end
  end
end
