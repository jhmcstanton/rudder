# frozen_string_literal: true

require_relative 'util'

module Rudder
  module DSL
    ##
    # Base class for other pipeline sub components to extend
    #
    # Not intended for public usage and subject to change.
    #
    class Component
      include Rudder::DSL::Util

      ##
      # Required method for all subclasses to implement.
      #
      # @raise [RuntimeError] if not implemented
      def _inner_hash
        raise 'Implement this in a subclass'
      end

      def to_h
        _deep_to_h(_inner_hash)
      end

      ##
      # Populates the inner hash with missing method names and
      # their arguments
      #
      # @param method [Symbol] top level key of this {Rudder::DSL::Component}
      #                Corresponds to the highest level key in a concourse
      #                component.
      #
      # @param *args entire arg collection is assigned to the value of the key
      #              +method+. Note: if only 1 argument is provided it is
      #              unwrapped from the +args+ {Array}.
      # @param **kwargs treated as the last value of +args+ if provided
      # @return the value related to +method+ if no arguments or keyword
      #                arguments are provided. Otherwise, +nil+.
      #
      # rubocop:disable Style/MethodMissingSuper
      def method_missing(method, *args, **kwargs)
        # Accessing inner hash as attribute
        return _inner_hash[method] if args.empty? && kwargs.empty?

        # Ruby treats dictionaries passed as the last argument as keyword dicts
        # (specifically when they use symbols as keys). Just smashing
        # these into args so we don't miss anything
        args << kwargs unless kwargs.empty?
        raise "Argument list missing from [#{method}]" if args.empty?

        # If a single arg is given then assume this field is scalar,
        # otherwise assume its a list that needs all args
        formatted_args = args.size == 1 ? args[0] : args
        _inner_hash[method] = formatted_args
      end
      # rubocop:enable Style/MethodMissingSuper

      ##
      # Components respond to everything by default
      #
      # @return true
      #
      def respond_to?(_name, _include_all = true)
        true
      end

      ##
      # Components respond to missing by default
      #
      # @return true
      #
      def respond_to_missing?(*_)
        true
      end
    end
  end
end
