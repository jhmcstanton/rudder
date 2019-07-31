# frozen_string_literal: true

require_relative 'util'

module Rudder
  module DSL
    #
    # Base class for other pipeline sub components to extend
    #
    class Component
      include Rudder::DSL::Util

      def _inner_hash
        raise 'Implement this in a subclass'
      end

      def to_h
        _deep_to_h(_inner_hash)
      end

      #
      # Populates the inner hash with missing method names and
      # their arguments
      #
      def method_missing(m, *args, **kwargs)
        # Accessing inner hash as attribute
        return _inner_hash[m] if args.empty? && kwargs.empty?

        # Ruby treats dictionaries passed as the last argument as keyword dicts
        # (specifically when they use symbols as keys). Just smashing
        # these into args so we don't miss anything
        args << kwargs unless kwargs.empty?
        raise "Argument list missing from [#{m}]" if args.empty?

        # If a single arg is given then assume this field is scalar,
        # otherwise assume its a list that needs all args
        formatted_args = args.size == 1 ? args[0] : args
        _inner_hash[m] = formatted_args
      end

      def respond_to?(_name, _include_all = true)
        true
      end
    end
  end
end
