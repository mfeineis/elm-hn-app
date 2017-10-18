module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Http
import Request.Story


type alias Model =
    { stories : List Story
    , storyIds : List StoryId
    }


type Msg
    = StoryIdsLoaded (Result Http.Error (List StoryId))
    | StoriesLoaded (Result Http.Error (List Story))



-- Setting up The Elm Architecture (TEA)


init : ( Model, Cmd Msg )
init =
    ( { stories = [], storyIds = [] }
    , Http.send StoryIdsLoaded Request.Story.fetchNewIds
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
        StoryIdsLoaded (Err _) ->
            ( { model | storyIds = [] }, Cmd.none )

        StoryIdsLoaded (Ok ids) ->
            ( { model | stories = [], storyIds = ids }
            , Request.Story.fetchStories StoriesLoaded (List.take 5 ids)
            )

        StoriesLoaded (Err _) ->
            ( { model | stories = [] }, Cmd.none )

        StoriesLoaded (Ok stories) ->
            ( { model | stories = stories }, Cmd.none )



-- Displaying the current model


renderStory : Story -> Html msg
renderStory { id, title } =
    Html.div []
        [ Html.text <| "ID" ++ toString id ++ " | " ++ title
        ]


view : Model -> Html Msg
view { stories } =
    case stories of
        [] ->
            Html.text "No stories around..."

        _ ->
            Html.div []
                (List.map renderStory stories)
