module Descriptor exposing (bold, d, l, list, makeTag, p, t)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Palette
import Tag exposing (Tag)
import Utils exposing (..)


p : List (Element msg) -> Element msg
p children =
    paragraph Palette.attrsParagraph
        children


l : String -> String -> Element msg
l label url =
    newTabLink
        [ Font.underline
        , pointer
        ]
        { label = text label
        , url = url
        }


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


bold : Element msg -> Element msg
bold child =
    el [ Font.bold ] child


t =
    text


d =
    column []


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
        [ paddingXY 0 10
        , spacing <| Palette.textLineSpacing Palette.textSizeNormal
        ]
        rows
