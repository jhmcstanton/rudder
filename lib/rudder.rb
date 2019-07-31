# frozen_string_literal: true

require 'yaml'

require_relative 'rudder/dsl.rb'

#
# Methods to compile Rudder definitions
# to Concourse Pipeline definitions
#
module Rudder
  #
  # Compiles a Pipeline definition from disk
  # to a Hash
  #
  def self.compile(path)
    Rudder::DSL.eval_from_file(path).to_h
  end

  #
  # Dumps a Rudder::DSL::Pipeline or Pipeline Hash
  # to disk formatted as YAML
  #
  def self.dump(pipeline, output_path)
    File.open(output_path, 'w+') do |f|
      f.puts(YAML.dump(pipeline.to_h))
    end
  end
end
