#!ruby -EWindows-31J
# coding: Windows-31J

#
# == 概要
# 0 ～ 9 までの数字をすべて使って表されるピタゴラス数 (a, b, c) のうち，
# a が最小，かつ a, b, c が互いに素なものを求めるプログラム。
#
# 
# == 実行結果
# > ruby solve.rb -b
#  763,291084,291085
#        user     system      total        real
#    0.360000   0.000000   0.360000 (  0.375000)
# 

require 'benchmark'
require 'optparse'

# 
# 本プログラムのバージョン
# 
Version = "1.0"

# 
# 互いに素なピタゴラスの数を求める。
# 
def main()
  benchmarked = false
  option_parser = OptionParser.new()
  option_parser.on('-b', 'output benchmark') { benchmarked = true }
  begin
    option_parser.parse!(ARGV)
  rescue OptionParser::ParseError => e
    puts "error: " + e.message
    puts option_parser.help
    exit(1)
  end
  
  proc = lambda {
    answer = solve()
    puts "#{answer[0]},#{answer[1]},#{answer[2]}"
  }
  if benchmarked
    benchmark = Benchmark::measure { proc.call() }
    puts Benchmark::CAPTION
    puts benchmark
  else
    proc.call()
  end
end

#
# 自然数 m, n を元にピタゴラス数を計算する。
# m と n は，互いに素，m > n，かつ m - n は奇数でなければならない。
# 上記を満たす場合，ピタゴラス数は次式で求められる。
#   (a, b, c) = (m^2 - n^2, 2mn, m^2 + n^2)
#
def pythagorean_triple(m, n)
  m_2 = m**2
  n_2 = n**2
  a = m_2 - n_2
  b = 2 * m * n
  c = m_2 + n_2
  
  return (a < b) ? [a, b, c] : [b, a, c]
end

# 
# m と n の最大公約数を返す。
# 
def greatest_common_divisor(m, n)
  # m より n の方が大きい場合は，m と n を入れ替える。
  if m < n
    t = m
    m = n
    n = t
  end
  
  # ユークリッド互除法で最大公約数を求める。
  loop {
    rest = m % n
    break if rest == 0
    
    m = n
    n = rest
  }
  
  return n
end

# 
# m, n が互いに素な整数であるかを調べる。
# 
def relatively_prime?(m, n)
  gcd = greatest_common_divisor(m, n)
  return gcd == 1
end

#
# 0 ～ 9 までの数字をすべて使って表される
# ピタゴラス数 (a, b, c) のうち，a が最小のものを求める。
# 戻り値は，ピタゴラス数を格納した大きさ 3 の配列である。
#
def solve()
  answer = Array.new(3, Float::INFINITY)
  
  m = 2
  n = 1
  loop {
    # ピタゴラス数を求める。
    a, b, c = pythagorean_triple(m, n)
    
    # 文字列 "0123456789" から a, b, c に含まれる数字を削除する。
    # その結果が空文字列であれば，条件を満たすピタゴラス数である。
    f = "0123456789".tr!(a.to_s + b.to_s + c.to_s, "");
    if f.empty? && a < answer[0]
      answer = [a, b, c]
    end
    
    # 未探索の m, n のうち，m が最小であるものの中で n が最小の組を求める。
    # 求める (m, n) は，(3, 2), (4, 1), (4, 3), (5, 2), (5, 4), ... である。
    begin
      n += 1
      if (m <= n)
        m += 1
        n  = 1
        
        # m = a (a は自然数) のとき，m^2 - n^2 が最小となるのは n = a - 1 のとき，
        # 2mn が最小となるのは n = 1 のときである。
        # また，(m^2 - n^2) < ((m + 1)^2 - (n + 1)^2) であり，
        # 2mn < 2(m + 1)(n + 1) である。
        # 以上のことから，n = 1，n = (a - 1) のときのピタゴラス数が
        # 見つけた解より大きければ，見つけた解が最小解である。
        a1 = pythagorean_triple(m, 1)[0]
        a2 = pythagorean_triple(m, m - 1)[0]
        if answer[0] < a1 && answer[0] < a2
          return answer
        end
      end
    end until (m - n).odd? && relatively_prime?(m, n)
  }
end

main()
