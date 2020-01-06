module Works exposing (ofLanguage)

import Data.Kotokan
import Data.Runnerby
import Data.TeaRoom
import Language exposing (..)
import Work exposing (..)


ofLanguage : Language -> List (WorkLanguages msg) -> List (Work msg)
ofLanguage language data =
    let
        getLanguage workLanguage =
            Work.ofLanguage language workLanguage
    in
    List.map getLanguage data
