module Main exposing (Document, Model, init, main, subscriptions, update, view)

import AppUrl exposing (QueryParameters)
import Browser
import Browser.Events
import Browser.Navigation as Navigation
import Color exposing (Color)
import CustomEl
import Data.Introduction as Introduction
import Data.Labels as Labels exposing (Labels)
import Data.Settings as Settings exposing (Settings)
import Descriptor
import Dict
import Doc exposing (Doc)
import Element exposing (Attribute, Element, alignBottom, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, image, inFront, layout, mouseDown, moveDown, moveLeft, newTabLink, none, padding, paddingEach, paddingXY, paragraph, pointer, px, row, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Language exposing (Language(..))
import LayoutFormat exposing (LayoutFormat(..))
import List.Extra
import Maybe.Extra
import Palette
import Regex
import SaveState exposing (SaveState)
import SmoothScroll
import Tag exposing (Tag)
import Task
import Url exposing (Url)
import Util.AppUrl as AppUrl
import Util.Color as Color
import Utils exposing (..)
import VideoEmbed
import View.Icon exposing (IconName)
import Viewport exposing (Viewport)
import Work exposing (..)
import Work.Date as Date exposing (Date)
import Work.Visual as Visual exposing (Visual(..))
import Works



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }



-- MODEL


type alias Model =
    { language : Language
    , viewport : Viewport
    , popupVisual : Maybe Visual
    , query : Query
    , data : DataStatus
    , navigationData : NavigationData
    }


type DataStatus
    = DataLoading
    | DataLoadError Http.Error
    | DataLoaded (List WorkLanguages)


type alias Flags =
    { languages : List String
    , viewport : { width : Int, height : Int }
    , storedState : Maybe String
    }


type alias Query =
    { tag : Maybe Tag
    }


type alias NavigationData =
    { url : Url
    , key : Navigation.Key
    }


queryParser : QueryParameters -> Query
queryParser queryParameters =
    let
        tag =
            queryParameters
                |> Dict.get "tag"
                |> Maybe.andThen List.head
                |> Maybe.andThen Tag.fromString
    in
    { tag = tag }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        saveState =
            Maybe.withDefault "" flags.storedState
                |> SaveState.load

        initLanguage =
            case saveState of
                Just { language } ->
                    language

                Nothing ->
                    getLanguageFromPreferred flags.languages

        query =
            url
                |> AppUrl.fromUrl
                |> .queryParameters
                |> queryParser
    in
    ( { language = initLanguage
      , query = query
      , viewport = flags.viewport
      , popupVisual = Nothing
      , data = DataLoading
      , navigationData = { url = url, key = navKey }
      }
    , getData
    )


getData : Cmd Msg
getData =
    Http.get
        { url = "works/data.json"
        , expect = Http.expectJson GotData Work.allWorksDecoder
        }



-- ROUTING


onUrlChange : Url -> Msg
onUrlChange url =
    NoOp


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest urlRequest =
    NoOp



-- UPDATE


type Msg
    = SelectedLanguage Language
    | SelectedTag Tag
    | SelectedVisual (Maybe Visual)
    | SelectedGoHome
    | Resized
    | GotViewport Viewport
    | GotData (Result Http.Error (List WorkLanguages))
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedLanguage language ->
            ( { model | language = language }
            , SaveState.save { language = language }
            )

        SelectedTag tag ->
            let
                query =
                    model.query

                newQuery =
                    { query | tag = Just tag }
            in
            ( { model | query = newQuery }
            , Cmd.batch
                [ Task.attempt
                    (always NoOp)
                    (SmoothScroll.scrollToWithOptions
                        { defaultScroll | speed = 10 }
                        "works"
                    )
                , changeQuery model.navigationData newQuery
                ]
            )

        SelectedVisual selection ->
            ( { model | popupVisual = selection }
            , Cmd.none
            )

        SelectedGoHome ->
            ( model
            , Navigation.load "/"
            )

        Resized ->
            ( model
            , Viewport.get
            )

        GotViewport viewport ->
            ( { model | viewport = viewport }
            , Cmd.none
            )

        GotData result ->
            case result of
                Ok data ->
                    ( { model | data = DataLoaded data }
                    , Cmd.none
                    )

                Err err ->
                    ( { model | data = DataLoadError err }
                    , Cmd.none
                    )

        NoOp ->
            ( model, Cmd.none )


