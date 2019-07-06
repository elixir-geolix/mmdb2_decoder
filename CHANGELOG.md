# Changelog

## v1.1.0 (2019-07-06)

- Enhancements
    - Maps can be decoded with a custom key type by passing `:map_keys` in the options of `lookup/5`
        - default is `:atoms` (keeping current behaviour, uses `String.to_atom/1`)
        - `:atoms!` uses `String.to_existing_atom/1`
        - `:strings` to perform no conversion (future default)
    - Precision for `:double` data can be defined by passing `:double_precision` in the options of `lookup/5`
        - default is `8` (keeping current behaviour)
        - `nil` will deactivate rounding (future default)
    - Precision for `:float` data can be defined by passing `:float_precision` in the options of `lookup/5`
        - default is `4` (keeping current behaviour)
        - `nil` will deactivate rounding (future default)

- Bug fixes
    - Max values for `:double` and `:float` datatypes (magic `'Inf'` string in Perl) should now properly decode

- Deprecations
    - The function `MMDB2Decoder.Data.value/2` is no longer documented as it should not be called directly. It will be made fully private in the next major release

## v1.0.1 (2019-06-09)

- Bug fixes
    - Encountering an invalid node count in a database will result in `{:error, :invalid_node_count}` being returned instead of raising an unexpected `ArgumentError`
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
