module Descriptor exposing (bold, d, fromDoc, l, list, makeTag, p, t)

import Doc exposing (Doc)
import Doc.Paragraph as Paragraph exposing (Paragraph)
import Doc.Text as Text exposing (Text)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Palette
import Tag exposing (Tag)
import Utils exposing (..)


d =
    column []


makeTag : (Tag -> msg) -> Tag -> String -> Element msg
makeTag messenger theTag label =
    el
        [ Background.color Palette.highlightDark
        , Font.color Palette.light
        , paddingXY 11 3
        , Border.rounded 15
        , onClick (messenger theTag)
        , pointer
        ]
        (text label)


p : List (Element msg) -> Element msg
p children =
    paragraph
        [ Font.size Palette.textSizeNormal
        , paddingXY 0 10
        , spacing <| Palette.textLineSpacing Palette.textSizeNormal
        ]
        children


t =
    text


bold : Element msg -> Element msg
bold child =
    el [ Font.bold ] child


l : String -> String -> Element msg
l label url =
    newTabLink
        [ Font.underline
        , pointer
        ]
        { label = text label
        , url = url
        }


list : List (Element msg) -> Element msg
list children =
    let
        toRow : Element msg -> Element msg
        toRow child =
            row [ spacing (fraction 0.3 Palette.textSizeNormal) ]
                [ text "→"
                , child
                ]

        rows : List (Element msg)
        rows =
            List.map toRow children
    in
    column
        [ paddingXY 0 (fraction 0.5 Palette.textSizeNormal)
        , spacing <| Palette.textLineSpacing Palette.textSizeNormal
        ]
        rows


fromDoc : Doc -> Element msg
fromDoc doc =
    let
        fromParagraph par =
            p <| List.map fromText (Paragraph.content par)

        fromText txt =
            t (Text.content txt)
    in
    textColumn [] <| List.map fromParagraph (Doc.content doc)
