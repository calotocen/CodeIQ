#!ruby -E Windows-31J
# conding: Windows-31J

# ��΃p�^�[���̐� (Key: gems, Value: ��΃p�^�[���̐�)
$days_memo = {}

# �T���ς݂̕�΃p�^�[�� (Key: ��΃p�^�[��, Value: true)
$patterns = {}

# �T�����̕�΃p�^�[������������
$total_days = 0

# gems ����쐬������΃p�^�[���ɂ��āCtarget_pattern �������ڂɌ���邩��\������B
def solve(gems, target_pattern, pattern = "")
  # gems ����쐬�ł����΃p�^�[���̐��B
  days = 0
  
  if target_pattern[0, pattern.size] != pattern && $days_memo.has_key?(gems)
    # �T�����̃p�^�[������T���Ă����΃p�^�[������ꂸ�C
    # ���ߋ��� gems ��T���������т�����ꍇ�́C���̌��ʂ��g�p����B
    days         = $days_memo[gems]
    $total_days += days
  else
    # �e��΂��g�p������΃p�^�[����T������B
    gems.chars { |ch|
      # ��΃p�^�[�����쐬����B
      new_pattern = pattern + ch
      
      # ���ɒT��������΃p�^�[���ł��邩���m�F����B
      # �T���ς݂ł������ꍇ�́C���̕�΃p�^�[���̒T���Ɉڂ�B
      next if $patterns.has_key?(new_pattern)
      $patterns[new_pattern] = true
      
      # �V������΃p�^�[�����P������̂ŁC�������C���N�������g����B
      days += 1
      $total_days += 1
      
      # �T�����̃p�^�[�������������ꍇ�́C�����ڂɌ���邩���o�͂��ď������I������B
      if target_pattern == new_pattern
        p $total_days
        exit
      end
      
      # ��΃p�^�[���ɉ�������΂���菜���āC��΃p�^�[�����ċA�I�ɍ쐬����B
      new_gems = gems.sub(/#{ch}/, "")
      days += solve(new_gems, target_pattern, new_pattern)
    }
    
    # gems ����쐬�ł����΃p�^�[���̐�����������B
    $days_memo[gems] = days
  end
  
  # gems ����쐬�ł����΃p�^�[���̐���Ԃ��B
  return days
end


# �\�����ʁF1
# solve("aaabcc", "a")

# �\�����ʁF95
# solve("aaabcc", "baaac")

# �\�����ʁF188
# solve("aaabcc", "ccbaaa")

# �\�����ʁF5578864439
solve("abbbbcddddeefggg", "eagcdfbe")
