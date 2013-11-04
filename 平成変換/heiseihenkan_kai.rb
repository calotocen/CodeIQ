#!ruby -EWindows-31J
# coding: Windows-31J

#
# = 平成変換(処理速度向上版)
#
# Authors:: calotocen(カトー)
#
# == 使い方
#     heiseihenkan_kai [options] BEFORE AFTER
#     BEFORE     変換前の値
#     AFTER      変換後の値
#     -b         ベンチマークを表示する。
#     -e N       N ステップの解が見つかるまで，探索を続ける。
#     -l SIZE    探索対象とする項の最大文字列長を指定する (デフォルト：9 文字)。
#
# == 使用例
#     > ruby heiseihenkan_kai.rb -b 2014 26
#           user     system      total        real
#       3.359000   0.015000   3.374000 (  3.468750)
#     2014->[2]0[14]->[4019]6->1[6]152(361)6->136(1521)(9)6->1(36)[3](9)(36)->(16)(9)(36)->(4)(36)->26
#     7 steps
# 
# == 初期バージョン(heiseihenkan.rb)からの変更点
# 1. 変換前の値と変換後の値の両方から探索するようにし，解探索時間の短縮を図った。
# 2. 文字区切り (String#stable_permutation) の処理方式を幾つか考え，処理速度を吟味した。
#    詳細は，create_subvalues_list_benchmark.rb に記載している。
# 3. 式生成 (ExpressionFactory#expressions) の処理方式を幾つか考え，処理速度を吟味した。
#    詳細は，create_expressions.rb に記載している。
# 4. 平方根の結果が整数でない場合の探索打ち切り判定を最上位関数 (solve 内) から，
#    式生成中 (ExpressionFactory#expressions_internal 内) に変更することで不要な式生成を減らし，
#    式生成時間の短縮を図った (式生成時間を 60% ほど削減)。
# 5. 最大文字列長の打ち切り判定を最上位関数 (solve 内) から，
#    式生成中 (ExpressionFactory#expressions_internal 内) に変更することで不要な式生成を減らし，
#    式生成時間の短縮を図った (式生成時間を 10% ほど削減)。
# 6. 式の表現を最終形式 ("[2]0(14)" など) から
#    中間形式 (["2", 1], ["0", 0], ["14", -1] など) にすることで，
#    式生成時間の短縮を図った (式生成時間を 5% ほど削減)。
# 7. 重複した式が生成されないようにすることで不要な式変更を減らし，
#    式生成時間の短縮を図った (式生成時間を 5% ほど削減)。
#    (修正前は，例えば ["2", "0", "14"] と ["20", "14"] の両方から "20(14)" などが生成された)。
# 8. 括弧の直後が "0" となる式を生成するように式生成処理を修正した (バグ修正)。
#    (修正前は，"2014" から "[2]014" のような式を生成できなかった)。
# 9. コマンドライン引数でベンチマーク表示有無などを指定できるようにした。
# 10. ソースコード全体をリファクタリングした。
# 
# == 処理速度の向上について
# 解探索処理の大部分は式生成処理で，この処理に一番時間を使う。
# よって，生成する式の絶対数を少なくする (上記変更点 (1)) ことと，
# 式生成処理を早くする (上記変更点 (2) ～ (7)) が高速化の鍵である (と思う)。
# 参考までに本プログラムの実行時プロファイルを次に示す。
# (BEFORE=2014, AFTER=26 は時間がかかるので，BEFORE=62196, AFTER=6 を用いた)。
#     > ruby -r profile heiseihenkan_kai.rb 62196 6
#     62196->[6][2]1(9)[6]->[3](64)1[3]36->(9)(81)(9)(36)->[3](9)(36)->(9)(36)->(36)->6
#     6 steps
#       %   cumulative   self              self     total
#      time   seconds   seconds    calls  ms/call  ms/call  name
#      32.20     5.57      5.57    19853     0.28     3.76  ExpressionFactory#expressions_internal
#      20.36     9.10      3.53    19427     0.18     0.23  Expression#pop_term
#       7.49    10.40      1.30     8166     0.16     0.27  Expression#push_root_term
#       6.16    11.46      1.07     8166     0.13     0.17  Expression#push_square_term
#       5.70    12.45      0.99    26954     0.04     0.04  BasicObject#!=
#       2.96    12.96      0.51     9390     0.05     0.07  Expression#push_nop_term
#       2.25    13.35      0.39    59543     0.01     0.01  String#size
#       1.99    13.70      0.35    35682     0.01     0.01  Fixnum#>
#       1.88    14.03      0.33     8166     0.04     0.04  Math.sqrt
#       1.72    14.32      0.30    29643     0.01     0.01  String#[]#        :
#        :
#       0.00    17.30      0.00        1     0.00     0.00  Context#continue
#       0.00    17.30      0.00        1     0.00     0.00  TracePoint#disable
#       0.00    17.31      0.00        1     0.00 17312.00  #toplevel
#     ※ 1 ～ 4 位と 6 位が式生成用関数である (他にもそれらしいものがあるが，
#        どの処理で使われているのかは判断不能である)。
#        分かる範囲でも式生成処理が全体の 57.59% を占めている。
# 
# == 今後の展望について
# 本プログラムで探索した解が最短ステップではない場合がある。
# 例えば，`ruby heiseihenkan_kai.rb -l 8 2014 26` で得られる解は 8 ステップである
# (最短解は７ステップ)。
# この問題は，変換前と変換後の両方から探索していて，
# なおかつ，各ステップを最後まで探索しないために発生する。
# 幅優先探索を行っているため，通常は最短解が見つかるが，
# 双方向探索では以下のような状況で最短解以外の解が得られる。
#     変換前の値からの探索   変換後の値からの探索
#                +---           ---+
#     1 ｽﾃｯﾌﾟの解|                 |1 ｽﾃｯﾌﾟの解
#                +---           ---+
#                +---           ---+
#     2 ｽﾃｯﾌﾟの解|                 |2 ｽﾃｯﾌﾟの解
#                |   <---(2)-+     |
#                +---        |  ---+
#                +---        |  ---+
#     3 ｽﾃｯﾌﾟの解|   <---(1)-o->   |3 ｽﾃｯﾌﾟの解
#                |           |  
#                |           +->
#                +---           
#     ※ 図中 (1) の時点で解 (6 ステップ) が見つかったので探索を打ち切るが，
#        (2) のような解 (5 ステップ) を得られる可能性はある。
# 
# 上記の問題を解決するためには，探索にステップの概念を導入し，
# ステップを全て探索するようにすればよい。
# (本プログラムは探索速度を優先しオプション -e を作るに留めたが，
# 本来の趣旨から言えば，求めた解が必ず最短解の方がよい。
# なお，-e オプションを使う場合，先の例だと
# `ruby heiseihenkan_kai.rb -l 8 -e 7 2014 26` で最短解を求められる)。
#


