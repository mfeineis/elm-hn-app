module Main exposing (main)

import Data.Story exposing (Story, StoryId)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Ports exposing (Msg(..))
import Request.Story
import Styled


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
    = Interop Ports.Msg
    | ShowPage Page
    | StoryIdsLoaded (Result Http.Error (List StoryId))
    | StoriesLoaded (Result Http.Error (List (Maybe Story)))



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
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Interop
            (Ports.toElm Ports.decoder)
        ]



-- Model updates


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Interop msg ->
            let
                msg2 =
                    Debug.log "Interop.msg" msg
            in
            Debug.log "Interop.result"
                ( model, Ports.fromElm (Ports.encoder Pong) )

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
    Styled.pageFrame []
        [ Styled.pageHeader [] (headerItems model)
        , Styled.pageMain [] storyList
        ]


renderStory : Story -> Html msg
renderStory { descendants, id, title, url } =
    let
        descendantInfo =
            case descendants of
                Nothing ->
                    ""

                Just 0 ->
                    ""

                Just amount ->
                    " (" ++ toString amount ++ ")"
    in
    case url of
        Nothing ->
            Styled.storyItem []
                [ Html.text title
                , Html.text descendantInfo
                ]

        Just url ->
            Styled.storyItem []
                [ Html.a [ Attr.href url ]
                    [ Html.text title
                    ]
                , Html.text descendantInfo
                ]


navButton : String -> Page -> PageState -> Html Msg
navButton label reference pageState =
    case pageState of
        Loaded page ->
            if reference == page then
                Styled.navButtonSelected
                    [ onClick (ShowPage reference) ]
                    [ Html.text label ]
            else
                Styled.navButton
                    [ onClick (ShowPage reference) ]
                    [ Html.text label ]

        Loading _ ->
            Styled.navButtonDisabled
                [ onClick (ShowPage reference) ]
                [ Html.text label ]


headerItems : { a | pageState : PageState } -> List (Html Msg)
headerItems { pageState } =
    [ Styled.navLogo [ onClick (ShowPage NewStories) ]
    , Styled.navTitle
        [ onClick (ShowPage NewStories) ]
        [ Html.text "Hacker News" ]
    , navButton "new" NewStories pageState
    , navButton "top" TopStories pageState
    , navButton "best" BestStories pageState
    ]
