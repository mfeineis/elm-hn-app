module Data.Story
    exposing
        ( Story
        , StoryId
        , decoder
        , storyIdDecoder
        , storyIdToString
        )

import Json.Decode as Decode exposing (Decoder)


{- https://github.com/HackerNews/API -}


type alias StoryId =
    Int


storyIdToString : StoryId -> String
storyIdToString id =
    toString id


storyIdDecoder : Decoder StoryId
storyIdDecoder =
    Decode.int


decoder : Decoder Story
decoder =
    Decode.map5 Story
        (Decode.field "id" storyIdDecoder)
        (Decode.field "by" Decode.string)
        (Decode.maybe (Decode.field "url" Decode.string))
        (Decode.field "title" Decode.string)
        (Decode.maybe (Decode.field "descendants" Decode.int))


type alias Story =
    { id : StoryId

    --, deleted : Bool
    --, type_ : String
    , by : String

    --, time : Int
    --, text : String
    --, dead : Bool
    --, parent : Int
    --, poll : Int
    --, kids : List Int
    , url : Maybe String

    --, score : Int
    , title : String

    --, parts : List Int
    , descendants : Maybe Int
    }



-- Initial model, is this safe?


type alias Item =
    { id : Int
    , deleted : Bool
    , type_ : String
    , by : String
    , time : Int
    , text : String
    , dead : Bool
    , parent : Int
    , poll : Int
    , kids : List Int
    , url : String
    , score : Int
    , title : String
    , parts : List Int
    , descendants : Int
    }
