module Data.Labels exposing (Labels, ofLanguage)

import Language exposing (..)


type alias Labels =
    { title : String
    , readMoreEnglish : String
    , readMoreJapanese : String
    , readMoreSpanish : String
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
    , readMoreEnglish = "Read more about it."
    , readMoreJapanese = "Read more about it (in Japanese)."
    , readMoreSpanish = "Read more about it (in Spanish)."
    }


japanese =
    { title = "アレ・グリリのポートフォリオ"
    , readMoreEnglish = "さらに詳しく（英語）。"
    , readMoreJapanese = "さらに詳しく。"
    , readMoreSpanish = "さらに詳しく（スペイン語）。"
    }


spanish =
    { title = "Portafolio de Ale Grilli"
    , readMoreEnglish = "Lee más al respecto (en inglés)."
    , readMoreJapanese = "Lee más al respecto (en japonés)."
    , readMoreSpanish = "Lee más al respecto."
    }
