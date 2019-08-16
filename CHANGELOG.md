# Changelog

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2019-08-16
### Changed
- Corrected link in README / doc index for DSL details.
  Previously this was hardcoded to the development docs.

## [0.2.1] - 2019-08-16
### Added
- Missing documentation link from gem specification

## [0.2.0] - 2019-08-08
### Added
- Added helper methods `#merge_components` and `#include_pipeline`. Supports
  various convenient methods to import external Pipelines and components
  into the current definition.

### Breaking Changes
- `#load_component` helper method has been renamed `#include_component`.
  

## [0.1.0] - 2019-01-08
### Added
- Initial implementation of Rudder DSL. Includes:
-- Support for pipeline primitives (resources, resource types, jobs, groups)
-- Pipeline definition support with various helper methods
-- Compiles to YAML
-- CLI
-- Examples
-- Docs
