module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Http
import Request.Story
import Task


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
            , fetchStoriesV1 (List.take 5 ids)
            )

        StoriesLoaded (Err _) ->
            ( { model | stories = [] }, Cmd.none )

        StoriesLoaded (Ok stories) ->
            ( { model | stories = stories }, Cmd.none )


fetchStoriesV1 : List StoryId -> Cmd Msg
fetchStoriesV1 ids =
    let
        fetchStory =
            Request.Story.fetchStory

        convertHttpRequestToTask =
            Http.toTask

        fetchStoryAndConvertToTask =
            \storyId ->
                fetchStory storyId
                    |> convertHttpRequestToTask
    in
    Task.attempt StoriesLoaded
        (Task.sequence
            (List.map fetchStoryAndConvertToTask ids)
        )



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
