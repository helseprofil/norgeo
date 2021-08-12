## library(norgeo)
devtools::load_all()

dlist <- get_list("fylke", 2019)
dlist
dchg <- get_change("fylke", year = 2020, from = 2010)
dchg
dset <- geo_set("fylke", 2020)
dset

dc <- get_change("fylke", 2020)
get_change("f", 2020, 2017)[]

get_code("b", 2000, 2020)[]
get_code("b", 2020)
get_change("b", 2020, 2019)[]

geo_set("fylke", 2021, 2018)

## Kommune
komchg <- get_change("kom", year = 2020, from = 2019)
komchg
uniqueN(komchg$newCode)
unique(komchg$newCode)
komchg[duplicated(newCode), .N]

dtc <- track_change("kommune", 2015, 2021)


## install
remotes::install_github("helseprofil/norgeo@HEAD")
library(norgeo)

dtg <- get_change("g", 2018)
dtg[newCode == 15350309]
dtt <- norgeo::track_change("g", 2020)
dtt[currentCode == 15350309]
dtt[oldName == "Hjelset"]

## cast-geo
devtools::load_all()
dk <- find_correspond("komm", "grunn", 2021)
dk[targetCode == 15390107]
cast_geo()

bb <- cast_geo(2021)
names(bb)
bb
bb[is.na(code)]
bb[code == "01019999"]
bb[code == 15390107]
bb[grunnkrets == 15390107]
bb[level == "kommune" & code == 1539]
