-- �t�B�{�i�b�`��������X�g����B
fibonacciSequence = 0 : 1 : zipWith (+) fibonacciSequence (tail fibonacciSequence)

-- ���̐������e���ɕ�������
digits 0 = []
digits n = digits (div n 10) ++ [mod n 10]

-- ���̐������e���̑��a�Ŋ������Ƃ��̗]�肪 0 �ł��邩�𒲂ׂ�B
isAliquot x = let s = sum $ digits x
              in s /= 0 && mod x s == 0

-- �e���̑��a�Ŋ������Ƃ��̗]�肪 0 �ł��鐮�������X�g����B
aliquots (x:xn) = (if isAliquot x then [x] else []) ++ aliquots xn

-- n �𒴂���̐������X�g����B
greater n (x:xn) = (if x > n then [x] else []) ++ greater n xn

-- �e���̑��a�Ŋ������Ƃ��̗]�肪 0 �ł���t�B�{�i�b�`�������X�g����B
main = do print $ take 5 $ greater 144 $ aliquots $ fibonacciSequence
