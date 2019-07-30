require 'set'

module Rudder
  module DSL
    class Group
      attr_accessor :name
      attr_accessor :jobs

      def initialize(name)
        raise ArgumentError "Name cannot be nil" if name.nil?
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