changeQuery : NavigationData -> Query -> Cmd Msg
changeQuery { url, key } query =
    let
        appUrl =
            url
                |> AppUrl.fromUrl

        queryParams =
            case query.tag of
                Just tag ->
                    Dict.fromList
                        [ ( "tag", [ Tag.toString tag ] ) ]

                Nothing ->
                    Dict.empty

        resultUrl =
            { appUrl | queryParameters = queryParams }
                |> AppUrl.toStringWithTrailingSlash
    in
    Navigation.pushUrl key resultUrl



-- VIEW


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


view : Model -> Document Msg
view model =
    let
        labels =
            Labels.ofLanguage model.language

        globalStyles =
            [ Font.family Palette.font ]

        popupVisual =
            case model.popupVisual of
                Just visual ->
                    [ inFront (viewPopupVisual model.viewport visual) ]

                Nothing ->
                    []
    in
    { title = labels.title
    , body =
        [ viewMain model
            |> layout (globalStyles ++ popupVisual)
        , Html.node "style"
            []
            [ "body { background-color: {color}; }"
                |> String.replace "{color}" (Color.toCssString Palette.baseColorAt70)
                |> Html.text
            ]
        ]
    }


viewMain : Model -> Element Msg
viewMain model =
    let
        labels =
            Labels.ofLanguage model.language

        layoutFormat =
            LayoutFormat.fromDimensions model.viewport

        settings =
            Settings.forFormat layoutFormat

        worksBlockWidth =
            case settings.worksBlockWidth of
                Just num ->
                    num

                Nothing ->
                    model.viewport.width

        worksBlock =
            el
                [ width (px worksBlockWidth)
                , paddingXY
                    (ifElse (layoutFormat == PhoneLayout)
                        Palette.spaceSmall
                        0
                    )
                    Palette.spaceNormal
                , CustomEl.id "works"
                ]

        content =
            case model.data of
                DataLoaded data ->
                    let
                        works =
                            Works.ofLanguage model.language data
                    in
                    worksBlock <|
                        viewWorks
                            { blockWidth =
                                ifElse (layoutFormat == PhoneLayout)
                                    (worksBlockWidth - (2 * Palette.spaceSmall))
                                    worksBlockWidth
                            , labels = labels
                            , maybeTag = model.query.tag
                            , works = works
                            , settings = settings
                            }

                DataLoading ->
                    worksBlock <|
                        viewLoadMessage labels.loading

                DataLoadError err ->
                    case err of
                        Http.BadBody msg ->
                            worksBlock <|
                                viewLoadMessage ("Data error!\n\n" ++ msg)

                        _ ->
                            worksBlock <|
                                viewLoadMessage labels.loadError
    in
    column
        [ width <| Maybe.withDefault fill (settings.worksBlockWidth |> Maybe.map px)
        , centerX
        , inFront <| viewLanguageSelector model.language
        , inFront <| viewBackButton labels.backToHome
        , paddingEach { sides | top = Palette.spaceSmall, bottom = Palette.spaceNormal }
        ]
        [ viewTop model.language model.query.tag
        , content
        ]


viewTop : Language -> Maybe Tag -> Element Msg
viewTop language selectedTag =
    column
        [ Font.color (Palette.baseColorAt10 |> Color.toElmUi)
        , Background.color (Palette.baseColorAt90 |> Color.toElmUi)
        , paddingEach { sides | top = Palette.spaceNormal, bottom = Palette.spaceSmall }
        ]
        [ viewIntroduction (Introduction.ofLanguage SelectedTag selectedTag language)
        ]


viewLanguageSelector : Language -> Element Msg
viewLanguageSelector language =
    row
        [ spacing Palette.spaceSmallest
        , alignRight
        , paddingEach { sides | right = Palette.spaceSmall }
        ]
        [ viewLanguageButton "EN" English language
        , viewLanguageButton "ES" Spanish language
        , viewLanguageButton "日" Japanese language
        ]


viewBackButton : String -> Element Msg
viewBackButton label =
    el [ centerX, centerY ] (text label)
        |> el
            [ alignLeft
            , paddingXY Palette.spaceSmall 0
            , Font.size Palette.textSizeNormal
            , height (px (fraction 2.3 Palette.textSizeNormal))
            , pointer
            , Background.color (Palette.baseColorAt90 |> Color.toElmUi)
            , Border.color (Palette.baseColorAt50 |> Color.toElmUi)
            , Border.widthEach { left = 1, right = 1, bottom = 1, top = 0 }
            , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
            , mouseDown
                [ Background.color (Palette.baseColorAt10 |> Color.toElmUi)
                , Font.color (Palette.baseColorAt90 |> Color.toElmUi)
                ]
            , onClick SelectedGoHome
            ]
        |> el [ paddingEach { sides | left = Palette.spaceSmall } ]