require 'benchmark'
require 'optparse'

#
# 拡張した String クラス
#
class String
  #
  # 順序を保持した文字列の順列を生成するための再帰用関数である。
  #
  def stable_permutation_internal(value, subvalues, block)
    (1 ... value.size).each { |i|
      subvalues << value[0, i]
      stable_permutation_internal(value[i ... value.size], subvalues, block)
      subvalues.delete_at(-1)
    }
    
    block.call(subvalues + [value])
  end
  private :stable_permutation_internal

  #
  # 順序を保持した文字列の順列を生成する。得られる順列の順序は不定である。
  # - ブロックが指定された場合，生成した順列の各値を引数としてブロックを実行する。
  #   この場合，戻り値として自分自身を返す。
  #     "abc".stable_permutation() { |strs| p strs }
  #     ->["a", "b", "c"]
  #       ["a", "bc"]
  #       ["ab", "c"]
  #       ["abc"]
  #     
  #     n = 0
  #     "".stable_permutation() { n += 1 }
  #     p n
  #     ->0
  # - ブロックが指定されなかった場合，順列を生成する Enumerator オブジェクトを返す。
  #     e = "12".stable_permutation()
  #     e.each { |strs| p strs }
  #     ->["1", "2"]
  #       ["12"]
  #
  def stable_permutation(&block) # :yield: strs
    return to_enum :stable_permutation unless block_given?
    
    unless self.empty?
      # 全ての文字列分解を再帰用クラスで行うと，
      # 再帰の都合上，未分解の文字列が複数生成される。
      # これを防ぐため，最初の分解は再帰関数の呼び出し元で行う。
      (1 ... self.size).each { |i|
        stable_permutation_internal(self[i ... self.size], [self[0, i]], block)
      }
      
      # 上記の処理では未分解の文字列が生成されないため，
      # ここで未分解の文字列を処理する。
      block.call([self])
    end
    
    return self
  end
