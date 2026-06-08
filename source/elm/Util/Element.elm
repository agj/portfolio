module Util.Element exposing
    ( backgroundColor
    , glow
    , iOsTextScalingFix
    , id
    , imageInline
    , inlineCenter
    , radialGradient
    , sides
    , style
    , svgFilter
    )

import Color exposing (Color)
import Element as Ui
import Html.Attributes as Attributes


sides : { left : number, right : number, top : number, bottom : number }
sides =
    { left = 0
    , right = 0
    , top = 0
    , bottom = 0
    }



-- ELEMENTS


imageInline : List (Ui.Attribute msg) -> { src : String, description : String } -> Ui.Element msg
imageInline attrs desc =
    Ui.image (style "display" "inline-flex" :: attrs) desc



-- ATTRIBUTES


backgroundColor : Color -> Ui.Attribute msg
backgroundColor color =
    style "background-color" (Color.toCssString color)


svgFilter : String -> Ui.Attribute msg
svgFilter filterId =
    style "filter" ("url(#" ++ filterId ++ ")")


inlineCenter : Ui.Attribute msg
inlineCenter =
    style "vertical-align" "middle"


radialGradient : List ( Float, Color ) -> Ui.Attribute msg
radialGradient colors =
    let
        process : ( Float, Color ) -> String
        process ( position, color ) =
            Color.toCssString color
                ++ " "
                ++ String.fromFloat (position * 100.0)
                ++ "%"

        processedColors : List String
        processedColors =
            List.map process colors
    in
    style "background"
        ("radial-gradient(closest-side, "
            ++ String.join ", " processedColors
            ++ ")"
        )


glow : { color : Color, strength : Float, size : Float } -> Ui.Attribute msg
glow { color, strength, size } =
    let
        colorCss : String
        colorCss =
            Color.toCssString color

        value : String
        value =
            "0 0 "
                ++ String.fromFloat size
                ++ "px "
                ++ colorCss
    in
    style "text-shadow"
        (String.join ", "
            (List.repeat (max 1 (round strength)) value)
        )


iOsTextScalingFix : Ui.Attribute msg
iOsTextScalingFix =
    style "-webkit-text-size-adjust" "100%"


style : String -> String -> Ui.Attribute msg
style attribute value =
    Ui.htmlAttribute (Attributes.style attribute value)


id : String -> Ui.Attribute msg
id name =
    Ui.htmlAttribute (Attributes.id name)
