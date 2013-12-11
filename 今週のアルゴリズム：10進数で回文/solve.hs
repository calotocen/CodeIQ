import Numeric

-- 10 進数、2 進数、8 進数のいずれで表現しても回文数となる数のうち，
-- 10 進数の 10 以上で最小の値を求める。
main = print $ head $ filter match [10 ..]

-- 10 進数，2 進数表記，8 進数のいずれで表現しても回文数となる数かを調べる。
match :: Integer -> Bool
match n = isPalindrome(i2bs n) && isPalindrome(i2os n) && isPalindrome(i2ds n)

-- 回文であるかを調べる。
isPalindrome :: String -> Bool
isPalindrome cs = cs == (reverse cs)

-- 数値を二進数表記の文字列に変換する。
i2bs :: Integer -> String
i2bs n = concat $ map show $ reverse $ i2bs' n
  where
    i2bs' 0 = []
    i2bs' n = n `mod` 2 : i2bs' (n `div` 2)

-- 数値を八進数表記の文字列に変換する。
i2os :: Integer -> String
i2os n = showOct n ""

-- 数値を十進数表記の文字列に変換する。
i2ds :: Integer -> String
i2ds n = show n