end

#
# 平成変換式を表すクラス
#
class Expression
  #
  # 何もしないことを表す ID
  #
  NOP_TERM_ID = 0
  
  #
  # ２乗での変換を表す ID
  #
  SQUARE_TERM_ID = 1
  
  #
  # ２乗根での変換を表す ID
  #
  ROOT_TERM_ID   = -1
  
  #
  # 式の評価結果(String)
  #
  attr_reader :result
  
  #
  # 平成変換式を生成する。
  # - 空の平成変換式を生成する。
  #     Expression.new()
  # - 項を 1 つ持つ平成変換式を生成する (上級者向け)。
  #   terms には，式を構成する項の配列を指定する。
  #   項の形式は，[変換前の値, 変換方法, 変換後の値] である。
  #   results には，各項の変換後の値を連結した値を指定する。
  #     Expression.new(
  #       [["2", Expression::SQUARE_TERM_ID, "4"],
  #        ["9", Expression::ROOT_TERM_ID, "3"]],
  #       "43")
  #
  def initialize(terms = [], result = "")
    @terms  = terms
    @result = result
  end
  
  #
  # 変換前の値を返す。
  #   p Expression.new().push_nop_term("3").push_root_term("121").value
  #   ->"3121"
  def value()
    value = ""
    @terms.each { |term| value << term[0] }
    return value
  end
  
  #
  # 式の末尾に項を追加する。
  #   p Expression.new().push_nop_term("3").to_s()
  #   ->"3"
  def push_nop_term(value)
    @terms  << [value, NOP_TERM_ID, value]
    @result << value
    return self
  end
  
  #
  # 式の末尾に２乗項を追加する。
  #   p Expression.new().push_square_term("3").to_s()
  #   ->"[3]"
  #
  def push_square_term(value)
    square_value = (value.to_i()**2).to_s()
    @terms  << [value, SQUARE_TERM_ID, square_value]
    @result << square_value
    return self
  end
  
  #
  # 式の末尾に２乗根項を追加する。
  # - ２乗根の結果が整数である場合は，項を追加する。
  #     p Expression.new().push_root_term("121").to_s()
  #     ->"(121)"
  # - ２乗根の結果が整数でない場合は，nil を返す。
  #     p Expression.new().push_root_term("120")
  #     ->nil
  #
  def push_root_term(value)
    root_value_f = Math.sqrt(value.to_i())
    root_value_i = root_value_f.to_i()
    if root_value_i != root_value_f
      # 平方根が整数でない。
      return nil
    end
    root_value = root_value_i.to_s()
    
    @terms  << [value, ROOT_TERM_ID, root_value]
    @result << root_value
    return self
  end
  
  #
  # 式の末尾にある項を削除した後，削除した項を返す。
  # 項の形式については，Expression::new を参照のこと。
  #   p Expression.new().push_root_term("121").pop_term()
  #   ->["121", -1, "11"]
  #
  def pop_term()
    @result = @result[0, @result.size - @terms[-1][2].size]
    return @terms.pop()
  end
  
  #
  # 式を逆転する。
  # 戻り値は，変換後の値を変換前の値に戻す式である。
  #   e = Expression.new().push_square_term("7").push_root_term("81")
  #   p e.to_s()
  #   p e.invert().to_s()
  #   ->"[7](81)"
  #     "(49)[9]"
  #
  def invert()
    terms  = []
    result = ""
    @terms.each { |term|
      terms  << [term[2], -term[1], term[0]]
      result << term[0]
    }
    
    return self.class.send(:new, terms, result)
  end
  
  #
  # 式を clone する。
  #
  def clone()
    return self.class.send(:new, @terms.clone(), @result.clone())
  end
  
  #
  # 式を dup する。
  #
  def dup()
    return self.class.send(:new, @terms.dup(), @result.dup())
  end
  
  #
  # 文字列形式の式を返す。
  #
  def to_s()
    brackets = {
      NOP_TERM_ID    => ["", ""],
      SQUARE_TERM_ID => ["[", "]"],
      ROOT_TERM_ID   => ["(", ")"],
    }
    
    str = ""
    @terms.each { |value, function_id|
      str << brackets[function_id][0] + value + brackets[function_id][1]
    }
    return str
  end
  
  #
  # 文字列形式の式を返す。
  # 戻り値は，to_s() と同じである。
  #
  def inspect()
    return to_s()
  end
