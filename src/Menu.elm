module Menu exposing (..)

type alias MenuItem = 
  { title : String
  , path : String
}

menu : List MenuItem
menu = 
    [ 
      { title = "Home"
      , path = "/"
      }
      ,{ title = "Archive"
      , path = "/chapters"
      }
      ,{ title = "About"
      , path = "/about"
      }
    ]
