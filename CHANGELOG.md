# Changelog

## v1.0.1-dev

- Bug fixes
    - Return typespecs for `MMDB2Decoder.lookup/4` and dependent functions now include the possible `nil` return

## v1.0.0 (2019-02-16)

- Enhancements
    - All public lookup functions are now always returning either `{:ok, term}` or `{:error, term}`. Both `lookup!/4` and `pipe_lookup!/2` are available to get only the lookup result or raise in case of an error

- Backwards incompatible changes
    - Minimum required elixir version is now `~> 1.5`

## v0.4.0 (2018-12-21)

- Enhancements
    - Database parsing speed has been improved
    - Trying to locate a node below the available node count will now return `{:error, :node_below_count}` instead of an improper `0`

## v0.3.0 (2018-07-13)

- Enhancements
    - Errors from `MMDB2Decoder.parse_database/1` are now returned from the `MMDB2Decoder.pipe_lookup/2` function instead of raising a `FunctionClauseError`
    - Parsing speed has been improved

## v0.2.0 (2018-02-17)

- Enhancements
    - Parsing speed has been improved

## v0.1.0 (2017-10-30)

- Initial Release
