-- �t�B�{�i�b�`��������X�g����B
fibonacciSequence = 0 : 1 : zipWith (+) fibonacciSequence (tail fibonacciSequence)

-- ���̐������e���ɕ�������
digits 0 = []
digits n = digits (div n 10) ++ [mod n 10]

-- ���̐������e���̑��a�Ŋ������Ƃ��̗]�肪 0 �ł��邩�𒲂ׂ�B
match x = let s = sum $ digits x
          in s /= 0 && mod x s == 0

-- �e���̑��a�Ŋ������Ƃ��̗]�肪 0 �ł���t�B�{�i�b�`�������X�g����B
main = do print $ take 5 $ dropWhile (<= 144) $ filter match fibonacciSequence
