module Data.Introduction exposing (ofLanguage)

import Descriptor exposing (..)
import Element exposing (Element)
import Language exposing (..)
import Palette
import Tag exposing (Tag)
import Utils exposing (..)
import View.Icon exposing (IconName)


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
            , t ". Thank you for taking a look at my "
            , bold <| t "portfolio"
            , t "!"
            ]
        , p
            [ t "I’m based in Santiago, Chile. "
            , t "My work is concerned with various intersections of four areas—"
            , tag Tag.VisualCommunication "Visual Communication"
            , icon View.Icon.VisualCommunication
            , t ", "
            , tag Tag.Programming "Programming"
            , icon View.Icon.Programming
            , t ", "
            , tag Tag.Language "Language"
            , icon View.Icon.Language
            , t ", and "
            , tag Tag.Learning "Learning"
            , icon View.Icon.Learning
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
            , t " work occasionally; subtitling too."
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
            , t "をご覧いただきありがとうございます！"
            ]
        , p
            [ t "拠点をチリのサンティアゴにしている者です。"
            , tag Tag.VisualCommunication "視覚コミュニケーション"
            , icon View.Icon.VisualCommunication
            , t "、"
            , tag Tag.Programming "プログラミング"
            , icon View.Icon.Programming
            , t "、"
            , tag Tag.Language "言語"
            , icon View.Icon.Language
            , t "、"
            , tag Tag.Learning "習得"
            , icon View.Icon.Learning
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
            [ t "言語オタクだと言っても過言ではないほど言語が好きです。"
            , t "ネイティブのスペイン語に加えて英語と日本語が（未熟な点が多々ありながら）流暢で、現在中国語能力を上げることに集中しています。"
            , tag Tag.Translation "翻訳"
            , t "や字幕の仕事をすることもあります。"
            ]
        , p
            [ t "「習得」について頻繁に考えます。"
            , t "教育テクノロジーの会社で"
            , tag Tag.EducationalSoftware "教育ソフト"
            , t "を開発する経験があります。時折"
            , tag Tag.LanguageTeaching "言語を教える"
            , t "こともあります。"
            ]
        , p
            [ t "作ってきた作品や仕事の例を見るには上のキーワードから一つ選択してから閲覧できます。"
            , tag Tag.Any "全て"
            , t "を一気に見ることも可能です。"
            , t "連絡はＥメール（"
            , bold <| t "ale¶agj.cl"
            , t "；¶\u{00A0}=\u{00A0}@）、あるいは"
            , l "マストドン" (Url "https://mstdn.social/@agj")
            , t "よりお願いします。"
            , t "ご連絡をお待ちしております！"
            ]
        ]


spanish tag =
    d
        [ p
            [ t "Me llamo "
            , bold <| t "Ale Grilli"
            , t ". ¡Gracias por revisar mi "
            , bold <| t "portafolio"
            , t "!"
            ]
        , p
            [ t "Vivo en Santiago de Chile. Mi trabajo coincide con diversas intersecciones de cuatro áreas: "
            , tag Tag.VisualCommunication "Comunicación Visual"
            , icon View.Icon.VisualCommunication
            , t ", "
            , tag Tag.Programming "Programación"
            , icon View.Icon.Programming
            , t ", "
            , tag Tag.Language "Idiomas"
            , icon View.Icon.Language
            , t ", y "
            , tag Tag.Learning "Aprendizaje"
            , icon View.Icon.Learning
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
            [ t "Soy fanático de los idiomas. Además de mi español nativo, hablo fluído inglés y japonés, y estoy aprendiendo chino mandarín. En ocasiones trabajo "
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
