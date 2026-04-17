module Tag exposing
    ( Tag(..)
    , decoder
    , fromString
    , toString
    )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, andThen, string)
import Maybe.Extra


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


tagCodes : Dict String Tag
tagCodes =
    Dict.fromList
        [ ( "Any", Any )
        , ( "VisualCommunication", VisualCommunication )
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
                Dict.get code tagCodes
                    |> Maybe.Extra.filter (\tag -> tag /= Any)
                    |> (\maybeTag ->
                            case maybeTag of
                                Just tag ->
                                    Decode.succeed tag

                                Nothing ->
                                    Decode.fail ("Tag unknown: " ++ code)
                       )
            )


toString : Tag -> String
toString tag =
    case tag of
        Any ->
            "Any"

        VisualCommunication ->
            "VisualCommunication"

        Programming ->
            "Programming"

        Language ->
            "Language"

        Learning ->
            "Learning"

        Digital ->
            "Digital"

        VideoGame ->
            "VideoGame"

        Web ->
            "Web"

        UserInterface ->
            "UserInterface"

        Graphic ->
            "Graphic"

        Video ->
            "Video"

        Translation ->
            "Translation"

        EducationalSoftware ->
            "EducationalSoftware"

        LanguageTeaching ->
            "LanguageTeaching"

        Interactive ->
            "Interactive"


fromString : String -> Maybe Tag
fromString string =
    Dict.get string tagCodes
