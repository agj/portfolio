module Tag exposing (..)

import Dict
import Dict.Extra
import Json.Decode as Decode exposing (Decoder, andThen, string)
import Json.Encode as Encode exposing (Value)


type Tag
    = Any
    | VisualCommunication
    | Programming
    | Language
    | Learning
    | Digital
    | VideoGame
    | Web
    | UserInterface
    | Graphic
    | Video
    | Translation
    | EducationalSoftware
    | LanguageTeaching
    | Interactive


tagCodes =
    Dict.fromList
        [ ( "VisualCommunication", VisualCommunication )
        , ( "Programming", Programming )
        , ( "Language", Language )
        , ( "Learning", Learning )
        , ( "Digital", Digital )
        , ( "VideoGame", VideoGame )
        , ( "Web", Web )
        , ( "UserInterface", UserInterface )
        , ( "Graphic", Graphic )
        , ( "Video", Video )
        , ( "Translation", Translation )
        , ( "EducationalSoftware", EducationalSoftware )
        , ( "LanguageTeaching", LanguageTeaching )
        , ( "Interactive", Interactive )
        ]


decoder : Decoder Tag
decoder =
    string
        |> andThen
            (\code ->
                case Dict.get code tagCodes of
                    Just tag ->
                        Decode.succeed tag

                    Nothing ->
                        Decode.fail <| "Tag unknown: " ++ code
            )


encoder : Maybe Tag -> Value
encoder maybeTag =
    case maybeTag of
        Just tag ->
            case Dict.Extra.find (\_ t -> tag == t) tagCodes of
                Just ( code, _ ) ->
                    Encode.string code

                Nothing ->
                    Encode.null

        Nothing ->
            Encode.null
