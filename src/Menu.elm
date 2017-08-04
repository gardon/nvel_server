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
      ,{ title = "Start reading"
      , path = "/start"
      }
      ,{ title = "Index"
      , path = "/index"
      }
      ,{ title = "Latest chapter"
      , path = "/latest"
      }
    ]
