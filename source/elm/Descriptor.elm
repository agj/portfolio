module Descriptor exposing
    ( Url(..)
    , bold
    , boldItalic
    , d
    , fromDoc
    , icon
    , iconStroke
    , italic
    , l
    , lineBreak
    , list
    , makeTag
    , onClick
    , oscillate
    , p
    , t
    )

import Color exposing (Color)
import Doc exposing (Doc)
import Doc.Format as Format exposing (Format)
import Doc.Link as Link
import Doc.Paragraph as Paragraph exposing (Paragraph)
import Doc.Text as Text exposing (Text)
import Element as Ui
import Element.Background as Background
import Element.Events
import Element.Font as Font
import Html
import Html.Attributes
import Palette
import Tag exposing (Tag)
import Util.Bool as Bool
import Util.Color as Color
import Util.Element as Ui
import Util.Int as Int
import View.Icon


type Url
    = Url String


d : List (Ui.Element msg) -> Ui.Element msg
d =
    Ui.textColumn [ Ui.width Ui.fill ]


makeTag : (Tag -> msg) -> Maybe Tag -> Tag -> String -> Ui.Element msg
makeTag messenger selectedTag tag label =
    let
        isSelectedTag : Bool
        isSelectedTag =
            case selectedTag of
                Just st ->
                    st == tag

                Nothing ->
                    False
    in
    Ui.el
        [ Bool.ifElse isSelectedTag
            (Background.color (Palette.baseColorAt10 |> Color.toElmUi))
            (Background.color (Palette.baseColorAt70 |> Color.toElmUi))
        , Font.color (Bool.ifElse isSelectedTag (Palette.baseColorAt90 |> Color.toElmUi) (Palette.baseColorAt10 |> Color.toElmUi))
        , Ui.paddingXY
            (Int.fraction 0.3 Palette.textSizeNormal)
            (Int.fraction 0.1 Palette.textSizeNormal)
        , Element.Events.onClick (messenger tag)
        , Ui.pointer
        , Ui.mouseDown
            [ Background.color (Palette.baseColorAt10 |> Color.toElmUi)
            , Font.color (Palette.baseColorAt90 |> Color.toElmUi)
            ]
        ]
        (Ui.text label)


p : List (Ui.Element msg) -> Ui.Element msg
p children =
    Ui.paragraph
        [ Font.size Palette.textSizeNormal
        , Ui.paddingXY 0 10
        , Ui.spacing (Palette.textLineSpacing Palette.textSizeNormal)
        , Ui.iOsTextScalingFix
        ]
        children


t : String -> Ui.Element msg
t =
    Ui.text


l : String -> Url -> Ui.Element msg
l textContent (Url url) =
    Ui.newTabLink linkStyle
        { label = t textContent
        , url = url
        }


onClick : msg -> Ui.Element msg -> Ui.Element msg
onClick msg label =
    Ui.el
        (linkStyle
            ++ [ Element.Events.onClick msg ]
        )
        label


bold : Ui.Element msg -> Ui.Element msg
bold child =
    Ui.el
        [ Font.bold
        , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
        ]
        child


italic : Ui.Element msg -> Ui.Element msg
italic child =
    Ui.el
        [ Font.italic
        , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
        ]
        child


boldItalic : Ui.Element msg -> Ui.Element msg
boldItalic child =
    Ui.el
        [ Font.bold
        , Font.italic
        , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
        ]
        child


list : List (Ui.Element msg) -> Ui.Element msg
list children =
    let
        toRow : Ui.Element msg -> Ui.Element msg
        toRow child =
            Ui.row [ Ui.spacing (Int.fraction 0.3 Palette.textSizeNormal) ]
                [ Ui.text "→"
                , child
                ]

        rows : List (Ui.Element msg)
        rows =
            List.map toRow children
    in
    Ui.column
        [ Ui.paddingXY 0 (Int.fraction 0.5 Palette.textSizeNormal)
        , Ui.spacing (Palette.textLineSpacing Palette.textSizeNormal)
        ]
        rows


lineBreak : Ui.Element msg
lineBreak =
    Html.br [] []
        |> Ui.html


icon : View.Icon.IconName -> Ui.Element msg
icon =
    iconWithStyle View.Icon.StyleFilled


iconStroke : View.Icon.IconName -> Ui.Element msg
iconStroke =
    iconWithStyle View.Icon.StyleStroke


oscillate : Ui.Element msg -> Ui.Element msg
oscillate el =
    Ui.el
        [ Html.Attributes.class "oscillate"
            |> Ui.htmlAttribute
        , Html.Attributes.style "display" "inline-block"
            |> Ui.htmlAttribute
        ]
        el


fromDoc : Color -> Doc -> Ui.Element msg
fromDoc color doc =
    Ui.textColumn [ Ui.width Ui.fill ] (List.map (fromParagraph color) (Doc.content doc))



-- INTERNAL


fromParagraph : Color -> Paragraph -> Ui.Element msg
fromParagraph color par =
    p (List.map (fromText color) (Paragraph.content par))


fromText : Color -> Text -> Ui.Element msg
fromText color txt =
    let
        textContent : String
        textContent =
            Text.content txt

        format : Format
        format =
            Text.format txt
    in
    case ( Format.link format, getStyle format ) of
        ( Just lnk, style ) ->
            Ui.newTabLink
                (linkStyle ++ style)
                { label = t textContent
                , url = Link.url lnk
                }

        ( Nothing, [] ) ->
            if Format.isCode format then
                Ui.html
                    (Html.span
                        [ Html.Attributes.style "white-space" "pre"
                        , Html.Attributes.style "font-family" "monospace"
                        ]
                        [ Html.text textContent ]
                    )

            else
                t textContent

        ( Nothing, style ) ->
            Ui.el style (t textContent)


getStyle : Format -> List (Ui.Attribute msg)
getStyle format =
    Bool.ifElse (Format.isBold format) [ Font.bold ] []
        ++ Bool.ifElse (Format.isItalic format) [ Font.italic ] []


linkStyle : List (Ui.Attribute msg)
linkStyle =
    [ Font.underline
    , Ui.pointer
    , Ui.mouseDown [ Font.color (Palette.baseColorAt10 |> Color.toElmUi) ]
    ]


iconWithStyle : View.Icon.Style -> View.Icon.IconName -> Ui.Element msg
iconWithStyle style iconName =
    Ui.el [ Ui.paddingXY (Int.fraction 0.1 Palette.textSizeNormal) 0 ]
        (View.Icon.icon iconName (Int.fraction 1.4 Palette.textSizeNormal)
            |> View.Icon.withStyle style
            |> View.Icon.view
        )
