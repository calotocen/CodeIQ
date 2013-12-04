-- フィボナッチ数列をリストする。
fibonacciSequence = 0 : 1 : zipWith (+) fibonacciSequence (tail fibonacciSequence)

-- 正の整数を各桁に分解する
digits 0 = []
digits n = digits (div n 10) ++ [mod n 10]

-- 正の整数を各桁の総和で割ったときの余りが 0 であるかを調べる。
isAliquot x = let s = sum $ digits x
              in s /= 0 && mod x s == 0

-- 各桁の総和で割ったときの余りが 0 である整数をリストする。
aliquots (x:xn) = (if isAliquot x then [x] else []) ++ aliquots xn

-- n を超えるの数をリストする。
greater n (x:xn) = (if x > n then [x] else []) ++ greater n xn

-- 各桁の総和で割ったときの余りが 0 であるフィボナッチ数をリストする。
main = do print $ take 5 $ greater 144 $ aliquots $ fibonacciSequence
