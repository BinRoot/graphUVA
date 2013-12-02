{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, NoMonomorphismRestriction #-}

import Network.HTTP
import Network.URI
import Data.Char
import Data.List (elemIndex)
import Data.Maybe
import Text.XML.HXT.Core
import Data.Tree.NTree.TypeDefs
import System.Environment 
import Text.JSON
import Database.MongoDB
import Control.Concurrent (threadDelay)
import Control.Monad.Trans (liftIO)
import qualified Data.Map as M
import qualified Data.Text as T

data Person = Person 
              { firstName :: String
              , lastName :: String
              , email :: String
              , other :: [(String, String)]
              } deriving (Show, Eq)

instance JSON Person where 
  showJSON p = jobj [ ("firstName", jstr $ firstName p)
                    , ("lastName", jstr $ lastName p)
                    , ("email", jstr $ email p)
                    , ("other", jobj $ map toJSValTuple (other p)) ]

data SearchResultErr = NoResultsErr | TooManyResultsErr deriving (Show, Eq)
instance JSON SearchResultErr where 
  showJSON NoResultsErr = jobj [("err", jstr "No Results")]
  showJSON TooManyResultsErr = jobj [("err", jstr "Too Many Results")]

type SearchResult = Either SearchResultErr [Person]

-- ./main "abba"   # searches only "abba"
-- ./main "b" "c"  # searches between "b" and "c"
-- ./main          # searches everything
main = do
  args <- getArgs
  pipe <- runIOE $ connect (readHostPort mongoURL)
  doWork args pipe
  Database.MongoDB.close pipe

doWork args pipe
  | null args = main' "a" "{" pipe
  | length args == 1 = do
    let query = head args
    doc <- getDoc query
    searchResult <- scanDoc query doc
    print $ encode $ showJSON searchResult
  | otherwise        = main' (head args) (args !! 1) pipe

main' query stop pipe = do
  print query
  doc <- getDoc query
  searchResult <- scanDoc query doc
  print searchResult
  case searchResult of
    Right plist -> access pipe (ConfirmWrites ["w" =: 2]) "graphuva" (runInsert plist)
    _ -> access pipe master "graphuva" (runInsert [])
  threadDelay 5000000
  if searchResult == Left TooManyResultsErr
    then main' (nextDeepQuery query) stop pipe
    else if next >= stop then print "done!" else main' next stop pipe where next = nextQuery query
  
getDoc query = do  
  rsp <- simpleHTTP $ uvaRequest query
  html <- fmap (takeWhile isAscii) (getResponseBody rsp)
  return $ readString [withParseHTML yes, withWarnings no] html

scanDoc :: String -> IOStateArrow () XmlTree XmlTree -> IO SearchResult
scanDoc query doc = do
  h3s <- runX $ doc //> hasName "h3"
  if length h3s == 2 
    then do
      let errMsg = (getText'.getTreeVal.head.getTreeChildren.head) h3s
      return $ Left $ if errMsg == "No matching entries were found" 
                      then NoResultsErr
                      else TooManyResultsErr
    else do
      centers <- runX $ doc //> hasName "center"
      if length centers == 2 
        then do
          texts <- runX $ doc //> hasName "td" //> getText
          let textList = (tail.tail.tail) texts
          let fullName = (unwords.init.words) (texts !! 1)
          let computingId = (tail.init.last.words) (texts !! 1)
          let person = Person {
                firstName = clean $ (head.words) fullName,
                lastName = clean $ (last.words) fullName,
                email = clean $ map toLower $
                        findKeyInList textList "Primary E-Mail Address",
                other = [ ("status", clean $ trim $ 
                                     findKeyInList textList "Classification")
                        , ("department", clean $ trim $
                                         findKeyInList textList "Department")
                        , ("computingId", computingId) ]
                }
          return $ Right [person]
        else do
          rows <- runX $ doc //> hasName "tr"
          return $ Right (readTableRows rows)
  
findKeyInList list key = case elemIndex key list of
  Just i -> list !! (i+1)
  Nothing -> ""
  
safeMap f ls n = if length ls >= n then map f $ ls !! n else ""

nextDeepQuery query = query ++ "a"

nextQuery "z" = "{"
nextQuery query = if last query == 'z'
                  then nextQuery $ init query
                  else init query ++ [succ $ last query]

readTableRows :: [NTree XNode] -> [Person]
readTableRows (a:b:rows) = fmap parseRow rows
readTableRows rows = []

parseRow row = Person { 
  firstName = clean $ (head.tail.words) fullName,
  lastName = clean $ (init.head.words) fullName,
  email = clean $ map toLower $ getEmailFromTr row,
  other = [ ("phoneNumber", clean pNum)
          , ("status", clean $ getTypeFromTr row)
          , ("department", clean $ getDepartmentFromTr row)
          , ("computingId", computingId)]
  }
  where fullName = (unwords.init.words) $ getNameFromTr row
        computingId = (tail.init.last.words) $ getNameFromTr row
        pNum = getPhoneNumberFromTr row
        

getNameFromTr row = getLinkTextFromTd $ getTreeChildren row !! 3
getEmailFromTr row = getLinkTextFromTd $ getTreeChildren row !! 5
getPhoneNumberFromTr row = getTextFromTd $ getTreeChildren row !! 7
getTypeFromTr row = getTextFromTd $ getTreeChildren row !! 9
getDepartmentFromTr row = getTextFromTd $ getTreeChildren row !! 11

getTextFromTd tree = getText' $ getTreeVal $ head $ getTreeChildren tree
getLinkTextFromTd tree = 
  if null val then "" else (getText'.getTreeVal.head) val
  where val = (getTreeChildren.head.getTreeChildren) tree


getTreeVal (NTree a b) = a
getTreeChildren (NTree a b) = b
getText' (XText a) = a

uvaRequest :: String -> Request_String
uvaRequest query = Request { 
    rqURI = case parseURI "http://www.virginia.edu/cgi-local/ldapweb" of Just u -> u
  , rqMethod = POST
  , rqHeaders = [ mkHeader HdrContentType "text/html"
                , mkHeader HdrContentLength $ show $ length body
                ]
  , rqBody = body
  }
  where body = "whitepages=" ++ query

toJSValTuple (a, b) = (a, jstr b)

jstr :: String -> JSValue
jstr = JSString . toJSString

jobj :: [(String,JSValue)] -> JSValue
jobj = JSObject . toJSObject

trim :: String -> String
trim = f . f
   where f = reverse . dropWhile isSpace
         
clean :: String -> String
clean str = if str == "\160" then "" else str

mongoURL = "ds053788.mongolab.com:53788"

runInsert plist = do
  auth "hermes" "hermes"
  insertPeople' plist

{-
insertPeople plist = do
  case null plist of       
    True -> find (select [] "people2") {sort = ["home.city" =: 1]}
    False -> do
      insertPerson' (head plist)
      runInsert (tail plist)
-}
insertPeople' plist = insertMany "people" (bsonList plist)

insertPerson p = repsert (select ["_id" =: computingId p] "people") (bsonStruct p)
insertPerson' p = save "people" (bsonStruct p)

bsonTuple [] = []
bsonTuple ((a,b):xs) = ((T.pack a) =: b) : (bsonTuple xs)

bsonStruct p = [ "_id" =: computingId p
               , "firstName" =: firstName p
               , "lastName" =: lastName p
               , "email" =: email p
               , "other" =: (bsonTuple.other) p ]

computingId p = getValFromMap (other p) "computingId"
getValFromMap m key = (fromMaybe "" $ M.lookup key (M.fromList m))

bsonList [] = []
bsonList (p:ps) = bsonStruct p : bsonList ps