# frozen_string_literal: true

require_relative 'group'
require_relative 'job'
require_relative 'resource'
require_relative 'resource_type'
require_relative 'util'

module Rudder
  module DSL
    ##
    # Concourse Pipeline. Main entry of the DSL. Evaluates
    # user defined pipelines.
    #
    # == DSL Usage:
    #
    # {Rudder::DSL::Pipeline}'s are composed of various components:
    #
    # - {Rudder::DSL::Resource}: basic inputs and output of jobs.
    # - {Rudder::DSL::Job}: basic computation unit of a pipeline
    # - {Rudder::DSL::ResourceType}: custom resource definitions
    # - {Rudder::DSL::Group}: logical grouping of jobs in the UI.
    #   Either every job is in a Group or no job is (hard Concourse
    #   requirement)
    #
    # === Adding Components
    #
    # Components are added to the Pipeline by component type, followed
    # by name, optional arguments, then typically a block.
    #
    # @example Adding Components to Pipelines
    #   #
    #   # my_pipeline_definition.rb
    #   #
    #   resource :my_git_repo, :git do
    #     source[:uri]    = 'https://github.com/my/repo.git'
    #     source[:branch] = :master
    #   end
    #
    #   resource :daily, :time do
    #     source[:interval] = '24h'
    #
    #   job :build_project do
    #     plan << [in_parallel: [{ get: :my_git_repo }, { get: :daily, trigger: true}]]
    #     build = { task: 'build my project', config: {
    #       platform: :linux,
    #       image_resource: { type: 'docker-image', source: { repository: 'busybox' } },
    #       run: { path: 'my_git_repo/build.sh' }
    #     }}
    #     plan << build
    #   end
    #
    #
    # === Loading Other Pipelines
    #
    # {Rudder::DSL::Pipeline}'s can load other pipeline definitions
    # using {Rudder::DSL::Pipeline#load}. This is a useful mechanism
    # for abstracting out common subsections of pipelines, then
    # merging them into larger pipelines.
    #
    # @example Loading / Importing Pipelines
    #   #
    #   # load_neighbor.rb
    #   #
    #   neighbor = load 'neighbor_pipeline.rb'
    #
    #   # merge all the neighboring resources and jobs into this pipeline
    #   resources.merge! neighbor.resources
    #   jobs.merge! neighbor.jobs
    #
    #   resource_type :slack_notification, 'docker-image' do
    #     source[:repository] = 'some/slack-docker-repo'
    #   end
    #
    #   resource :our_slack_channel, :slack_notification do
    #     source[:url] = '((slack-team-webhook))'
    #   end
    #
    #   # Add a slack notification task to the end
    #   # of every job
    #   jobs.values.each do |job|
    #     job.plan << {
    #       put: :our_slack_channel,
    #       params: { text: "Job #{job.name} complete!" }
    #     }
    #   end
    #
    # === Loading Individual Components
    # Individual pipeline components can also be defined on a per-file
    # basis and then loaded into a {Rudder::DSL::Pipeline} using
    # {Rudder::DSL::Pipeline#load_component}. This is useful for factoring
    # out common resources for multiple pipeline's to use.
    #
    # @example Loading / Importing Individual Components
    #   #
    #   # operations_scripts_resource.rb
    #   #
    #   type :git
    #   source[:uri]    = 'https://github.com/<our org>/operations_scripts.git'
    #   source[:branch] = 'master'
    #
    #
    #   #
    #   # some_operations_pipeline.rb
    #   #
    #
    #   # load the resource into the pipeline. Automatically includes
    #   # the resource into the resources list with the name :scripts
    #   load_component 'operations_scripts_resource.rb', :resource, :scripts
    #
    #   job :audit do |pipeline|
    #     plan << {
    #       task: 'run the audit script', config: {
    #         platform: :linux,
    #         image_resource: {
    #           type: 'docker-image',
    #           source: { repository: 'alpine/git' }
    #         },
    #         run: {
    #           path: pipeline.scripts.sub_path('audit.rb')
    #         }
    #       }
    #     }
    #   end
    class Pipeline
      include Rudder::DSL::Util
      # {Hash} of names to {Rudder::DSL::Resource}
      # @return [Hash<(String, Symbol), Rudder::DSL::Resource>]
      attr_accessor :resources
      # {Hash} of names to {Rudder::DSL::Job}
      # @return [Hash<(String, Symbol), Rudder::DSL::Job>]
      attr_accessor :jobs
      # {Hash} of names to {Rudder::DSL::ResourceType}
      # @return [Hash<(String, Symbol), Rudder::DSL::ResourceType>]
      attr_accessor :resource_types
      # {Hash} of names to {Rudder::DSL::Group}
      # @return [Hash<(String, Symbol), Rudder::DSL::Group>]
      attr_accessor :groups

      ##
      # All pipelines require:
      # - Jobs
      # - Resources
      #
      # Concourse Pipelines may optionally provide:
      # - Resource Types
      # - Groups
      #
      # +Rudder+ Pipelines may optionally include a +file_path+. This
      # is required when loading resources from neighboring files.
      #
      # All pipeline requirements are only needed at the Pipeline
      # render time (after evaluation), and need not be specified
      # for initialization.
      #
      # @param file_path [String] path to this {Rudder::DSL::Pipeline} definition.
      # @param resources [Hash<(String, Symbol), Rudder::DSL::Resource]
      #                  map of Resource names to their definitions.
      # @param jobs      [Hash<(String, Symbol), Rudder::DSL::Job]
      #                  map of Job names to their definitions.
      # @param groups    [Hash<(String, Symbol), Rudder::DSL::Group]
      #                  map of Group names to their definitions.
      # @param resources_types [Hash<(String, Symbol), Rudder::DSL::ResourceType]
      #                  map of Resource Type names to their definitions.
      #
      def initialize(file_path = nil, resources: {}, jobs: {},
                     groups: {}, resource_types: {})
        @resources      = resources
        @jobs           = jobs
        @groups         = groups
        @resource_types = resource_types
        # rubocop:disable Layout/AlignHash, Layout/SpaceBeforeComma
        @known_classes  = {
          resource:      { clazz: Resource    , pipeline_group: @resources      },
          job:           { clazz: Job         , pipeline_group: @jobs           },
          group:         { clazz: Group       , pipeline_group: @groups         },
          resource_type: { clazz: ResourceType, pipeline_group: @resource_types }
        }
        # rubocop:enable Layout/AlignHash, Layout/SpaceBeforeComma
        @pipelines = {}
        @file_path = file_path
      end

      ##
      # Renders all of this pipeline's components to their +Hash+
      # representations.
      #
      # @return [Hash] YAML friendly +Hash+ representation of this +Pipeline+
      #         if either +groups+ or +resource_types+ is empty they will
      #         not be included in the rendering at all.
      #
      def to_h
        h = {
          'resources' => p_convert_h_val(@resources.values),
          'jobs' => p_convert_h_val(@jobs.values)
        }
        h['groups'] = p_convert_h_val(@groups.values) unless @groups.empty?
        h['resource_types'] = p_convert_h_val(@resource_types.values) unless @resource_types.empty?
        h
      end

      #
      # Wraps {_convert_h_val} since it will always set use_name to false
      #
      def p_convert_h_val(hash)
        _convert_h_val(hash, false)
      end

      ##
      # Populates this {Rudder::DSL::Pipeline} with components
      # and optionally fetches defined components.
      #
      # Fetching
      # --------------------------------------------------------------------
      # When +method+ is called with no arguments it is treated
      # as a {Rudder::DSL::Pipeline} getter method. +method+ is translated
      # to the name of a {Rudder::DSL::Component} and the +Component+
      # is returned if defined, otherwise nil is returned.
      # --------------------------------------------------------------------
      #
      # Setting
      # --------------------------------------------------------------------
      # When +method+ is passed _any_ arguments (positional, placement, or block)
      # then +method+ is treated as a setter.
      #
      # When setting, +method+ must be the name of a known {Rudder::DSL::Component}.
      # The first argument is a required _name_ for the component. _All_ arguments
      # and keyword arguments are then delegated to the {Rudder::DSL::Component}'s
      # specific initializer.
      #
      # Finally, when a block is provided it is evaluated within the context
      # of the newly constructed {Rudder::DSL::Component} with full priveleges
      # to operate on it.
      # --------------------------------------------------------------------
      #
      # @return [Rudder::DSL::Component, nil] when +method+ is called with no
      #         arguments, returns the {Rudder::DSL::Component} with name
      #         +method+, if any exists. Otherwise returns +nil+.
      # @raise [RuntimeError] when attempting to define an unknown
      #         {Rudder::DSL::Component}
      # @internal_todo
      #   TODO: Clean this up so these can be reenabled
      #   rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def method_missing(method, *args, &component_block)
        local_component = _get_local_component(method)
        if !@known_classes.include?(method) && !local_component
          return super.send(method, args, component_block)
        end

        # Look up a previously defined component from the pipeline
        return local_component if local_component && args.empty? && !block_given?

        component_group = @known_classes[method][:pipeline_group]
        name = args[0]
        raise "Overlapping component name: #{method}" if component_group.include? name

        component = @known_classes[method][:clazz].new(*args)

        component.instance_exec self, &component_block if block_given?
        component_group[name] = component
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      ##
      # {Rudder::DSL::Pipeline}'s respond to missing
      #
      # @return true
      def respond_to_missing?(*_)
        true
      end

      def respond_to?(name, _include_all = true)
        @known_classes.key? name
      end

      ##
      # Evaluates the given file path.
      # If file_path nil, defaults to the one provided at construction time
      # If both are nil, raises an exception
      #
      # @param file_path [String, nil] path to {Rudder::DSL::Pipeline} definition
      #                  to evaluate. Uses the current +file_path+ if +nil+
      # @raise [RuntimeError] if +file_path+ and {Rudder::DSL::Pipeline#file_path}
      #                       are both +nil+
      # @return [Rudder::DSL::Pipeline] the evaluated pipeline
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

      ##
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
      #
      # @param other_pipeline_path [String] relative path to {Rudder::DSL::Pipeline}
      #        definition to load and evaluate.
      # @param resources [Hash<(String, Symbol), Rudder::DSL::Resource]
      #        resources to initialize the other {Rudder::DSL::Pipeline} with
      # @param resources_types [Hash<(String, Symbol), Rudder::DSL::ResourceType]
      #        resources_types to initialize the other {Rudder::DSL::Pipeline} with
      # @param jobs [Hash<(String, Symbol), Rudder::DSL::Job]
      #        jobs to initialize the other {Rudder::DSL::Pipeline} with
      # @param groups [Hash<(String, Symbol), Rudder::DSL::Group]
      #        groups to initialize the other {Rudder::DSL::Pipeline} with
      def load(other_pipeline_path, resources: {}, resource_types: {},
               jobs: {}, groups: {})
        if @pipelines.key? other_pipeline_path
          @pipelines[other_pipeline_path]
        else
          dir = File.dirname(@file_path)
          full_path = File.join(dir, other_pipeline_path)
          pipeline = Rudder::DSL::Pipeline.new(
            full_path, resources: resources, resource_types: resource_types,
                       jobs: jobs, groups: groups
          ).eval
          @pipelines[other_pipeline_path] = pipeline
          pipeline
        end
      end

      ##
      # Given a path to a component, its class, and
      # any args required to construct it, creates
      # a new component
      #
      # Note that this automatically includes the component into this pipeline
      #
      # @param component_path [String] path, relative to this pipeline, containing
      #        a {Rudder::DSL::Component} to load
      # @param class_sym [Symbol] symbol of a {Rudder::DSL::Component}. May be one of:
      #        (+:job+, +:resource+, +:resource_type+, +:group+)
      # @param name [String, Symbol] name to use for the loaded
      #             {Rudder::DSL::Component}. Must not be +nil+.
      # @param *args any additional arguments to pass to the {Rudder::DSL::Component}
      #             constructor.
      # @raise RuntimeError if +name+ is +nil+ or an uknown +class_sym+ is provided.
      #
      def load_component(component_path, class_sym, name, *args)
        raise "Unable to load #{class_sym}" unless @known_classes.keys.include? class_sym
        raise 'Name must not be nil' if name.nil?

        full_path = File.join(File.dirname(@file_path), component_path)
        component = @known_classes[class_sym][:clazz].new(name, *args)
        component.instance_eval File.read(full_path), full_path
        @known_classes[class_sym][:pipeline_group][name] = component
        component
      end

      # Yikes! Seems like a bad idea - if someone uses the same name twice (say, 1 resource
      # and 1 job), then this will return one pretty much at random.
      # TODO: Make this not bad
      # Oh well..
      # TODO: This may be returning a non-nil/non-falsey type that causes some issues
      def _get_local_component(component)
        component = component.to_sym
        locals = @known_classes.values.map do |m|
          m[:pipeline_group][component]
        end.compact
        # TODO: Add a logger here..
        puts "Found multiple bindings for: #{p}. Getting first found" unless locals.size <= 1
        locals[0]
      end
    end
  end
end
