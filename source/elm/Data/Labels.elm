module Data.Labels exposing (Labels, ofLanguage)

import Language exposing (..)


type alias Labels =
    { title : String
    , backToHome : String
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
    , backToHome = "Back to agj.cl"
    , readMoreEnglish = "Read more about it"
    , readMoreJapanese = "Read more about it (in Japanese)"
    , readMoreSpanish = "Read more about it (in Spanish)"
    , loading = "Loading…"
    , loadError = "Load error! Please try refreshing the page."
    , pleaseSelect = "Select a keyword from above"
    }


japanese =
    { title = "アレ・グリリのポートフォリオ"
    , backToHome = "agj.cl に戻る"
    , readMoreEnglish = "もっと詳しく（英語）"
    , readMoreJapanese = "もっと詳しく"
    , readMoreSpanish = "もっと詳しく（スペイン語）"
    , loading = "読み込み中…"
    , loadError = "データの読み込みはできませんでした。リロードを試してください。"
    , pleaseSelect = "上からキーワードを選択してください"
    }


spanish =
    { title = "Portafolio de Ale Grilli"
    , backToHome = "Volver a agj.cl"
    , readMoreEnglish = "Lee más al respecto (en inglés)"
    , readMoreJapanese = "Lee más al respecto (en japonés)"
    , readMoreSpanish = "Lee más al respecto"
    , loading = "Cargando…"
    , loadError = "Error de carga. Por favor intenta cargar la página otra vez."
    , pleaseSelect = "Elige alguna palabra de arriba"
    }
