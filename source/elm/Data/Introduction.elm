module Data.Introduction exposing (ofLanguage)

import Descriptor exposing (Url(..), bold, d, icon, iconStroke, l, makeTag, p, t)
import Element exposing (Element)
import Language exposing (Language(..))
import Tag exposing (Tag)
import View.Icon


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


english : (Tag -> String -> Element msg) -> Element msg
english tag =
    d
        [ p
            [ t "My name is "
            , bold (t "Ale Grilli")
            , t ". Thank you for taking a look at my "
            , bold (t "portfolio")
            , t "!"
            ]
        , p
            [ t "I’m based in Santiago, Chile. "
            , t "I’ve mostly done work in various intersections of four areas: "
            , tag Tag.Programming "Programming"
            , icon View.Icon.Programming
            , t ", "
            , tag Tag.VisualCommunication "Visual Communication"
            , icon View.Icon.VisualCommunication
            , t ", "
            , tag Tag.Language "Language"
            , icon View.Icon.Language
            , t ", and "
            , tag Tag.Learning "Learning"
            , icon View.Icon.Learning
            , t "."
            ]
        , p
            [ t "I’m a master in new media art from Tokyo Geidai (Japan, 2017,) graphic designer from U. Diego Portales (Chile, 2009,) "
            , t "and a self-taught programmer from a young age, starting with web and Flash stuff."
            ]
        , p
            [ t "I’m a creator. I’ve made "
            , tag Tag.Digital "digital things"
            , t ", such as "
            , tag Tag.Web "web stuff"
            , t " and "
            , tag Tag.VideoGame "games"
            , t ". I’ve designed "
            , tag Tag.UserInterface "user interfaces"
            , t " and other "
            , tag Tag.Interactive "interactive things"
            , t ", as well as "
            , tag Tag.Graphic "graphics"
            , t ". I’ve shot and edited "
            , tag Tag.Video "videos"
            , t "."
            ]
        , p
            [ t "I’m a languages nerd, fluent in English and Japanese, apart from my native Spanish, and currently working on my Mandarin Chinese. "
            , t "I have done "
            , tag Tag.Translation "translation"
            , t " and subtitling."
            ]
        , p
            [ t "I think a lot about learning. "
            , t "I’ve worked for ed-tech companies, programming "
            , tag Tag.EducationalSoftware "educational software"
            , t ". I have also "
            , tag Tag.LanguageTeaching "taught languages"
            , t "."
            ]
        , p
            [ t "You will see a selection of my personal, student and work projects if you "
            , bold (t "press any of the highlighted keywords above.")
            , t " Or you can choose to see "
            , tag Tag.Any "all of them"
            , t " at once, regardless of category."
            ]
        , p
            [ t "Get in touch! Send me an email at "
            , bold (t "ale")
            , iconStroke View.Icon.At
            , bold (t "agj.cl")
            , t ", or message me on "
            , l "Mastodon" (Url "https://mstdn.social/@agj")
            , t ". "
            , icon View.Icon.Star
            ]
        ]


japanese : (Tag -> String -> Element msg) -> Element msg
japanese tag =
    d
        [ p
            [ bold (t "アレ・グリリ（Ale Grilli）")
            , t "の"
            , bold (t "ポートフォリオ")
            , t "をご覧いただきありがとうございます！"
            ]
        , p
            [ t "私は拠点を南米チリのサンティアゴにする者です。"
            , tag Tag.Programming "プログラミング"
            , icon View.Icon.Programming
            , t "、"
            , tag Tag.VisualCommunication "ビジュアルコミュニケーション"
            , icon View.Icon.VisualCommunication
            , t "、"
            , tag Tag.Language "言語"
            , icon View.Icon.Language
            , t "、"
            , tag Tag.Learning "学習"
            , icon View.Icon.Learning
            , t "という４つのエリアで主に活動してきました。"
            ]
        , p
            [ t "正規教育は東京藝術大学大学院メディア映像専攻（2017年卒）と、"
            , t "ディエゴ・ポルタレス大学グラフィックデザイン学部（チリ・2009年卒）です。"
            , t "プログラミングは独学として身についたもので、幼い頃から Web・スクリプト・フラッシュ等で遊んで覚え始めました。"
            ]
        , p
            [ t "クリエイターとして主に生み出してきたのは "
            , tag Tag.Web "Web"
            , t "・"
            , tag Tag.VideoGame "ゲーム"
            , t "など、とにかく"
            , tag Tag.Digital "デジタル"
            , t "領域の物です。"
            , t "デザイナーとして"
            , tag Tag.Graphic "グラフィック"
            , t "がもちろんありますが、主に"
            , tag Tag.UserInterface "ＵＩデザイン"
            , t "や他に"
            , tag Tag.Interactive "インタラクティブ"
            , t "系の物に手掛けてきました。"
            , tag Tag.Video "映像"
            , t "の制作にも手をつけたことがあります。"
            ]
        , p
            [ t "言語オタクだと宣言します。"
            , t "ネイティブのスペイン語に加えて英語と日本語が（未熟な点が多々ありながら）流暢です。"
            , t "現在中国語能力を向上させている最中です。"
            , tag Tag.Translation "翻訳"
            , t "や字幕を作る経験があります。"
            ]
        , p
            [ t "「学習」という概念について常々考えます。"
            , t "教育工学の会社で"
            , tag Tag.EducationalSoftware "教育ソフト"
            , t "を開発する経験があります。"
            , tag Tag.LanguageTeaching "言語を教えた"
            , t "こともあります。"
            ]
        , p
            [ bold (t "上記に強調表示されたキーワードを一つ押して")
            , t "おけば、関連する私の作ってきた作品やプロジェクトをいくつかご覧いただけます。"
            , t "分類を問わず"
            , tag Tag.Any "全てを一気に"
            , t "見ることもできます。"
            ]
        , p
            [ t "気楽にご連絡ください！連絡先はＥメールの "
            , bold (t "ale")
            , iconStroke View.Icon.At
            , bold (t "agj.cl")
            , t "、または"
            , l "マストドン" (Url "https://mstdn.social/@agj")
            , t "よりお願いします。お待ちしております！"
            , icon View.Icon.Star
            ]
        ]


