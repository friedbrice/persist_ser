{-# OPTIONS_GHC -Wall -Wno-missing-signatures -Wno-unused-top-binds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}

import Data.ByteString
import Data.Text
import Database.Persist.Postgresql
import Database.Persist.TH
import Database.PostgreSQL.Simple

import Lib

share [mkPersist sqlSettings, mkMigrate "fooMigrate"] [persistLowerCase|
PersistSer sql=persist_ser
  xlj [X] sqltype=jsonb
  deriving Show
|]

-- run: `stack build && (stack run | friendly) && psql -d persist_ser -c 'select * from persist_ser;' -x`
main = do
  conn <- connectPostgreSQL "host=localhost port=5432 dbname=persist_ser"
  backend <- openSimpleConn mempty conn
  [r@(Entity _ PersistSer{})] <- runSqlConn (selectList [] []) backend
  print r
