#!ruby -EWindows-31J
# coding: Windows-31J

# 平成変換の式生成で使用する元値を区切る処理のベンチマークをとり，
# 最も速い処理方式を明らかにする。
# 結論としては，create_subvalues_list1 が最も速い。
# 
# create_subvalues_list の仕様は，次のとおりである。
#   create_subvalues_list(String) -> [[String]]
#   文字列 value から作成できるサブ文字列のリストを全て作成する。
#   サブ文字列の生成順序は，一定ではない場合がある。
#   例：create_subvalues_list("")    -> []
#       create_subvalues_list("a")   -> [["a"]]
#       create_subvalues_list("ab")  -> [["a,b", "ab"]]
#       create_subvalues_list("abc") -> [["a,b,c", "ab,c", "a,bc", "abc"]]
# 
# 実行結果：
#   > ruby create_subvalues_list_benchmark.rb
#         user     system      total        real
#   value=, times=500000
#     1.078000   0.016000   1.094000 (  1.296875)
#     2.156000   0.000000   2.156000 (  2.562500)
#     7.610000   0.062000   7.672000 (  8.718750)
#   value=a, times=500000
#     1.453000   0.000000   1.453000 (  1.656250)
#     2.703000   0.016000   2.719000 (  2.859375)
#     8.734000   0.047000   8.781000 ( 10.000000)
#   value=ab, times=200000
#     1.235000   0.000000   1.235000 (  1.328125)
#     1.828000   0.000000   1.828000 (  2.078125)
#     7.125000   0.031000   7.156000 (  8.406250)
#   value=abc, times=100000
#     1.297000   0.000000   1.297000 (  1.437500)
#     1.937000   0.000000   1.937000 (  2.328125)
#     7.516000   0.031000   7.547000 (  8.406250)
#   value=abcd, times=50000
#     1.297000   0.000000   1.297000 (  1.765625)
#     2.047000   0.000000   2.047000 (  2.468750)
#     7.656000   0.000000   7.656000 (  8.921875)
#   value=abcde, times=20000
#     1.078000   0.000000   1.078000 (  1.281250)
#     1.719000   0.000000   1.719000 (  2.671875)
#     6.109000   0.016000   6.125000 (  7.625000)
#   value=abcdef, times=10000
#     1.110000   0.000000   1.110000 (  1.187500)
#     1.875000   0.000000   1.875000 (  2.031250)
#     6.234000   0.000000   6.234000 (  7.531250)
#   value=abcdefg, times=5000
#     1.141000   0.000000   1.141000 (  1.234375)
#     2.078000   0.000000   2.078000 (  2.328125)
#     6.422000   0.000000   6.422000 (  7.578125)
#   value=abcdefgh, times=2000
#     0.906000   0.000000   0.906000 (  0.968750)
#     1.844000   0.000000   1.844000 (  1.984375)
#     5.235000   0.000000   5.235000 (  6.015625)
#   value=abcdefghi, times=1000
#     0.953000   0.000000   0.953000 (  1.015625)
#     1.922000   0.000000   1.922000 (  2.328125)
#     5.546000   0.000000   5.546000 (  6.562500)
#   value=abcdefghij, times=500
#     1.000000   0.000000   1.000000 (  1.093750)
#     2.188000   0.000000   2.188000 (  2.390625)
#     5.969000   0.015000   5.984000 (  7.250000)
#   
#   >


require 'benchmark'

def create_subvalues_list1(value, result = [], work = [])
  (1 ... value.size).each { |i|
    work << value[0, i]
    create_subvalues_list1(value[i ... value.size], result, work)
    work.delete_at(-1)
  }
  
  unless value.empty?
    # work の内容が変わるときは，必ず work の内容をコピーする。
    # でなければ，result に格納した配列の内容が変わってしまう。
    work += [value]
  end
  
  result << work
end

def create_subvalues_list2(value)
  result = []
  
  subvalues_sizes = Array.new(value.size, 1)
  loop {
    subvalues = []
    subvalues_sizes.reduce(0) { |index, size|
      subvalues << value[index, size]
      index + size
    }
    
    result << subvalues
    
    n = subvalues_sizes.pop()
    break if subvalues_sizes.empty?
    
    subvalues_sizes[-1] += 1
    (n - 1).times { subvalues_sizes << 1 }
  }
  
  return result
end

def create_subvalues_list3(value)
  result = []
  
  subvalues = value.split("")
  loop {
    result << subvalues.clone()
    
    subvalue = subvalues.pop()
    break if subvalues.empty?
    
    subvalues[-1] += subvalue[0]
    subvalues.concat(subvalue[1 ... subvalue.size].split(""))
  }
  
  return result
end

BENCHMARK_TARGETS = [
  lambda { |value| return create_subvalues_list1(value) },
  lambda { |value| return create_subvalues_list2(value) },
  lambda { |value| return create_subvalues_list3(value) },
]

BENCHMARK_CASES = [
  {:times => 500000, :value => ""},
  {:times => 500000, :value => "a"},
  {:times => 200000, :value => "ab"},
  {:times => 100000, :value => "abc"},
  {:times => 50000,  :value => "abcd"},
  {:times => 20000,  :value => "abcde"},
  {:times => 10000,  :value => "abcdef"},
  {:times => 5000,   :value => "abcdefg"},
  {:times => 2000,   :value => "abcdefgh"},
  {:times => 1000,   :value => "abcdefghi"},
  {:times => 500,    :value => "abcdefghij"},
]

puts Benchmark::CAPTION
BENCHMARK_CASES.each { |benchmark_case|
  results = []
  times = benchmark_case[:times]
  value = benchmark_case[:value]
  
  puts("value=#{value}, times=#{times}")
  BENCHMARK_TARGETS.each { |benchmark_target|
    result = nil
    puts Benchmark::measure {
      times.times {
        result = benchmark_target.call(value)
      }
    }
    results << result
  }
  
=begin
  (0 ... results.size - 1).each { |i|
    p results[i].sort() == results[i + 1].sort()
  }
=end
  
=begin
  results.each { |result|
    result.each { |e| p e }
  }
=end
}
