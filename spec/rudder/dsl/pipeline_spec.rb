# frozen_string_literal: true

require 'rudder/dsl/pipeline'
require 'spec_helper'

RSpec.describe Rudder::DSL::Pipeline do
  let(:path)     { File.join(File.dirname(__FILE__), 'does_not_exist.rb') }
  let(:pipeline) { described_class.new path }

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

  describe '#load_component' do
    it 'includes a component from disk into self' do
      pipeline.load_component 'sample_resource.rb', :resource, :test_resource
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
      expected = {
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
      expect(other.to_h).to eq(expected)
    end
  end
end
