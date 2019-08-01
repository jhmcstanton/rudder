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
      # @return [Hash] representation of this class
      #
      def _deep_to_h(hash)
        hash.map do |k, v|
          k = _convert_h_val(k)
          v = _convert_h_val(v)
          [k, v]
        end.to_h
      end

      ##
      # Converts non-collections to YAML safe strings
      # and collections to collections of YAML safe strings
      #
      #
      def _convert_h_val(value)
        case value
        when Hash
          _deep_to_h(value)
        when Array
          value.map { |x| _convert_h_val(x) }
        when Symbol
          value.to_s
        else
          if value.respond_to? :to_h
            _deep_to_h(value.to_h)
          else
            value
          end
        end
      end
    end
  end
end