viewLanguageButton : String -> Language -> Language -> Element Msg
viewLanguageButton label language selectedLanguage =
    if language == selectedLanguage then
        none

    else
        el
            [ onClick (SelectedLanguage language)
            , Font.size Palette.textSizeNormal
            , width (px (fraction 2.9 Palette.textSizeNormal))
            , height (px (fraction 2.3 Palette.textSizeNormal))
            , pointer
            , Background.color (Palette.baseColorAt50 |> Color.toElmUi)
            , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
            , mouseDown
                [ Background.color (Palette.baseColorAt10 |> Color.toElmUi)
                , Font.color (Palette.baseColorAt90 |> Color.toElmUi)
                ]
            ]
            (el
                [ centerX
                , centerY
                ]
                (text label)
            )


viewIntroduction : Element Msg -> Element Msg
viewIntroduction introductionText =
    el
        [ width fill
        , paddingXY Palette.spaceNormal Palette.spaceNormal
        , Font.size Palette.textSizeNormal
        ]
        introductionText


viewLoadMessage : String -> Element Msg
viewLoadMessage message =
    viewMessageBlock <|
        Descriptor.p
            [ Descriptor.t message
            ]


viewMessageBlock : Element Msg -> Element Msg
viewMessageBlock child =
    viewWorkBlock [] <|
        [ el
            [ paddingXY Palette.spaceNormal Palette.spaceNormal
            , width fill
            , Font.center
            ]
            child
        ]


viewPopupVisual : Viewport -> Visual -> Element Msg
viewPopupVisual viewport visual =
    let
        reservedSpace =
            fraction 3 Palette.spaceNormal

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

        color =
            case visual of
                Image desc ->
                    desc.color

                Video desc ->
                    desc.color

        visualEl =
            el
                [ width (px usableWidth)
                , height (px usableHeight)
                , alignLeft
                , alignBottom
                ]
                (case visual of
                    Image desc ->
                        image
                            [ width (px visualWidth)
                            , height (px visualHeight)
                            , centerX
                            , centerY
                            , Background.color (color |> Color.toElmUi)
                            ]
                            { src = desc.url
                            , description = ""
                            }

                    Video desc ->
                        VideoEmbed.get desc visualWidth visualHeight
                )

        closeButton =
            el
                [ width (px reservedSpace)
                , height (px reservedSpace)
                , padding <| fraction 0.3 reservedSpace
                , alignRight
                , alignTop
                , pointer
                , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
                ]
                (View.Icon.icon View.Icon.Close (fraction 0.4 reservedSpace)
                    |> View.Icon.view
                )
    in
    el
        [ width fill
        , height fill
        , Background.color (color |> Palette.colorAt70 |> Color.setOpacity 0.8 |> Color.toElmUi)
        , onClick (SelectedVisual Nothing)
        , pointer
        , inFront closeButton
        ]
        visualEl



-- VIEW WORKS


viewWorks : { blockWidth : Int, labels : Labels, maybeTag : Maybe Tag, works : List Work, settings : Settings } -> Element Msg
viewWorks { blockWidth, labels, maybeTag, works, settings } =
    let
        filteredWorks =
            case maybeTag of
                Nothing ->
                    []

                Just Tag.Any ->
                    works

                Just tag ->
                    List.filter
                        (\w -> List.member tag w.tags)
                        works
                        |> sortWorks tag
    in
    if List.isEmpty filteredWorks then
        viewLoadMessage labels.pleaseSelect

    else
        column
            [ width fill
            , spacing Palette.spaceNormal
            ]
            (List.map
                (viewWork blockWidth labels settings)
                filteredWorks
            )


viewWorkBlock : List (Attribute Msg) -> List (Element Msg) -> Element Msg
viewWorkBlock attrs children =
    column
        ([ width fill
         , Font.color (Palette.baseColorAt10 |> Color.toElmUi)
         , Background.color (Palette.baseColorAt90 |> Color.toElmUi)
         , Font.size Palette.textSizeNormal
         ]
            ++ attrs
        )
        children


