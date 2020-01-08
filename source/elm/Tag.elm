module Tag exposing (..)

import Json.Decode as Decode exposing (Decoder, andThen, string)


type Tag
    = VisualCommunication
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


decoder : Decoder Tag
decoder =
    string
        |> andThen
            (\tagString ->
                case tagString of
                    "VisualCommunication" ->
                        Decode.succeed VisualCommunication

                    "Programming" ->
                        Decode.succeed Programming

                    "Language" ->
                        Decode.succeed Language

                    "Learning" ->
                        Decode.succeed Learning

                    "Digital" ->
                        Decode.succeed Digital

                    "VideoGame" ->
                        Decode.succeed VideoGame

                    "Web" ->
                        Decode.succeed Web

                    "UserInterface" ->
                        Decode.succeed UserInterface

                    "Graphic" ->
                        Decode.succeed Graphic

                    "Video" ->
                        Decode.succeed Video

                    "Translation" ->
                        Decode.succeed Translation

                    "EducationalSoftware" ->
                        Decode.succeed EducationalSoftware

                    "LanguageTeaching" ->
                        Decode.succeed LanguageTeaching

                    other ->
                        Decode.fail <| "Tag unknown: " ++ other
            )
