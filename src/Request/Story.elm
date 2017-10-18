module Request.Story exposing (fetchNewIds, fetchStories)

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


fetchNewIds : Http.Request (List StoryId)
fetchNewIds =
    fetchIds "/newstories"


fetchStories : (Result Http.Error (List Story) -> msg) -> List StoryId -> Cmd msg
fetchStories msg ids =
    Task.attempt msg <|
        Task.sequence
            (List.map (fetchStory >> Http.toTask) ids)


fetchStory : StoryId -> Http.Request Story
fetchStory id =
    Http.get
        (apiRoot ++ "/item/" ++ Story.storyIdToString id ++ ".json")
        Story.decoder
