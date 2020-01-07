module Work exposing (Date(..), Link, ReadMore, VideoDescription, VideoHost(..), Visual(..), Work, WorkLanguages, allWorksDecoder, languages, ofLanguage)

import Element exposing (Element)
import Element.Font as Font
import Json.Decode as Decode exposing (Decoder, andThen, float, list, nullable, oneOf, string)
import Json.Decode.Pipeline exposing (required)
import Language exposing (..)
import Mark
import Mark.Error
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



-- DECODERS


allWorksDecoder : Decoder (List (WorkLanguages msg))
allWorksDecoder =
    list workLanguagesDecoder


workLanguagesDecoder : Decoder (WorkLanguages msg)
workLanguagesDecoder =
    Decode.succeed (\en ja es -> WorkLanguages { english = en, japanese = ja, spanish = es })
        |> required "en" workDecoder
        |> required "ja" workDecoder
        |> required "es" workDecoder


workDecoder : Decoder (Work msg)
workDecoder =
    Decode.succeed Work
        |> required "name" string
        |> required "description" emuDecoder
        |> required "mainVisualUrl" string
        |> required "date" dateDecoder
        |> required "tags" (list Tag.decoder)
        |> required "visuals" (list visualDecoder)
        |> required "links" (list linkDecoder)
        |> required "readMore" (nullable readMoreDecoder)


emuDecoder : Decoder (Element msg)
emuDecoder =
    string
        |> andThen
            (\raw ->
                Decode.succeed (renderEmu raw)
            )


renderEmu : String -> Element msg
renderEmu raw =
    case Mark.compile emuDocument raw of
        Mark.Success result ->
            result

        Mark.Almost { result, errors } ->
            Element.column []
                (List.map (Mark.Error.toString >> Element.text) errors)

        Mark.Failure errors ->
            Element.column []
                (List.map (Mark.Error.toString >> Element.text) errors)


emuDocument : Mark.Document (Element msg)
emuDocument =
    Mark.document
        (Element.column [])
        (Mark.text styledTextToEl)


styledTextToEl styles str =
    Element.text str


dateDecoder : Decoder Date
dateDecoder =
    string |> andThen (\date -> Decode.succeed (Date date))


visualDecoder : Decoder Visual
visualDecoder =
    let
        imageDecoder =
            Decode.succeed (\tUrl url ar -> Image { thumbnailUrl = tUrl, url = url, aspectRatio = ar })
                |> required "thumbnailUrl" string
                |> required "url" string
                |> required "aspectRatio" float

        videoDecoder =
            Decode.succeed (\tUrl id ar host -> Video { thumbnailUrl = tUrl, id = id, aspectRatio = ar, host = host })
                |> required "thumbnailUrl" string
                |> required "id" string
                |> required "aspectRatio" float
                |> required "host" videoHostDecoder
    in
    oneOf
        [ imageDecoder
        , videoDecoder
        ]


videoHostDecoder : Decoder VideoHost
videoHostDecoder =
    string
        |> andThen
            (\hostString ->
                case hostString of
                    "Youtube" ->
                        Decode.succeed Youtube

                    "Vimeo" ->
                        Decode.succeed Vimeo

                    other ->
                        Decode.fail <| "Video host unknown: " ++ other
            )


linkDecoder : Decoder Link
linkDecoder =
    Decode.succeed Link
        |> required "label" string
        |> required "url" string


readMoreDecoder : Decoder ReadMore
readMoreDecoder =
    Decode.succeed { url = "http://example.com", language = English }
