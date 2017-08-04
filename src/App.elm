-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html
port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Header, Request)
import Json.Decode as Decode
import BasicAuth  

import Config exposing (..)
import Skeleton exposing (..)
import Chapter exposing (..)
import Menu exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { chapters : Maybe (List Chapter)
  , siteInformation : SiteInformation
  , backendConfig : BackendConfig
  , menu : List MenuItem
  }


init : (Model, Cmd Msg)
init =
  let
    model = Model Nothing Config.siteInformation (switchBackend Local) Menu.menu
  in 
    ( model
    , Cmd.batch [ getSiteInformation model, getChapters model ]
    )



-- UPDATE


type Msg
  = ChaptersLoad (Result Http.Error (List Chapter))
  | UpdateSiteInfo (Result Http.Error SiteInformation)


port updateSiteInfo : SiteInformation -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChaptersLoad (Ok chapters) ->
      ({ model | chapters = Just chapters } , Cmd.none)

    ChaptersLoad (Err _) ->
      (model, Cmd.none)

    UpdateSiteInfo (Ok siteInformation) ->
      ({ model | siteInformation = siteInformation } , (updateSiteInfo siteInformation))

    UpdateSiteInfo (Err _) ->
      (model, Cmd.none)



-- VIEW


view : Model -> Html msg
view model =
  div [] [
    skeletonRow [ style [ ("margin-top", "15%") ] ] [
      skeletonColumn TwelveColumns []
        [ text "Here goes the menu" ]
      ]

    ,skeletonRow [] [
      skeletonColumn TwelveColumns []
        (viewChapterList model.chapters)
      ]
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
      model.backendConfig.backendURL ++ chapterListEndpoint
  in
    Http.send ChaptersLoad (Http.get url decodeChapters)

chapterDecoder = 
  Decode.field "field_description" Decode.string
    |> Decode.map2 Chapter (Decode.field "title" Decode.string)

decodeChapters : Decode.Decoder (List Chapter)
decodeChapters =
  Decode.list chapterDecoder

getAuth : String -> Decode.Decoder a -> Request a
getAuth url decoder =
  let 
    authHeader = BasicAuth.buildAuthorizationHeader "admin" "admin"
  in 
    Http.request 
      { method = "GET"
      , headers = [ authHeader ]
      , url = url
      , body = Http.emptyBody
      , expect = Http.expectJson decoder
      , timeout = Nothing
      , withCredentials = False
      }

getSiteInformation : Model -> Cmd Msg
getSiteInformation model = 
  let 
    url = 
      model.backendConfig.backendURL ++ siteInformationEndpoint

  in 
    Http.send UpdateSiteInfo (getAuth url decodeSiteInformation)

decodeSiteInformation : Decode.Decoder SiteInformation
decodeSiteInformation = 
  Decode.field "description" Decode.string
    |> Decode.map2 SiteInformation (Decode.field "title" Decode.string)