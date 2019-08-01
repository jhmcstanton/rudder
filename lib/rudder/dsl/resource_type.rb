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
    class ResourceType < Rudder::DSL::Resource
    end
  end
end
