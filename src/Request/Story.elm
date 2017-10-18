module Request.Story
    exposing
        ( fetchBestIds
        , fetchNewIds
        , fetchStories
        , fetchTopIds
        )

import Data.Story as Story exposing (Story, StoryId)
import Http
import Json.Decode as Decode
import Task


apiRoot : String
apiRoot =
    "https://hacker-news.firebaseio.com/v0"


fetchIds : String -> Http.Request (List StoryId)
fetchIds endpoint =
    Http.get
        (apiRoot ++ endpoint ++ ".json")
        (Decode.list Story.storyIdDecoder)


fetchBestIds : Http.Request (List StoryId)
fetchBestIds =
    fetchIds "/beststories"


fetchNewIds : Http.Request (List StoryId)
fetchNewIds =
    fetchIds "/newstories"


fetchTopIds : Http.Request (List StoryId)
fetchTopIds =
    fetchIds "/topstories"


fetchStories : (Result Http.Error (List (Maybe Story)) -> msg) -> List StoryId -> Cmd msg
fetchStories msg ids =
    Task.attempt msg <|
        Task.sequence
            (List.map (fetchStory >> Http.toTask) ids)


fetchStory : StoryId -> Http.Request (Maybe Story)
fetchStory id =
    Http.get
        (apiRoot ++ "/item/" ++ Story.storyIdToString id ++ ".json")
        (Decode.maybe Story.decoder)