spanish : (Tag -> String -> Element msg) -> Element msg
spanish tag =
    d
        [ p
            [ t "Me llamo "
            , bold (t "Ale Grilli")
            , t ". ¡Gracias por revisar mi "
            , bold (t "portafolio")
            , t "!"
            ]
        , p
            [ t "Vivo en Santiago de Chile. "
            , t "He operado principalmente en cuatro áreas: "
            , tag Tag.Programming "Programación"
            , icon View.Icon.Programming
            , t ", "
            , tag Tag.VisualCommunication "Comunicación Visual"
            , icon View.Icon.VisualCommunication
            , t ", "
            , tag Tag.Language "Idiomas"
            , icon View.Icon.Language
            , t " y "
            , tag Tag.Learning "Aprendizaje"
            , icon View.Icon.Learning
            , t "."
            ]
        , p
            [ t "Soy magíster en nuevos medios de Tokyo Geidai (Japón, 2017), "
            , t "diseñador gráfico de U. Diego Portales (Chile, 2009), "
            , t "y programador autodidacta desde niño. Di mis primeros pasos con cosas para la web y Flash."
            ]
        , p
            [ t "Soy un creador. He hecho cosas "
            , tag Tag.Digital "digitales"
            , t ", como "
            , tag Tag.VideoGame "videojuegos"
            , t " y "
            , tag Tag.Web "cosas web"
            , t ". He diseñado "
            , tag Tag.UserInterface "interfaces de usuario"
            , t " y otras "
            , tag Tag.Interactive "cosas interactivas"
            , t ", además de "
            , tag Tag.Graphic "gráfica"
            , t ". He grabado y editado "
            , tag Tag.Video "videos"
            , t "."
            ]
        , p
            [ t "Soy fanático de los idiomas. "
            , t "Además de mi español nativo, hablo fluído inglés y japonés, y estoy aprendiendo chino mandarín. "
            , t "He trabajado "
            , tag Tag.Translation "traduciendo"
            , t " y subtitulando videos."
            ]
        , p
            [ t "El aprendizaje es un tema sobre el que pienso mucho. "
            , t "He trabajado para compañías de tecnología para la educación, programando "
            , tag Tag.EducationalSoftware "software educativo"
            , t ". También me ha tocado "
            , tag Tag.LanguageTeaching "enseñar idiomas"
            , t "."
            ]
        , p
            [ t "Si "
            , bold (t "apretas alguna de las palabras destacadas de arriba")
            , t " verás algunos ejemplos de cosas relacionadas que hecho. "
            , t "También puedes elegir verlos "
            , tag Tag.Any "todos juntos"
            , t ", sin distinguir por categoría."
            ]
        , p
            [ t "¡Contáctame! Me puedes mandar un correo a "
            , bold (t "ale")
            , iconStroke View.Icon.At
            , bold (t "agj.cl")
            , t ", o me puedes escribir en "
            , l "Mastodon" (Url "https://mstdn.social/@agj")
            , t ". "
            , icon View.Icon.Star
            ]
        ]
