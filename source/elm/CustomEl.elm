module CustomEl exposing
    ( backgroundColor
    , glow
    , iOsTextScalingFix
    , id
    , imageInline
    , inlineCenter
    , radialGradient
    , style
    , svgFilter
    )

import Color exposing (Color)
import Element exposing (Element, image)
import Html.Attributes as Attributes
import Utils exposing (..)



-- ELEMENTS


imageInline : List (Element.Attribute msg) -> { src : String, description : String } -> Element msg
imageInline attrs desc =
    image
        ([ style "display" "inline-flex"
         ]
            ++ attrs
        )
        desc



-- ATTRIBUTES


backgroundColor : Color -> Element.Attribute msg
backgroundColor color =
    style "background-color" (Color.toCssString color)


svgFilter : String -> Element.Attribute msg
svgFilter filterId =
    style "filter" ("url(#" ++ filterId ++ ")")


inlineCenter : Element.Attribute msg
inlineCenter =
    style "vertical-align" "middle"


radialGradient : List ( Float, Color ) -> Element.Attribute msg
radialGradient colors =
    let
        process ( position, color ) =
            Color.toCssString color
                ++ " "
                ++ String.fromFloat (position * 100.0)
                ++ "%"

        processedColors =
            List.map process colors
    in
    style "background" <|
        "radial-gradient(closest-side, "
            ++ String.join ", " processedColors
            ++ ")"


glow : { color : Color, strength : Float, size : Float } -> Element.Attribute msg
glow { color, strength, size } =
    let
        colorCss =
            Color.toCssString color

        value =
            "0 0 "
                ++ String.fromFloat size
                ++ "px "
                ++ colorCss
    in
    style "text-shadow" <|
        String.join ", "
            (List.repeat (max 1 (round strength)) value)


iOsTextScalingFix : Element.Attribute msg
iOsTextScalingFix =
    style "-webkit-text-size-adjust" "100%"


style : String -> String -> Element.Attribute msg
style attribute value =
    Element.htmlAttribute <| Attributes.style attribute value


id : String -> Element.Attribute msg
id name =
    Element.htmlAttribute <| Attributes.id name
