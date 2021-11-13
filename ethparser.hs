{-# LANGUAGE GADTs #-}
{-# LANGUAGE StandaloneDeriving #-}

import System.IO   
import System.Environment   
import Numeric (showHex)

class Serializable a where
  serialize :: a -> String
  
lwToInt :: LaneWidth -> Int
lwToInt LW1 = 1
lwToInt LW2 = 2
lwToInt LW4 = 4
lwToInt LW8 = 8

withLeftPad :: Int -> String -> String 
withLeftPad lw val = let padDiff = 2 * lw - length val in if padDiff > 0 then replicate padDiff '0' ++ val else val  
  
data Type = I | F deriving (Read, Show, Eq)

data LaneWidth = LW1 | LW2 | LW4 | LW8 deriving (Read, Show, Eq)
  
data LaneCount = LC2 | LC4 | LC8 | LC16 | LC32 deriving (Read, Show, Eq)

data SimdByte = SimdByte Type LaneWidth LaneCount deriving (Read, Show)
instance Serializable SimdByte where
  serialize (SimdByte t x l)
    | t == I && x == LW1 && l == LC2 = "00"
    | t == I && x == LW1 && l == LC4 = "20"
    | t == I && x == LW1 && l == LC8 = "40"
    | t == I && x == LW1 && l == LC16 = "60"
    | t == I && x == LW1 && l == LC32 = "80"
    | t == I && x == LW2 && l == LC2 = "04"
    | t == I && x == LW2 && l == LC4 = "24"
    | t == I && x == LW2 && l == LC8 = "44"
    | t == I && x == LW2 && l == LC16 = "64"
    | t == I && x == LW4 && l == LC2 = "08"
    | t == I && x == LW4 && l == LC4 = "28"
    | t == I && x == LW4 && l == LC8 = "48"
    | t == I && x == LW8 && l == LC2 = "0c"
    | t == I && x == LW8 && l == LC4 = "2c"
    | t == F && x == LW4 && l == LC2 = "09"
    | t == F && x == LW4 && l == LC4 = "29"
    | t == F && x == LW4 && l == LC8 = "49"
    | t == F && x == LW8 && l == LC2 = "0d"
    | t == F && x == LW8 && l == LC4 = "2d" 

data Op where
  Xadd :: SimdByte -> Op
  Xmul :: SimdByte -> Op
  Xsub :: SimdByte -> Op
  Xdiv :: SimdByte -> Op
  Xsdiv :: SimdByte -> Op
  Xmod :: SimdByte -> Op
  Xsmod :: SimdByte -> Op
  Xlt :: SimdByte -> Op
  Xgt :: SimdByte -> Op
  Xslt :: SimdByte -> Op
  Xsgt :: SimdByte -> Op
  Xeq :: SimdByte -> Op
  Xiszero :: SimdByte -> Op
  Xand :: SimdByte -> Op
  Xoor :: SimdByte -> Op
  Xxor :: SimdByte -> Op
  Xnot :: SimdByte -> Op
  Xshl :: SimdByte -> Op
  Xshr :: SimdByte -> Op
  Xsar :: SimdByte -> Op
  Xrol :: SimdByte -> Op
  Xror :: SimdByte -> Op
  Xpush :: SimdByte -> [Int] -> Op
  Add :: Op
  Mul :: Op
  Sub :: Op
  Div :: Op
  Lt :: Op
  Gt :: Op
  Eq :: Op
  Iszero :: Op
  And :: Op
  Or :: Op
  Xor :: Op
  Not :: Op
  Shl :: Op
  Shr :: Op
  Push :: LaneWidth -> Int -> Op
  Pop :: Op
  
deriving instance Read Op

instance Serializable Op where
  serialize (Xadd sb) = "c1" ++ (serialize sb)
  serialize (Xmul sb) = "c2" ++ (serialize sb)
  serialize (Xsub sb) = "c3" ++ (serialize sb)
  serialize (Xdiv sb) = "c4" ++ (serialize sb)
  serialize (Xsdiv sb) = "c5" ++ (serialize sb)
  serialize (Xmod sb) = "c6" ++ (serialize sb)
  serialize (Xsmod sb) = "c7" ++ (serialize sb)
  serialize (Xlt sb) = "d0" ++ (serialize sb)
  serialize (Xgt sb) = "d1" ++ (serialize sb)
  serialize (Xslt sb) = "d2" ++ (serialize sb)
  serialize (Xsgt sb) = "d3" ++ (serialize sb)
  serialize (Xeq sb) = "d4" ++ (serialize sb)
  serialize (Xiszero sb) = "d5" ++ (serialize sb)
  serialize (Xand sb) = "d6" ++ (serialize sb)
  serialize (Xoor sb) = "d7" ++ (serialize sb)
  serialize (Xxor sb) = "d8" ++ (serialize sb)
  serialize (Xnot sb) = "d9" ++ (serialize sb)
  serialize (Xshl sb) = "db" ++ (serialize sb)
  serialize (Xshr sb) = "dc" ++ (serialize sb)
  serialize (Xsar sb) = "dd" ++ (serialize sb)
  serialize (Xrol sb) = "de" ++ (serialize sb)
  serialize (Xror sb) = "df" ++ (serialize sb)
  serialize (Xpush sb@(SimdByte t lw lc) vec)
    | bytes == 2 = "e0" ++ (serialize sb) ++ vecToHex lw "" vec 
    | bytes == 4 = "e0" ++ (serialize sb) ++ vecToHex lw "" vec 
    | bytes == 8 = "e0" ++ (serialize sb) ++ vecToHex lw "" vec 
    | bytes == 16 = "e0" ++ (serialize sb) ++ vecToHex lw "" vec 
    | bytes == 32 = "e0" ++ (serialize sb) ++ vecToHex lw "" vec 
    where
      bytes = (lwToInt lw) * length vec
      vecToHex lw acc [] = acc
      vecToHex lw acc (x:xs) = vecToHex lw (acc ++ withLeftPad (lwToInt lw) (showHex x "")) xs 
  serialize Add = "01"
  serialize Mul = "02"
  serialize Sub = "03"
  serialize Div = "04"
  serialize Lt = "10"
  serialize Gt = "11"
  serialize Eq = "14"
  serialize Iszero = "15"
  serialize And = "16"
  serialize Or = "17"
  serialize Xor = "18"
  serialize Not = "19"
  serialize Shl = "21"
  serialize Shr = "22"
  serialize Pop = "50"
  serialize (Push lw x)
    | bytes == 1 = "60" ++ withLeftPad (lwToInt lw) (showHex x "") 
    | bytes == 2 = "61" ++ withLeftPad (lwToInt lw) (showHex x "") 
    | bytes == 4 = "63" ++ withLeftPad (lwToInt lw) (showHex x "") 
    | bytes == 8 = "67" ++ withLeftPad (lwToInt lw) (showHex x "") 
    | bytes == 16 = "6f" ++ withLeftPad (lwToInt lw) (showHex x "") 
    where
      bytes = lwToInt lw
      

main = do 
    [rawRepeat, rawPath, simdRepeat, simdPath] <- getArgs
    withFile simdPath ReadMode (\handle -> do  
        contents <- hGetContents handle 
        let ops = map (serialize . (read :: String -> Op)) $ lines contents    
        mapM_ putStr (concat $ replicate (read simdRepeat :: Int) ops)) 
    withFile rawPath ReadMode (\handle -> do  
        contents <- hGetContents handle 
        let ops = map (serialize . (read :: String -> Op)) $ lines contents    
        mapM_ putStr (concat $ replicate (read rawRepeat :: Int) ops))  

