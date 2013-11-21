import Network.HTTP
import Network.URI
import Data.Char
-- import Text.XML.HXT.Parser.XmlParsec
import Text.XML.HXT.Core
import Data.Tree.NTree.TypeDefs
import System.Environment 

main = do
  args <- getArgs
  let query = if (take 1 args)==[] then "a" else head args
  main' query

main' query = do
  print query
  rsp <- simpleHTTP $ uvaRequest query
  html <- fmap (takeWhile isAscii) (getResponseBody rsp)
  let doc = readString [withParseHTML yes, withWarnings no] html
  searchResult <- scanDoc query doc
  print searchResult
  if searchResult == Left TooManyResultsErr
    then main' $ nextDeepQuery query
    else if (next == "*") then print "done!" else main' next where next = nextQuery query
  
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
                email = map toLower $ texts !! 12,
                other = []
                }
          return $ Right [person]
        else do
          rows <- runX $ doc //> hasName "tr"
          return $ Right (readTableRows rows)
  
nextDeepQuery query = query ++ "a"

nextQuery "z" = "*"
nextQuery query = if (last query) == 'z'
                    then ((init.init) query) ++ [succ $ last $ init query]
                    else (init query) ++ [succ $ last query]

readTableRows :: [NTree XNode] -> [Person]
readTableRows (a:b:rows) = fmap parseRow rows
readTableRows rows = []

parseRow row = Person { 
  firstName = (head.words) fullName,
  lastName = (last.words) fullName,
  email = map toLower $ getEmailFromTr row,
  other = [("phoneNumber", getPhoneNumberFromTr row),
           ("status", getTypeFromTr row),
           ("department", getDepartmentFromTr row)]
  }
  where fullName = (unwords.init.words) $ getNameFromTr row

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


data Person = Person 
              { firstName :: String
              , lastName :: String
              , email :: String
              , other :: [(String, String)] -- grad status, department, phonenumber, etc
              } deriving (Show, Eq)
              
data SearchResultErr = NoResultsErr | TooManyResultsErr deriving (Show, Eq)

type SearchResult = Either SearchResultErr [Person]

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
