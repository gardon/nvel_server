module Msgs exposing (..)

import Http exposing (Error)
import Models exposing (..)
import Navigation exposing (Location)

type Msg
  = ChaptersLoad (Result Error (List Chapter))
  | ChapterContentLoad (Result Error (Chapter))
  | UpdateSiteInfo (Result Error SiteInformation)
  | OnLocationChange Location
  | ChangeLocation String
  | UpdatePageData PageData