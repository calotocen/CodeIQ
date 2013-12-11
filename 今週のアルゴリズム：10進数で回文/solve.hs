import Numeric

-- 10 �i���A2 �i���A8 �i���̂�����ŕ\�����Ă��񕶐��ƂȂ鐔�̂����C
-- 10 �i���� 10 �ȏ�ōŏ��̒l�����߂�B
main = print $ head $ filter match [10 ..]

-- 10 �i���C2 �i���\�L�C8 �i���̂�����ŕ\�����Ă��񕶐��ƂȂ鐔���𒲂ׂ�B
match :: Integer -> Bool
match n = isPalindrome(i2bs n) && isPalindrome(i2os n) && isPalindrome(i2ds n)

-- �񕶂ł��邩�𒲂ׂ�B
isPalindrome :: String -> Bool
isPalindrome cs = cs == (reverse cs)

-- ���l���i���\�L�̕�����ɕϊ�����B
i2bs :: Integer -> String
i2bs n = concat $ map show $ reverse $ i2bs' n
  where
    i2bs' 0 = []
    i2bs' n = n `mod` 2 : i2bs' (n `div` 2)

-- ���l�𔪐i���\�L�̕�����ɕϊ�����B
i2os :: Integer -> String
i2os n = showOct n ""

-- ���l���\�i���\�L�̕�����ɕϊ�����B
i2ds :: Integer -> String
i2ds n = show n
