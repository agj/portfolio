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
            , t "—thank you for taking a look at my "
            , bold <| t "portfolio"
            , t ". "
            , t "I’m based in Santiago, Chile. "
            , t "My work is concerned with various intersections of four areas—"
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
            , t ". "
            , t "I'm a master in new media from Tokyo Geidai (Japan), graphic designer from U. Diego Portales (Chile), and a self-taught programmer."
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
            , t "."
            ]
        , p
            [ t "I’m a languages nerd, fluent in English and Japanese, apart from my native Spanish, and also working on my Mandarin Chinese currently. "
            , t "I do "
            , tag Tag.Translation "translation"
            , t " work; subtitling too."
            ]
        , p
            [ t "I think a lot about learning. "
            , t "I’ve worked for ed-tech companies programming "
            , tag Tag.EducationalSoftware "educational software"
            , t ". I occasionally "
            , tag Tag.LanguageTeaching "teach languages"
            , t " as well."
            ]
        , p
            [ t "To see examples of my work, choose any of the highlighted keywords above. "
            , t "Or you can choose to see "
            , tag Tag.Any "all"
            , t " of them at once. "
            , t "Get in touch via email at "
            , bold <| t "ale¶agj.cl"
            , t " (¶\u{00A0}=\u{00A0}@), or "
            , l "Mastodon" (Url "https://mstdn.social/@agj")
            , t "!"
            ]
        ]


japanese tag =
    d
        [ p
            [ bold <| t "アレ・グリリ（Ale Grilli）"
            , t "の"
            , bold <| t "ポートフォリオ"
            , t "をご覧いただきありがとうございます。"
            , t "拠点をチリのサンティアゴにしている者です。"
            , tag Tag.VisualCommunication "視覚コミュニケーション"
            , icon "visual-communication"
            , t "、"
            , tag Tag.Programming "プログラミング"
            , icon "programming"
            , t "、"
            , tag Tag.Language "言語"
            , icon "language"
            , t "、"
            , tag Tag.Learning "習得"
            , icon "learning"
            , t "という４つのエリアの組み合わせで活動してきました。"
            , t "東京芸術大学大学院のメディア映像専攻や、チリ Diego Portales 大学グラフィックデザイン学部の卒業生です。"
            , t "プログラミングを独学しました。"
            ]
        , p
            [ t "クリエイターです。"
            , tag Tag.VideoGame "ゲーム"
            , t "や"
            , tag Tag.Web "ウェブ"
            , t "など、"
            , tag Tag.Digital "デジタル"
            , t "の何かしらを作ることが多いです。"
            , tag Tag.UserInterface "ユーザーインタフェース"
            , t "などいった"
            , tag Tag.Interactive "インタラクティブ"
            , t "や"
            , tag Tag.Graphic "グラフィック"
            , t "をデザインしたりします。"
            , tag Tag.Video "映像"
            , t "作成にも手を組んだりします。"
            ]
        , p
            [ t "言語オタクだと言っていいくらい言語が好きです。"
            , t "ネイティブのスペイン語に加えて英語と日本語が流暢で、現在中国語能力を上げることに集中しています。"
            , tag Tag.Translation "翻訳"
            , t "や字幕の仕事をしたりします。"
            ]
        , p
            [ t "「習得」についてよく考えます。"
            , t "教育テクノロジーの会社で"
            , tag Tag.EducationalSoftware "教育ソフト"
            , t "を開発したことがあります。時折"
            , tag Tag.LanguageTeaching "言語を教える"
            , t "ことがあります。"
            ]
        , p
            [ t "作ってきた作品や仕事の例を見るには上のキーワードから一つ選択してから以下から閲覧できることになります。"
            , tag Tag.Any "全て"
            , t "を一気に見ることもできます。"
            , t "連絡はメール（"
            , bold <| t "ale¶agj.cl"
            , t "；¶\u{00A0}=\u{00A0}@）、あるいは"
            , l "マストドン" (Url "https://mstdn.social/@agj")
            , t "よりお願いします。"
            , t "ご連絡を待っております！"
            ]
        ]


spanish tag =
    d
        [ p
            [ t "Me llamo "
            , bold <| t "Ale Grilli"
            , t "—gracias por revisar mi "
            , bold <| t "portafolio"
            , t ". Vivo en Santiago de Chile. Mi trabajo coincide con diversas intersecciones de cuatro áreas: "
            , tag Tag.VisualCommunication "Comunicación Visual"
            , icon "visual-communication"
            , t ", "
            , tag Tag.Programming "Programación"
            , icon "programming"
            , t ", "
            , tag Tag.Language "Idiomas"
            , icon "language"
            , t ", y "
            , tag Tag.Learning "Aprendizaje"
            , icon "learning"
            , t ". Soy magíster en nuevos medios de Tokyo Geidai (Japón), diseñador gráfico de U. Diego Portales (Chile), y programador autoenseñado."
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
            , t "."
            ]
        , p
            [ t "Soy fanático de los idiomas. Además de mi español nativo, hablo fluído inglés y japonés, y estoy aprendiendo chino mandarín. Trabajo "
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
            , t " juntos. "
            , t "Contáctame por correo a "
            , bold <| t "ale¶agj.cl"
            , t " (¶\u{00A0}=\u{00A0}@), o por "
            , l "Mastodon" (Url "https://mstdn.social/@agj")
            , t "."
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
