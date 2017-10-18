module Request.Story exposing (fetchNew)

import Data.Story as Story
import Http
import Json.Decode as Decode


apiRoot : String
apiRoot =
    "https://hacker-news.firebaseio.com/v0/"


fetch : String -> Http.Request (List Story.StoryId)
fetch kind =
    Http.get
        (apiRoot ++ kind ++ ".json")
        (Decode.list Story.storyIdDecoder)


fetchNew : Http.Request (List Story.StoryId)
fetchNew =
    fetch "newstories"
