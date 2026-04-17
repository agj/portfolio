module Works exposing (ofLanguage)

import Language exposing (Language)
import Work exposing (Work, WorkLanguages)


ofLanguage : Language -> List WorkLanguages -> List Work
ofLanguage language data =
    let
        getLanguage : WorkLanguages -> Work
        getLanguage workLanguage =
            Work.ofLanguage language workLanguage
    in
    List.map getLanguage data
