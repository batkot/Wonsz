{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}

module Wonsz.Storage.InMemory.KeyValueStorage
    ( runInMemoryKvsT
    ) where

import qualified Data.HashMap.Strict as HM
import Data.IORef

import Control.Monad.IO.Class (MonadIO(..))
import Control.Monad.Trans.Class (MonadTrans)
import Control.Monad.Error.Class (MonadError)
import Control.Monad.Reader (ReaderT, runReaderT, ask)

import Wonsz.Storage (KeyValueStorage(..))

type InMemKvs a = IORef (HM.HashMap String a)

runInMemoryKvsT
    :: MonadIO m
    => HM.HashMap String v
    -> InMemoryKvsT v m a
    -> m a
runInMemoryKvsT map kvsT = do
    ioRef <- liftIO $ newIORef map
    flip runReaderT ioRef $ unInMemoryKvsT kvsT

newtype InMemoryKvsT v m a = InMemoryKvsT { unInMemoryKvsT :: ReaderT (InMemKvs v) m a }
    deriving newtype (Functor, Applicative, Monad, MonadTrans, MonadIO)

deriving newtype instance MonadError err m => MonadError err (InMemoryKvsT v m)

instance (MonadIO m, Show k) => KeyValueStorage (InMemoryKvsT v m) k v where
    get key = InMemoryKvsT $ do
        ioRef <- ask
        map <- liftIO (readIORef ioRef)
        return $ HM.lookup (show key) map

    set key value = InMemoryKvsT $ do
        ioRef <- ask
        liftIO $ modifyIORef ioRef $ HM.insert (show key) value
