module Descriptor exposing (Url(..), bold, d, fromDoc, l, list, makeTag, p, t)

import CustomEl
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
import Html
import Html.Attributes
import Palette
import Tag exposing (Tag)
import Utils exposing (..)


type Url
    = Url String


d : List (Element msg) -> Element msg
d =
    textColumn [ width fill ]


makeTag : (Tag -> msg) -> Maybe Tag -> Tag -> String -> Element msg
makeTag messenger selectedTag tag label =
    let
        isSelectedTag =
            case selectedTag of
                Just st ->
                    st == tag

                Nothing ->
                    False
    in
    el
        [ ifElse isSelectedTag
            (Background.color Palette.highlightLight)
            (Background.color Palette.highlightDark)
        , Font.color <| ifElse isSelectedTag Palette.dark Palette.light
        , paddingXY
            (fraction 0.3 Palette.textSizeNormal)
            (fraction 0.1 Palette.textSizeNormal)
        , onClick (messenger tag)
        , pointer
        , mouseDown
            [ Background.color Palette.highlightLight
            , Font.color Palette.dark
            ]
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


t : String -> Element msg
t =
    text


l : String -> Url -> Element msg
l textContent (Url url) =
    newTabLink linkStyle
        { label = t textContent
        , url = url
        }


bold : Element msg -> Element msg
bold child =
    el
        [ Font.bold
        , Font.color Palette.highlightLight
        ]
        child


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


fromDoc : Element.Color -> Doc -> Element msg
fromDoc color doc =
    textColumn [ width fill ] <| List.map (fromParagraph color) (Doc.content doc)



-- INTERNAL


fromParagraph : Element.Color -> Paragraph -> Element msg
fromParagraph color par =
    p <| List.map (fromText color) (Paragraph.content par)


fromText : Element.Color -> Text -> Element msg
fromText color txt =
    let
        textContent =
            Text.content txt

        format =
            Text.format txt
    in
    case ( Format.link format, getStyle format ) of
        ( Just lnk, style ) ->
            newTabLink
                (linkStyle ++ style)
                { label = t textContent
                , url = Link.url lnk
                }

        ( Nothing, [] ) ->
            if Format.isCode format then
                html
                    (Html.span
                        [ Html.Attributes.style "white-space" "pre"
                        , Html.Attributes.style "font-family" "monospace"
                        ]
                        [ Html.text textContent ]
                    )

            else
                t textContent

        ( Nothing, style ) ->
            el style (t textContent)


getStyle : Format -> List (Element.Attribute msg)
getStyle format =
    ifElse (Format.isBold format) [ Font.bold ] []
        ++ ifElse (Format.isItalic format) [ Font.italic ] []


linkStyle : List (Element.Attribute msg)
linkStyle =
    [ Font.underline
    , pointer
    , mouseDown [ Font.color Palette.highlightLight ]
    ]
