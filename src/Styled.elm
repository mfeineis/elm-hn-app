module Styled
    exposing
        ( navButton
        , navButtonDisabled
        , navButtonSelected
        , navLogo
        , navTitle
        , pageFrame
        , pageHeader
        , pageMain
        , storyItem
        )

import Css exposing (..)
import Css.Colors as Colors
import Html exposing (Html, button, div)
import Html.Attributes as Attr


styles : List Style -> Html.Attribute msg
styles =
    Css.asPairs >> Attr.style


navButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navButton attrs children =
    Html.a
        (styles
            [ color Colors.black
            , cursor pointer
            , display inlineBlock
            , lineHeight (px 31)
            , marginLeft (px 15)
            , textDecoration none
            , verticalAlign top
            ]
            :: ([ Attr.href "#" ] ++ attrs)
        )
        children


navButtonDisabled : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navButtonDisabled attrs children =
    Html.a
        (styles
            [ color Colors.gray
            , cursor notAllowed
            , display inlineBlock
            , lineHeight (px 31)
            , marginLeft (px 15)
            , textDecoration none
            , verticalAlign top
            ]
            :: ([] ++ attrs)
        )
        children


navButtonSelected : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navButtonSelected attrs children =
    Html.a
        (styles
            [ color Colors.white
            , cursor pointer
            , display inlineBlock
            , lineHeight (px 31)
            , marginLeft (px 15)
            , textDecoration none
            , verticalAlign top
            ]
            :: ([ Attr.href "#" ] ++ attrs)
        )
        children


navLogo : List (Html.Attribute msg) -> Html msg
navLogo attrs =
    Html.span
        (styles
            [ border3 (px 1) solid Colors.white
            , display inlineBlock
            , cursor pointer
            , height (px 18)
            , margin (px 5)
            , width (px 18)
            ]
            :: attrs
        )
        [ Html.img
            [ styles
                [ display inlineBlock
                , position absolute
                ]
            , Attr.alt "Y combinator logo"
            , Attr.src "https://news.ycombinator.com/y18.gif"
            ]
            []
        ]


navTitle : List (Html.Attribute msg) -> List (Html msg) -> Html msg
navTitle attrs children =
    Html.a
        (styles
            [ color Colors.black
            , display inlineBlock
            , fontWeight bold
            , lineHeight (px 31)
            , margin (px 0)
            , marginRight (px 5)
            , textDecoration none
            , verticalAlign top
            ]
            :: ([ Attr.href "#" ] ++ attrs)
        )
        children


pageFrame : List (Html.Attribute msg) -> List (Html msg) -> Html msg
pageFrame attrs children =
    Html.div
        (styles
            [ fontFamilies [ "Verdana", "Geneva", "sans-serif" ]
            , margin (px 0)
            ]
            :: attrs
        )
        children


pageHeader : List (Html.Attribute msg) -> List (Html msg) -> Html msg
pageHeader attrs children =
    Html.header
        (styles
            [ backgroundColor Colors.orange
            ]
            :: attrs
        )
        children


pageMain : List (Html.Attribute msg) -> List (Html msg) -> Html msg
pageMain attrs children =
    Html.main_
        (styles
            [ backgroundColor (hex "f6f6ef")
            , padding (px 10)
            ]
            :: attrs
        )
        children


storyItem : List (Html.Attribute msg) -> List (Html msg) -> Html msg
storyItem attrs children =
    Html.div
        (styles
            [ paddingBottom (px 10)
            ]
            :: attrs
        )
        children
