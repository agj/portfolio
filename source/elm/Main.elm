module Main exposing (Document, Model, init, main, subscriptions, update, view)

import Browser
import Browser.Events
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Html exposing (Html)
import Language exposing (Language(..))
import List.Extra exposing (..)
import Palette
import Tag exposing (Tag)
import Utils exposing (..)
import VideoEmbed
import Work exposing (..)
import Works



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { language : Language
    , tag : Maybe Tag
    , works : List (Work Msg)
    , viewport : Viewport
    , popupVisual : Maybe Visual
    }


type alias Flags =
    { languages : List String
    , viewport : { width : Int, height : Int }
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { language = English
      , tag = Nothing
      , works = Works.all
      , viewport = flags.viewport
      , popupVisual = Nothing
      }
    , Cmd.none
    )


getLayoutSize : Viewport -> LayoutSize
getLayoutSize viewport =
    if viewport.width < 600 then
        PhoneSize

    else
        DesktopSize


type LayoutSize
    = PhoneSize
    | DesktopSize



-- UPDATE


type Msg
    = SelectedLanguage Language
    | SelectedTag Tag
    | SelectedVisual (Maybe Visual)
    | GotViewport Viewport


type alias Viewport =
    { width : Int
    , height : Int
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedLanguage language ->
            ( model, Cmd.none )

        SelectedTag tag ->
            ( { model | tag = Just tag }
            , Cmd.none
            )

        SelectedVisual selection ->
            ( { model | popupVisual = selection }
            , Cmd.none
            )

        GotViewport viewport ->
            ( { model | viewport = viewport }
            , Cmd.none
            )



-- VIEW


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


view : Model -> Document Msg
view model =
    { title = "Portfolio"
    , body =
        [ layout
            (case model.popupVisual of
                Just visual ->
                    [ inFront (viewPopupVisual model.viewport visual) ]

                Nothing ->
                    []
            )
            (viewMain model)
        ]
    }


viewMain : Model -> Element Msg
viewMain model =
    let
        layoutSize =
            getLayoutSize model.viewport

        worksBlockWidth =
            if layoutSize == PhoneSize then
                model.viewport.width

            else
                600
    in
    column
        [ width <|
            if layoutSize == PhoneSize then
                fill

            else
                px 600
        , centerX
        ]
        [ viewIntroduction
        , viewWorks worksBlockWidth model
        ]


viewIntroduction : Element Msg
viewIntroduction =
    column
        [ width fill
        , padding Palette.spaceNormal
        , Font.color Palette.light
        , Background.color Palette.dark
        , Font.size Palette.textSizeNormal
        ]
        [ standardP []
            [ text "My name is "
            , el [ Font.bold ] (text "Ale Grilli")
            , text ". I’m based in Santiago, Chile. My work is concerned with various intersections of the following four areas."
            ]
        , list []
            [ linkTag Tag.VisualCommunication <| text "Visual communication"
            , linkTag Tag.Programming <| text "Programming"
            , linkTag Tag.Language <| text "Language"
            , linkTag Tag.Learning <| text "Learning"
            ]
        , standardP []
            [ text "I’m a creator. I make "
            , linkTag Tag.Digital <| text "digital things"
            , text ", such as "
            , linkTag Tag.VideoGame <| text "games"
            , text " and "
            , linkTag Tag.Web <| text "web stuff"
            , text ". I design "
            , linkTag Tag.UserInterface <| text "user interfaces"
            , text " and "
            , linkTag Tag.Graphic <| text "graphics"
            , text ". I shoot and edit "
            , linkTag Tag.Video <| text "videos"
            , text " on occasion."
            ]
        , standardP []
            [ text "I’m a languages nerd. I am fluent in three (Spanish, English, Japanese) and am working on a fourth (Chinese Mandarin). I do "
            , linkTag Tag.Translation <| text "translation"
            , text " work, subtitling too."
            ]
        , standardP []
            [ text "I think a lot about learning. I’ve worked for ed-tech companies programming "
            , linkTag Tag.EducationalSoftware <| text "educational software"
            , text ". I occasionally "
            , linkTag Tag.LanguageTeaching <| text "teach languages"
            , text "."
            ]
        ]


viewWorks : Int -> { a | tag : Maybe Tag, works : List (Work Msg) } -> Element Msg
viewWorks blockWidth model =
    let
        works =
            case model.tag of
                Nothing ->
                    []

                Just tag ->
                    List.filter
                        (\w -> List.member tag w.tags)
                        model.works

        paddingAmount =
            Palette.spaceSmall
    in
    el
        [ width (px blockWidth)
        , padding paddingAmount
        ]
    <|
        if List.length works == 0 then
            viewWorkBlock <|
                [ standardP
                    []
                    [ text "Select any highlighted keyword above to see examples of my work."
                    ]
                ]

        else
            column
                [ width fill
                , spacing Palette.spaceSmall
                ]
                (List.map (viewWork (blockWidth - (paddingAmount * 2))) works)


viewWorkBlock : List (Element Msg) -> Element Msg
viewWorkBlock children =
    column
        [ width fill
        , Font.color Palette.light
        , Background.color Palette.dark
        , Font.size Palette.textSizeNormal
        ]
        children


viewWork : Int -> Work Msg -> Element Msg
viewWork blockWidth work =
    viewWorkBlock
        [ viewWorkTitle blockWidth work.name work.mainVisualUrl
        , viewWorkVisuals blockWidth work.visuals
        , viewWorkLinks work.links
        , viewWorkDescription work.description
        ]


viewWorkDescription : Element Msg -> Element Msg
viewWorkDescription child =
    el [ paddingXY Palette.spaceNormal 0 ]
        child


viewWorkLinks : List Link -> Element Msg
viewWorkLinks links =
    let
        makeLink link =
            newTabLink
                [ Background.color Palette.highlightDark
                , Border.rounded (fraction 0.2 Palette.textSizeNormal)
                , paddingXY
                    (fraction 0.6 Palette.textSizeNormal)
                    (fraction 0.4 Palette.textSizeNormal)
                , centerX
                ]
                { url = link.url
                , label = text link.label
                }
    in
    wrappedRow
        [ paddingXY Palette.spaceNormal Palette.spaceSmall
        , width fill
        ]
    <|
        List.map makeLink links


viewWorkTitle : Int -> String -> String -> Element Msg
viewWorkTitle blockWidth title mainVisualUrl =
    let
        mainBlock =
            el
                [ width (px blockWidth)
                , height (px blockWidth)
                , Background.image ("works/" ++ mainVisualUrl)
                , Font.shadow
                    { offset = ( 0.0, 0.1 * toFloat Palette.textSizeLarge )
                    , blur = 0
                    , color = rgb 0 0 0
                    }
                ]

        gradientBlock =
            column
                [ height (px <| Palette.textSizeLarge * 2)
                , width fill
                , alignBottom
                , paddingXY Palette.spaceNormal 0
                , Background.gradient
                    { angle = 0
                    , steps =
                        [ rgba 0 0 0 0.7
                        , rgba 0 0 0 0.3
                        , rgba 0 0 0 0
                        ]
                    }
                ]

        yearBlock =
            el
                [ alignBottom
                , paddingXY 0 0
                , Font.size Palette.textSizeSmall
                ]

        titleBlock =
            el
                [ alignBottom
                , paddingXY 0 Palette.spaceSmaller
                , Font.size Palette.textSizeLarge
                ]
    in
    mainBlock
        (gradientBlock
            [ yearBlock (text "2010")
            , titleBlock (text title)
            ]
        )


viewWorkVisuals : Int -> List Visual -> Element Msg
viewWorkVisuals blockWidth visuals =
    let
        perRow =
            4

        spaceBetween =
            Palette.spaceSmallest

        thumbnailSize =
            toFloat (blockWidth - (spaceBetween * (perRow - 1)))
                / perRow
                |> floor
    in
    wrappedRow
        [ spacing spaceBetween
        , paddingEach { top = spaceBetween, bottom = 0, left = 0, right = 0 }
        ]
        (List.map (viewVisualThumbnail thumbnailSize) visuals)


viewVisualThumbnail : Int -> Visual -> Element Msg
viewVisualThumbnail size visual =
    let
        thumbnailUrl =
            case visual of
                Image desc ->
                    desc.thumbnailUrl

                Video desc ->
                    desc.thumbnailUrl
    in
    image
        [ width (px size)
        , height (px size)
        , onClick (SelectedVisual (Just visual))
        ]
        { src = "works/" ++ thumbnailUrl
        , description = "(thumbnail)"
        }


viewPopupVisual : Viewport -> Visual -> Element Msg
viewPopupVisual viewport visual =
    let
        reservedSpace =
            50

        viewportVertical =
            toFloat viewport.width / toFloat viewport.height < 1

        usableWidth =
            if viewportVertical then
                viewport.width

            else
                viewport.width - reservedSpace

        usableHeight =
            if viewportVertical then
                viewport.height - reservedSpace

            else
                viewport.height

        usableAR =
            toFloat usableWidth / toFloat usableHeight

        visualAR =
            case visual of
                Image desc ->
                    desc.aspectRatio

                Video desc ->
                    desc.aspectRatio

        visualVertical =
            visualAR > 1

        visualWidth =
            if visualAR > usableAR then
                usableWidth

            else
                floor (toFloat usableHeight * visualAR)

        visualHeight =
            if visualAR < usableAR then
                usableHeight

            else
                floor (toFloat usableWidth * (1 / visualAR))

        visualEl =
            case visual of
                Image desc ->
                    image
                        [ width (px visualWidth)
                        , height (px visualHeight)
                        , centerX
                        , centerY
                        ]
                        { src = "works/" ++ desc.url
                        , description = "(image)"
                        }

                Video desc ->
                    VideoEmbed.get desc visualWidth visualHeight

        closeButton =
            el
                [ width (px reservedSpace)
                , height (px reservedSpace)
                , Font.color (rgb 1 1 1)
                , onClick (SelectedVisual Nothing)
                ]
                (text "CLOSE")
    in
    el
        [ width fill
        , height fill
        , Background.color (rgba 0 0 0 0.3)
        ]
    <|
        if viewportVertical then
            column
                [ width fill
                , height fill
                ]
                [ closeButton
                , visualEl
                ]

        else
            row
                [ width fill
                , height fill
                ]
                [ visualEl
                , closeButton
                ]


standardP : List (Attribute Msg) -> List (Element Msg) -> Element Msg
standardP attrs children =
    paragraph
        (attrs
            ++ [ paddingXY 0 10
               , spacing <| Palette.textLineSpacing Palette.textSizeNormal
               ]
        )
        children


list : List (Attribute Msg) -> List (Element Msg) -> Element Msg
list attrs children =
    let
        toRow : Element Msg -> Element Msg
        toRow child =
            row [ spacing (fraction 0.3 Palette.textSizeNormal) ]
                [ text "→"
                , child
                ]

        rows : List (Element Msg)
        rows =
            List.map toRow children
    in
    column
        (attrs
            ++ [ paddingXY 0 10
               , spacing <| Palette.textLineSpacing Palette.textSizeNormal
               ]
        )
        rows


linkTag : Tag -> Element Msg -> Element Msg
linkTag tag child =
    el
        [ Background.color Palette.highlightDark
        , Font.color Palette.light
        , paddingXY 11 3
        , Border.rounded 15
        , onClick (SelectedTag tag)
        ]
        child



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize <|
        \w h ->
            GotViewport { width = w, height = h }
