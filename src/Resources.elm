module Resources exposing (..)

import Http exposing (Header, Request)
import Models exposing (..)
import BasicAuth
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Image exposing (Image)
import Date
--import Markdown

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
      "single_panel" ->
          decodeSingleImageSection
      "spacer" ->
          decodeSpacer
      "title_panel" ->
          decodeTitlePanel
      "text" ->
          decodeText
      _ ->
          Decode.fail <| "Unknown section type: " ++ sectionType

decodeFullWidthSingleImageSection : Decode.Decoder Section
decodeFullWidthSingleImageSection =
  decode Section
      |> hardcoded FullWidthSingleImage
      |> required "image" imageDecoder
      |> required "chapter" Decode.string
      |> required "id" Decode.int
      |> hardcoded False

decodeSingleImageSection : Decode.Decoder Section
decodeSingleImageSection =
  decode Section
      |> hardcoded SingleImage
      |> required "image" imageDecoder
      |> required "chapter" Decode.string
      |> required "id" Decode.int
      |> hardcoded False

decodeSpacer : Decode.Decoder Section
decodeSpacer =
  decode Section
      |> hardcoded Spacer
      |> hardcoded Image.emptyImage
      |> required "chapter" Decode.string
      |> required "id" Decode.int
      |> hardcoded False

decodeTitlePanel : Decode.Decoder Section
decodeTitlePanel =
  Decode.field "features" decodeTitlePanelFeatures
      |> Decode.andThen decodeTitlePanelSection

decodeTitlePanelSection : TitlePanelFeatures -> Decode.Decoder Section
decodeTitlePanelSection features =
  decode Section
      |> hardcoded (TitlePanel features)
      |> optional "image" imageDecoder Image.emptyImage
      |> required "chapter" Decode.string
      |> required "id" Decode.int
      |> hardcoded False

decodeTitlePanelFeatures : Decode.Decoder TitlePanelFeatures
decodeTitlePanelFeatures = 
  decode TitlePanelFeatures
      |> required "title" Decode.string
      |> required "author" Decode.string
      |> required "copyright" Decode.string
      |> required "extra" Decode.string

decodeText : Decode.Decoder Section
decodeText =
  Decode.field "text" Decode.string
      |> Decode.andThen decodeTextSection

decodeTextSection : String -> Decode.Decoder Section
decodeTextSection text =
  decode Section
      |> hardcoded (Text text)
      |> hardcoded Image.emptyImage
      |> required "chapter" Decode.string
      |> required "id" Decode.int
      |> hardcoded False

--markdownDecoder : Decode.Decoder (Html msg)
--markdownDecoder = 
--  Decode.string
--      |> Decode.andThen Markdown.toHtml []

decodeSiteInformation : Decode.Decoder SiteInformation
decodeSiteInformation = 
   decode SiteInformation
      |> required "title" Decode.string
      |> required "description" Decode.string
      |> optional "facebook_page" Decode.string ""
      |> optional "instagram_handle" Decode.string ""
      |> optional "deviantart_profile" Decode.string ""
      |> optional "about" Decode.string "# About"

