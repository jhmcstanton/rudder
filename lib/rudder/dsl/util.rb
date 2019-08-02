# frozen_string_literal: true

module Rudder
  module DSL
    ##
    # Utility helper methods for DSL components.
    #
    # This is ntended for internal use and is subject to change.
    #
    module Util
      ##
      # Recursively converts keys and values
      # of a {Hash} to YAML friendly values
      #
      # @param use_name [Boolean] when true named objects
      #    are rendered only by name. Otherwise, renders
      #    to {Hash} (if able), or returns the object itself.
      # @return [Hash] representation of this class
      #
      def _deep_to_h(hash, use_name = true)
        hash.map do |k, v|
          k = _convert_h_val(k, use_name)
          v = _convert_h_val(v, use_name)
          [k, v]
        end.to_h
      end

      ##
      # Converts non-collections to YAML safe strings
      # and collections to collections of YAML safe strings
      #
      # @param use_name [Boolean] when true named objects
      #    are rendered only by name. Otherwise, renders
      #    to {Hash} (if able), or returns the object itself.
      #
      def _convert_h_val(value, use_name = true)
        case value
        when Array
          value.map { |x| _convert_h_val(x, use_name) }
        when Symbol
          value.to_s
        else
          if use_name && value.respond_to?(:name)
            value.name.to_s
          elsif value.respond_to? :to_h
            _deep_to_h(value.to_h, use_name)
          else
            value
          end
        end
      end
    end
  end
end
