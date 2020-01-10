module Language exposing (Language(..), decoder, fromCode)

import Dict
import Json.Decode as Decode exposing (Decoder, andThen, string)


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


decoder : Decoder Language
decoder =
    string
        |> andThen
            (\code ->
                case fromCode code of
                    Just language ->
                        Decode.succeed language

                    Nothing ->
                        Decode.fail <| "Language code unknown: " ++ code
            )
