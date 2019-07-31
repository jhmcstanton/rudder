# frozen_string_literal: true

require 'set'

module Rudder
  module DSL
    #
    # Concourse group. Logically groups together Concourse
    # jobs in the UI.
    #
    class Group
      attr_accessor :name
      attr_accessor :jobs

      def initialize(name)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        @name = name
        @jobs = Set.new
      end

      def to_h
        {
          'name' => @name.to_s,
          'jobs' => @jobs.to_a.map(&:to_s)
        }
      end

      def add(*args)
        args.each { |arg| @jobs << arg }
      end
    end
  end
end
