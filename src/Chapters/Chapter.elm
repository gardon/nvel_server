module Chapters.Chapter exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, href)
import Models exposing (Chapter)


view :  Maybe Chapter -> Html msg
view model =
    case model of
        Nothing ->
            div []
                [ h1 [] [ text "Loading" ]    
            ]

        Just model ->
            div []
                [ h1 [] [ text model.title ]    
            ]

