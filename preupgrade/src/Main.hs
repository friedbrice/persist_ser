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

seedDatabase = do
  rawExecute "DROP TABLE IF EXISTS persist_ser;" []
  runMigration fooMigrate
  insert_ PersistSer
    {
      persistSerXlj = [X "persistSerXlj"]
    }

-- before running: `createdb persist_ser`
-- run: `stack build && (stack run | friendly) && psql -d persist_ser -c 'select * from persist_ser;' -x`
main = do
  conn <- connectPostgreSQL "host=localhost port=5432 dbname=persist_ser"
  backend <- openSimpleConn mempty conn
  runSqlConn seedDatabase backend
  [x@(Entity _ PersistSer{})] <- runSqlConn (selectList [] []) backend
  print x
