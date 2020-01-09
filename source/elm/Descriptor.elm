module Descriptor exposing (bold, d, fromDoc, list, makeTag, p, t)

import Doc exposing (Doc)
import Doc.Format as Format exposing (Format)
import Doc.Link as Link exposing (Link)
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
    textColumn [] <| List.map fromParagraph (Doc.content doc)



-- INTERNAL


fromParagraph : Paragraph -> Element msg
fromParagraph par =
    p <| List.map fromText (Paragraph.content par)


fromText : Text -> Element msg
fromText txt =
    let
        textContent =
            Text.content txt

        format =
            Text.format txt
    in
    case ( Format.link format, getStyle format ) of
        ( Just lnk, style ) ->
            newTabLink
                ([ Font.underline
                 , pointer
                 ]
                    ++ style
                )
                { label = t textContent
                , url = Link.url lnk
                }

        ( Nothing, [] ) ->
            t textContent

        ( Nothing, style ) ->
            el style (t textContent)


getStyle : Format -> List (Element.Attribute msg)
getStyle format =
    ifElse (Format.isBold format) [ Font.bold ] []
        ++ ifElse (Format.isItalic format) [ Font.italic ] []
