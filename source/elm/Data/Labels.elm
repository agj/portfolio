module Data.Labels exposing (Labels, ofLanguage)

import Descriptor exposing (icon, iconStroke, oscillate, p, t)
import Element exposing (Element)
import Language exposing (Language(..))
import Tag exposing (Tag)
import View.Icon


type alias Labels msg =
    { title : String
    , readMoreEnglish : String
    , readMoreJapanese : String
    , readMoreSpanish : String
    , loading : Element msg
    , loadError : Element msg
    , pleaseSelect : Element msg
    , thatsAll : { tag : Tag, onClearTag : msg } -> Element msg
    }


ofLanguage : Language -> Labels msg
ofLanguage language =
    case language of
        English ->
            english

        Japanese ->
            japanese

        Spanish ->
            spanish



-- ACTUAL DATA


english : Labels msg
english =
    { title = "Ale Grilli's portfolio"
    , readMoreEnglish = "Read more about it"
    , readMoreJapanese = "Read more about it (in Japanese)"
    , readMoreSpanish = "Read more about it (in Spanish)"
    , loading =
        p
            [ icon View.Icon.Hourglass
            , t " Loading…"
            ]
    , loadError =
        p
            [ icon View.Icon.LoadError
            , t " Failed loading the data. Please try refreshing the page."
            ]
    , pleaseSelect =
        p
            [ icon View.Icon.HandUp
                |> oscillate
            , t " Press a keyword from above!"
            ]
    , thatsAll =
        \{ tag, onClearTag } ->
            if tag == Tag.Any then
                p
                    [ t "That was all of them. "
                    , iconStroke View.Icon.Check
                    , t " "
                    , t "You may go back up and filter by a keyword."
                        |> Descriptor.onClick onClearTag
                    ]

            else
                p
                    [ t "That was all related to “"
                    , t (Tag.name English tag)
                    , t ".” "
                    , iconStroke View.Icon.Check
                    , t " "
                    , t "You may go back up and choose another keyword!"
                        |> Descriptor.onClick onClearTag
                    ]
    }


japanese : Labels msg
japanese =
    { title = "アレ・グリリのポートフォリオ"
    , readMoreEnglish = "もっと詳しく（英語）"
    , readMoreJapanese = "もっと詳しく"
    , readMoreSpanish = "もっと詳しく（スペイン語）"
    , loading =
        p
            [ icon View.Icon.Hourglass
            , t " 読み込み中…"
            ]
    , loadError =
        p
            [ icon View.Icon.LoadError
            , t " データの読み込みが失敗しました。リロードを試してください。"
            ]
    , pleaseSelect =
        p
            [ icon View.Icon.HandUp
                |> oscillate
            , t " 上のキーワードを一つ押してみましょう！"
            ]
    , thatsAll =
        \{ tag, onClearTag } ->
            if tag == Tag.Any then
                p
                    [ t "以上は全ての項目でした。"
                    , iconStroke View.Icon.Check
                    , t " "
                    , t "上に戻りキーワードを選択すればフィルターできます。"
                        |> Descriptor.onClick onClearTag
                    ]

            else
                p
                    [ t "以上「"
                    , t (Tag.name Japanese tag)
                    , t "」に関連する項目でした。"
                    , iconStroke View.Icon.Check
                    , t " "
                    , t "また別のキーワードを選択してみますか？"
                        |> Descriptor.onClick onClearTag
                    ]
    }


spanish : Labels msg
spanish =
    { title = "Portafolio de Ale Grilli"
    , readMoreEnglish = "Lee más al respecto (en inglés)"
    , readMoreJapanese = "Lee más al respecto (en japonés)"
    , readMoreSpanish = "Lee más al respecto"
    , loading =
        p
            [ icon View.Icon.Hourglass
            , t " Cargando…"
            ]
    , loadError =
        p
            [ icon View.Icon.LoadError
            , t " Error cargando datos. Por favor intenta cargar la página otra vez."
            ]
    , pleaseSelect =
        p
            [ icon View.Icon.HandUp
                |> oscillate
            , t " ¡Aprieta alguna palabra clave de arriba!"
            ]
    , thatsAll =
        \{ tag, onClearTag } ->
            if tag == Tag.Any then
                p
                    [ t "Eso fue todo. "
                    , iconStroke View.Icon.Check
                    , t " "
                    , t "Si quieres, puedes filtrar por una palabra clave."
                        |> Descriptor.onClick onClearTag
                    ]

            else
                p
                    [ t "Eso fue todo lo relacionado con “"
                    , t (Tag.name Spanish tag)
                    , t "”. "
                    , iconStroke View.Icon.Check
                    , t " "
                    , t "¿Quieres elegir otra palabra clave?"
                        |> Descriptor.onClick onClearTag
                    ]
    }
