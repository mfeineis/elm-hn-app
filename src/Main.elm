module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Http
import Request.Story


type PageState
    = Loading
    | Loaded


type alias Model =
    { pageState : PageState
    , stories : List Story
    , storyIds : List StoryId
    }


type Msg
    = StoryIdsLoaded (Result Http.Error (List StoryId))
    | StoriesLoaded (Result Http.Error (List (Maybe Story)))
    | ShowCategory String



-- Setting up The Elm Architecture (TEA)


init : ( Model, Cmd Msg )
init =
    ( { pageState = Loading, stories = [], storyIds = [] }
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
            ( model |> setLoading
            , Http.send StoryIdsLoaded Request.Story.fetchBestIds
            )

        ShowCategory "newstories" ->
            ( model |> setLoading
            , Http.send StoryIdsLoaded Request.Story.fetchNewIds
            )

        ShowCategory "topstories" ->
            ( model |> setLoading
            , Http.send StoryIdsLoaded Request.Story.fetchTopIds
            )

        ShowCategory _ ->
            -- Hmm, this seems off
            ( model |> setLoaded
            , Cmd.none
            )

        StoriesLoaded (Err _) ->
            ( { model | stories = [] } |> setLoaded
            , Cmd.none
            )

        StoriesLoaded (Ok stories) ->
            let
                filtered =
                    List.filterMap identity stories
            in
            ( { model | stories = filtered } |> setLoaded
            , Cmd.none
            )

        StoryIdsLoaded (Err _) ->
            ( { model | stories = [], storyIds = [] }
                |> setLoaded
            , Cmd.none
            )

        StoryIdsLoaded (Ok ids) ->
            ( { model | stories = [], storyIds = ids }
                |> setLoaded
            , Request.Story.fetchStories StoriesLoaded (List.take 5 ids)
            )


setLoaded model =
    { model | pageState = Loaded }


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


headerItems : { a | pageState : PageState } -> List (Html Msg)
headerItems { pageState } =
    case pageState of
        Loading ->
            [ Html.span [] [ Html.text "[Y]" ]
            , Html.span [] [ Html.text "Loading" ]
            ]

        Loaded ->
            [ Html.span [] [ Html.text "[Y]" ]
            , Html.button [ onClick (ShowCategory "beststories") ] [ Html.text "best" ]
            , Html.button [ onClick (ShowCategory "newstories") ] [ Html.text "new" ]
            , Html.button [ onClick (ShowCategory "topstories") ] [ Html.text "top" ]
            ]
