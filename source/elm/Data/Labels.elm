module Data.Labels exposing (Labels, ofLanguage)

import Descriptor exposing (icon, iconStroke, oscillate, p, t)
import Element exposing (Element)
import Language exposing (Language(..))
import View.Icon


type alias Labels msg =
    { title : String
    , readMoreEnglish : String
    , readMoreJapanese : String
    , readMoreSpanish : String
    , loading : Element msg
    , loadError : Element msg
    , pleaseSelect : Element msg
    , thatsAll : { onClearTag : msg } -> Element msg
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
        \{ onClearTag } ->
            p
                [ t "That's all for that keyword. "
                , iconStroke View.Icon.Check
                , t " "
                , t "You may go back up and choose another!"
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
        \{ onClearTag } ->
            p
                [ t "以上このキーワードに関連する項目でした。"
                , iconStroke View.Icon.Check
                , t " "
                , t "また別のを選択してみますか？"
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
        \{ onClearTag } ->
            p
                [ t "Eso es todo para esta palabra clave. "
                , iconStroke View.Icon.Check
                , t " "
                , t "¿Quieres elegir otra?"
                    |> Descriptor.onClick onClearTag
                ]
    }
