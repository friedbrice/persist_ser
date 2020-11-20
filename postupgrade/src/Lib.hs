{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib where

import Data.ByteString
import Data.Text as T
import Data.Text.Encoding as TE
import Database.Persist.Postgresql
import Database.Persist.TH
import Database.PostgreSQL.Simple

tshow :: Show a => a -> Text
tshow = T.pack . show

newtype X = X Text
  deriving Show via Text

instance PersistField X where
  toPersistValue (X x) = PersistLiteralEscaped $ TE.encodeUtf8 x
  fromPersistValue (PersistLiteralEscaped bs) = Right . X $ TE.decodeUtf8 bs
  fromPersistValue x = Left $ "Failed to deserialize " <> tshow x

instance PersistFieldSql X where
  sqlType _ = SqlOther "text"
