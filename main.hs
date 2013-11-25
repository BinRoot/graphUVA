import Network.HTTP
import Network.URI
import Data.Char
import Text.XML.HXT.Core
import Data.Tree.NTree.TypeDefs
import System.Environment 
import Text.JSON

-- search for "zacho" fails w/
-- main: Prelude.(!!): index too large

data Person = Person 
              { firstName :: String
              , lastName :: String
              , email :: String
              , other :: [(String, String)] -- grad status, department, phonenumber, etc
              } deriving (Show, Eq)

instance JSON Person where 
  showJSON p = jobj $ [ ("firstName", jstr $ firstName p)
                      , ("lastName", jstr $ lastName p)
                      , ("email", jstr $ email p)
                      , ("other", jobj $ map toJSValTuple (other p)) ]

toJSValTuple (a, b) = (a, jstr b)

jstr :: String -> JSValue
jstr = JSString . toJSString

jobj :: [(String,JSValue)] -> JSValue
jobj = JSObject . toJSObject

data SearchResultErr = NoResultsErr | TooManyResultsErr deriving (Show, Eq)
instance JSON SearchResultErr where 
  showJSON NoResultsErr = jobj $ [("err", jstr "No Results")]
  showJSON TooManyResultsErr = jobj $ [("err", jstr "Too Many Results")]


type SearchResult = Either SearchResultErr [Person]

-- ./main "abba" # searches only "abba"
-- ./main "b" "c" # searches between "b" and "c"
-- ./main # searches everything
main = do
  args <- getArgs
  doWork args
  
doWork args
  | length args == 0 = main' "a" "{"
  | length args == 1 = do
    let query = args !! 0
    doc <- getDoc query
    searchResult <- scanDoc query doc
    print $ encode $ showJSON searchResult
  | otherwise        = main' (args !! 0) (args !! 1)

main' query stop = do
  print query
  doc <- getDoc query
  searchResult <- scanDoc query doc
  print searchResult
  if searchResult == Left TooManyResultsErr
    then main' (nextDeepQuery query) stop
    else if (next >= stop) then print "done!" else main' next stop where next = nextQuery query
  
getDoc query = do  
  rsp <- simpleHTTP $ uvaRequest query
  html <- fmap (takeWhile isAscii) (getResponseBody rsp)
  return $ readString [withParseHTML yes, withWarnings no] html

scanDoc :: String -> IOStateArrow () XmlTree XmlTree -> IO (SearchResult)
scanDoc query doc = do
  h3s <- runX $ doc //> hasName "h3"
  if length h3s == 2 
    then do
      let errMsg = (getText'.getTreeVal.head.getTreeChildren.head) h3s
      if errMsg == "No matching entries were found" 
        then return $ Left NoResultsErr
        else return $ Left TooManyResultsErr
    else do
      centers <- runX $ doc //> hasName "center"
      if length centers == 2 
        then do
          texts <- runX $ doc //> hasName "td" //> getText
          let fullName = (unwords.init.words) (texts !! 1)
          let person = Person {
                firstName = (head.words) fullName,
                lastName = (last.words) fullName,
                email = safeMap toLower texts 12,
                other = [("status", trim $ texts !! 6)
                        ,("department", trim $ texts !! 8)]
                }
          return $ Right [person]
        else do
          rows <- runX $ doc //> hasName "tr"
          return $ Right (readTableRows rows)
  
nextDeepQuery query = query ++ "a"

safeMap f ls n = if (length ls) >= n then map f $ ls !! n else ""

nextQuery "z" = "{"
nextQuery query = if (last query) == 'z'
                    then ((init.init) query) ++ [succ $ last $ init query]
                    else (init query) ++ [succ $ last query]

readTableRows :: [NTree XNode] -> [Person]
readTableRows (a:b:rows) = fmap parseRow rows
readTableRows rows = []

parseRow row = Person { 
  firstName = (head.tail.words) fullName,
  lastName = (init.head.words) fullName,
  email = map toLower $ getEmailFromTr row,
  other = [("phoneNumber", getPhoneNumberFromTr row),
           ("status", getTypeFromTr row),
           ("department", getDepartmentFromTr row)]
  }
  where fullName = (unwords.init.words) $ getNameFromTr row
-- Abbate, Jessica Lee

getNameFromTr row = getLinkTextFromTd $ (getTreeChildren row) !! 3
getEmailFromTr row = getLinkTextFromTd $ (getTreeChildren row) !! 5
getPhoneNumberFromTr row = getTextFromTd $ (getTreeChildren row) !! 7
getTypeFromTr row = getTextFromTd $ (getTreeChildren row) !! 9
getDepartmentFromTr row = getTextFromTd $ (getTreeChildren row) !! 11

getTextFromTd tree = getText' $ getTreeVal $ head $ getTreeChildren tree
getLinkTextFromTd tree = if val==[] 
                         then "" 
                         else (getText'.getTreeVal.head) val
  where val = (getTreeChildren.head.getTreeChildren) tree


getTreeVal (NTree a b) = a
getTreeChildren (NTree a b) = b
getText' (XText a) = a

trim :: String -> String
trim = f . f
   where f = reverse . dropWhile isSpace

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
