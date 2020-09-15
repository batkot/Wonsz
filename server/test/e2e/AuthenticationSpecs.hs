{-# LANGUAGE DataKinds #-}

module AuthenticationSpecs
    ( test_tests
    ) where

import Data.Either

import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString.Lazy.Char8 as BSLC

import Test.Tasty (TestTree, testGroup, withResource)
import Test.Tasty.HUnit (testCase, (@?=), (@?))
import Test.Tasty.QuickCheck (testProperty, ioProperty)
import Test.QuickCheck (Arbitrary(..), getPrintableString)

import Network.HTTP.Types.Status (status401)

import Servant.Client 
import Servant.Auth.Client
import Resources.WonszApp 

import Wonsz.Server.Authentication (rawToken)

test_tests :: TestTree
test_tests = withWonszApp $ \client -> 
            testGroup "Login workflow tests" 
                [ testCase "Given wrong credentails should raise 401" $ do
                    c <- client
                    Left (FailureResponse _ (Response responseStatus _ _ _)) <- runClientM ((login c) invalidLoginRequest) (env c)
                    responseStatus @?= status401

                , testCase "Given good credentials should return working token" $ do
                    c <- client
                    Right authToken <- runClientM ((login c) validLoginRequest) (env c)
                    let token = Token . BSL.toStrict . rawToken $ authToken
                    result <- runClientM (getOverview c token) (env c)
                    isRight result @? "Should get result"

                , testCase "Token renewal return new working token" $ do 
                    c <- client
                    Right authToken <- runClientM ((login c) validLoginRequest) (env c)
                    let token = Token . BSL.toStrict . rawToken $ authToken
                    Right renewedToken <- runClientM (renewToken c token) (env c)
                    let newToken = Token . BSL.toStrict . rawToken $ renewedToken
                    result <- runClientM (getOverview c newToken) (env c)
                    isRight result @? "Should get result"

                , testProperty "Given fake token should return 401" $ \(BadAuthToken badTokenString) -> ioProperty $ do 
                    c <- client
                    let badToken = Token . BSL.toStrict . BSLC.pack $ badTokenString
                    Left (FailureResponse _ (Response responseStatus _ _ _)) <- runClientM (getOverview c badToken) (env c)
                    return $ responseStatus == status401
                ]

newtype BadAuthToken = BadAuthToken { getToken :: String } deriving (Show)

instance Arbitrary BadAuthToken where
  arbitrary = BadAuthToken . mconcat . lines . getPrintableString <$> arbitrary
