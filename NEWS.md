# norgeo 2.4.6
- Bugfix: `cast_geo` no longer maps levekaar to bydel, as levekaar spanning across bydel caused duplicates in the list. 

# norgeo 2.4.5
- change location of manual geo-split files (#91).
- Remove deprecated-message when using track_change()

# norgeo 2.4.4
- Include data on living condition zones (#90). This is implemented in `get_code()`, `get_correspond()`, `get_change()`, `track_change()`, `track_merge()`, `track_split()`, `cast_geo()`

# norgeo 2.4.3
- Include data on economical regions (#88). This is implemented in `get_code()`, `get_correspond()`, `get_change()`, `track_change()`, `track_merge()`, `track_split()`, `cast_geo()`, 

# norgeo 2.4.2
- Get future data from API. Thank to @raniets for the request and proposed solution (#83)
- Fix error on the date in `date_future()`
- Fix geo codes manually when necessary (#84). This is done by sourcing [config
  files](https://github.com/helseprofil/config/tree/main/geo) according to their
  granularity level. Use argument `fix = TRUE` to execute sourcing these file.
- Deactivate testing for data based on `GrunnkretsBefore2002` since it isn't clean dataset.

# norgeo 2.3.1
- Replace `httr` package with `httr2` package.
- Use manually created correspond table when not found in API except for bydel
  (#81)
- Minor edit for naming of objects and messages.

# norgeo 2.1.6
- Update test file

# norgeo 2.1.5
- Update test file (#79)
- Use argument `names = FALSE` to exclude granularity names in the output. 

# norgeo 2.1.4
- Update test file after changes in SSB API (#77)

# norgeo 2.1.3
- Update test file after changes in SSB API (#76)

# norgeo 2.1.2
- Update test after changes in SSB API (#74)

# norgeo 2.1.1
- Update documentation.
- Add startup message with version number.
- Refactor some codes for cleanliness.
- Change title to "Tracking Geo Code Change of Regional Granularity in Norway".

# norgeo 2.1.0
- Clean up enumeration codes before 2002. Some codes that were already recoded
  could still exist after 2002. Those codes were excluded from the code change
  before 2002. Thanks to @jorgenRM to notice this (#62)
- Retry connection if fail or give feedback if error to connect to the API (#63)
- Area codes for grunnkrets doesn't always available from API. It makes it
  difficult to know if the codes have been changed multiple times or not.
  `get_change()` will ensure that area codes for grunnkrets will be created if
  it doesn't exist from the change table to ensure that area codes for
  grunnkrets will always exist. Thanks to @jorgenRM to notice this error (#65)

# norgeo 2.0.0
- All functions for the downloaded data from SSB are now deactivated. It's no
  more relevant after implementing API related functions. (#57)
- Code change for grunnkrets before 2003 is available with
  `GrunnkretsBefore2002`. The list is not available via API and received
  directly from SSB.

# norgeo 1.0.0
- `cast_geo()` now add unknown grunnkrets to respective bydel, kommune and fylke.
- Some geo code don't have missing codes. Have to add it manually
  when not available from SSB.
- Fix issues #42.
- Fix issues #41.
- Function `cast_code` is now internal only.
- All geo codes downloaded via API can be cast for geo granularity with `cast_geo`

  | codes   | year | level   | grks    | fylke | kommune | bydel  |
  |---------|------|---------|---------|-------|---------|--------|
  | 0320333 | 2021 | grks    | 0333333 | 03    | 0320    | 032141 |
  | 0322    | 2021 | kommune | NA      | 03    | 0322    | NA     |

- Gives error message if specification in `get_correspond()` for `type` and
  `correspond` in opposite order.
- Give error message if year specification in `from` and `to` in a wrong order.
- Stop if there is no code change for the specified year when running `track_change()`
- Add enumerator (_grunnkrets_) for missing with `99999999` when not already
  available in the dataset downloaded from API. This is needed for merging
  dataset that has this code to be able to calculate total for the whole dataset.

# norgeo 0.9.2

All API functions now use arguments `from` and `to` instead of `year` as in `geo_` functions.
This is matching the specification from SSB API Klass.

New features are introduced to help working with the downloaded data from API. Now you can use:

- `track_change` to get all code changes until the date specified year in `to` argument
- `track_split` to find geo codes that are split to different geo codes
- `track_merge` to find geo codes that are merged to a new geo

# norgeo 0.9.1

Introduce functions to download data via API with `get_` prefix:

- `get_code` function to download geo levels via API from SSB.
- `get_change` function to download code changes.
- `get_correspond` function to get geo codes for corresponding granularity.
- `get_set` function is now a wrapper function for `get_list` and `get_change`

# norgeo 0.9.0

* The real first release version

# norgeo 1.3.3

Despite it was version 1.3.3 til then, unfortunately `norgeo` was actually
premature since it hasn't been tested properly, but was released due to
the need to use the function. So that was much too early and I have to
pull it back and make rebirth of `norgeo 0.9` with a bit properly thought
function names and structure. But of course there are always errors and
things that can be better... Anyway, `norgeo 1.3.3` before
`norgeo 0.9.0` works but too ambitious to call it 1.3.3, but hopefully
the second future version of `norgeo 1.3.3` will be much better :-)

## `dev` branch

All ongoing new ideas will be implemented here. So contributions
and bugs reports are very much welcome.

## Track changes

* `geo_merge()` function provide output for `split` and `merge` codes,
but it's only relevant to those that are split or merged in the most
recent code list. All that happened prior to this haven't been handled
properly. So may be you can help to solve this?

## Change table

Hopefully a better alternative to solve this challenge when SSB
doesn't provide codes that have changed. May be SSB sees the problem
and will fix it to help external users.
