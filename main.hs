import Network.HTTP
import Network.URI
import Data.Char
-- import Text.XML.HXT.Parser.XmlParsec
import Text.XML.HXT.Core
import Data.Tree.NTree.TypeDefs
import System.Environment 

main = do
  args <- getArgs
  rsp <- simpleHTTP $ uvaRequest (if (take 1 args)==[] then "aaa" else head args)
  html <- fmap (takeWhile isAscii) (getResponseBody rsp)
  let doc = readString [withParseHTML yes, withWarnings no] html
  rows <- runX $ doc //> hasName "tr"
  dat <- runX $ doc >>> multi (hasName "td") >>> getChildren
  print $ readTableRows rows
  
readTableRows (a:b:rows) = fmap parseRow rows
readTableRows rows = []

parseRow row = ( getNameFromTr row,
                 getEmailFromTr row,
                 getPhoneNumberFromTr row,
                 getTypeFromTr row,
                 getDepartmentFromTr row
               )

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
              } deriving Show
              
data SearchResultErr = NoResultsErr | TooManyResultsErr deriving Show

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
