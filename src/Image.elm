module Image exposing (..)

type alias Image =
    { uri : String
    , width : Int
    , height : Int
    , alt : String
    , title : String
    , derivatives : List Derivative
    }

type alias Derivative =
    { uri : String
    , size : String
    }