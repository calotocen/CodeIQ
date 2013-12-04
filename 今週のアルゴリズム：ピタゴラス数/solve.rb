#!ruby -EWindows-31J
# coding: Windows-31J

#
# == �T�v
# 0 �` 9 �܂ł̐��������ׂĎg���ĕ\�����s�^�S���X�� (a, b, c) �̂����C
# a ���ŏ��C���� a, b, c ���݂��ɑf�Ȃ��̂����߂�v���O�����B
#
# 
# == ���s����
# > ruby solve.rb -b
#  763,291084,291085
#        user     system      total        real
#    0.360000   0.000000   0.360000 (  0.375000)
# 

require 'benchmark'
require 'optparse'

# 
# �{�v���O�����̃o�[�W����
# 
Version = "1.0"

# 
# �݂��ɑf�ȃs�^�S���X�̐������߂�B
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
# ���R�� m, n �����Ƀs�^�S���X�����v�Z����B
# m �� n �́C�݂��ɑf�Cm > n�C���� m - n �͊�łȂ���΂Ȃ�Ȃ��B
# ��L�𖞂����ꍇ�C�s�^�S���X���͎����ŋ��߂���B
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
# m �� n �̍ő���񐔂�Ԃ��B
# 
def greatest_common_divisor(m, n)
  # m ��� n �̕����傫���ꍇ�́Cm �� n �����ւ���B
  if m < n
    t = m
    m = n
    n = t
  end
  
  # ���[�N���b�h�ݏ��@�ōő���񐔂����߂�B
  loop {
    rest = m % n
    break if rest == 0
    
    m = n
    n = rest
  }
  
  return n
end

# 
# m, n ���݂��ɑf�Ȑ����ł��邩�𒲂ׂ�B
# 
def relatively_prime?(m, n)
  gcd = greatest_common_divisor(m, n)
  return gcd == 1
end

#
# 0 �` 9 �܂ł̐��������ׂĎg���ĕ\�����
# �s�^�S���X�� (a, b, c) �̂����Ca ���ŏ��̂��̂����߂�B
# �߂�l�́C�s�^�S���X�����i�[�����傫�� 3 �̔z��ł���B
#
def solve()
  answer = Array.new(3, Float::INFINITY)
  
  m = 2
  n = 1
  loop {
    # �s�^�S���X�������߂�B
    a, b, c = pythagorean_triple(m, n)
    
    # ������ "0123456789" ���� a, b, c �Ɋ܂܂�鐔�����폜����B
    # ���̌��ʂ��󕶎���ł���΁C�����𖞂����s�^�S���X���ł���B
    f = "0123456789".tr!(a.to_s + b.to_s + c.to_s, "");
    if f.empty? && a < answer[0]
      answer = [a, b, c]
    end
    
    # ���T���� m, n �̂����Cm ���ŏ��ł�����̂̒��� n ���ŏ��̑g�����߂�B
    # ���߂� (m, n) �́C(3, 2), (4, 1), (4, 3), (5, 2), (5, 4), ... �ł���B
    begin
      n += 1
      if (m <= n)
        m += 1
        n  = 1
        
        # m = a (a �͎��R��) �̂Ƃ��Cm^2 - n^2 ���ŏ��ƂȂ�̂� n = a - 1 �̂Ƃ��C
        # 2mn ���ŏ��ƂȂ�̂� n = 1 �̂Ƃ��ł���B
        # �܂��C(m^2 - n^2) < ((m + 1)^2 - (n + 1)^2) �ł���C
        # 2mn < 2(m + 1)(n + 1) �ł���B
        # �ȏ�̂��Ƃ���Cn = 1�Cn = (a - 1) �̂Ƃ��̃s�^�S���X����
        # �����������傫����΁C�����������ŏ����ł���B
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
