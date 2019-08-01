# frozen_string_literal: true

require 'yaml'

require_relative 'rudder/dsl.rb'
require_relative 'rudder/version.rb'

##
# Methods to compile Rudder definitions
# to Concourse Pipeline definitions
#
module Rudder
  ##
  # Compiles a {Rudder::DSL::Pipeline} definition from +path+
  # to a {Hash}
  #
  # @param path [String] the path to the +Rudder+ definition
  # @return [Hash] Concourse YAML friendly hash
  #
  def self.compile(path)
    Rudder::DSL.eval_from_file(path).to_h
  end

  ##
  # Dumps a {Rudder::DSL::Pipeline} or Pipeline {Hash}
  # to the provided file handle +output+
  #
  # @param pipeline {Rudder::DSL::Pipeline} definition. Assumed to be evaluated.
  # @param output [File] handle to dump YAML to
  # @return [nil]
  #
  def self.dump(pipeline, output)
    output.puts(YAML.dump(pipeline.to_h))
  end
end
