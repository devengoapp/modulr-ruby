# Changelog

All notable changes to this gem are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org).

## [Unreleased]

## [0.1.0] - 2026-11-10

### Changed

- **Breaking:** requires Ruby 3.2 or later ([#53](https://github.com/devengoapp/modulr-ruby/pull/53)).
- **Breaking:** depends on Faraday 2 (`>= 2.0, < 3`) instead of Faraday 1, and no longer on `faraday_middleware` ([#53](https://github.com/devengoapp/modulr-ruby/pull/53)).
- Releases are published with trusted publishing and a Sigstore attestation ([#54](https://github.com/devengoapp/modulr-ruby/pull/54)).

### Security

- The request logger filters the `Authorization` header ([#58](https://github.com/devengoapp/modulr-ruby/pull/58)).
- `Modulr::Client#inspect` no longer prints the API key, secret or proxy credentials ([#51](https://github.com/devengoapp/modulr-ruby/pull/51)).

### Dependencies

- Adds `base64` as a runtime dependency, needed from Ruby 3.4 ([#53](https://github.com/devengoapp/modulr-ruby/pull/53)).

[Unreleased]: https://github.com/devengoapp/modulr-ruby/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/devengoapp/modulr-ruby/compare/v0.0.49...v0.1.0
