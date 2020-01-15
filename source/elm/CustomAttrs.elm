module CustomAttrs exposing (backgroundColor, svgFilter)

import Element
import Html.Attributes as Attributes
import Utils exposing (..)


backgroundColor : Element.Color -> Element.Attribute msg
backgroundColor color =
    style "background-color" (toCssColor color)


svgFilter : String -> Element.Attribute msg
svgFilter id =
    style "filter" ("url(#" ++ id ++ ")")



-- INTERNAL


style : String -> String -> Element.Attribute msg
style attribute value =
    Element.htmlAttribute <| Attributes.style attribute value
