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
    | StoryLoaded (Result Http.Error Story)



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
            let
                cmd =
                    case List.head ids of
                        Nothing ->
                            Cmd.none

                        Just id ->
                            Http.send StoryLoaded (Request.Story.fetchStory id)
            in
            ( { model | storyIds = ids }, cmd )

        StoryLoaded (Err _) ->
            ( { model | stories = [] }, Cmd.none )

        StoryLoaded (Ok story) ->
            ( { model | stories = [ story ] }, Cmd.none )



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
