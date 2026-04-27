module Tag exposing
    ( Tag(..)
    , decoder
    , fromString
    , name
    , toString
    )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, andThen, string)
import Language exposing (Language(..))
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


all : List Tag
all =
    [ Any
    , VisualCommunication
    , Programming
    , Language
    , Learning
    , Digital
    , VideoGame
    , Web
    , UserInterface
    , Graphic
    , Video
    , Translation
    , EducationalSoftware
    , LanguageTeaching
    , Interactive
    ]


tagCodes : Dict String Tag
tagCodes =
    all
        |> List.map (\tag -> ( toString tag, tag ))
        |> Dict.fromList


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


name : Language -> Tag -> String
name language tag =
    case ( language, tag ) of
        ( English, Any ) ->
            "any"

        ( English, VisualCommunication ) ->
            "visual communication"

        ( English, Programming ) ->
            "programming"

        ( English, Language ) ->
            "language"

        ( English, Learning ) ->
            "learning"

        ( English, Digital ) ->
            "digital"

        ( English, VideoGame ) ->
            "video game"

        ( English, Web ) ->
            "web"

        ( English, UserInterface ) ->
            "user interface"

        ( English, Graphic ) ->
            "graphic"

        ( English, Video ) ->
            "video"

        ( English, Translation ) ->
            "translation"

        ( English, EducationalSoftware ) ->
            "educational software"

        ( English, LanguageTeaching ) ->
            "language teaching"

        ( English, Interactive ) ->
            "interactive"

        ( Spanish, Any ) ->
            "cualquiera"

        ( Spanish, VisualCommunication ) ->
            "comunicación visual"

        ( Spanish, Programming ) ->
            "programación"

        ( Spanish, Language ) ->
            "idiomas"

        ( Spanish, Learning ) ->
            "aprendizaje"

        ( Spanish, Digital ) ->
            "digital"

        ( Spanish, VideoGame ) ->
            "videojuegos"

        ( Spanish, Web ) ->
            "web"

        ( Spanish, UserInterface ) ->
            "interfaz de usuario"

        ( Spanish, Graphic ) ->
            "gráfica"

        ( Spanish, Video ) ->
            "video"

        ( Spanish, Translation ) ->
            "traducción"

        ( Spanish, EducationalSoftware ) ->
            "software educativo"

        ( Spanish, LanguageTeaching ) ->
            "enseñanza de idiomas"

        ( Spanish, Interactive ) ->
            "interactivo"

        ( Japanese, Any ) ->
            "どれも"

        ( Japanese, VisualCommunication ) ->
            "ビジュアルコミュニケーション"

        ( Japanese, Programming ) ->
            "プログラミング"

        ( Japanese, Language ) ->
            "言語"

        ( Japanese, Learning ) ->
            "学習"

        ( Japanese, Digital ) ->
            "デジタル"

        ( Japanese, VideoGame ) ->
            "ゲーム"

        ( Japanese, Web ) ->
            "Web"

        ( Japanese, UserInterface ) ->
            "ユーザーインタフェース"

        ( Japanese, Graphic ) ->
            "グラフィック"

        ( Japanese, Video ) ->
            "映像"

        ( Japanese, Translation ) ->
            "翻訳"

        ( Japanese, EducationalSoftware ) ->
            "教育ソフト"

        ( Japanese, LanguageTeaching ) ->
            "言語教育"

        ( Japanese, Interactive ) ->
            "インタラクティブ"
