#!ruby -EWindows-31J
# coding: Windows-31J

# 平成変換の式を生成する処理のベンチマークをとり，
# 最も速い処理方式を明らかにする。
# 結論としては，create_expressions2 が最も速い。
# 
# 実行結果：
#   > ruby create_expressions.rb
#         user     system      total        real
#   value=["1"], times=200000
#     1.375000   0.000000   1.375000 (  1.390625)
#     1.453000   0.000000   1.453000 (  1.468750)
#     2.532000   0.000000   2.532000 (  2.562500)
#   value=["1", "2"], times=100000
#     1.625000   0.000000   1.625000 (  1.734375)
#     1.656000   0.000000   1.656000 (  1.703125)
#     4.031000   0.000000   4.031000 (  4.156250)
#   value=["2", "3", "4"], times=10000
#     1.266000   0.000000   1.266000 (  1.265625)
#     1.140000   0.000000   1.140000 (  1.140625)
#     1.453000   0.000000   1.453000 (  1.453125)
#   value=["2", "3", "4", "56"], times=5000
#     2.266000   0.015000   2.281000 (  2.390625)
#     2.109000   0.000000   2.109000 (  2.187500)
#     3.110000   0.000000   3.110000 (  3.125000)
#   value=["2", "3", "4", "56", "128"], times=2500
#     3.547000   0.000000   3.547000 (  3.562500)
#     3.297000   0.000000   3.297000 (  3.375000)
#     5.593000   0.016000   5.609000 (  5.687500)
#   value=["01"], times=200000
#     0.500000   0.000000   0.500000 (  0.500000)
#     0.469000   0.000000   0.469000 (  0.484375)
#     0.547000   0.000000   0.547000 (  0.546875)
#   
#   >


require 'benchmark'

FUNCTIONS = [1, 2, 3]

def create_expressions1(subvalues, result = [], work = [])
  if subvalues.size > 0
    return nil if subvalues[0][0] == '0'
    functions = (subvalues[0] == "1") ? [FUNCTIONS[0]] : FUNCTIONS
    functions.each { |f|
      work << [subvalues[0], f]
      create_expressions1(subvalues[1 ... subvalues.size], result, work)
      work.delete_at(-1)
    }
  else
    result << work.dup
  end
  
  return result
end

def create_expressions2_internal(subvalues, result = [], work = [])
  if subvalues.size > 0
    functions = (subvalues[0] == "1") ? [FUNCTIONS[0]] : FUNCTIONS
    functions.each { |f|
      work << [subvalues[0], f]
      create_expressions2_internal(subvalues[1 ... subvalues.size], result, work)
      work.delete_at(-1)
    }
  else
    result << work.dup
  end
  
  return result
end
def create_expressions2(subvalues)
  subvalues.each { |subvalue| return nil if subvalue[0] == '0' }
  return create_expressions2_internal(subvalues)
end

def create_expressions3(subvalues)
  result = []
  
  subvalues.each { |subvalue|
    return nil if subvalue[0] == '0'
  }
  
  FUNCTIONS.repeated_permutation(subvalues.size) { |functions|
    catch(:DONE) {
      work = subvalues.zip(functions)
      work.each { |subvalue, function|
        throw :DONE if subvalue == "1" && function != FUNCTIONS[0]
      }
      
      result << work
    }
  }
  
  return result
end

BENCHMARK_TARGETS = [
  lambda { |value| return create_expressions1(value) },
  lambda { |value| return create_expressions2(value) },
  lambda { |value| return create_expressions3(value) },
]

BENCHMARK_CASES = [
  {:times => 200000, :value => ["1"]},
  {:times => 100000, :value => ["1", "2"]},
  {:times => 10000,  :value => ["2", "3", "4"]},
  {:times => 5000,   :value => ["2", "3", "4", "56"]},
  {:times => 2500,   :value => ["2", "3", "4", "56", "128"]},
  {:times => 200000, :value => ["01"]},
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
    if results[i].kind_of?(Array) && results[i + 1].kind_of?(Array)
      p results[i].sort() == results[i + 1].sort()
    else
      p results[i] == results[i + 1]
    end
  }
=end
  
=begin
  results.each { |result| p result }
=end
}
