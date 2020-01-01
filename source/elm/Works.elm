module Works exposing (all, ofLanguage)

import AssocList as Dict exposing (Dict)
import Data.Kotokan
import Data.Runnerby
import Data.TeaRoom
import Language exposing (..)
import Work exposing (..)


all : List (Dict Language (Work msg))
all =
    [ Data.Runnerby.data
    , Data.TeaRoom.data
    , Data.Kotokan.data
    ]


ofLanguage : Language -> List (Dict Language (Work msg)) -> List (Work msg)
ofLanguage language data =
    let
        getLanguage workData =
            Dict.get language workData
    in
    List.map getLanguage data
        |> List.filterMap identity
