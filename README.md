# Rudder

[![Gem Version](https://badge.fury.io/rb/rudder.svg)](https://badge.fury.io/rb/rudder)
[![Documentation](https://img.shields.io/badge/docs-rdoc.info-blue.svg)](https://rubydoc.org/gems/rudder/frames)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

This gem provides a DSL for building [Concourse CI](https://concourse-ci.org/) pipelines.

Rubygems release docs can be found above, or head over to
[rudder.jhmcstanton.com](https://rudder.jhmcstanton.com) for the latest
docs from HEAD.

## Goals

The intent of this project is to allow Concourse users to build complex pipelines with
a fully featured language rather than error-prone YAML files. 

Related goals:

- Support referencing first-class concourse features (`resource-types`, `resources`,
  `jobs`, etc) inside pipeline definition (for example, a task may be able to use
  a previously defined resource as an input by passing a reference to it, rather
  than just its name)
- Support breaking pipeline definitions into multiple pieces to allow composing
  them together
- Small amounts of pipeline validation

### Current State

Currently this project supports building a pipeline from a single definition file.
Pipelines can utilize other pipeline definitions by either entirely importing
the contents or borrowing only specific pieces.

TODOs:

- More tests & add a coverage tool
- Add CI

## Non-Goals

- Tieing this project directly to concourse. The ecosystem is fairly large, so supporting
  all resources the community creates or each new feature of concourse would be arduous.
  Instead this aims to be general, at the cost of allowing users to create incorrect
  pipelines

## Development

Use `bundle exec rake docker_up` to stand up a local concourse instance
for pipeline development. Credit goes to Stark and Wayne for their excellent 
[Concourse tutorial](https://github.com/starkandwayne/concourse-tutorial/) that
includes the `docker-compose.yml` found here.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rudder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rudder

## Usage

### DSL
See the [DSL class documentation](./Rudder/DSL.html)
for specific details. 

### Compiling Pipelines

Compile your `Rudder` definitions using the provided CLI tool:

```
Usage: rudder [options]
    -o, --output YAML_PATH           YAML_PATH to write the pipeline config
    -c, --config RUDDER_CONFIG       Path to the RUDDER_CONFIG file to evaluate
    -l CONCOURSE_VARS,               Path to the CONCOURSE_VARS yaml file
        --load-vars-from
    -v, --version                    Show version

```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Docs

Build the docs with

```
bundle exec rake yard
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jhmcstanton/rudder.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
