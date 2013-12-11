#!ruby -EWindows-31J
# coding: Windows-31J

# �񕶂ł���ꍇ�� true�C����ȊO�̏ꍇ�� false ��Ԃ��B
def is_palindrome(str)
  return str == str.reverse
end

# 10 �i���A2 �i���A8 �i���̂�����ŕ\�����Ă��񕶐��ƂȂ鐔�̂����C
# 10 �i���� 10 �ȏ�ōŏ��̒l�����߂�B
answer = nil
10.upto(Float::INFINITY) { |n|
  next unless is_palindrome(n.to_s(2))
  next unless is_palindrome(n.to_s(8))
  next unless is_palindrome(n.to_s(10))
  answer = n
  break
}

p answer
