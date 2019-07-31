# frozen_string_literal: true

module Rudder
  module DSL
    module Util
      #
      # Recursively converts keys and values
      # of a hash to Yaml friendly values
      #
      def _deep_to_h(h)
        h.map do |k, v|
          k = _convert_h_val(k)
          v = _convert_h_val(v)
          [k, v]
        end.to_h
      end

      def _convert_h_val(v)
        case v
        when Hash
          _deep_to_h(v)
        when Array
          v.map { |x| _convert_h_val(x) }
        when Symbol
          v.to_s
        else
          if v.is_a? Rudder::DSL::Component
            v.to_h
          elsif v.respond_to? :to_h
            v.to_h
          else
            v
          end
        end
      end
    end
  end
end
