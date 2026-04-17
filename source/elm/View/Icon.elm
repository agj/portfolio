module View.Icon exposing
    ( Icon
    , IconName(..)
    , Style(..)
    , icon
    , view
    , withStyle
    )

import Element exposing (Element)
import Element.Font
import Html.Attributes
import Phosphor


type Icon
    = Icon
        { name : IconName
        , size : Int
        , style : Style
        }


type IconName
    = ArrowLeft
    | At
    | Check
    | Close
    | Globe
    | HandUp
    | Hourglass
    | Language
    | Learning
    | LoadError
    | Play
    | Programming
    | Star
    | VisualCommunication


type Style
    = StyleFilled
    | StyleStroke


icon : IconName -> Int -> Icon
icon name size =
    Icon { name = name, size = size, style = StyleFilled }


withStyle : Style -> Icon -> Icon
withStyle style (Icon config) =
    Icon { config | style = style }


view : Icon -> Element msg
view (Icon config) =
    let
        phosphorIcon : Phosphor.Icon
        phosphorIcon =
            case config.name of
                ArrowLeft ->
                    Phosphor.arrowLeft

                At ->
                    Phosphor.at

                Check ->
                    Phosphor.checkCircle

                Close ->
                    Phosphor.xCircle

                Globe ->
                    Phosphor.globeSimple

                HandUp ->
                    Phosphor.handPointing

                Hourglass ->
                    Phosphor.hourglassMedium

                Language ->
                    Phosphor.chatCircle

                Learning ->
                    Phosphor.brain

                LoadError ->
                    Phosphor.fileX

                Play ->
                    Phosphor.playCircle

                Programming ->
                    Phosphor.bracketsCurly

                Star ->
                    Phosphor.star

                VisualCommunication ->
                    Phosphor.eye

        style : Phosphor.IconWeight
        style =
            case config.style of
                StyleFilled ->
                    Phosphor.Fill

                StyleStroke ->
                    Phosphor.Bold
    in
    Element.el [ Element.Font.size config.size ]
        (phosphorIcon style
            |> Phosphor.toHtml [ Html.Attributes.style "vertical-align" "middle" ]
            |> Element.html
        )
