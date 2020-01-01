module Data.Introduction exposing (ofLanguage)

import Descriptor exposing (..)
import Element exposing (Element)
import Language exposing (..)
import Tag exposing (Tag)


ofLanguage : (Tag -> msg) -> Language -> Element msg
ofLanguage tagSelectionMessenger language =
    case language of
        English ->
            english (makeTag tagSelectionMessenger)

        Japanese ->
            japanese (makeTag tagSelectionMessenger)

        Spanish ->
            spanish (makeTag tagSelectionMessenger)


english tag =
    d
        [ p
            [ t "My name is "
            , bold (t "Ale Grilli")
            , t ". I’m based in Santiago, Chile. My work is concerned with various intersections of the following four areas."
            ]
        , list
            [ tag Tag.VisualCommunication "Visual communication"
            , tag Tag.Programming "Programming"
            , tag Tag.Language "Language"
            , tag Tag.Learning "Learning"
            ]
        , p
            [ t "I’m a creator. I make "
            , tag Tag.Digital "digital things"
            , t ", such as "
            , tag Tag.VideoGame "games"
            , t " and "
            , tag Tag.Web "web stuff"
            , t ". I design "
            , tag Tag.UserInterface "user interfaces"
            , t " and "
            , tag Tag.Graphic "graphics"
            , t ". I shoot and edit "
            , tag Tag.Video "videos"
            , t " on occasion."
            ]
        , p
            [ t "I’m a languages nerd. I am fluent in three (Spanish, English, Japanese) and am working on a fourth (Chinese Mandarin). I do "
            , tag Tag.Translation "translation"
            , t " work, subtitling too."
            ]
        , p
            [ t "I think a lot about learning. I’ve worked for ed-tech companies programming "
            , tag Tag.EducationalSoftware "educational software"
            , t ". I occasionally "
            , tag Tag.LanguageTeaching "teach languages"
            , t "."
            ]
        ]


japanese tag =
    d
        [ p
            [ bold (t "アレ・グリリ（Ale Grilli）")
            , t "と言います。拠点をチリのサンティアゴにしています。活動は次の四つのエリアの組み合わせです。"
            ]
        , list
            [ tag Tag.VisualCommunication "視覚コミュニケーション"
            , tag Tag.Programming "プログラミング"
            , tag Tag.Language "言語"
            , tag Tag.Learning "習得"
            ]
        , p
            [ t "I’m a creator. I make "
            , tag Tag.Digital "digital things"
            , t ", such as "
            , tag Tag.VideoGame "games"
            , t " and "
            , tag Tag.Web "web stuff"
            , t ". I design "
            , tag Tag.UserInterface "user interfaces"
            , t " and "
            , tag Tag.Graphic "graphics"
            , t ". I shoot and edit "
            , tag Tag.Video "videos"
            , t " on occasion."
            ]
        , p
            [ t "I’m a languages nerd. I am fluent in three (Spanish, English, Japanese) and am working on a fourth (Chinese Mandarin). I do "
            , tag Tag.Translation "translation"
            , t " work, subtitling too."
            ]
        , p
            [ t "I think a lot about learning. I’ve worked for ed-tech companies programming "
            , tag Tag.EducationalSoftware "educational software"
            , t ". I occasionally "
            , tag Tag.LanguageTeaching "teach languages"
            , t "."
            ]
        ]


spanish tag =
    d
        [ p
            [ t "Me llamo "
            , bold (t "Ale Grilli")
            , t ". Vivo en Santiago, Chile. Mi trabajo se preocupa de la intersección entre las siguientes cuatro áreas."
            ]
        , list
            [ tag Tag.VisualCommunication "Comunicación visual"
            , tag Tag.Programming "Programación"
            , tag Tag.Language "Idiomas"
            , tag Tag.Learning "Aprendizaje"
            ]
        , p
            [ t "I’m a creator. I make "
            , tag Tag.Digital "digital things"
            , t ", such as "
            , tag Tag.VideoGame "games"
            , t " and "
            , tag Tag.Web "web stuff"
            , t ". I design "
            , tag Tag.UserInterface "user interfaces"
            , t " and "
            , tag Tag.Graphic "graphics"
            , t ". I shoot and edit "
            , tag Tag.Video "videos"
            , t " on occasion."
            ]
        , p
            [ t "I’m a languages nerd. I am fluent in three (Spanish, English, Japanese) and am working on a fourth (Chinese Mandarin). I do "
            , tag Tag.Translation "translation"
            , t " work, subtitling too."
            ]
        , p
            [ t "I think a lot about learning. I’ve worked for ed-tech companies programming "
            , tag Tag.EducationalSoftware "educational software"
            , t ". I occasionally "
            , tag Tag.LanguageTeaching "teach languages"
            , t "."
            ]
        ]
