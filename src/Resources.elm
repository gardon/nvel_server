module Resources exposing (..)

import Http exposing (Header, Request)
import Models exposing (..)
import BasicAuth
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Image exposing (Image)
import Date

getAuth : String -> Decode.Decoder a -> Request a
getAuth url decoder =
  let 
    authHeader = BasicAuth.buildAuthorizationHeader "" ""
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

dateDecoder : Decode.Decoder Date.Date
dateDecoder =
  Decode.string
    |> Decode.andThen (\val ->
        case Date.fromString val of
          Err err -> Decode.fail err
          Ok date -> Decode.succeed <| date)


imageDecoder : Decode.Decoder Image
imageDecoder =
  decode Image
      |> required "uri" Decode.string
      |> required "width" Decode.int
      |> required "height" Decode.int
      |> optional "alt" Decode.string ""
      |> optional "title" Decode.string ""
      |> optional "derivatives" (Decode.list decodeDerivative) []

decodeDerivative : Decode.Decoder Image.Derivative
decodeDerivative =
  decode Image.Derivative
      |> required "uri" Decode.string
      |> required "size" Decode.string

sectionDecoder : Decode.Decoder Section
sectionDecoder =
  Decode.field "type" Decode.string
      |> Decode.andThen decodeSection

decodeSection : String -> Decode.Decoder Section
decodeSection sectionType =
  case sectionType of 
      "full_width_single_panel" ->
          decodeFullWidthSingleImageSection
      _ ->
          Decode.fail <| "Unknown section type: " ++ sectionType

decodeFullWidthSingleImageSection : Decode.Decoder Section
decodeFullWidthSingleImageSection =
  decode Section
      |> hardcoded FullWidthSingleImage
      |> required "image" imageDecoder
