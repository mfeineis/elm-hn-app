module Data.Story exposing (Story, StoryId, storyIdDecoder)

import Json.Decode as Decode exposing (Decoder)


{- https://github.com/HackerNews/API -}


type alias StoryId =
    Int


storyIdDecoder : Decoder StoryId
storyIdDecoder =
    Decode.int


type alias Story =
    { id : StoryId
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