end

#
# 平成変換式を生成するクラス
#
class ExpressionFactory
  include Enumerable
  
  #
  # 平成変換式生成オブジェクトを生成する。
  # limit を指定した場合は，
  # 式の評価結果の文字列長が limit 以下となる式のみ生成する。
  #
  def initialize(limit = Float::INFINITY)
    @limit = limit
  end
  
  #
  # 平成変換式を順列を生成するための再帰用関数である。
  #
  def expressions_internal(subvalues, expression, expression_results, block)
    # 式の評価結果が limit を超えている場合は，以降の処理を止める。
    return if expression.result.size > @limit
    
    if subvalues.size > 0
      head = subvalues[0]
      tail = subvalues[1 ... subvalues.size]
      
      if head[0] != '0' && head != "1"
        # 先頭が 0 である値に括弧を付けるのは，平成変換式の規約違反である。
        # また，1 を２乗，または２乗根しても 1 であるので，必ず重複が発生する。
        # よって，上記２つに該当しない場合のみ，２乗，２乗根の項を作成する。
        
        # ２乗根の項を追加する。
        # ２乗根の結果が整数であった場合のみ，式に項を追加できる。
        r = expression.push_root_term(head)
        unless r.nil?
          expressions_internal(tail, expression, expression_results, block)
          expression.pop_term()
        end
        
        # ２乗の項を追加する。
        expression.push_square_term(head)
        expressions_internal(tail, expression, expression_results, block)
        expression.pop_term()
      end
      
      # 項を追加する。
      expression.push_nop_term(head)
      expressions_internal(tail, expression, expression_results, block)
      expression.pop_term()
    else
      # 式の評価結果が重複していない場合のみ，ブロックを実行する。
      unless expression_results.has_key?(expression.result)
        block.call(expression.dup())
        expression_results[expression.result] = true
      end
    end
  end
  private :expressions_internal
  
  #
  # value を元に平成変換式を生成する。
  # 本関数で生成される式の評価結果は，重複しない
  # (例えば，"2014" が生成された後に "20(1)4" などは生成されない)。
  # - ブロックが指定された場合，生成した平成変換式を引数としてブロックを実行する。
  #     ExpressionFactory.new().expressions("2014") { |expr| p expr.to_s() }
  #     ->"[2]01(4)"
  #       "[2]01[4]"
  #       "[2]014"
  #       "201(4)"
  #       "201[4]"
  #       "[2]0[14]"
  #       "20[14]"
  #       "[20]1(4)"
  #       "[20]1[4]"
  #       "[20]14"
  #       "[20][14]"
  #       "[201](4)"
  #       "[201][4]"
  #       "[201]4"
  #       "[2014]"
  #     
  #     n = 0
  #     ExpressionFactory.new(4).expressions("") { n += 1 }
  #     p n
  #     ->0
  # - ブロックが指定されなかった場合，平成変換式を生成する Enumerator オブジェクトを返す。
  #     e = ExpressionFactory.new(4).expressions("2014")
  #     e.each { |expr| puts "#{expr.to_s()} => #{expr.result}" }
  #     ->[2]01(4) => 4012
  #       [2]014 => 4014
  #       201(4) => 2012
  #
  def expressions(value, &block) # :yield: expr
    return to_enum :expressions, value unless block_given?
    
    expression_results = {value => true}
    value.stable_permutation() { |subvalues|
      expressions_internal(subvalues, Expression.new(), expression_results, block)
    }
    return self
  end
end

