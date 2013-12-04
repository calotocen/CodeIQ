#!ruby -EWindows-31J
# coding: Windows-31J

class FibonacciSequence
  def self.each
    yield 0
    yield 1
    
    fn_2 = 0
    fn_1 = 1
    loop {
      fn   = fn_1 + fn_2
      yield fn
      
      fn_2 = fn_1
      fn_1 = fn
    }
  end
end

answer = []
FibonacciSequence.each { |fn|
  next if fn <= 144
  s = fn.to_s.split("").reduce(0) { |sum, n| sum += n.to_i }
  answer << fn if fn % s == 0
  break if answer.size >= 5
}

p answer
