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
    = Loaded Page
    | Loading Page


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
    ( { pageState = Loading NewStories
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
                |> resetStories
                |> setLoading BestStories
            , Http.send StoryIdsLoaded Request.Story.fetchBestIds
            )

        ShowPage NewStories ->
            ( model
                |> resetStories
                |> setLoading NewStories
            , Http.send StoryIdsLoaded Request.Story.fetchNewIds
            )

        ShowPage TopStories ->
            ( model
                |> resetStories
                |> setLoading TopStories
            , Http.send StoryIdsLoaded Request.Story.fetchTopIds
            )

        StoriesLoaded (Err _) ->
            ( model
                |> resetStories
                |> setLoaded
            , Cmd.none
            )

        StoriesLoaded (Ok stories) ->
            ( model
                |> setStories (List.filterMap identity stories)
                |> setLoaded
            , Cmd.none
            )

        StoryIdsLoaded (Err _) ->
            ( model
                |> setStoryIds []
                |> resetStories
                |> setLoaded
            , Cmd.none
            )

        StoryIdsLoaded (Ok ids) ->
            ( model
                |> setStoryIds ids
                |> resetStories
                |> setLoading (getPage model)
            , Request.Story.fetchStories StoriesLoaded (List.take 5 ids)
            )


getPage : { a | pageState : PageState } -> Page
getPage ({ pageState } as model) =
    case pageState of
        Loaded page ->
            page

        Loading page ->
            page


resetStories : { a | stories : List Story } -> { a | stories : List Story }
resetStories model =
    { model | stories = [] }


setLoaded : { a | pageState : PageState } -> { a | pageState : PageState }
setLoaded ({ pageState } as model) =
    { model | pageState = Loaded (getPage model) }


setLoading : Page -> { a | pageState : PageState } -> { a | pageState : PageState }
setLoading page ({ pageState } as model) =
    { model | pageState = Loading page }


setStories : List Story -> { a | stories : List Story } -> { a | stories : List Story }
setStories stories model =
    { model | stories = stories }


setStoryIds : List StoryId -> { a | storyIds : List StoryId } -> { a | storyIds : List StoryId }
setStoryIds storyIds model =
    { model | storyIds = storyIds }



-- Displaying the current model


view : Model -> Html Msg
view ({ pageState, stories } as model) =
    let
        message =
            case pageState of
                Loading page ->
                    "Loading page " ++ toString page ++ " ..."

                Loaded page ->
                    "No stories around for page " ++ toString page

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


navButton : String -> Page -> PageState -> Html Msg
navButton label reference pageState =
    case pageState of
        Loaded page ->
            Html.button
                [ Attr.disabled (reference == page), onClick (ShowPage reference) ]
                [ Html.text label ]

        Loading _ ->
            Html.button
                [ Attr.disabled True, onClick (ShowPage reference) ]
                [ Html.text label ]


headerItems : { a | pageState : PageState } -> List (Html Msg)
headerItems { pageState } =
    [ Html.span [] [ Html.text "[Y]" ]
    , navButton "new" NewStories pageState
    , navButton "top" TopStories pageState
    , navButton "best" BestStories pageState
    ]
