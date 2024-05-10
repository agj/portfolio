module Main exposing (Document, Model, init, main, subscriptions, update, view)

import Animator exposing (Animator)
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
import Element as Ui
import Element.Background as UiBackground
import Element.Border as UiBorder
import Element.Events as UiEvents
import Element.Font as UiFont
import Html exposing (Html)
import Html.Attributes
import Http
import Language exposing (Language(..))
import LayoutFormat exposing (LayoutFormat(..))
import List.Extra
import Palette
import Ports
import SaveState exposing (SaveState)
import Tag exposing (Tag)
import Time
import Url exposing (Url)
import Util.AppUrl as AppUrl
import Util.Color as Color
import Utils exposing (..)
import VideoEmbed
import View.CssSvg as CssSvg
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
    , popupVisual : Animator.Timeline (Maybe Visual)
    , highlightedWorkIndex : Maybe Int
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
      , popupVisual = Animator.init Nothing
      , highlightedWorkIndex = Nothing
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
    | ClearedTag
    | SelectedVisual (Maybe Visual)
    | SelectedGoHome
    | Resized
    | GotViewport Viewport
    | GotData (Result Http.Error (List WorkLanguages))
    | AnimationTick Time.Posix
    | ScrolledOverWork (Maybe Int)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedLanguage language ->
            ( { model | language = language }
            , SaveState.save { language = language }
            )

        SelectedTag tag ->
            updateTag (Just tag) model

        ClearedTag ->
            updateTag Nothing model

        SelectedVisual selection ->
            ( { model | popupVisual = Animator.go Animator.quickly selection model.popupVisual }
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

        AnimationTick time ->
            ( model |> Animator.update time animator
            , Cmd.none
            )

        ScrolledOverWork maybeWorkIndex ->
            ( { model | highlightedWorkIndex = maybeWorkIndex }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


updateTag : Maybe Tag -> Model -> ( Model, Cmd Msg )
updateTag tag model =
    let
        query =
            model.query

        newQuery =
            { query | tag = tag }

        scrollTargetId =
            case tag of
                Just _ ->
                    "works"

                Nothing ->
                    ""
    in
    ( { model | query = newQuery }
    , Cmd.batch
        [ Ports.scrollTo scrollTargetId
        , changeQuery model.navigationData newQuery
        ]
    )


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
            [ UiFont.family Palette.font ]

        highlightedWork : Maybe Work
        highlightedWork =
            case ( model.highlightedWorkIndex, model.data ) of
                ( Just workIndex, DataLoaded data ) ->
                    getCurrentWorks model.language model.query data
                        |> List.Extra.getAt workIndex

                _ ->
                    Nothing

        backgroundColor =
            highlightedWork
                |> Maybe.map (\work -> Palette.colorAt80 work.mainVisualColor)
                |> Maybe.withDefault Palette.baseColorAt80
    in
    { title = labels.title
    , body =
        [ viewMain model
            |> Ui.layout (globalStyles ++ viewPopupVisualAttr model.viewport model.popupVisual)
        , Html.node "style"
            []
            [ """
                body {
                    background-color: {color};
                    background-image: {background-image};
                }
              """
                |> String.replace "{color}" (Color.toCssString backgroundColor)
                |> String.replace "{background-image}" (CssSvg.patternOverlappingCircles Palette.baseColorAt90)
                |> Html.text
            ]
        ]
    }


viewMain : Model -> Ui.Element Msg
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

        worksBlock : Ui.Element Msg -> Ui.Element Msg
        worksBlock =
            Ui.el
                [ Ui.width (Ui.px worksBlockWidth)
                , Ui.paddingXY
                    (ifElse (layoutFormat == PhoneLayout)
                        Palette.spaceSmall
                        0
                    )
                    0
                , Ui.spacing Palette.spaceNormal
                , CustomEl.id "works"
                ]

        content : Ui.Element Msg
        content =
            case model.data of
                DataLoaded data ->
                    viewWorks
                        { blockWidth =
                            ifElse (layoutFormat == PhoneLayout)
                                (worksBlockWidth - (2 * Palette.spaceSmall))
                                worksBlockWidth
                        , labels = labels
                        , works = getCurrentWorks model.language model.query data
                        , settings = settings
                        }

                DataLoading ->
                    viewLoadMessage labels.loading

                DataLoadError err ->
                    case err of
                        Http.BadBody msg ->
                            viewLoadMessage (Descriptor.p [ Descriptor.t ("Data error!\n\n" ++ msg) ])

                        _ ->
                            viewLoadMessage labels.loadError
    in
    Ui.column
        [ Ui.width <| Maybe.withDefault Ui.fill (settings.worksBlockWidth |> Maybe.map Ui.px)
        , Ui.centerX
        , Ui.inFront <| viewLanguageSelector model.language
        , Ui.inFront <| viewBackButton labels.backToHome
        , Ui.paddingEach { sides | top = Palette.spaceSmall, bottom = Palette.spaceLarge }
        , Ui.spacing Palette.spaceNormal
        ]
        [ viewTop model.language model.query.tag
        , worksBlock content
        ]


viewTop : Language -> Maybe Tag -> Ui.Element Msg
viewTop language selectedTag =
    Ui.column
        [ UiFont.color (Palette.baseColorAt10 |> Color.toElmUi)
        , UiBackground.color (Palette.baseColorAt90 |> Color.toElmUi)
        , Ui.paddingEach { sides | top = Palette.spaceNormal, bottom = Palette.spaceSmall }
        ]
        [ viewIntroduction (Introduction.ofLanguage SelectedTag selectedTag language)
        ]


viewLanguageSelector : Language -> Ui.Element Msg
viewLanguageSelector language =
    Ui.row
        [ Ui.spacing Palette.spaceSmallest
        , Ui.alignRight
        , Ui.paddingEach { sides | right = Palette.spaceSmall }
        ]
        [ viewLanguageButton "EN" English language
        , viewLanguageButton "ES" Spanish language
        , viewLanguageButton "日" Japanese language
        ]


viewBackButton : String -> Ui.Element Msg
viewBackButton label =
    Ui.el [ Ui.centerX, Ui.centerY ] (Ui.text label)
        |> Ui.el
            [ Ui.alignLeft
            , Ui.paddingXY Palette.spaceSmall 0
            , UiFont.size Palette.textSizeNormal
            , Ui.height (Ui.px (fraction 2.3 Palette.textSizeNormal))
            , Ui.pointer
            , UiBackground.color (Palette.baseColorAt90 |> Color.toElmUi)
            , UiBorder.color (Palette.baseColorAt50 |> Color.toElmUi)
            , UiBorder.widthEach { left = 1, right = 1, bottom = 1, top = 0 }
            , UiFont.color (Palette.baseColorAt10 |> Color.toElmUi)
            , Ui.mouseDown
                [ UiBackground.color (Palette.baseColorAt10 |> Color.toElmUi)
                , UiFont.color (Palette.baseColorAt90 |> Color.toElmUi)
                ]
            , UiEvents.onClick SelectedGoHome
            ]
        |> Ui.el [ Ui.paddingEach { sides | left = Palette.spaceSmall } ]


viewLanguageButton : String -> Language -> Language -> Ui.Element Msg
viewLanguageButton label language selectedLanguage =
    if language == selectedLanguage then
        Ui.none

    else
        Ui.el
            [ UiEvents.onClick (SelectedLanguage language)
            , UiFont.size Palette.textSizeNormal
            , Ui.width (Ui.px (fraction 2.9 Palette.textSizeNormal))
            , Ui.height (Ui.px (fraction 2.3 Palette.textSizeNormal))
            , Ui.pointer
            , UiBackground.color (Palette.baseColorAt50 |> Color.toElmUi)
            , UiFont.color (Palette.baseColorAt10 |> Color.toElmUi)
            , Ui.mouseDown
                [ UiBackground.color (Palette.baseColorAt10 |> Color.toElmUi)
                , UiFont.color (Palette.baseColorAt90 |> Color.toElmUi)
                ]
            ]
            (Ui.el
                [ Ui.centerX
                , Ui.centerY
                ]
                (Ui.text label)
            )


viewIntroduction : Ui.Element Msg -> Ui.Element Msg
viewIntroduction introductionText =
    Ui.el
        [ Ui.width Ui.fill
        , Ui.paddingXY Palette.spaceNormal Palette.spaceNormal
        , UiFont.size Palette.textSizeNormal
        ]
        introductionText


viewLoadMessage : Ui.Element Msg -> Ui.Element Msg
viewLoadMessage message =
    message
        |> Ui.el
            [ UiFont.color (Palette.baseColorAt10 |> Color.toElmUi)
            , Ui.width Ui.fill
            ]
        |> viewMessageBlock


viewMessageBlock : Ui.Element Msg -> Ui.Element Msg
viewMessageBlock child =
    viewWorkBlock [] <|
        [ Ui.el
            [ Ui.paddingXY Palette.spaceNormal Palette.spaceNormal
            , Ui.width Ui.fill
            , UiFont.center
            ]
            child
        ]


viewPopupVisualAttr : Viewport -> Animator.Timeline (Maybe Visual) -> List (Ui.Attribute Msg)
viewPopupVisualAttr viewport popupVisualTimeline =
    let
        popupVisualShowingDegree : Float
        popupVisualShowingDegree =
            Animator.move popupVisualTimeline
                (\state ->
                    case state of
                        Just _ ->
                            Animator.at 1

                        Nothing ->
                            Animator.at 0
                )
    in
    case ( Animator.current popupVisualTimeline, Animator.previous popupVisualTimeline ) of
        ( Just visual, _ ) ->
            [ Ui.inFront (viewPopupVisual viewport visual popupVisualShowingDegree) ]

        ( _, Just visual ) ->
            [ Ui.inFront (viewPopupVisual viewport visual popupVisualShowingDegree) ]

        _ ->
            []


viewPopupVisual : Viewport -> Visual -> Float -> Ui.Element Msg
viewPopupVisual viewport visual showingDegree =
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
            Ui.el
                [ Ui.width (Ui.px usableWidth)
                , Ui.height (Ui.px usableHeight)
                , Ui.alignLeft
                , Ui.alignBottom
                , Ui.scale (0.8 + showingDegree * 0.2)
                ]
                (case visual of
                    Image desc ->
                        Ui.image
                            [ Ui.width (Ui.px visualWidth)
                            , Ui.height (Ui.px visualHeight)
                            , Ui.centerX
                            , Ui.centerY
                            , UiBackground.color (color |> Color.toElmUi)
                            , Html.Attributes.class "popup-visual"
                                |> Ui.htmlAttribute
                            , Html.Attributes.style "background-image" (CssSvg.patternAngles (Palette.colorAt60 desc.color))
                                |> Ui.htmlAttribute
                            ]
                            { src = desc.url
                            , description = ""
                            }

                    Video desc ->
                        VideoEmbed.get desc visualWidth visualHeight
                )

        closeButton =
            Ui.el
                [ Ui.width (Ui.px reservedSpace)
                , Ui.height (Ui.px reservedSpace)
                , Ui.padding <| fraction 0.3 reservedSpace
                , Ui.alignRight
                , Ui.alignTop
                , Ui.pointer
                , UiFont.color (color |> Palette.colorAt10 |> Color.toElmUi)
                ]
                (View.Icon.icon View.Icon.Close (fraction 0.4 reservedSpace)
                    |> View.Icon.view
                )
    in
    Ui.el
        [ Ui.width Ui.fill
        , Ui.height Ui.fill
        , UiBackground.color (color |> Palette.colorAt70 |> Color.setOpacity 0.8 |> Color.toElmUi)
        , UiEvents.onClick (SelectedVisual Nothing)
        , Ui.pointer
        , Ui.inFront closeButton
        , Ui.alpha showingDegree
        ]
        visualEl



-- VIEW WORKS


viewWorks : { blockWidth : Int, labels : Labels Msg, works : List Work, settings : Settings } -> Ui.Element Msg
viewWorks { blockWidth, labels, works, settings } =
    if List.isEmpty works then
        viewLoadMessage labels.pleaseSelect

    else
        [ works
            |> List.map (viewWork blockWidth labels settings)
        , [ viewLoadMessage (labels.thatsAll { onClearTag = ClearedTag }) ]
        ]
            |> List.concat
            |> Ui.column
                [ Ui.width Ui.fill
                , Ui.spacing Palette.spaceNormal
                ]


viewWorkBlock : List (Ui.Attribute Msg) -> List (Ui.Element Msg) -> Ui.Element Msg
viewWorkBlock attrs children =
    Ui.column
        ([ Ui.width Ui.fill
         , UiFont.size Palette.textSizeNormal
         , Html.Attributes.class "work"
            |> Ui.htmlAttribute
         ]
            ++ attrs
        )
        children


viewWork : Int -> Labels Msg -> Settings -> Work -> Ui.Element Msg
viewWork blockWidth labels settings work =
    viewWorkBlock
        [ Ui.inFront <| viewWorkReadMore labels work.readMore work.mainVisualColor
        , Ui.paddingEach { sides | bottom = Palette.spaceNormal }
        , UiFont.color (work.mainVisualColor |> Palette.colorAt10 |> Color.toElmUi)
        , UiBackground.color (work.mainVisualColor |> Palette.colorAt90 |> Color.toElmUi)
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
    -> Ui.Element Msg
viewWorkTitle blockWidth { title, date, mainVisualUrl, mainVisualColor, icons, settings } =
    let
        colorAt70 =
            Palette.colorAt70 mainVisualColor

        mainBlock =
            Ui.column
                [ Ui.width (Ui.px blockWidth)
                , Ui.height (Ui.px (round (toFloat blockWidth / settings.mainVisualAspectRatio)))
                , UiBackground.image mainVisualUrl
                , CustomEl.backgroundColor colorAt70
                ]

        iconsBlock =
            Ui.row
                [ Ui.paddingXY Palette.spaceNormal Palette.spaceSmall
                , CustomEl.style "flex-basis" "auto"
                ]
                [ viewIcon mainVisualColor View.Icon.VisualCommunication icons.visualCommunication
                , viewIcon mainVisualColor View.Icon.Programming icons.programming
                , viewIcon mainVisualColor View.Icon.Language icons.language
                , viewIcon mainVisualColor View.Icon.Learning icons.learning
                ]

        gradientBlock =
            Ui.column
                [ Ui.width Ui.fill
                , Ui.alignBottom
                , Ui.paddingEach { left = Palette.spaceNormal, right = Palette.spaceNormal, top = fraction 1 Palette.textSizeLarge, bottom = 0 }
                , UiBackground.gradient
                    { angle = 0
                    , steps =
                        [ colorAt70 |> Color.setOpacity 0.9 |> Color.toElmUi
                        , colorAt70 |> Color.setOpacity 0.4 |> Color.toElmUi
                        , colorAt70 |> Color.setOpacity 0 |> Color.toElmUi
                        ]
                    }
                ]

        yearBlock =
            Ui.el
                [ Ui.alignBottom
                , Ui.paddingXY 0 0
                , UiFont.size Palette.textSizeSmall
                , UiFont.bold
                , CustomEl.glow
                    { color = mainVisualColor |> Palette.colorAt70
                    , strength = 5.0
                    , size = 3.0
                    }
                ]

        titleBlock =
            Ui.el
                [ Ui.alignBottom
                , Ui.paddingXY 0 Palette.spaceSmaller
                , UiFont.size Palette.textSizeLarge
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
            [ yearBlock (Ui.text <| Date.toString date)
            , titleBlock <|
                Ui.paragraph [] [ Ui.text title ]
            ]
        ]


viewIcon : Color -> IconName -> Bool -> Ui.Element msg
viewIcon color iconName isVisible =
    let
        size =
            fraction 1.5 Palette.spaceNormal
    in
    if isVisible then
        icon size color iconName

    else
        Ui.none


viewWorkVisuals : Int -> Settings -> Color -> List Visual -> Ui.Element Msg
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
        Ui.none

    else
        Ui.wrappedRow
            [ Ui.spacing spaceBetween
            , Ui.width Ui.fill
            , Ui.paddingEach { sides | top = spaceBetween }
            ]
            (List.map (viewVisualThumbnail mainVisualColor thumbnailSize) visuals)


viewVisualThumbnail : Color -> Int -> Visual -> Ui.Element Msg
viewVisualThumbnail mainVisualColor size visual =
    let
        ( thumbnailUrl, color, isVideo ) =
            case visual of
                Image desc ->
                    ( desc.thumbnailUrl, desc.color, False )

                Video desc ->
                    ( desc.thumbnailUrl, desc.color, True )
    in
    Ui.el
        ([ Ui.width (Ui.px size)
         , Ui.height (Ui.px size)
         , UiEvents.onClick (SelectedVisual (Just visual))
         , Ui.pointer
         , UiBackground.color (color |> Color.toElmUi)
         ]
            ++ ifElse isVideo
                [ Ui.inFront <|
                    Ui.el
                        [ Ui.alignRight
                        , Ui.alignBottom
                        ]
                        (icon (fraction 0.3 size) mainVisualColor View.Icon.Play)
                ]
                []
        )
        (Ui.image
            [ Ui.width (Ui.px size)
            , Ui.height (Ui.px size)
            ]
            { src = thumbnailUrl
            , description = " "
            }
        )


viewWorkLinks : Color -> List Link -> Ui.Element Msg
viewWorkLinks color links =
    let
        makeLink link =
            Ui.newTabLink
                (Ui.centerX :: linkStyle color)
                { url = link.url
                , label = Ui.text link.label
                }
    in
    if List.isEmpty links then
        Ui.none

    else
        Ui.wrappedRow
            [ Ui.paddingEach { left = Palette.spaceNormal, right = Palette.spaceNormal, top = Palette.spaceNormal, bottom = 0 }
            , Ui.width Ui.fill
            ]
        <|
            List.map makeLink links


viewWorkDescription : Color -> Doc -> Ui.Element Msg
viewWorkDescription color doc =
    Ui.el [ Ui.paddingXY Palette.spaceNormal Palette.spaceSmall ]
        (Descriptor.fromDoc color doc)


viewWorkReadMore : Labels Msg -> Maybe Work.ReadMore -> Color -> Ui.Element Msg
viewWorkReadMore labels readMore color =
    case readMore of
        Nothing ->
            Ui.none

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
            Ui.el
                [ Ui.alignRight
                , Ui.alignBottom
                , Ui.moveDown <| 0.3 * toFloat Palette.textSizeNormal
                , Ui.moveLeft <| toFloat Palette.spaceNormal
                ]
            <|
                Ui.newTabLink (linkStyle color)
                    { url = desc.url
                    , label = Ui.text label
                    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize <|
            \w h -> Resized
        , Viewport.got GotViewport NoOp
        , animator |> Animator.toSubscription AnimationTick model
        , Ports.scrolledOverWork (Just >> ScrolledOverWork) (ScrolledOverWork Nothing)
        ]



-- OTHER


linkStyle : Color -> List (Ui.Attribute Msg)
linkStyle color =
    [ UiBackground.color (color |> Color.toElmUi)
    , Ui.paddingXY
        (fraction 0.6 Palette.textSizeNormal)
        (fraction 0.4 Palette.textSizeNormal)
    , Ui.centerX
    , Ui.pointer
    , Ui.mouseDown
        [ UiBackground.color (color |> Palette.colorAt10 |> Color.toElmUi)
        , UiFont.color (color |> Palette.colorAt90 |> Color.toElmUi)
        ]
    ]


getLanguageFromPreferred : List String -> Language
getLanguageFromPreferred codes =
    codes
        |> List.map (String.left 2)
        |> List.filterMap Language.fromCode
        |> List.head
        |> Maybe.withDefault English


icon : Int -> Color -> IconName -> Ui.Element msg
icon size color iconName =
    Ui.el
        [ Ui.padding <| fraction 0.1 size
        , CustomEl.radialGradient
            [ ( 0.5, color |> Palette.colorAt70 |> Color.setOpacity 0.9 )
            , ( 1, color |> Palette.colorAt70 |> Color.setOpacity 0 )
            ]
        ]
        (View.Icon.icon iconName (fraction 0.8 size)
            |> View.Icon.view
        )


getCurrentWorks : Language -> Query -> List WorkLanguages -> List Work
getCurrentWorks language query data =
    let
        works =
            Works.ofLanguage language data
    in
    case query.tag of
        Nothing ->
            []

        Just Tag.Any ->
            works

        Just tag ->
            works
                |> List.filter (\w -> List.member tag w.tags)
                |> sortWorks tag


sortWorks : Tag -> List Work -> List Work
sortWorks tag works =
    let
        tagIndex work =
            List.Extra.elemIndex tag work.tags
                |> Maybe.withDefault 999
    in
    List.sortBy tagIndex works


animator : Animator Model
animator =
    Animator.animator
        |> Animator.watchingWith
            .popupVisual
            (\newState model ->
                { model | popupVisual = newState }
            )
            (always False)
