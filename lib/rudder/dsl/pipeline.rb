# require_relative 'group'
require_relative 'job'
require_relative 'resource'
require_relative 'util'

module Rudder
  module DSL
    class Pipeline
      include Rudder::DSL::Util
      def initialize
        @resources     = {}
        @jobs          = {}
        @groups        = {}
        @known_classes = {
          resource: { clazz: Resource, pipeline_group: @resources },
          job:      { clazz: Job     , pipeline_group: @jobs      }
          # group: { clazz: Group, pipeline_group: @groups }
        }
      end

      def to_h
        h = {
          'resources' => _convert_h_val(@resources.values),
          'jobs' => _convert_h_val(@jobs.values)
        }
        h['groups'] = _convert_h_val(@groups.values) if @groups.size > 0
        h
      end

      def method_missing(m, *args, **kwargs, &component_block)
        local_component = _get_local_component(m)
        if !@known_classes.include?(m) && !local_component
          return super.send(m, args, kwargs, component_block)
        end

        # Look up a previously defined component from the pipeline
        if local_component && args.empty? && kwargs.empty? && !block_given?
          return local_component
        end

        raise "Unexpected keyword arguments for method #{m}" if kwargs.size > 0
        component_group = @known_classes[m][:pipeline_group]
        name = args[0]
        raise "Overlapping component name: #{m}" if component_group.include? name
        component = @known_classes[m][:clazz].new(*args)

        if block_given?
          component.instance_exec self, &component_block
        end
        component_group[name] = component
      end

      def respond_to?(name, include_all=true)
        @known_classes.key? name
      end

      # Yikes! Seems like a bad idea - if someone uses the same name twice (say, 1 resource
      # and 1 job), then this will return one pretty much at random.
      # TODO: Make this not bad
      # Oh well..
      def _get_local_component(p)
        p = p.to_sym
        locals = @known_classes.values.map do |m|
          m[:pipeline_group][p]
        end.compact
        # TODO: Add a logger here..
        puts "Found multiple bindings for: #{p}. Getting first found" unless locals.size <= 1
        locals[0]
      end
    end
  end
end
