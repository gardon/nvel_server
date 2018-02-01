module Menu exposing (..)

import Language exposing (..)
import Models exposing (MenuItem,Phrase)

menu : List MenuItem
menu = 
    [ 
      { title = Models.MenuHome
      , path = "/"
      }
      ,{ title = Models.MenuArchive
      , path = "/chapters"
      }
      ,{ title = Models.MenuAbout
      , path = "/about"
      }
    ]
