-- フィボナッチ数列をリストする。
fibonacciSequence = 0 : 1 : zipWith (+) fibonacciSequence (tail fibonacciSequence)

-- 正の整数を各桁に分解する
digits 0 = []
digits n = digits (div n 10) ++ [mod n 10]

-- 正の整数を各桁の総和で割ったときの余りが 0 であるかを調べる。
match x = let s = sum $ digits x
          in s /= 0 && mod x s == 0

-- 各桁の総和で割ったときの余りが 0 であるフィボナッチ数をリストする。
main = do print $ take 5 $ dropWhile (<= 144) $ filter match fibonacciSequence
