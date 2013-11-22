#!ruby -EWindows-31J
# coding: Windows-31J

# 
# = テトロミノ＋ビンゴの賞集計プログラム
# Authors:: calotocen
# 
# == 使い方
#   Usage: solve [options]
#       -b                               output benchmark
#       -f PATH                          data file path
# 
# == 使用例
#   > ruby solve.rb -b -f data.txt
#   I:222,L:1111,O:333,S:666,T:777
#         user     system      total        real
#    20.843000   0.032000  20.875000 ( 21.000000)
#   
#   >
# 
# == 高速化の工夫
# 実行時間を短くするために，次のように工夫した。
# - 穴の大きさを記憶し，その大きさがテトロミノの数 (4 個) と異なる場合は，
#   テトロミノの判定処理を行わないようにした。
# - 穴の開いていないマスの数が一定数未満である場合は絶対にテトロミノができないため，
#   この場合に解探索を打ち切るようにした
#   (探索を打ち切るべき穴の開いていないマスの数は，テトロミノの形によって異なる)。
# - 穴を開けた部分にのみ，テトロミノの判定処理を行うようにした
#   (ただ，カードのサイズとテトロミノのサイズが同じくらいのため，
#   大きな効果は得られない)。
# 

require 'benchmark'
require 'optparse'

# 
# 本プログラムのバージョン
# 
Version = "1.0"

# 
# データファイルを読み込み，テトロミノ＋ビンゴの賞を集計する。
# 集計結果は「I:nI,L:nL,O:nO,S:nS,T:nT」(nX は，数値) の形式で標準出力へ書き出す。
# データファイルのフォーマットは，次のとおりとする。
# - １行目：
#   読み上げる数をコンマ区切りで指定する
#   (例：1,2,3,4,5)
# - ２行目以降：
#   ビンゴカードの内容を，列をスラッシュ区切り，行をコンマ区切りで指定する
#   (例：1,2,3,4,5/6,7,8,9,10/11,12,13,14,15/16,17,18,19,20)
# 
def main()
  benchmarked    = false
  data_file_path = nil
  
  option_parser = OptionParser.new()
  option_parser.on('-b', 'output benchmark') { benchmarked = true }
  option_parser.on('-f PATH', 'data file path') { |v| data_file_path = v }
  begin
    option_parser.parse!(ARGV)
  rescue OptionParser::ParseError => e
    puts "error: " + e.message
    puts option_parser.help
    exit(1)
  end
  
  # データファイルを開く。
  # データファイルが指定されていない場合は，標準入力を使用する。
  data_file = STDIN
  unless data_file_path.nil? || data_file_path == "-"
    begin
      data_file = File::open(data_file_path)
    rescue SystemCallError => e
      puts "error: " + e.message
      exit(2)
    end
  end
  
  # 読み上げる数を読み込む。
  numbers = data_file.readline.chomp.split(",").map! { |e| e.to_i }
  
  # ビンゴカードを読み込む。
  cards = []
  begin
    loop {
      cards << Card.new(
        data_file.readline.chomp.split("/").map! { |e|
          e.split(",").map{ |e| e.to_i }
        })
    }
  rescue EOFError
  end
  
  # テトロミノのフィルターを作成する。
  filters = Filter.filters
  
  # カードを順番に調べ，賞を特定して出力する。
  proc   = lambda {
    answer = {"I" => 0, "L" => 0, "O" => 0, "S" => 0, "T" => 0}
    cards.each { |card|
      prize = solve(numbers, card, filters)
      answer[prize] += 1 unless prize.nil?
    }
    puts answer.to_a.map!{ |e| e.join(":") }.join(",")
  }
  if benchmarked
    benchmark = Benchmark::measure { proc.call }
    puts Benchmark::CAPTION
    puts benchmark
  else
    proc.call
  end
end

# 
# numbers に指定された数を読み上げたときに
# filter に指定したテトロミノが card に指定したビンゴカードにできるか調べる。
# テトロミノができる場合は，filter に対応する賞の名前を返す。
# テトロミノができない場合は，nil を返す。
#
def solve(numbers, card, filters)
  # カードの中身を変更するので，dup する。
  card  = card.dup
  
  # テトロミノができるかを調べる。
  # できる場合は，prize に賞の名前を設定して処理を終了する。
  prize = nil
  catch (:DONE) {
    numbers.each { |n|
      # カードに穴を開ける。
      # カードに穴を開けた場合のみ，フィルタにマッチするかを調べる。
      if card.punch(n)
        truncated = true
        filters.each { |filter|
          if filter.match?(card)
            prize = filter.name
            throw :DONE
          end
          
          truncated &&= filter.truncated?(card)
        }
        
        break if truncated
      end
    }
  }
  
  return prize
