module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Http
import Request.Story


type Page
    = BestStories
    | NewStories
    | TopStories


type PageState
    = Loaded
    | Loading


type alias Model =
    { pageState : PageState
    , stories : List Story
    , storyIds : List StoryId
    }


type Msg
    = StoryIdsLoaded (Result Http.Error (List StoryId))
    | StoriesLoaded (Result Http.Error (List (Maybe Story)))
    | ShowPage Page



-- Setting up The Elm Architecture (TEA)


init : ( Model, Cmd Msg )
init =
    ( { pageState = Loading
      , stories = []
      , storyIds = []
      }
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
        ShowPage BestStories ->
            ( model
                |> setLoading
            , Http.send StoryIdsLoaded Request.Story.fetchBestIds
            )

        ShowPage NewStories ->
            ( model
                |> setLoading
            , Http.send StoryIdsLoaded Request.Story.fetchNewIds
            )

        ShowPage TopStories ->
            ( model
                |> setLoading
            , Http.send StoryIdsLoaded Request.Story.fetchTopIds
            )

        StoriesLoaded (Err _) ->
            ( model
                |> resetStories
                |> setLoaded
            , Cmd.none
            )

        StoriesLoaded (Ok stories) ->
            let
                filtered =
                    List.filterMap identity stories
            in
            ( { model | stories = filtered }
                |> setLoaded
            , Cmd.none
            )

        StoryIdsLoaded (Err _) ->
            ( { model | storyIds = [] }
                |> resetStories
                |> setLoaded
            , Cmd.none
            )

        StoryIdsLoaded (Ok ids) ->
            ( { model | storyIds = ids }
                |> resetStories
                |> setLoading
            , Request.Story.fetchStories StoriesLoaded (List.take 5 ids)
            )


resetStories : Model -> Model
resetStories model =
    { model | stories = [] }


setLoaded : Model -> Model
setLoaded model =
    { model | pageState = Loaded }


setLoading : Model -> Model
setLoading model =
    { model | pageState = Loading }



-- Displaying the current model


view : Model -> Html Msg
view ({ pageState, stories } as model) =
    let
        message =
            case pageState of
                Loading ->
                    "Loading something..."

                Loaded ->
                    "No stories around."

        storyList =
            case stories of
                [] ->
                    [ Html.text message ]

                _ ->
                    List.map renderStory stories
    in
    Html.div []
        [ Html.header [] (headerItems model)
        , Html.main_ [] storyList
        ]


renderStory : Story -> Html msg
renderStory { descendants, id, title, url } =
    let
        descendantInfo =
            case descendants of
                Nothing ->
                    ""

                Just amount ->
                    " (" ++ toString amount ++ ")"
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


headerItems : { a | pageState : PageState } -> List (Html Msg)
headerItems { pageState } =
    case pageState of
        Loading ->
            [ Html.span [] [ Html.text "[Y]" ]
            ]

        Loaded ->
            [ Html.span [] [ Html.text "[Y]" ]
            , Html.button [ onClick (ShowPage BestStories) ] [ Html.text "best" ]
            , Html.button [ onClick (ShowPage NewStories) ] [ Html.text "new" ]
            , Html.button [ onClick (ShowPage TopStories) ] [ Html.text "top" ]
            ]
