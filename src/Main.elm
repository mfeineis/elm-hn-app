module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Http
import Request.Story


type alias Model =
    { stories : List Story
    , storyIds : List StoryId
    }


type Msg
    = StoryIdsLoaded (Result Http.Error (List StoryId))
    | StoriesLoaded (Result Http.Error (List (Maybe Story)))
    | ShowCategory String



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
        ShowCategory "beststories" ->
            ( model, Http.send StoryIdsLoaded Request.Story.fetchBestIds )

        ShowCategory "newstories" ->
            ( model, Http.send StoryIdsLoaded Request.Story.fetchNewIds )

        ShowCategory "topstories" ->
            ( model, Http.send StoryIdsLoaded Request.Story.fetchTopIds )

        ShowCategory _ ->
            -- Hmm, this seems off
            ( model, Cmd.none )

        StoriesLoaded (Err _) ->
            ( { model | stories = [] }, Cmd.none )

        StoriesLoaded (Ok stories) ->
            let
                filtered =
                    List.filterMap identity stories
            in
            ( { model | stories = filtered }, Cmd.none )

        StoryIdsLoaded (Err _) ->
            ( { model | stories = [], storyIds = [] }, Cmd.none )

        StoryIdsLoaded (Ok ids) ->
            ( { model | stories = [], storyIds = ids }
            , Request.Story.fetchStories StoriesLoaded (List.take 5 ids)
            )



-- Displaying the current model


renderStory : Story -> Html msg
renderStory { descendants, id, title, url } =
    let
        descendantInfo =
            case descendants of
                Nothing ->
                    ""

                Just amount ->
                    "(" ++ toString amount ++ ")"
    in
    case url of
        Nothing ->
            Html.div []
                [ Html.text <| "ID" ++ Data.Story.storyIdToString id ++ " | " ++ title
                , Html.text descendantInfo
                ]

        Just url ->
            Html.div []
                [ Html.text <| "ID" ++ Data.Story.storyIdToString id ++ " | "
                , Html.a [ Attr.href url ]
                    [ Html.text title
                    ]
                , Html.text descendantInfo
                ]


headerItems : List (Html Msg)
headerItems =
    [ Html.span [] [ Html.text "[Y]" ]
    , Html.button [ onClick (ShowCategory "beststories") ] [ Html.text "best" ]
    , Html.button [ onClick (ShowCategory "newstories") ] [ Html.text "new" ]
    , Html.button [ onClick (ShowCategory "topstories") ] [ Html.text "top" ]
    ]


view : Model -> Html Msg
view { stories } =
    let
        storyList =
            case stories of
                [] ->
                    [ Html.text "No stories around..." ]

                _ ->
                    List.map renderStory stories
    in
    Html.div []
        [ Html.header [] headerItems
        , Html.main_ [] storyList
        ]
