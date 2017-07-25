-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html
port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Config exposing (..)
import Skeleton exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Chapter =
  { title : String
  , field_description: String
  }

type alias Model =
  { chapters : List Chapter
  , siteInformation : SiteInformation
  , backendConfig : BackendConfig
  }


init : (Model, Cmd Msg)
init =
  let
    model = Model [] Config.siteInformation (switchBackend Local)
  in 
    ( model
    , Cmd.batch [ updateSiteInfo model.siteInformation, getChapters model ]
    )



-- UPDATE


type Msg
  = ChaptersLoad (Result Http.Error (List Chapter))
  | UpdateSiteInfo


port updateSiteInfo : SiteInformation -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChaptersLoad (Ok chapters) ->
      ({ model | chapters = chapters } , Cmd.none)

    ChaptersLoad (Err _) ->
      (model, Cmd.none)

    UpdateSiteInfo ->
      (model, (updateSiteInfo model.siteInformation))



-- VIEW


view : Model -> Html Msg
view model =
  skeletonRow [
    skeletonColumn [ classList [ ("one-half", True) ] ]
      (List.map viewChapter model.chapters)  
    ]

viewChapter : Chapter -> Html Msg
viewChapter chapter =
  div []
    [
      h2 [] [ text chapter.title ]
    , div [] [ text chapter.field_description ]
    ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP


getChapters : Model -> Cmd Msg
getChapters model =
  let
    url =
      model.backendConfig.backendURL ++ "/chapters"
  in
    Http.send ChaptersLoad (Http.get url decodeChapters)

chapterDecoder = Decode.map2 Chapter (Decode.field "title" Decode.string) (Decode.field "field_description" Decode.string)

decodeChapters : Decode.Decoder (List Chapter)
decodeChapters =
  Decode.list chapterDecoder