end

# 
# 縦，横に伸びる二次元のセル集合を表すクラス。
# 
class Cells
  # 
  # Cells を作成する。
  # cells には，セルの内容を Cells 自身，配列，文字列のいずれかで指定する。
  # outside_value には，領域外にアクセスされたときに返す値を指定する。
  # 
  def initialize(cells, outside_value = nil)
    @cells = []
    if cells.instance_of?(Cells)
      cells.height.times { |y|
        column = []
        cells.width.times { |x| column << cells[x, y] }
        @cells << column
      }
    elsif cells.instance_of?(Array)
      @cells = cells.dup.map! { |column| column.dup }
    elsif cells.instance_of?(String)
      @cells = cells.split("/").map! { |column|
        column_items = column.split(",")
        column_items.map! { |e| yield e } if block_given?()
        column_items
      }
    end
    
    # 上記３条件に一致しなかった場合，
    # ここで nil:NilClass の NoMethodError が発生する。
    @width         = @cells[0].size
    @height        = @cells.size
    @outside_value = outside_value
  end
  
  # 
  # 横方向に並んでいるセルの数
  # 
  attr_reader :width
  
  # 
  # 縦方向に並んでいるセルの数
  # 
  attr_reader :height
  
  # 
  # x, y で指定したセル座標が領域内かを調べる。
  # 領域内である場合は true，領域外である場合は false を返す。
  # 
  def inside?(x, y)
    return 0 <= x && x < @width && 0 <= y && y < @height
  end
  
  # 
  # x, y で指定したセル座標から，(x + width)，(x + height) までの座標を返す。
  # 引数を省略した場合，x と y には 0，
  # width と height には Cells の width と height が指定されたものとみなす。
  #   Cells.new("1,2/3,4").coords
  #   -> [[0, 0], [0, 1], [1, 0], [1, 1]]
  #   
  #   Cells.new("1,2/3,4").coords(1, 1, 1, 1)
  #   -> [[1, 1]]
  # 
  def coords(x = 0, y = 0, width = @width, height = @height)
    return (x ... x + width).to_a.product((y ... y + height).to_a)
  end
  
  # 
  # x, y で指定したセルの値を返す。
  # 
  def [](x, y)
    return @cells[y][x] if inside?(x, y)
    return @outside_value
  end
  
  # 
  # x, y で指定したセルの値を value に設定する。
  # 
  def []=(x, y, value)
    @cells[y][x] = value if inside?(x, y)
    return self
  end
  
  # 
  # 時計回りに 90 度回転させた Cells を返す。
  # 
  def rotate
    cells = []
    0.upto(@width - 1) { |x|
      column = []
      (@height - 1).downto(0) { |y| column << self[x, y] }
      cells << column
    }
    return Cells.new(cells, @outside_value)
  end
  
  # 
  # 左右逆転させた Cells を返す。
  # 
  def invert()
    cells = []
    0.upto(@height - 1) { |y|
      column = []
      (@width - 1).downto(0) { |x| column << self[x, y] }
      cells << column
    }
    return Cells.new(cells, @outside_value)
  end
  
  # 
  # 内容 (横方向のセルの数，縦方向のセルの数，および各セルの値) が等しいかを調べる。
  # 内容が等しい場合は true，異なる場合は false を返す。
  # 
  def ==(other)
    return eql?(other)
  end
  
  # 
  # 内容 (幅，高さ，および各セルの値) が等しいかを調べる。
  # 内容が等しい場合は true，異なる場合は false を返す。
  # 
  def eql?(other)
    return hash == other.hash
  end
  
  # 
  # ハッシュ値を返す。
  # 
  def hash()
    return to_s.hash
  end
  
  # 
  # セルの内容を文字列で返す。
  # 
  def to_s()
    return @cells.to_s
  end
  
  # 
  # セルの内容を人間が見やすい文字列で返す。
  # 
  def inspect()
    str = ""
    @height.times { |y|
      @width.times { |x|
        str += sprintf("%02s", self[x, y].to_s)
      }
      str += "\n"
    }
    return str.chomp
  end
end

