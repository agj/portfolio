module Data.Introduction exposing (ofLanguage)

import CustomEl
import Descriptor exposing (..)
import Element exposing (Element)
import Element.Background as Background
import Language exposing (..)
import Palette
import Tag exposing (Tag)
import Utils exposing (..)


ofLanguage : (Tag -> msg) -> Maybe Tag -> Language -> Element msg
ofLanguage tagMessenger selectedTag language =
    case language of
        English ->
            english (makeTag tagMessenger selectedTag)

        Japanese ->
            japanese (makeTag tagMessenger selectedTag)

        Spanish ->
            spanish (makeTag tagMessenger selectedTag)



-- ACTUAL DATA


english tag =
    d
        [ p
            [ t "My name is "
            , bold <| t "Ale Grilli"
            , t "—thank you for perusing my "
            , bold <| t "portfolio"
            , t ". I’m based in Santiago, Chile. My work is concerned with various intersections of four areas—"
            , tag Tag.VisualCommunication "Visual Communication"
            , icon "visual-communication"
            , t ", "
            , tag Tag.Programming "Programming"
            , icon "programming"
            , t ", "
            , tag Tag.Language "Language"
            , icon "language"
            , t ", and "
            , tag Tag.Learning "Learning"
            , icon "learning"
            , t ". I'm a master in new media from Tokyo Geidai, graphic designer from U. Diego Portales, and self-taught programmer."
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
            , t " and other "
            , tag Tag.Interactive "interactive things"
            , t ", as well as "
            , tag Tag.Graphic "graphics"
            , t ". I shoot and edit "
            , tag Tag.Video "videos"
            , t " on occasion."
            ]
        , p
            [ t "I’m a languages nerd, fluent in two second languages (English, Japanese) and working on a third (Chinese Mandarin.) I do "
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
        , p
            [ t "To see examples of my work, choose any of the highlighted keywords above. Or you can choose to see "
            , tag Tag.Any "all"
            , t " of them at once."
            ]
        ]


japanese tag =
    d
        [ p
            [ bold <| t "アレ・グリリ（Ale Grilli）"
            , t "の"
            , bold <| t "ポートフォリオ"
            , t "をご覧いただきありがとうございます。拠点をチリのサンティアゴにしている者です。"
            , tag Tag.VisualCommunication "視覚コミュニケーション"
            , t "、"
            , tag Tag.Programming "プログラミング"
            , t "、"
            , tag Tag.Language "言語"
            , t "、"
            , tag Tag.Learning "習得"
            , t "という４つのエリアの組み合わせで活動します。東京藝大大学院のメディア映像や、チリ Diego Portales 大学グラフィックデザイン学部の卒業生です。プログラミングを独学しました。"
            ]
        , p
            [ t "クリエイターであって、"
            , tag Tag.VideoGame "ゲーム"
            , t "や"
            , tag Tag.Web "ウェブ"
            , t "など、"
            , tag Tag.Digital "デジタル"
            , t "の物を作ることが多いです。"
            , tag Tag.UserInterface "ユーザーインタフェース"
            , t "やその他"
            , tag Tag.Interactive "インタラクティブ"
            , t "と"
            , tag Tag.Graphic "グラフィック"
            , t "をデザインしたりします。"
            , tag Tag.Video "映像"
            , t "も撮ったり編集したりします。"
            ]
        , p
            [ t "自称言語オタクです。第二言語２つ（英語・日本語）が流暢で、現在３つ目（中国語）を目指しています。"
            , tag Tag.Translation "翻訳"
            , t "や字幕の仕事をしたりします。"
            ]
        , p
            [ t "「習得」についてよく考えます。教育テクノロジーの会社で"
            , tag Tag.EducationalSoftware "教育ソフト"
            , t "を開発したことがあります。時折"
            , tag Tag.LanguageTeaching "言語を教える"
            , t "ことがあります。"
            ]
        , p
            [ t "作ってきた作品や仕事の例を見るには上のキーワードから一つ選択してください。もしくは"
            , tag Tag.Any "全て"
            , t "を一気に見ることもできます。"
            ]
        ]


spanish tag =
    d
        [ p
            [ t "Me llamo "
            , bold <| t "Ale Grilli"
            , t "—gracias por revisar mi "
            , bold <| t "portafolio"
            , t ". Vivo en Santiago, Chile. Mi trabajo coincide con diversas intersecciones de cuatro áreas: "
            , tag Tag.VisualCommunication "Comunicación Visual"
            , t ", "
            , tag Tag.Programming "Programación"
            , t ", "
            , tag Tag.Language "Idiomas"
            , t ", y "
            , tag Tag.Learning "Aprendizaje"
            , t ". Soy magíster en nuevos medios de Tokyo Geidai, diseñador gráfico de U. Diego Portales, y programador autoenseñado."
            ]
        , p
            [ t "Soy un creador. Hago cosas "
            , tag Tag.Digital "digitales"
            , t ", como "
            , tag Tag.VideoGame "videojuegos"
            , t " y otras para la "
            , tag Tag.Web "web"
            , t ". Diseño "
            , tag Tag.UserInterface "interfaces de usuario"
            , t " y otros "
            , tag Tag.Interactive "interactivos"
            , t ", además de "
            , tag Tag.Graphic "gráfica"
            , t ". Creo y edito "
            , tag Tag.Video "videos"
            , t " ocasionalmente."
            ]
        , p
            [ t "Soy fanático de los idiomas. Hablo fluído dos segundas lenguas (inglés, japonés), y estoy aprendiendo una tercera (chino mandarín). Trabajo "
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
        , p
            [ t "Para ver ejemplos de mi trabajo, elige alguna de las palabras destacadas de arriba. También puedes elegir verlos "
            , tag Tag.Any "todos"
            , t " juntos."
            ]
        ]



-- INTERNAL


icon : String -> Element msg
icon name =
    CustomEl.imageInline
        [ Element.width (Element.px <| fraction 1.5 Palette.textSizeNormal)
        , Element.height (Element.px <| fraction 1.5 Palette.textSizeNormal)
        , CustomEl.inlineCenter
        ]
        { src = "image/icon-" ++ name ++ "-light.svg"
        , description = " "
        }
