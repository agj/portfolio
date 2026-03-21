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
    = Language
    | VisualCommunication
    | Programming
    | Learning
    | Play
    | Close
    | HandUp
    | Hourglass
    | LoadError
    | ArrowLeft


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
        phosphorIcon =
            case config.name of
                Language ->
                    Phosphor.chatCircle

                VisualCommunication ->
                    Phosphor.eye

                Programming ->
                    Phosphor.bracketsCurly

                Learning ->
                    Phosphor.brain

                Play ->
                    Phosphor.playCircle

                Close ->
                    Phosphor.xCircle

                HandUp ->
                    Phosphor.handPointing

                Hourglass ->
                    Phosphor.hourglassMedium

                LoadError ->
                    Phosphor.fileX

                ArrowLeft ->
                    Phosphor.arrowLeft

        style =
            case config.style of
                StyleFilled ->
                    Phosphor.Fill

                StyleStroke ->
                    Phosphor.Bold
    in
    phosphorIcon style
        |> Phosphor.toHtml
            [ Html.Attributes.style "vertical-align" "middle"
            ]
        |> Element.html
        |> Element.el
            [ Element.Font.size config.size ]
