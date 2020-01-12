module Language exposing (Language(..), decoder, encoder, fromCode)

import Dict
import Dict.Extra
import Json.Decode as Decode exposing (Decoder, andThen, string)
import Json.Encode as Encode exposing (Value)


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


encoder : Language -> Value
encoder language =
    case Dict.Extra.find (\_ lang -> language == lang) languageCodes of
        Just ( code, _ ) ->
            Encode.string code

        Nothing ->
            Encode.null
