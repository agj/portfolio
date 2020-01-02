module Works exposing (all, ofLanguage)

import Data.Kotokan
import Data.Runnerby
import Data.TeaRoom
import Language exposing (..)
import Work exposing (..)


all : List (WorkLanguages msg)
all =
    [ Data.Runnerby.data
    , Data.TeaRoom.data
    , Data.Kotokan.data
    ]


ofLanguage : Language -> List (WorkLanguages msg) -> List (Work msg)
ofLanguage language data =
    let
        getLanguage workLanguage =
            Work.ofLanguage language workLanguage
    in
    List.map getLanguage data
