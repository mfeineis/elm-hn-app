module Request.Story exposing (fetchNewIds, fetchStory)

import Data.Story as Story
import Http
import Json.Decode as Decode


apiRoot : String
apiRoot =
    "https://hacker-news.firebaseio.com/v0"


fetchIds : String -> Http.Request (List Story.StoryId)
fetchIds endpoint =
    Http.get
        (apiRoot ++ endpoint ++ ".json")
        (Decode.list Story.storyIdDecoder)


fetchNewIds : Http.Request (List Story.StoryId)
fetchNewIds =
    fetchIds "/newstories"


fetchStory : Story.StoryId -> Http.Request Story.Story
fetchStory id =
    Http.get
        (apiRoot ++ "/item/" ++ Story.storyIdToString id ++ ".json")
        Story.decoder