# 
# ビンゴカードを表すクラス。
# 
class Card < Cells
  # 
  # ビンゴカードを作成する。
  # cells には Cells，または Cells を表す配列か文字列を，
  # hole_value には穴を表す値，outside_value には領域外の値を指定する。
  # また，指定する値は次の条件を満たす必要がある。
  # - cells 内に同じ値が２つ以上あってはならない。
  # - cells の各値，hole_value，および outside_value は，
  #   互いに素な値でなければならない。
  # 
  def initialize(cells, hole_value = 0, outside_value = -1)
    super(cells, outside_value) { |e| e.to_i }
    
    hole_size_cells = []
    @height.times { |y|
      column = []
      @width.times { |x| column << [[x, y], 0] }
      hole_size_cells << column
    }
    
    @hole_value       = hole_value
    @plain_count      = @width * @height
    @hole_count       = 0
    @last_punch_coord = nil
    @hole_sizes        = Cells.new(hole_size_cells, [[-1, -1], 0])
  end
  
  # 
  # 穴を開けたマスの数を表す属性
  # 
  attr_reader :hole_count
  
  # 
  # 穴を開けていないマスの数を表す属性
  # 
  attr_reader :plain_count
  
  # 
  # 最後に穴を開けた位置を [x, y] 形式で表す属性。
  # 穴を一つも開けていない場合，この属性の値は nil である。
  # 
  attr_reader :last_punch_coord
  
  # 
  # x, y で指定したマスにある穴の大きさを返す。
  # 
  def hole_size(x, y)
    return @hole_sizes[x, y][1]
  end
  
  # 
  # x, y で指定したマスに穴が開いているかを調べる。
  # 穴が開いている場合 true を，開いていない場合 false を返す。
  # 
  def hole?(x, y)
    return self[x, y] == @hole_value
  end
  
  # 
  # x, y で指定したマスに穴が開いていないかを調べる。
  # 穴が開いていない場合 true を，開いている場合 false を返す。
  # 
  def plain?(x, y)
    return self[x, y] != @hole_value
  end
  
  # 
  # 内容が value であるマスに穴を開ける。
  # 
  def punch(value)
    result = false
    coords.each { |x, y|
      if self[x, y] == value
        # 内容が value であるマスを見つけたので，穴を開ける。
        result             = true
        self[x, y]         = 0
        @plain_count      -= 1
        @hole_count       += 1
        @last_punch_coord  = [x, y]
        
        # 穴を開けたマスの穴のサイズを更新する。
        # 穴のサイズは @hole_sizes に保持しており，
        # そのデータ構造は [[x, y], size] である (x, y は座標，size は穴のサイズ)。
        # [x, y] は，キーとして重複チェックに使用する。
        # 
        # 基本的には，穴を開けたマスの上下左右にあるマスが保持している
        # 穴のサイズを足すことで，そのマスの穴のサイズを求める。
        # ただし，'L' 字型の穴は
        # 
        #   例１：+----------+
        #         |01■030405|
        #         |06★■■10|
        #         |11■131415|
        #         |16■■1920|
        #         |■■232415|
        #         +----------+
        #         ★の位置に穴を開けた場合，穴のサイズは上下左右にある
        #         穴のサイズに自分の分を足して 9 になる。
        #   
        #   例２：+----------+
        #         |0102030405|
        #         |0607080910|
        #         |11■★1415|
        #         |16■■1920|
        #         |2122232415|
        #         +----------+
        #         単純に★の上下左右の穴のサイズを足すと 6 になる。
        #         このような重複を避けるため穴のサイズにキーを持たせ，
        #         同じキーを持つ穴のサイズは足さないようにする。
        #     
        size = 1
        keys = {[x, y] => true}
        [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]].each { |x, y|
          unless keys.has_key?(@hole_sizes[x, y][0])
            keys[@hole_sizes[x, y][0]]  = true
            size                      += @hole_sizes[x, y][1]
          end
        }
        update_hole_size(x, y, [x, y], size)
        break
      end
    }
    return result
  end
  
  # 
  # 新たな穴のサイズを上下左右のマスに伝播し，穴のサイズを更新する。
  # 
  def update_hole_size(x, y, key, size)
    @hole_sizes[x, y] = [key, size]
    [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]].each { |x, y|
      if @hole_sizes.inside?(x, y) &&
         @hole_sizes[x, y][0] != key &&
         hole?(x, y)
        update_hole_size(x, y, key, size)
      end
    }
  end
  private :update_hole_size
end

