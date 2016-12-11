import System.IO  
import System.Directory  
import Data.List  
import Debug.Trace
import System.Environment
  
-- Represents a distance to another city
data Dist = Dist {dest :: Int, distance :: Int} deriving (Show)
instance Eq Dist where
    Dist {dest = d1} == Dist {dest = d2} = d1 == d2
instance Ord Dist where
    Dist {distance = d1} `compare` Dist {distance = d2} = d1 `compare` d2

-- List of distances from a src city
data Dists = Dists {city :: Int, dists :: [Dist]} deriving (Show)
instance Eq Dists where
  Dists {city = c1} == Dists {city = c2} = c1 == c2

-- rounded euclidean distance between two nodes
edist [_, x1, y1] [_, x2, y2] = 
    let x' = fromIntegral $ x1 - x2
        y' = fromIntegral $ y1 - y2
    in  round $ sqrt (x'^2 + y'^2)

-- function to read TSP input as integers
readInt :: String -> Int
readInt = read

-- takes dmat and start node and accumulator, returns list of nodes to take
greedyPath :: [Dists] -> Int -> [Int] -> [Int]
-- base case
greedyPath [lastEntry] lastCity path = lastCity:path 
greedyPath dmat curr path = 
    let
        -- get Dists row for current city
        Just Dists {dists = currDists} = find (\x -> city x == curr) dmat

        -- function to delete a city from Dists
        deleteCity = delete (Dist {dest = curr, distance = undefined})
        deleteCityFromDists Dists{city = c, dists = ds} = Dists{city=c, dists = deleteCity ds}
        
        -- distance matrix without current city
        withoutCurr = [deleteCityFromDists entry | entry <- dmat, city entry /= curr]
        -- next city
        nearestCity = dest $ minimum currDists
    in  greedyPath withoutCurr nearestCity (curr:path) 

main = do     
    f <- getArgs
    handle <- openFile (head f) ReadMode 
    contents <- hGetContents handle  
    -- init to drop EOF line
    let datalines = init (drop 6 $ lines contents)
        split = map (map readInt . words) datalines

        dmat = [Dists (head src) [Dist (head dest) (edist src dest) | dest <- split, src /= dest] | src <- split]
        start = city $ head dmat
        res = greedyPath dmat start []

    putStrLn "Solution (list of city IDs):"
    -- grab last city
    print (reverse $ start:res)