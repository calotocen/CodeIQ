#!ruby -E Windows-31J
# conding: Windows-31J

# 宝石パターンの数 (Key: gems, Value: 宝石パターンの数)
$days_memo = {}

# 探索済みの宝石パターン (Key: 宝石パターン, Value: true)
$patterns = {}

# 探索中の宝石パターンが現れる日数
$total_days = 0

# gems から作成した宝石パターンについて，target_pattern が何日目に現れるかを表示する。
def solve(gems, target_pattern, pattern = "")
  # gems から作成できる宝石パターンの数。
  days = 0
  
  if target_pattern[0, pattern.size] != pattern && $days_memo.has_key?(gems)
    # 探索中のパターンから探している宝石パターンを作れず，
    # かつ過去に gems を探索した実績がある場合は，その結果を使用する。
    days         = $days_memo[gems]
    $total_days += days
  else
    # 各宝石を使用した宝石パターンを探索する。
    gems.chars { |ch|
      # 宝石パターンを作成する。
      new_pattern = pattern + ch
      
      # 既に探索した宝石パターンであるかを確認する。
      # 探索済みであった場合は，次の宝石パターンの探索に移る。
      next if $patterns.has_key?(new_pattern)
      $patterns[new_pattern] = true
      
      # 新しい宝石パターンを１つ作ったので，日数をインクリメントする。
      days += 1
      $total_days += 1
      
      # 探索中のパターンが見つかった場合は，何日目に現れるかを出力して処理を終了する。
      if target_pattern == new_pattern
        p $total_days
        exit
      end
      
      # 宝石パターンに加えた宝石を取り除いて，宝石パターンを再帰的に作成する。
      new_gems = gems.sub(/#{ch}/, "")
      days += solve(new_gems, target_pattern, new_pattern)
    }
    
    # gems から作成できる宝石パターンの数をメモする。
    $days_memo[gems] = days
  end
  
  # gems から作成できる宝石パターンの数を返す。
  return days
end


# 表示結果：1
# solve("aaabcc", "a")

# 表示結果：95
# solve("aaabcc", "baaac")

# 表示結果：188
# solve("aaabcc", "ccbaaa")

# 表示結果：5578864439
solve("abbbbcddddeefggg", "eagcdfbe")
