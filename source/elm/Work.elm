module Work exposing (..)

import Element exposing (Element)
import Tag exposing (Tag)


type alias Work msg =
    { name : String
    , description : Element msg
    , mainVisualUrl : String
    , date : Date
    , tags : List Tag
    , visuals : List Visual
    , links : List Link
    , readMoreUrl : Maybe String
    }


type Date
    = Date String


type Visual
    = Image
        { thumbnailUrl : String
        , url : String
        }
    | Video
        { thumbnailUrl : String
        , url : String
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
