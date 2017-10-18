module Static.Example exposing (view)

import Html exposing (Html, div, h1, text)


view : Html msg
view =
    div []
        [ h1 [] [ text "Example Title" ]
        , div [] [ text "Example Content" ]
        ]
