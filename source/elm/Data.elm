module Data exposing (All, Data, all, ofLanguage)

import Data.Introduction as Introduction
import Element exposing (Element)
import Language exposing (..)
import Tag exposing (Tag)
import Work exposing (Work)
import Works


type alias Data msg =
    { introduction : Element msg
    , works : List (Work msg)
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
            }
        , japanese =
            { introduction = Introduction.ofLanguage tagMessenger Japanese
            , works = Works.ofLanguage Japanese Works.all
            }
        , spanish =
            { introduction = Introduction.ofLanguage tagMessenger Spanish
            , works = Works.ofLanguage Spanish Works.all
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