viewWork : Int -> Labels -> Settings -> Work -> Element Msg
viewWork blockWidth labels settings work =
    viewWorkBlock
        [ inFront <| viewWorkReadMore labels work.readMore work.mainVisualColor
        , paddingEach { sides | bottom = Palette.spaceNormal }
        , Font.color (work.mainVisualColor |> Palette.colorAt10 |> Color.toElmUi)
        , Background.color (work.mainVisualColor |> Palette.colorAt90 |> Color.toElmUi)
        ]
        [ viewWorkTitle blockWidth
            { title = work.name
            , date = work.date
            , mainVisualUrl = work.mainVisualUrl
            , mainVisualColor = work.mainVisualColor
            , icons =
                { visualCommunication = List.member Tag.VisualCommunication work.tags
                , programming = List.member Tag.Programming work.tags
                , language = List.member Tag.Language work.tags
                , learning = List.member Tag.Learning work.tags
                }
            , settings = settings
            }
        , viewWorkVisuals blockWidth settings work.mainVisualColor work.visuals
        , viewWorkLinks work.mainVisualColor work.links
        , viewWorkDescription work.mainVisualColor work.description
        ]


viewWorkTitle :
    Int
    ->
        { title : String
        , date : Date
        , mainVisualUrl : String
        , mainVisualColor : Color
        , settings : Settings
        , icons :
            { visualCommunication : Bool, programming : Bool, language : Bool, learning : Bool }
        }
    -> Element Msg
viewWorkTitle blockWidth { title, date, mainVisualUrl, mainVisualColor, icons, settings } =
    let
        colorAt70 =
            Palette.colorAt70 mainVisualColor

        mainBlock =
            column
                [ width (px blockWidth)
                , height (px (round (toFloat blockWidth / settings.mainVisualAspectRatio)))
                , Background.image mainVisualUrl
                , CustomEl.backgroundColor colorAt70
                ]

        iconsBlock =
            row
                [ paddingXY Palette.spaceNormal Palette.spaceSmall
                , CustomEl.style "flex-basis" "auto"
                ]
                [ viewIcon mainVisualColor View.Icon.VisualCommunication icons.visualCommunication
                , viewIcon mainVisualColor View.Icon.Programming icons.programming
                , viewIcon mainVisualColor View.Icon.Language icons.language
                , viewIcon mainVisualColor View.Icon.Learning icons.learning
                ]

        gradientBlock =
            column
                [ width fill
                , alignBottom
                , paddingEach { left = Palette.spaceNormal, right = Palette.spaceNormal, top = fraction 1 Palette.textSizeLarge, bottom = 0 }
                , Background.gradient
                    { angle = 0
                    , steps =
                        [ colorAt70 |> Color.setOpacity 0.9 |> Color.toElmUi
                        , colorAt70 |> Color.setOpacity 0.4 |> Color.toElmUi
                        , colorAt70 |> Color.setOpacity 0 |> Color.toElmUi
                        ]
                    }
                ]

        yearBlock =
            el
                [ alignBottom
                , paddingXY 0 0
                , Font.size Palette.textSizeSmall
                , Font.bold
                , CustomEl.glow
                    { color = mainVisualColor |> Palette.colorAt70
                    , strength = 5.0
                    , size = 3.0
                    }
                ]

        titleBlock =
            el
                [ alignBottom
                , paddingXY 0 Palette.spaceSmaller
                , Font.size Palette.textSizeLarge
                , CustomEl.glow
                    { color = mainVisualColor |> Palette.colorAt70
                    , strength = 5.0
                    , size = 3.0
                    }
                ]
    in
    mainBlock
        [ iconsBlock
        , gradientBlock
            [ yearBlock (text <| Date.toString date)
            , titleBlock <|
                paragraph [] [ text title ]
            ]
        ]


viewIcon : Color -> IconName -> Bool -> Element msg
viewIcon color iconName isVisible =
    let
        size =
            fraction 1.5 Palette.spaceNormal
    in
    if isVisible then
        icon size color iconName

    else
        none


