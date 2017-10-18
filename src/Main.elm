module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Http
import Request.Story


type alias Model =
    { stories : List StoryId
    }


type Msg
    = StoriesLoaded (Result Http.Error (List StoryId))



-- Setting up The Elm Architecture (TEA)


init : ( Model, Cmd Msg )
init =
    ( { stories = [] }
    , Http.send StoriesLoaded Request.Story.fetchNew
    )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }



-- Model updates


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoriesLoaded (Err _) ->
            ( { model | stories = [] }, Cmd.none )

        StoriesLoaded (Ok ids) ->
            ( { model | stories = ids }, Cmd.none )



-- Displaying the current model


renderStory : StoryId -> Html msg
renderStory id =
    Html.div []
        [ Html.text <| "StoryId: " ++ toString id
        ]


view : Model -> Html Msg
view { stories } =
    case stories of
        [] ->
            Html.text "No stories around..."

        _ ->
            Html.div []
                (List.map renderStory stories)
