#!ruby -EWindows-31J
# coding: Windows-31J

# 回文である場合は true，それ以外の場合は false を返す。
def is_palindrome(str)
  return str == str.reverse
end

# 10 進数、2 進数、8 進数のいずれで表現しても回文数となる数のうち，
# 10 進数の 10 以上で最小の値を求める。
answer = nil
10.upto(Float::INFINITY) { |n|
  next unless is_palindrome(n.to_s(2))
  next unless is_palindrome(n.to_s(8))
  next unless is_palindrome(n.to_s(10))
  answer = n
  break
}

p answer
