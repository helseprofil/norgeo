## R CMD check results
There were no ERRORs, WARNINGs or NOTEs

## Second submit
Please provide a link to the used webservices to the description field of your DESCRIPTION file in the form <http:...> or <https:...> with angle brackets for auto-linking and no space after 'http:' and 'https:'.

Please add \value to .Rd files regarding exported methods and explain the functions results in the documentation. Please write about the structure of the output (class) and also what the output means. (If a function does not return a value, please document that too, e.g. 
\value{No return value, called for side effects} or similar) Missing Rd-tags in up to 14 .Rd files, e.g.:
      cast_geo.Rd: \value
      find_change.Rd: \value
      find_correspond.Rd: \value
      geo_cast.Rd: \value
      geo_change.Rd: \value
      geo_merge.Rd: \value
      ...


Please fix and resubmit.

## Version 2.4.2
Please always explain all acronyms in the description text. -> 'SSB'

Please add \value to .Rd files regarding exported methods and explain
the functions results in the documentation. Please write about the
structure of the output (class) and also what the output means. (If a
function does not return a value, please document that too, e.g.
\value{No return value, called for side effects} or similar)
Missing Rd-tags:
      geo_save.Rd: \value
      pipe.Rd: \value

You write information messages to the console that cannot be easily
suppressed.
It is more R like to generate objects that can be used to extract the
information a user is interested in, and then print() that object.
Instead of print()/cat() rather use message()/warning() or
if(verbose)cat(..) (or maybe stop()) if you really have to write text to
the console. (except for print, summary, interactive functions) ->
R/cast-geo.R

Please fix and resubmit.
