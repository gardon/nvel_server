module Menu exposing (..)

import Language exposing (..)
import Models exposing (MenuItem,Phrase)

menu : List MenuItem
menu = 
    [ 
      { title = Models.MenuHome
      , path = "/"
      , route = Models.HomeRoute
      }
      ,{ title = Models.MenuArchive
      , path = "/chapters"
      , route = Models.ChaptersRoute
      }
      ,{ title = Models.MenuAbout
      , path = "/about"
      , route = Models.AboutRoute
      }
    ]
