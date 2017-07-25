module Skeleton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

skeletonRow : List (Html msg) -> Html msg
skeletonRow content =
  div [ class "row" ] content

skeletonColumn : List (Attribute msg) -> List (Html msg) -> Html msg
skeletonColumn attributes content =
  div ([ classList [ ("column", True) ] ] ++ attributes) content