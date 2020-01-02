module Data exposing (All, Data, Labels, all, ofLanguage)

import Data.Introduction as Introduction
import Element exposing (Element)
import Language exposing (..)
import Tag exposing (Tag)
import Work exposing (Work)
import Works


type alias Data msg =
    { introduction : Element msg
    , works : List (Work msg)
    , labels : Labels
    }


type alias Labels =
    { title : String
    , readMoreEnglish : String
    , readMoreJapanese : String
    , readMoreSpanish : String
    }


type All msg
    = All
        { english : Data msg
        , japanese : Data msg
        , spanish : Data msg
        }


all : (Tag -> msg) -> All msg
all tagMessenger =
    All
        { english =
            { introduction = Introduction.ofLanguage tagMessenger English
            , works = Works.ofLanguage English Works.all
            , labels =
                { title = "Ale Grilli's portfolio"
                , readMoreEnglish = "Read more about it."
                , readMoreJapanese = "Read more about it (in Japanese)."
                , readMoreSpanish = "Read more about it (in Spanish)."
                }
            }
        , japanese =
            { introduction = Introduction.ofLanguage tagMessenger Japanese
            , works = Works.ofLanguage Japanese Works.all
            , labels =
                { title = "アレ・グリリのポートフォリオ"
                , readMoreEnglish = "さらに詳しく（英語）。"
                , readMoreJapanese = "さらに詳しく。"
                , readMoreSpanish = "さらに詳しく（スペイン語）。"
                }
            }
        , spanish =
            { introduction = Introduction.ofLanguage tagMessenger Spanish
            , works = Works.ofLanguage Spanish Works.all
            , labels =
                { title = "Portafolio de Ale Grilli"
                , readMoreEnglish = "Lee más al respecto (en inglés)."
                , readMoreJapanese = "Lee más al respecto (en japonés)."
                , readMoreSpanish = "Lee más al respecto."
                }
            }
        }


ofLanguage : Language -> All msg -> Data msg
ofLanguage language allData =
    let
        data =
            case allData of
                All d ->
                    d
    in
    case language of
        English ->
            data.english

        Japanese ->
            data.japanese

        Spanish ->
            data.spanish
