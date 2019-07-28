# Rudder

This gem provides a DSL for building [Concourse CI](https://concourse-ci.org/) pipelines.

## Goals

The intent of this project is to allow Concourse users to build complex pipelines with
a fully featured language rather than error-prone YAML files. 

Related goals:

- Support referencing first-class concourse features (`resource-types`, `resources`,
  `jobs`, etc) inside pipeline definition (for example, a task may be able to use
  a previously defined resource as an input by passing a reference to it, rather
  than just its name)
- Small amounts of pipeline validation

## Non-Goals

- Tieing this project directly to concourse. The ecosystem is fairly large, so supporting
  all resources the community creates or each new feature of concourse would be arduous.
  Instead this aims to be general, at the cost of allowing users to create incorrect
  pipelines

## Development

Use `docker-compose up` to stand up a local concourse instance for pipeline development.
Credit goes to Stark and Wayne for their excellent [Concourse tutorial](https://github.com/starkandwayne/concourse-tutorial/)
that includes the `docker-compose.yml` found here.

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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rudder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
