# frozen_string_literal: true

require 'set'

module Rudder
  module DSL
    #
    # Concourse group. Logically groups together Concourse
    # jobs in the UI.
    #
    class Group
      def initialize(name)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        @name = name
        @jobs = Set.new
      end

      #
      # Assigns
      def name(name = nil)
        @name = name unless name.nil?
        @name
      end

      #
      # Adds job_name to the jobs list
      #
      def job(job_name)
        jobs job_name
      end

      #
      # Adds all the jobs to the jobs list
      #
      # Returns the latest list of jobs
      #
      def jobs(*args)
        args.each { |arg| @jobs << arg }
        @jobs
      end

      def to_h
        raise 'Groups require a name'         if @name.nil?
        raise 'Groups require at least 1 job' if @jobs.empty?

        {
          'name' => @name.to_s,
          'jobs' => @jobs.to_a.map(&:to_s)
        }
      end
    end
  end
end
