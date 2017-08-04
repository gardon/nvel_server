module Skeleton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

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
 div ([ class "row"] ++ attributes) content

skeletonColumn : GridSize ->  List (Attribute msg) -> List (Html msg) -> Html msg
skeletonColumn size attributes content =
  div (skeletonGridSize size ++ attributes) content