require 'benchmark'

def create_subvalues_list1(value, result = [], work = [])
  (1 ... value.size).each { |i|
    work << value[0, i]
    create_subvalues_list1(value[i, value.size], result, work)
    work.delete_at(-1)
  }
  
  result << (work + [value])
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
  
  (0 ... results.size - 1).each { |i|
    p results[i].sort() == results[i + 1].sort()
  }
# results.each { |result|
#   result.each { |e| p e }
# }
}
