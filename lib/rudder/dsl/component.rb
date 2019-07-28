module Rudder
  module DSL
    #
    # Base class for other pipeline sub components to extend
    #
    class Component

      def _inner_hash
        raise "Implement this in a subclass"
      end

      #
      # Populates the inner hash with missing method names and
      # their arguments
      #
      def method_missing(m, *args, **kwargs)
        # puts "Remove these lines, m: #{m}"
        # puts "args: #{args}"
        # puts "kwargs: #{kwargs}"

        # Accessing inner hash as attribute
        if args.size == 0 && kwargs.size == 0
          return _inner_hash[m]
        end

        # Ruby treats dictionaries passed as the last argument as keyword dicts
        # (specifically when they use symbols as keys). Just smashing
        # these into args so we don't miss anything
        args << kwargs unless kwargs.empty?
        raise "Argument list missing from [#{m}]" if args.empty?

        # If a single arg is given then assume this field is scalar,
        # otherwise assume its a list that needs all args
        formatted_args = if args.size == 1 then args[0] else args end
        _inner_hash[m] = formatted_args
      end

      def respond_to?(name)
        true
      end
    end
  end
end
