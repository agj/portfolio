module Descriptor exposing
    ( Url(..)
    , bold
    , d
    , fromDoc
    , icon
    , l
    , list
    , makeTag
    , onClick
    , p
    , t
    )

import Color exposing (Color)
import CustomEl
import Doc exposing (Doc)
import Doc.Format as Format exposing (Format)
import Doc.Link as Link exposing (Link)
import Doc.Paragraph as Paragraph exposing (Paragraph)
import Doc.Text as Text exposing (Text)
import Element exposing (Element, column, el, fill, html, mouseDown, newTabLink, paddingXY, paragraph, pointer, row, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Html
import Html.Attributes
import Palette
import Tag exposing (Tag)
import Util.Color as Color
import Utils exposing (..)
import View.Icon


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
            (Background.color (Palette.baseColorAt10 |> Color.toElmUi))
            (Background.color (Palette.baseColorAt70 |> Color.toElmUi))
        , Font.color <| ifElse isSelectedTag (Palette.baseColorAt90 |> Color.toElmUi) (Palette.baseColorAt10 |> Color.toElmUi)
        , paddingXY
            (fraction 0.3 Palette.textSizeNormal)
            (fraction 0.1 Palette.textSizeNormal)
        , Element.Events.onClick (messenger tag)
        , pointer
        , mouseDown
            [ Background.color (Palette.baseColorAt10 |> Color.toElmUi)
            , Font.color (Palette.baseColorAt90 |> Color.toElmUi)
            ]
        ]
        (text label)


p : List (Element msg) -> Element msg
p children =
    paragraph
        [ Font.size Palette.textSizeNormal
        , paddingXY 0 10
        , spacing <| Palette.textLineSpacing Palette.textSizeNormal
        , CustomEl.iOsTextScalingFix
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


onClick : msg -> Element msg -> Element msg
onClick msg label =
    el
        (linkStyle
            ++ [ Element.Events.onClick msg ]
        )
        label


bold : Element msg -> Element msg
bold child =
    el
        [ Font.bold
        , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
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


icon : View.Icon.IconName -> Element msg
icon iconName =
    View.Icon.icon iconName (fraction 1.4 Palette.textSizeNormal)
        |> View.Icon.view
        |> Element.el [ Element.paddingXY (fraction 0.1 Palette.textSizeNormal) 0 ]


fromDoc : Color -> Doc -> Element msg
fromDoc color doc =
    textColumn [ width fill ] <| List.map (fromParagraph color) (Doc.content doc)



-- INTERNAL


fromParagraph : Color -> Paragraph -> Element msg
fromParagraph color par =
    p <| List.map (fromText color) (Paragraph.content par)


fromText : Color -> Text -> Element msg
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
    , mouseDown [ Font.color (Palette.baseColorAt10 |> Color.toElmUi) ]
    ]
