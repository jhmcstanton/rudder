 require_relative 'group'
require_relative 'job'
require_relative 'resource'
require_relative 'resource_type'
require_relative 'util'

module Rudder
  module DSL
    #
    # Concourse Pipeline. Main entry of the DSL. Evaluates
    # user defined pipelines.
    #
    class Pipeline
      include Rudder::DSL::Util
      attr_accessor :resources
      attr_accessor :jobs
      attr_accessor :groups
      attr_accessor :resource_types
      def initialize(file_path = nil, resources: {}, jobs: {},
                     groups: {}, resource_types: {})
        @resources      = resources
        @jobs           = jobs
        @groups         = groups
        @resource_types = resource_types
        @known_classes  = {
          resource:      { clazz: Resource    , pipeline_group: @resources      },
          job:           { clazz: Job         , pipeline_group: @jobs           },
          group:         { clazz: Group       , pipeline_group: @groups         },
          resource_type: { clazz: ResourceType, pipeline_group: @resource_types }
        }
        @pipelines = {}
        @file_path = file_path
      end

      def to_h
        h = {
          'resources' => _convert_h_val(@resources.values),
          'jobs'      => _convert_h_val(@jobs.values)
        }
        h['groups'] = _convert_h_val(@groups.values) if @groups.size > 0
        if @resource_types.size > 0
          h['resource_types'] = _convert_h_val(@resource_types.values)
        end
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

      # Evaluates the given file path.
      # If file_path nil, defaults to the one provided at construction time
      # If both are nil, raises an exception
      def eval(file_path = nil)
        @file_path = file_path || @file_path
        if @file_path.nil?
          raise 'File path must be provided at Pipeline initialization or eval call'
        end
        File.open(@file_path) do |f|
          instance_eval f.read, @file_path
        end
        self
      end

      # Given a path relative to this pipeline, loads another
      # pipeline and returns it
      #
      # Note that this includes _nothing_ from the relative pipeline in this
      # one, instead just returning the pipeline to be manipulated
      #
      # May also optionally provides hashes for
      # - resources
      # - resource_types
      # - jobs
      # - groups
      def load(other_pipeline_path, resources: {}, resource_types: {},
               jobs: {}, groups: {})
        if @pipelines.key? other_pipeline_path
          @pipelines[other_pipeline_path]
        else
          dir = File.dirname(@file_path)
          full_path = File.join(dir, other_pipeline_path)
          pipeline = Rudder::DSL::Pipeline.new(
            full_path, resources: resources, resource_types: resource_types,
            jobs: jobs, groups: groups).eval
          @pipelines[other_pipeline_path] = pipeline
          pipeline
        end
      end

      # Given a path to a component, its class, and
      # any args required to construct it, creates
      # a new component
      #
      # Note that this automatically includes the component into this pipeline
      #
      def load_component(component_path, class_sym, name, *args)
        raise "Unable to load #{clazz}" unless @known_classes.keys.include? class_sym
        raise "Name must not be nil" if name.nil?

        dir = File.dirname(@file_path)
        full_path = File.join(dir, component_path)
        component = @known_classes[class_sym][:clazz].new(name, *args)
        File.open(full_path) do |f|
          component.instance_eval f.read, full_path
        end
        @known_classes[class_sym][:pipeline_group][name] = component
        component
      end

      # Yikes! Seems like a bad idea - if someone uses the same name twice (say, 1 resource
      # and 1 job), then this will return one pretty much at random.
      # TODO: Make this not bad
      # Oh well..
      # TODO: This may be returning a non-nil/non-falsey type that causes some issues
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
