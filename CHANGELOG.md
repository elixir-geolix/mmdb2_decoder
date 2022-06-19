# Changelog

## v3.0.1-dev

- Enhancements
    - Usage of to-be-deprecated `use Bitwise` has been replaced with `import Bitwise` to prepare for Elixir 1.14.x

## v3.0.0 (2020-05-17)

- Backwards incompatible changes
    - Lookup options are now only accepted in map format
    - Trying to lookup an IPv6 address in an IPv4-only database will now return an `{:error, :ipv6_lookup_in_ipv4_database}` tuple instead of a `nil` (not found) result. If the IP address is in the IPv6-to-IPv4-Mapping range (`::ffff:0:0/96`) the lookup will still be done using the mapped IPv4 address

## v2.1.0 (2019-12-07)

- Enhancements
    - Lookup options can now be passed as a map instead of a keyword list

- Bug fixes
    - Decoding `:pointer` values with a 32 bit offset should now work as expected
    - Raising from `lookup!/4` et al. is now behaving as expected with a `RuntimeError`

- Soft deprecations (no warnings)
    - Using a keyword list for lookup options is discouraged in favour of passing a map that does not need to be converted internally

## v2.0.0 (2019-11-02)

- Enhancements
    - The data at a specific pointer position can be retrieved
    - The pointer an IP has can be retrieved

- Backwards incompatible changes
    - Database entries of the type `data cache container` now return `:cache_container` (was `:cache`)
    - Database entries of the type `end marker` now return `:end_marker` (was `:end`)
    - Minimum required Elixir version is now `~> 1.7`
    - New decoding defaults are now active:
        - `double_prevision: nil`
        - `float_precision: nil`
        - `map_keys: :strings`
            - As a result the database descriptions in `MMDB2Decoder.Metadata` are now always a map with binary keys instead of atom keys
    - `MMDB2Decoder.Data.decode/3` is now private

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
    - The function `MMDB2Decoder.Data.decode/3` is no longer documented as it should not be called directly. It will be made fully private in the next major release

## v1.0.1 (2019-06-09)

- Bug fixes
    - Encountering an invalid node count in a database will result in `{:error, :invalid_node_count}` being returned instead of raising an unexpected `ArgumentError`
    - Return typespecs for `MMDB2Decoder.lookup/4` and dependent functions now include the possible `nil` return

## v1.0.0 (2019-02-16)

- Enhancements
    - All public lookup functions are now always returning either `{:ok, term}` or `{:error, term}`. Both `lookup!/4` and `pipe_lookup!/2` are available to get only the lookup result or raise in case of an error

- Backwards incompatible changes
    - Minimum required Elixir version is now `~> 1.5`

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
