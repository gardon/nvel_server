module Skeleton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msgs exposing (Msg)

type GridSize 
    = OneColumn
    | TwoColumns
    | ThreeColumns
    | FourColumns
    | FiveColumns
    | SixColumns
    | SevenColumns
    | EightColumns
    | NineColumns
    | TenColumns
    | ElevenColumns
    | TwelveColumns
    | OneThird
    | TwoThirds
    | OneHalf

skeletonGridSize : GridSize -> List (Attribute msg)
skeletonGridSize size =
    let class = 
        (case size of 
            OneColumn -> ["one", "column"]
            TwoColumns -> ["two", "columns"]
            ThreeColumns -> ["three", "columns"]
            FourColumns -> ["four", "columns"]
            FiveColumns -> ["five", "columns"]
            SixColumns -> ["six", "columns"]
            SevenColumns -> ["seven", "columns"]
            EightColumns -> ["eight", "columns"]
            NineColumns -> ["nine", "columns"]
            TenColumns -> ["ten", "columns"]
            ElevenColumns -> ["eleven", "columns"]
            TwelveColumns -> ["twelve", "columns"]
            OneThird -> ["one-third", "column"]
            TwoThirds -> ["two-thirds", "column"]
            OneHalf -> ["one-half", "column"])

            |> List.map (\a -> (a, True))
    in
        [ classList class ]

skeletonRow :  List (Attribute msg) -> List (Html msg) -> Html msg
skeletonRow attributes content =
    div ([ class "row container" ] ++ attributes) content

skeletonRowFullWidth :  List (Attribute msg) -> List (Html msg) -> Html msg
skeletonRowFullWidth attributes content =
    skeletonRow ( [ class "u-full-width u-max-full-width" ] ++ attributes ) content

skeletonColumn : GridSize ->  List (Attribute msg) -> List (Html msg) -> Html msg
skeletonColumn size attributes content =
    div (skeletonGridSize size ++ attributes) content

skeletonRowOneCol : List (Attribute Msg) -> List (Html Msg) -> Html Msg
skeletonRowOneCol attributes content = 
  skeletonRow attributes
    [ skeletonColumn TwelveColumns []
        content
    ]
