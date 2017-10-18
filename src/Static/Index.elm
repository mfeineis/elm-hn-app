module Static.Index exposing (view)

import Html exposing (Html, div, h1, node, p, text)
import Html.Attributes
    exposing
        ( attribute
        , charset
        , class
        , content
        , href
        , id
        , lang
        , name
        , rel
        , src
        , type_
        )


view : Html msg
view =
    cordovaShell "Static Elm" [] []


meta : List (Html.Attribute msg) -> List (Html msg) -> Html msg
meta =
    node "meta"


cordovaShell : String -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
cordovaShell title bodyAttrs bodyContent =
    node "html"
        [ lang "en" ]
        [ node "head"
            []
            [ meta [ charset "utf-8" ] []
            , meta
                [ attribute "http-equiv" "Content-Security-Policy"
                , content <|
                    String.join "; "
                        [ "default-src 'self' data: gap: https://ssl.gstatic.com 'unsafe-eval'"
                        , "style-src 'self' 'unsafe-inline' "
                        , "media-src *"
                        , "img-src 'self' data: content:;"
                        ]
                ]
                []
            , meta
                [ name "format-detection"
                , content "telephone=no"
                ]
                []
            , meta
                [ name "msapplication-tap-highlight"
                , content "no"
                ]
                []
            , meta
                [ name "viewport"
                , content <|
                    String.join ", "
                        [ "user-scalable=no"
                        , "initial-scale=1"
                        , "maximum-scale=1"
                        , "minimum-scale=1"
                        , "width=device-width"
                        , "shrink-to-fit=no"
                        ]
                ]
                []
            , node "title" [] [ text title ]
            ]
        , node "body"
            bodyAttrs
            ([ node "script" [ type_ "text/javascript", src "cordova.js" ] []
             , node "script" [ type_ "text/javascript", src "app.js" ] []
             , node "script" [ type_ "text/javascript", src "setup.js" ] []
             ]
                ++ bodyContent
            )
        ]
