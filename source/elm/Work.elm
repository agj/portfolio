module Work exposing (Link, ReadMore, Work, WorkLanguages, allWorksDecoder, ofLanguage)

import Color exposing (Color)
import Doc exposing (Doc)
import Doc.Format as Format exposing (Format)
import Doc.Link
import Doc.Paragraph as Paragraph exposing (Paragraph)
import Doc.Text as Text exposing (Text)
import Json.Decode as Decode exposing (Decoder, list, maybe, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (Language(..))
import Mark
import Mark.Error
import Tag exposing (Tag)
import Work.Date as Date exposing (Date)
import Work.Visual as Visual exposing (Visual)


type WorkLanguages
    = WorkLanguages WorkLanguagesInternal


type alias WorkLanguagesInternal =
    { english : Work
    , japanese : Work
    , spanish : Work
    }


type alias Work =
    { name : String
    , description : Doc
    , mainVisualUrl : String
    , mainVisualColor : Color
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


type alias Link =
    { label : String
    , url : String
    }



-- ACCESSORS


ofLanguage : Language -> WorkLanguages -> Work
ofLanguage language workLanguages =
    let
        data : WorkLanguagesInternal
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


allWorksDecoder : Decoder (List WorkLanguages)
allWorksDecoder =
    list workLanguagesDecoder


workLanguagesDecoder : Decoder WorkLanguages
workLanguagesDecoder =
    Decode.succeed (\en ja es -> WorkLanguages { english = en, japanese = ja, spanish = es })
        |> required "en" workDecoder
        |> required "ja" workDecoder
        |> required "es" workDecoder


workDecoder : Decoder Work
workDecoder =
    Decode.succeed Work
        |> required "name" string
        |> required "description" emuDecoder
        |> required "mainVisualUrl" string
        |> required "mainVisualColor" Visual.colorDecoder
        |> required "date" Date.decoder
        |> required "tags" (list Tag.decoder)
        |> required "visuals" (list Visual.decoder)
        |> required "links" (list linkDecoder)
        |> optional "readMore" (maybe readMoreDecoder) Nothing


linkDecoder : Decoder Link
linkDecoder =
    Decode.succeed Link
        |> required "label" string
        |> required "url" string


readMoreDecoder : Decoder ReadMore
readMoreDecoder =
    Decode.succeed (\url language -> { url = url, language = language })
        |> required "url" string
        |> required "language" Language.decoder


emuDecoder : Decoder Doc
emuDecoder =
    string
        |> Decode.map (\raw -> renderEmu raw)


renderEmu : String -> Doc
renderEmu raw =
    let
        withErrors : List Mark.Error.Error -> Doc
        withErrors errors =
            List.map errorToParagraph errors
                |> Doc.create
    in
    case Mark.compile emuDocument raw of
        Mark.Success result ->
            result

        Mark.Almost { errors } ->
            withErrors errors

        Mark.Failure errors ->
            withErrors errors


errorToParagraph : Mark.Error.Error -> Paragraph
errorToParagraph error =
    Mark.Error.toString error
        |> Text.create (Format.empty |> Format.setCode True)
        |> List.singleton
        |> Paragraph.create


emuDocument : Mark.Document Doc
emuDocument =
    Mark.document emuWrapper (Mark.manyOf [ Mark.map (List.concat >> Paragraph.create) inlineParser ])


emuWrapper : List Paragraph -> Doc
emuWrapper =
    Doc.create


inlineParser : Mark.Block (List (List Text))
inlineParser =
    Mark.textWith
        { view = \styles str -> [ toFormattedText styles str ]
        , replacements = []
        , inlines =
            [ Mark.annotation "link" toLinkedText
                |> Mark.field "url" Mark.string
            , Mark.verbatim "code" toCodeText
            ]
        }


toCodeText : String -> List Text
toCodeText str =
    [ Text.create (Format.empty |> Format.setCode True) str ]


toFormattedText : Mark.Styles -> String -> Text
toFormattedText styles str =
    Text.create (toFormat styles) str


toLinkedText : List ( Mark.Styles, String ) -> String -> List Text
toLinkedText strings url =
    let
        process : ( Mark.Styles, String ) -> Text
        process ( styles, str ) =
            Text.create
                (toFormat styles |> Format.setLink (Just (Doc.Link.create url)))
                str
    in
    List.map process strings


toFormat : Mark.Styles -> Format
toFormat styles =
    Format.empty
        |> Format.setBold styles.bold
        |> Format.setItalic styles.italic
