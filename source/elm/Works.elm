module Works exposing (ofLanguage)

import Language exposing (..)
import Work exposing (..)


ofLanguage : Language -> List (WorkLanguages msg) -> List (Work msg)
ofLanguage language data =
    let
        getLanguage workLanguage =
            Work.ofLanguage language workLanguage
    in
    List.map getLanguage data
