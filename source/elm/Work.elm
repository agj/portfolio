module Work exposing (Date(..), Link, ReadMore, VideoDescription, VideoHost(..), Visual(..), Work, WorkLanguages, languages, ofLanguage)

import Element exposing (Element)
import Language exposing (..)
import Tag exposing (Tag)


type WorkLanguages msg
    = WorkLanguages
        { english : Work msg
        , japanese : Work msg
        , spanish : Work msg
        }


type alias Work msg =
    { name : String
    , description : Element msg
    , mainVisualUrl : String
    , date : Date
    , tags : List Tag
    , visuals : List Visual
    , links : List Link
    , readMore : Maybe ReadMore
    }


type alias ReadMore =
    { url : String
    , language : Language
    }


type Date
    = Date String


type Visual
    = Image
        { thumbnailUrl : String
        , url : String
        , aspectRatio : Float
        }
    | Video VideoDescription


type alias VideoDescription =
    { thumbnailUrl : String
    , id : String
    , aspectRatio : Float
    , host : VideoHost
    }


type VideoHost
    = Youtube
    | Vimeo


type alias Link =
    { label : String
    , url : String
    }



-- ACCESSORS


languages : { english : Work msg, japanese : Work msg, spanish : Work msg } -> WorkLanguages msg
languages data =
    WorkLanguages data


ofLanguage : Language -> WorkLanguages msg -> Work msg
ofLanguage language workLanguages =
    let
        data =
            case workLanguages of
                WorkLanguages d ->
                    d
    in
    case language of
        English ->
            data.english

        Japanese ->
            data.japanese

        Spanish ->
            data.spanish
