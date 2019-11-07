# frozen_string_literal: true

require 'rudder/dsl/pipeline'
require 'spec_helper'

RSpec.describe Rudder::DSL::Pipeline do
  let(:path)     { File.join(File.dirname(__FILE__), 'does_not_exist.rb') }
  let(:pipeline) { described_class.new path }
  let(:sample_pipeline_h) do
    {
      'jobs' => [
        {
          'name' => 'sample_job',
          'plan' => [
            {
              'get' => 'sample_resource'
            }
          ]
        }
      ], 'resources' => [
        {
          'name' => 'sample_resource',
          'type' => 'git',
          'source' => {
            'uri' => 'some-uri'
          }
        }
      ]
    }
  end

  describe '#to_h' do
    context 'when no components are in the pipeline' do
      it 'returns a hash with empty resources and jobs' do
        expected = { 'resources' => [], 'jobs' => [] }
        expect(pipeline.to_h).to eq(expected)
      end
    end

    context 'when only jobs and resources are added' do
      it 'returns a hash with empty resources and jobs' do
        pipeline.resource :test_resource, :git
        pipeline.test_resource.source[:uri] = :anywhere

        pipeline.job :test_job
        pipeline.test_job.plan << { get: :test_resource }

        expected = {
          'resources' => [
            {
              'name' => 'test_resource',
              'type' => 'git',
              'source' => {
                'uri' => 'anywhere'
              }
            }
          ],
          'jobs' => [
            {
              'name' => 'test_job',
              'plan' => [{ 'get' => 'test_resource' }]
            }
          ]
        }
        expect(pipeline.to_h).to eq(expected)
      end
    end

    context 'when groups and resource types are added' do
      it 'they are included in the hash' do
        pipeline.resource_type :test_type, :whatevs
        pipeline.test_type.source[:uri] = :anywhere

        pipeline.group :test_group
        pipeline.test_group.jobs << :missing_job

        expected = {
          'jobs' => [],
          'resources' => [],
          'resource_types' => [
            {
              'name' => 'test_type',
              'type' => 'whatevs',
              'source' => {
                'uri' => 'anywhere'
              }
            }
          ],
          'groups' => [
            {
              'name' => 'test_group',
              'jobs' => ['missing_job']
            }
          ]
        }
        expect(pipeline.to_h).to eq(expected)
      end
    end
  end

  describe '#include_component' do
    it 'includes a component from disk into self' do
      pipeline.include_component 'sample_resource.rb', :resource, :test_resource
      expected = {
        'jobs' => [],
        'resources' => [
          {
            'type' => 'git',
            'name' => 'test_resource',
            'source' => {
              'uri' => 'some_uri'
            }
          }
        ]
      }
      expect(pipeline.to_h).to eq(expected)
    end
  end

  describe '#load' do
    it 'does _not_ include components by default' do
      pipeline.load 'sample_pipeline.rb'
      expect(pipeline.to_h).to eq('jobs' => [], 'resources' => [])
    end

    it 'evaluates the loaded pipeline' do
      other = pipeline.load 'sample_pipeline.rb'
      expect(other.to_h).to eq(sample_pipeline_h)
    end
  end

  describe '#include_pipeline' do
    it 'includes all elements of the target pipeline in this one' do
      pipeline.include_pipeline 'sample_pipeline.rb'
      expect(pipeline.to_h).to eq(sample_pipeline_h)
    end
  end

  describe '#merge_components' do
    context 'when provided a pipeline' do
      it 'includes all the components of other pipeline in this one' do
        other = pipeline.load 'sample_pipeline.rb'
        pipeline.merge_components other
        expect(pipeline.to_h).to eq(sample_pipeline_h)
      end
    end

    context 'when provided a pipeline hash' do
      it 'includes all the components of other pipeline in this one' do
        other = pipeline.load 'sample_pipeline.rb'
        pipeline.merge_components other.resources
        pipeline.merge_components other.jobs
        expect(pipeline.to_h).to eq(sample_pipeline_h)
      end
    end

    context 'when provides an array of resources' do
      it 'includes all the components in their appropriate hash' do
        other = pipeline.load 'sample_pipeline.rb'
        pipeline.merge_components other.resources.values
        pipeline.merge_components other.jobs.values
        expect(pipeline.to_h).to eq(sample_pipeline_h)
      end
    end

    context 'when provided an unsupported type' do
      it 'raises an Error' do
        expect { pipeline.merge_components(1) }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#initialize' do
    context 'when concourse vars are provided' do
      it 'converts the variables to a rudder friendly hash' do
        vars = { 'test' => 10, 'another' => [1, 2, 3] }
        expected_p_vars = { test: 10, another: [1, 2, 3] }
        pipeline = described_class.new(vars: vars)
        expect(pipeline.vars).to eq(expected_p_vars)
      end
    end
  end
end