viewWorkVisuals : Int -> Settings -> Color -> List Visual -> Element Msg
viewWorkVisuals blockWidth settings mainVisualColor visuals =
    let
        perRow =
            settings.thumbnailsPerRow

        spaceBetween =
            Palette.spaceSmallest

        thumbnailSize =
            toFloat (blockWidth - (spaceBetween * (perRow - 1)))
                / toFloat perRow
                |> floor
    in
    if List.isEmpty visuals then
        none

    else
        wrappedRow
            [ spacing spaceBetween
            , width fill
            , paddingEach { sides | top = spaceBetween }
            ]
            (List.map (viewVisualThumbnail mainVisualColor thumbnailSize) visuals)


viewVisualThumbnail : Color -> Int -> Visual -> Element Msg
viewVisualThumbnail mainVisualColor size visual =
    let
        ( thumbnailUrl, color, isVideo ) =
            case visual of
                Image desc ->
                    ( desc.thumbnailUrl, desc.color, False )

                Video desc ->
                    ( desc.thumbnailUrl, desc.color, True )
    in
    el
        ([ width (px size)
         , height (px size)
         , onClick (SelectedVisual (Just visual))
         , pointer
         , Background.color (color |> Color.toElmUi)
         ]
            ++ ifElse isVideo
                [ inFront <|
                    el
                        [ alignRight
                        , alignBottom
                        ]
                        (icon (fraction 0.3 size) mainVisualColor View.Icon.Play)
                ]
                []
        )
        (image
            [ width (px size)
            , height (px size)
            ]
            { src = thumbnailUrl
            , description = " "
            }
        )


viewWorkLinks : Color -> List Link -> Element Msg
viewWorkLinks color links =
    let
        makeLink link =
            newTabLink
                (centerX :: linkStyle color)
                { url = link.url
                , label = text link.label
                }
    in
    if List.isEmpty links then
        none

    else
        wrappedRow
            [ paddingEach { left = Palette.spaceNormal, right = Palette.spaceNormal, top = Palette.spaceNormal, bottom = 0 }
            , width fill
            ]
        <|
            List.map makeLink links


viewWorkDescription : Color -> Doc -> Element Msg
viewWorkDescription color doc =
    el [ paddingXY Palette.spaceNormal Palette.spaceSmall ]
        (Descriptor.fromDoc color doc)


viewWorkReadMore : Labels -> Maybe Work.ReadMore -> Color -> Element Msg
viewWorkReadMore labels readMore color =
    case readMore of
        Nothing ->
            none

        Just desc ->
            let
                label =
                    case desc.language of
                        English ->
                            labels.readMoreEnglish

                        Japanese ->
                            labels.readMoreJapanese

                        Spanish ->
                            labels.readMoreSpanish
            in
            el
                [ alignRight
                , alignBottom
                , moveDown <| 0.3 * toFloat Palette.textSizeNormal
                , moveLeft <| toFloat Palette.spaceNormal
                ]
            <|
                newTabLink (linkStyle color)
                    { url = desc.url
                    , label = text label
                    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize <|
            \w h -> Resized
        , Viewport.got GotViewport NoOp
        ]



-- OTHER


linkStyle : Color -> List (Element.Attribute Msg)
linkStyle backgroundColor =
    [ Background.color (backgroundColor |> Color.toElmUi) -- (Palette.colorAt50 Palette.baseColor)
    , paddingXY
        (fraction 0.6 Palette.textSizeNormal)
        (fraction 0.4 Palette.textSizeNormal)
    , centerX
    , pointer
    , mouseDown
        [ Background.color (Palette.baseColorAt10 |> Color.toElmUi)
        , Font.color (Palette.baseColorAt90 |> Color.toElmUi)
        ]
    ]


getLanguageFromPreferred : List String -> Language
getLanguageFromPreferred codes =
    codes
        |> List.map (String.left 2)
        |> List.filterMap Language.fromCode
        |> List.head
        |> Maybe.withDefault English


icon : Int -> Color -> IconName -> Element msg
icon size color iconName =
    el
        [ Element.padding <| fraction 0.1 size
        , CustomEl.radialGradient
            [ ( 0.5, color |> Palette.colorAt70 |> Color.setOpacity 0.9 )
            , ( 1, color |> Palette.colorAt70 |> Color.setOpacity 0 )
            ]
        ]
        (View.Icon.icon iconName (fraction 0.8 size)
            |> View.Icon.view
        )


sortWorks : Tag -> List Work -> List Work
sortWorks tag works =
    let
        tagIndex work =
            List.Extra.elemIndex tag work.tags
                |> Maybe.withDefault 999
    in
    List.sortBy tagIndex works


defaultScroll =
    SmoothScroll.defaultConfig
