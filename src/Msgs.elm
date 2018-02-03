module Msgs exposing (..)

import Http exposing (Error)
import Models exposing (..)
import Navigation exposing (Location)
import Dict exposing (Dict)


type Msg
  = ChaptersLoad (Result Error (Dict String Chapter))
  | ChapterContentLoad (Result Error (Chapter))
  | UpdateSiteInfo (Result Error SiteInformation)
  | OnLocationChange Location
  | ChangeLocation String
  | UpdatePageData PageData
  | Navbar NavbarAction