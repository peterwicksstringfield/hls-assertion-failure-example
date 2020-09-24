module SomePlugin (plugin) where

import Plugins
  ( Plugin (..),
    defaultPlugin,
  )
import TcRnTypes
  ( TcPlugin (..),
    TcPluginResult (..),
  )

plugin :: Plugin
plugin =
  defaultPlugin
    { tcPlugin =
        const $
          Just $
            TcPlugin
              { tcPluginInit = return (),
                tcPluginSolve = \_ _ _ _ -> return $ TcPluginOk [] [],
                tcPluginStop = \_ -> return ()
              }
    }
