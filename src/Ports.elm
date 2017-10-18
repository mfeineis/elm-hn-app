port module Ports exposing (Msg(..), decoder, encoder, fromElm, toElm)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Msg
    = Invalid String
    | Ping
    | Pong
    | Unknown String


type alias Envelope =
    { msg : String
    }


decoder : Decode.Value -> Msg
decoder json =
    let
        result : Result String Envelope
        result =
            Decode.decodeValue
                (Decode.map Envelope
                    (Decode.field "msg" Decode.string)
                )
                json
    in
    case result of
        Err reason ->
            Invalid reason

        Ok { msg } ->
            case msg of
                "Ping" ->
                    Ping

                _ ->
                    Unknown msg


encoder : Msg -> Value
encoder msg =
    Encode.object
        [ ( "msg", Encode.string (toString msg) )
        ]


port fromElm : Value -> Cmd msg


port toElm : (Value -> msg) -> Sub msg
