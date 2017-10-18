module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test
    exposing
        ( Test
        , describe
        , fuzz2
        , fuzz3
        )
import Util as Sut


suite : Test
suite =
    describe "my utilities"
        [ describe "the `testMe` function"
            [ fuzzArithmetic2 "it is commutative" <|
                \left right ->
                    Sut.testMe left right
                        |> Expect.equal (Sut.testMe right left)
            , fuzzArithmetic3 "it is associative" <|
                \first second third ->
                    Sut.testMe (Sut.testMe first second) third
                        |> Expect.equal (Sut.testMe first (Sut.testMe second third))
            ]

        -- , todo
        --     "Implement your next tests. See http://package.elm-lang.org/packages/elm-community/elm-test/latest for how to do this!"
        ]



{- Shamelessly plugged from https://github.com/rtfeldman/elm-css/blob/master/tests/Arithmetic.elm -}


fuzzArithmetic2 : String -> (Float -> Float -> Expectation) -> Test
fuzzArithmetic2 =
    fuzz2 (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int)


fuzzArithmetic3 : String -> (Float -> Float -> Float -> Expectation) -> Test
fuzzArithmetic3 =
    fuzz3 (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int)
