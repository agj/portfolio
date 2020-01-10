module Data.Labels exposing (Labels, ofLanguage)

import Language exposing (..)


type alias Labels =
    { title : String
    , readMoreEnglish : String
    , readMoreJapanese : String
    , readMoreSpanish : String
    , loading : String
    , loadError : String
    , pleaseSelect : String
    }


ofLanguage : Language -> Labels
ofLanguage language =
    case language of
        English ->
            english

        Japanese ->
            japanese

        Spanish ->
            spanish



-- ACTUAL DATA


english =
    { title = "Ale Grilli's portfolio"
    , readMoreEnglish = "Read more about it"
    , readMoreJapanese = "Read more about it (in Japanese)"
    , readMoreSpanish = "Read more about it (in Spanish)"
    , loading = "Loading…"
    , loadError = "Load error! Please try refreshing the page."
    , pleaseSelect = "Select a keyword from above"
    }


japanese =
    { title = "アレ・グリリのポートフォリオ"
    , readMoreEnglish = "さらに詳しく（英語）"
    , readMoreJapanese = "さらに詳しく"
    , readMoreSpanish = "さらに詳しく（スペイン語）"
    , loading = "読み込み中…"
    , loadError = "データの読み込みできませんでした。リロードを試してください。"
    , pleaseSelect = "上からキーワードを選択してください"
    }


spanish =
    { title = "Portafolio de Ale Grilli"
    , readMoreEnglish = "Lee más al respecto (en inglés)"
    , readMoreJapanese = "Lee más al respecto (en japonés)"
    , readMoreSpanish = "Lee más al respecto"
    , loading = "Cargando…"
    , loadError = "Error de carga. Por favor intenta cargar la página otra vez."
    , pleaseSelect = "Elige alguna palabra de arriba"
    }
