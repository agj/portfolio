module Language exposing (Language(..), fromCode)

import Dict


type Language
    = English
    | Spanish
    | Japanese


languageCodes =
    Dict.fromList
        [ ( "en", English )
        , ( "es", Spanish )
        , ( "ja", Japanese )
        ]


fromCode : String -> Maybe Language
fromCode code =
    Dict.get code languageCodes
