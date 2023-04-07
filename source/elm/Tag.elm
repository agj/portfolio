module Tag exposing
    ( Codification(..)
    , Tag(..)
    , decoder
    , encoder
    , fromString
    , toString
    )

import Dict
import Dict.Extra
import Json.Decode as Decode exposing (Decoder, andThen, string)
import Json.Encode as Encode exposing (Value)
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


type Codification
    = AllowsAny
    | DisallowsAny


decoder : Codification -> Decoder Tag
decoder codification =
    string
        |> andThen
            (\code ->
                Dict.get code tagCodes
                    |> Maybe.Extra.filter (\tag -> codification == AllowsAny || tag /= Any)
                    |> (\maybeTag ->
                            case maybeTag of
                                Just tag ->
                                    Decode.succeed tag

                                Nothing ->
                                    Decode.fail <| "Tag unknown: " ++ code
                       )
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