#
# 探索の情報を保持するクラス
#
class Context
  #
  # before に変換前の値，after に変換後の値を指定して，
  # コンテキストを生成する。
  #
  def initialize(before, after)
    @self_results = {before => nil}
    @self_nexts   = [before]
    @peer_results = {after => nil}
    @peer_nexts   = [after]
    @linked_value = ""
    @found        = false
    @turned       = false
  end
  
  #
  # コンテキストに探索で見つけた式を登録する。
  #
  def entry(expression)
    result = expression.result
    unless @self_results.has_key?(result)
      @self_results[result] = expression
      @self_nexts << result
      if @peer_results.has_key?(result)
        @linked_value = result
        @found        = true
      end
    end
    
    return self
  end
  
  #
  # 次に探索すべき値を返す。
  #
  def next_value()
    return @self_nexts.shift()
  end
  
  #
  # 引き続き探索できるようにする。
  # この関数を実行すると，found?() の結果が false に戻る。
  #
  def continue()
    @found = false
    return self
  end
  
  #
  # 解を見つけた場合は true を，それ以外の場合は false 返す。
  #
  def found?()
    return @found
  end
  
  #
  # 探索を終了した (解を見つけた，または全ての値を探索した) 場合は true を，
  # それ以外の場合は false を返す。
  #
  def completed?()
    return @found || (@self_nexts.empty?() && @peer_nexts.empty?())
  end
  
  #
  # 探索の方向を変える。
  #
  def turn()
    @tmp_results  = @self_results
    @tmp_nexts    = @self_nexts
    @self_results = @peer_results
    @self_nexts   = @peer_nexts
    @peer_results = @tmp_results
    @peer_nexts   = @tmp_nexts
    @turned       = !@turned
    return self
  end
  
  #
  # 変換方法を返す。
  # 解を見つけている場合は，値(String)，または式(Expression)で
  # 構成される配列を返す。
  # 解を見つけていない場合は，空配列を返す。
  #
  def results()
    return [] if @linked_value.empty?()
    
    forward_results  = @turned ? @peer_results : @self_results
    backward_results = @turned ? @self_results : @peer_results
    results          = []
    
    value = @linked_value
    until forward_results[value].nil?
      expression = forward_results[value]
      results.unshift(expression)
      value = expression.value
    end
    results.unshift(value)
    
    result = @linked_value
    until backward_results[result].nil?
      expression = backward_results[result]
      expression = expression.invert()
      results.push(expression)
      result = expression.result
    end
    results.push(result)
    
    return results
  end
end

#
# 平成変換の解を探す。
# 解が見つかった場合は true を，それ以外の場合は false を返す。
#
def solve(context, limit)
  factory      = ExpressionFactory.new(limit)
  linked_value = nil
  
  until context.completed?()
    value = context.next_value()
    unless value.nil?
      factory.expressions(value) { |expression|
        context.entry(expression)
        break if context.found?()
      }
    end
    
    context.turn()
  end
  
  return context.found?()
end

Version         = "1.0"
benchmarked     = false
continued       = false
expected_step   = nil
limit = 9

option_parser = OptionParser.new()
option_parser.banner = option_parser.banner + " BEFORE AFTER"
option_parser.on('-b', 'output benchmark') { benchmarked = true }
option_parser.on('-e N', 'continue to search until N steps answer is found') { |v|
  unless v =~ /^[+]?[0-9]+$/
    raise OptionParser::ParseError, "(invalid argument: #{v})"
  end
  expected_step = v.to_i()
}
option_parser.on('-l SIZE', "size limit of evaluated term (default: #{limit})") { |v|
  unless v =~ /^[+]?[0-9]+$/
    raise OptionParser::ParseError, "(invalid argument: #{v})"
  end
  limit = v.to_i()
}
begin
  option_parser.parse!(ARGV)
  if ARGV.size < 2
    raise OptionParser::ParseError, "BEFORE or AFTER wasn't specified"
  end
  if ARGV[0] !~ /^[0-9]+$/ || ARGV[1] !~ /^[0-9]+$/
    raise OptionParser::ParseError, "BEFORE and AFTER must be digits"
  end
rescue OptionParser::ParseError => e
  puts "error: " + e.message
  puts option_parser.help
  exit(1)
end

before  = ARGV[0]
after   = ARGV[1]
found   = false
context = Context.new(before, after)
begin
  if benchmarked
    puts Benchmark::CAPTION
    puts Benchmark::measure { solve(context, limit) }
  else
    solve(context, limit)
  end
  
  unless context.found?()
    unless found
      puts "couldn't convert from #{before} to #{after}"
    end
    break
  end
  
  results = context.results
  step    = results.size - 2
  puts results.join("->")
  puts "#{step} steps"
  
  found = true
  context.continue()
end until expected_step.nil? || step <= expected_step
