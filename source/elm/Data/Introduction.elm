module Data.Introduction exposing (ofLanguage)

import Descriptor exposing (..)
import Element exposing (Element)
import Language exposing (..)
import Tag exposing (Tag)


ofLanguage : (Tag -> msg) -> Language -> Element msg
ofLanguage tagMessenger language =
    case language of
        English ->
            english (makeTag tagMessenger)

        Japanese ->
            japanese (makeTag tagMessenger)

        Spanish ->
            spanish (makeTag tagMessenger)



-- ACTUAL DATA


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
            [ t "クリエイターです。"
            , tag Tag.VideoGame "ゲーム"
            , t "や"
            , tag Tag.Web "ウェブ"
            , t "の物など、"
            , tag Tag.Digital "デジタルの物"
            , t "を作ることが好きです。"
            , tag Tag.UserInterface "ユーザーインタフェース"
            , t "をデザインしたり、"
            , tag Tag.Graphic "グラフィック"
            , t "を設計したりします。"
            , tag Tag.Video "映像"
            , t "も撮ったり編集したりします。"
            ]
        , p
            [ t "言語オタクだと言えます。流暢に話せるのは３つ（スペイン語・英語・日本語）で、現在４つ目（中国語）で頑張っています。"
            , tag Tag.Translation "翻訳"
            , t "や字幕の仕事をしたりします。"
            ]
        , p
            [ t "習得についてよく考えます。テクノロジーと教育という会社に"
            , tag Tag.EducationalSoftware "教育ソフト"
            , t "を開発したことがあります。時に"
            , tag Tag.LanguageTeaching "言語を教える"
            , t "こともあります。"
            ]
        ]


spanish tag =
    d
        [ p
            [ t "Me llamo "
            , bold (t "Ale Grilli")
            , t ". Vivo en Santiago, Chile. Mi trabajo coincide con diversas intersecciones entre las siguientes cuatro áreas."
            ]
        , list
            [ tag Tag.VisualCommunication "Comunicación visual"
            , tag Tag.Programming "Programación"
            , tag Tag.Language "Idiomas"
            , tag Tag.Learning "Aprendizaje"
            ]
        , p
            [ t "Soy un creador. Hago "
            , tag Tag.Digital "cosas digitales"
            , t ", como "
            , tag Tag.VideoGame "videojuegos"
            , t " y "
            , tag Tag.Web "cosas web"
            , t ". Diseño "
            , tag Tag.UserInterface "interfaces de usuario"
            , t " y "
            , tag Tag.Graphic "gráficos"
            , t ". Creo y edito "
            , tag Tag.Video "videos"
            , t " ocasionalmente."
            ]
        , p
            [ t "Soy un “ñoño” de los idiomas. Soy fluído en tres idiomas (español, inglés, japonés), y estoy trabajando en un cuarto (chino mandarín). Trabajo "
            , tag Tag.Translation "traduciendo"
            , t " y subtitulando también."
            ]
        , p
            [ t "Pienso mucho sobre el aprendizaje. He trabajado para compañías de tecnología y educación, programando "
            , tag Tag.EducationalSoftware "software educativo"
            , t ". A veces "
            , tag Tag.LanguageTeaching "enseño idiomas"
            , t "."
            ]
        ]
