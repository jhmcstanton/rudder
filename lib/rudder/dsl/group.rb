# frozen_string_literal: true

require 'set'

module Rudder
  module DSL
    ##
    # Concourse group. Logically groups together Concourse
    # jobs in the UI.
    #
    # == DSL Usage:
    # 
    # {Rudder::DSL::Group}'s are the simplest element of any
    # Concourse Pipeline, defined by only a name and a non-empty
    # list of jobs.
    #
    #
    # @example
    #   # Name's are typically set during initialization
    #   group :my_awesome_group do # => Name is set to :my_awesome_group
    #
    #   # but the name may be changed post construction as well
    #   group :not_the_best_name do # => Name initialized to :not_the_best_name
    #     name :the_best_name
    #   end # => but is set to :the_best_name after the block is executed
    #
    # @example
    #   # Job's are always set post construction. They can be added
    #   # individually:
    #   group :my_awesome_group do
    #     job :some_prereq
    #     job :my_awesome_work
    #   end # => group.jobs = [:some_prereq, :my_awesome_work]
    #
    #   # and they can be added in collections
    #   group :my_awesome_group do
    #     jobs :a_job, :and_another, :and_one_more
    #   end # => group.jobs = [:a_job, :and_another, :and_one_more]
    #
    #
    class Group
      ##
      # All {Rudder::DSL::Group}'s require
      #
      # - Name of the group
      # - A list of jobs in the group
      #
      # Jobs are added after initilization.
      #
      # @param [String, Symbol] the non-+nil+ name of this group
      # @raise [ArgumentError] if +name+ is +nil
      #
      def initialize(name)
        raise super.ArgumentError 'Name cannot be nil' if name.nil?

        @name = name
        @jobs = Set.new
      end

      ##
      # Replace's this {Rudder::DSL::Group}'s name unless
      # +name+ is nil.
      #
      # @param name [String, Symbol] the new name to use. Ignored if +nil+.
      # @return [String, Symbol] the latest component name.
      #
      def name(name = nil)
        @name = name unless name.nil?
        @name
      end

      ##
      # Add a single job to the jobs list
      #
      # @param job_name [String, Symbol] to add to the jobs list
      # @return [Set<String, Symbol>] the latest list of jobs
      #
      def job(job_name)
        jobs job_name
      end

      ##
      # Adds all the jobs to the jobs list
      #
      # @param *args [*String, *Symbol] collection of jobs to add to this
      #        {Rudder::DSL::Group}
      # @return [Set<String, Symbol>] the latest list of jobs
      #
      def jobs(*args)
        args.each { |arg| @jobs << arg }
        @jobs
      end

      ##
      # @return [Hash] YAML friendly +Hash+ representation of this resource
      #
      # @raise [RuntimeError] if +name+ is +nil+ or +jobs+ is empty
      #
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