# 
# テトロミノフィルタを表すクラス。
# 
class Filter < Cells
  # 
  # テトロミノ "I" を表すフィルタを返す。
  # 
  def self.I()
    return Filter.new("I", Cells.new("0,1,0/1,2,1/1,2,1/1,2,1/1,2,1/0,1,0") { |e| e.to_i })
  end
  
  # 
  # テトロミノ "L" を表すフィルタを返す。
  # 
  def self.L()
    return Filter.new("L", Cells.new("0,1,0,0/1,2,1,0/1,2,1,0/1,2,2,1/0,1,1,0") { |e| e.to_i })
  end
  
  # 
  # テトロミノ "O" を表すフィルタを返す。
  # 
  def self.O()
    return Filter.new("O", Cells.new("0,1,1,0/1,2,2,1/1,2,2,1/0,1,1,0") { |e| e.to_i })
  end
  
  # 
  # テトロミノ "S" を表すフィルタを返す。
  # 
  def self.S()
    return Filter.new("S", Cells.new("0,0,1,0/0,1,2,1/1,2,2,1/1,2,1,0/0,1,0,0") { |e| e.to_i })
  end
  
  # 
  # テトロミノ "T" を表すフィルタを返す。
  # 
  def self.T()
    return Filter.new("T", Cells.new("0,1,1,1,0/1,2,2,2,1/0,1,2,1,0/0,0,1,0,0") { |e| e.to_i })
  end
  
  # 
  # 各テトロミノフィルタ，およびそれを回形，逆転させて作られる
  # 全てのフィルタを返す。
  # 
  def self.filters()
    filters = []
    [Filter.I, Filter.L, Filter.O, Filter.S, Filter.T].each { |filter|
      filters << filter
      filters << filter.rotate
      filters << filter.rotate.rotate
      filters << filter.rotate.rotate.rotate
      filters << filter.invert
      filters << filter.invert.rotate
      filters << filter.invert.rotate.rotate
      filters << filter.invert.rotate.rotate.rotate
    }
    filters.uniq
  end
  
  # 
  # テトロミノフィルタを作成する。
  # 
  def initialize(name, cells)
    super(cells)
    @name = name
    
    # マッチするのに必要な穴の開いているマスの数を調べる。
    @hole_count = 0
    coords.each { |x, y|
      @hole_count += 1 if self[x, y] == 2
    }
    
    # マッチするのに最低限必要な穴の開いていないマスの数を調べる。
    @min_plain_count = Float::INFINITY
    [[0, 0], [0, 1], [1, 0], [1, 1]].each { |ox, oy|
      min_plain_count = 0
      coords(ox, oy, self.width - 1, self.height - 1).each { |x, y|
        min_plain_count += 1 if self[x, y] == 1
      }
      if min_plain_count < @min_plain_count
        @min_plain_count = min_plain_count
      end
    }
  end
  
  # 
  # テトロミノフィルタの賞を表す属性。
  # 
  attr_accessor :name
  
  # 
  # 時計回りに 90 度回転させたテトロミノフィルタを返す。
  # 
  def rotate()
    Filter.new(self.name, super)
  end
  
  # 
  # 左右逆転させたテトロミノフィルタを返す。
  # 
  def invert()
    Filter.new(self.name, super)
  end
  
  # 
  # これ以降の探索でフィルタにマッチする可能性がないかを調べる。
  # 可能性がなければ true，あれば false を返す。
  # 
  def truncated?(card)
    return card.plain_count < @min_plain_count
  end
  
  # 
  # カードの穴がテトロミノフィルタにマッチするか調べる。
  # マッチするのは独立したテトロミノの形をした穴のみである。
  # 大きな穴の一部がテトロミノの形をしていてもマッチしない。
  # 
  def match?(card)
    lpcX = card.last_punch_coord[0]
    lpcY = card.last_punch_coord[1]
    return false if card.hole_size(lpcX, lpcY) != @hole_count
    
    startX = [-1,                        lpcX - @width  + 1].max
    endX   = [card.width  - @width + 2,  lpcX           - 1].min
    startY = [-1,                        lpcY - @height + 1].max
    endY   = [card.height - @height + 2, lpcY           - 1].min
    startX.upto(endX) { |x|
      startY.upto(endY) { |y|
        catch (:DONE) {
          coords.each { |dx, dy|
            f = self[dx, dy]
            
            next        if f == 0
            throw :DONE if f == 1 && card.hole?(x + dx, y + dy)
            throw :DONE if f == 2 && card.plain?(x + dx, y + dy)
          }
          return true
        }
      }
    }
    return false
  end
  
  # 
  # 内容が等しいかを調べる。
  # 
  def ==(other)
    return eql?(other)
  end
  
  # 
  # 内容が等しいかを調べる。
  # 
  def eql?(other)
    return (self.name == other.name) && super(other)
  end
  
  # 
  # ハッシュ値を返す。
  # 
  def hash()
    return to_s.hash
  end
  
  # 
  # テトロミノフィルタの内容を文字列で返す。
  # 
  def to_s()
    return @name + ":" + super.to_s
  end
  
  # 
  # テトロミノフィルタの内容を人間が見やすい文字列で返す。
  # 
  def inspect()
    return @name + "\n" + super.inspect.gsub(/"/, "").gsub(/\\n/, "\n")
  end
end

main()
