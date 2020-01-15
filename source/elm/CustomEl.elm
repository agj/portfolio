module CustomEl exposing (backgroundColor, imageInline, inlineCenter, svgFilter)

import Element exposing (..)
import Html.Attributes as Attributes
import Utils exposing (..)


backgroundColor : Element.Color -> Element.Attribute msg
backgroundColor color =
    style "background-color" (toCssColor color)


svgFilter : String -> Element.Attribute msg
svgFilter id =
    style "filter" ("url(#" ++ id ++ ")")


imageInline : List (Element.Attribute msg) -> { src : String, description : String } -> Element msg
imageInline attrs desc =
    image
        ([ style "display" "inline-flex"
         ]
            ++ attrs
        )
        desc


inlineCenter : Element.Attribute msg
inlineCenter =
    style "vertical-align" "middle"



-- INTERNAL


style : String -> String -> Element.Attribute msg
style attribute value =
    Element.htmlAttribute <| Attributes.style attribute value
