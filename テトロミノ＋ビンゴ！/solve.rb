#!ruby -EWindows-31J
# coding: Windows-31J

# 
# = �e�g���~�m�{�r���S�̏܏W�v�v���O����
# Authors:: calotocen
# 
# == �g����
#   Usage: solve [options]
#       -b                               output benchmark
#       -f PATH                          data file path
# 
# == �g�p��
#   > ruby solve.rb -b -f data.txt
#   I:222,L:1111,O:333,S:666,T:777
#         user     system      total        real
#    20.843000   0.032000  20.875000 ( 21.000000)
#   
#   >
# 
# == �������̍H�v
# ���s���Ԃ�Z�����邽�߂ɁC���̂悤�ɍH�v�����B
# - ���̑傫�����L�����C���̑傫�����e�g���~�m�̐� (4 ��) �ƈقȂ�ꍇ�́C
#   �e�g���~�m�̔��菈�����s��Ȃ��悤�ɂ����B
# - ���̊J���Ă��Ȃ��}�X�̐�����萔�����ł���ꍇ�͐�΂Ƀe�g���~�m���ł��Ȃ����߁C
#   ���̏ꍇ�ɉ�T����ł��؂�悤�ɂ���
#   (�T����ł��؂�ׂ����̊J���Ă��Ȃ��}�X�̐��́C�e�g���~�m�̌`�ɂ���ĈقȂ�)�B
# - �����J���������ɂ̂݁C�e�g���~�m�̔��菈�����s���悤�ɂ���
#   (�����C�J�[�h�̃T�C�Y�ƃe�g���~�m�̃T�C�Y���������炢�̂��߁C
#   �傫�Ȍ��ʂ͓����Ȃ�)�B
# 

require 'benchmark'
require 'optparse'

# 
# �{�v���O�����̃o�[�W����
# 
Version = "1.0"

# 
# �f�[�^�t�@�C����ǂݍ��݁C�e�g���~�m�{�r���S�̏܂��W�v����B
# �W�v���ʂ́uI:nI,L:nL,O:nO,S:nS,T:nT�v(nX �́C���l) �̌`���ŕW���o�͂֏����o���B
# �f�[�^�t�@�C���̃t�H�[�}�b�g�́C���̂Ƃ���Ƃ���B
# - �P�s�ځF
#   �ǂݏグ�鐔���R���}��؂�Ŏw�肷��
#   (��F1,2,3,4,5)
# - �Q�s�ڈȍ~�F
#   �r���S�J�[�h�̓��e���C����X���b�V����؂�C�s���R���}��؂�Ŏw�肷��
#   (��F1,2,3,4,5/6,7,8,9,10/11,12,13,14,15/16,17,18,19,20)
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
  
  # �f�[�^�t�@�C�����J���B
  # �f�[�^�t�@�C�����w�肳��Ă��Ȃ��ꍇ�́C�W�����͂��g�p����B
  data_file = STDIN
  unless data_file_path.nil? || data_file_path == "-"
    begin
      data_file = File::open(data_file_path)
    rescue SystemCallError => e
      puts "error: " + e.message
      exit(2)
    end
  end
  
  # �ǂݏグ�鐔��ǂݍ��ށB
  numbers = data_file.readline.chomp.split(",").map! { |e| e.to_i }
  
  # �r���S�J�[�h��ǂݍ��ށB
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
  
  # �e�g���~�m�̃t�B���^�[���쐬����B
  filters = Filter.filters
  
  # �J�[�h�����Ԃɒ��ׁC�܂���肵�ďo�͂���B
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
# numbers �Ɏw�肳�ꂽ����ǂݏグ���Ƃ���
# filter �Ɏw�肵���e�g���~�m�� card �Ɏw�肵���r���S�J�[�h�ɂł��邩���ׂ�B
# �e�g���~�m���ł���ꍇ�́Cfilter �ɑΉ�����܂̖��O��Ԃ��B
# �e�g���~�m���ł��Ȃ��ꍇ�́Cnil ��Ԃ��B
#
def solve(numbers, card, filters)
  # �J�[�h�̒��g��ύX����̂ŁCdup ����B
  card  = card.dup
  
  # �e�g���~�m���ł��邩�𒲂ׂ�B
  # �ł���ꍇ�́Cprize �ɏ܂̖��O��ݒ肵�ď������I������B
  prize = nil
  catch (:DONE) {
    numbers.each { |n|
      # �J�[�h�Ɍ����J����B
      # �J�[�h�Ɍ����J�����ꍇ�̂݁C�t�B���^�Ƀ}�b�`���邩�𒲂ׂ�B
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
# �c�C���ɐL�т�񎟌��̃Z���W����\���N���X�B
# 
class Cells
  # 
  # Cells ���쐬����B
  # cells �ɂ́C�Z���̓��e�� Cells ���g�C�z��C������̂����ꂩ�Ŏw�肷��B
  # outside_value �ɂ́C�̈�O�ɃA�N�Z�X���ꂽ�Ƃ��ɕԂ��l���w�肷��B
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
    
    # ��L�R�����Ɉ�v���Ȃ������ꍇ�C
    # ������ nil:NilClass �� NoMethodError ����������B
    @width         = @cells[0].size
    @height        = @cells.size
    @outside_value = outside_value
  end
  
  # 
  # �������ɕ���ł���Z���̐�
  # 
  attr_reader :width
  
  # 
  # �c�����ɕ���ł���Z���̐�
  # 
  attr_reader :height
  
  # 
  # x, y �Ŏw�肵���Z�����W���̈�����𒲂ׂ�B
  # �̈���ł���ꍇ�� true�C�̈�O�ł���ꍇ�� false ��Ԃ��B
  # 
  def inside?(x, y)
    return 0 <= x && x < @width && 0 <= y && y < @height
  end
  
  # 
  # x, y �Ŏw�肵���Z�����W����C(x + width)�C(x + height) �܂ł̍��W��Ԃ��B
  # �������ȗ������ꍇ�Cx �� y �ɂ� 0�C
  # width �� height �ɂ� Cells �� width �� height ���w�肳�ꂽ���̂Ƃ݂Ȃ��B
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
  # x, y �Ŏw�肵���Z���̒l��Ԃ��B
  # 
  def [](x, y)
    return @cells[y][x] if inside?(x, y)
    return @outside_value
  end
  
  # 
  # x, y �Ŏw�肵���Z���̒l�� value �ɐݒ肷��B
  # 
  def []=(x, y, value)
    @cells[y][x] = value if inside?(x, y)
    return self
  end
  
  # 
  # ���v���� 90 �x��]������ Cells ��Ԃ��B
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
  # ���E�t�]������ Cells ��Ԃ��B
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
  # ���e (�������̃Z���̐��C�c�����̃Z���̐��C����ъe�Z���̒l) �����������𒲂ׂ�B
  # ���e���������ꍇ�� true�C�قȂ�ꍇ�� false ��Ԃ��B
  # 
  def ==(other)
    return eql?(other)
  end
  
  # 
  # ���e (���C�����C����ъe�Z���̒l) �����������𒲂ׂ�B
  # ���e���������ꍇ�� true�C�قȂ�ꍇ�� false ��Ԃ��B
  # 
  def eql?(other)
    return hash == other.hash
  end
  
  # 
  # �n�b�V���l��Ԃ��B
  # 
  def hash()
    return to_s.hash
  end
  
  # 
  # �Z���̓��e�𕶎���ŕԂ��B
  # 
  def to_s()
    return @cells.to_s
  end
  
  # 
  # �Z���̓��e��l�Ԃ����₷��������ŕԂ��B
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
# �r���S�J�[�h��\���N���X�B
# 
class Card < Cells
  # 
  # �r���S�J�[�h���쐬����B
  # cells �ɂ� Cells�C�܂��� Cells ��\���z�񂩕�������C
  # hole_value �ɂ͌���\���l�Coutside_value �ɂ͗̈�O�̒l���w�肷��B
  # �܂��C�w�肷��l�͎��̏����𖞂����K�v������B
  # - cells ���ɓ����l���Q�ȏ゠���Ă͂Ȃ�Ȃ��B
  # - cells �̊e�l�Chole_value�C����� outside_value �́C
  #   �݂��ɑf�Ȓl�łȂ���΂Ȃ�Ȃ��B
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
  # �����J�����}�X�̐���\������
  # 
  attr_reader :hole_count
  
  # 
  # �����J���Ă��Ȃ��}�X�̐���\������
  # 
  attr_reader :plain_count
  
  # 
  # �Ō�Ɍ����J�����ʒu�� [x, y] �`���ŕ\�������B
  # ��������J���Ă��Ȃ��ꍇ�C���̑����̒l�� nil �ł���B
  # 
  attr_reader :last_punch_coord
  
  # 
  # x, y �Ŏw�肵���}�X�ɂ��錊�̑傫����Ԃ��B
  # 
  def hole_size(x, y)
    return @hole_sizes[x, y][1]
  end
  
  # 
  # x, y �Ŏw�肵���}�X�Ɍ����J���Ă��邩�𒲂ׂ�B
  # �����J���Ă���ꍇ true ���C�J���Ă��Ȃ��ꍇ false ��Ԃ��B
  # 
  def hole?(x, y)
    return self[x, y] == @hole_value
  end
  
  # 
  # x, y �Ŏw�肵���}�X�Ɍ����J���Ă��Ȃ����𒲂ׂ�B
  # �����J���Ă��Ȃ��ꍇ true ���C�J���Ă���ꍇ false ��Ԃ��B
  # 
  def plain?(x, y)
    return self[x, y] != @hole_value
  end
  
  # 
  # ���e�� value �ł���}�X�Ɍ����J����B
  # 
  def punch(value)
    result = false
    coords.each { |x, y|
      if self[x, y] == value
        # ���e�� value �ł���}�X���������̂ŁC�����J����B
        result             = true
        self[x, y]         = 0
        @plain_count      -= 1
        @hole_count       += 1
        @last_punch_coord  = [x, y]
        
        # �����J�����}�X�̌��̃T�C�Y���X�V����B
        # ���̃T�C�Y�� @hole_sizes �ɕێ����Ă���C
        # ���̃f�[�^�\���� [[x, y], size] �ł��� (x, y �͍��W�Csize �͌��̃T�C�Y)�B
        # [x, y] �́C�L�[�Ƃ��ďd���`�F�b�N�Ɏg�p����B
        # 
        # ��{�I�ɂ́C�����J�����}�X�̏㉺���E�ɂ���}�X���ێ����Ă���
        # ���̃T�C�Y�𑫂����ƂŁC���̃}�X�̌��̃T�C�Y�����߂�B
        # �������C'L' ���^�̌���
        # 
        #   ��P�F+----------+
        #         |01��030405|
        #         |06������10|
        #         |11��131415|
        #         |16����1920|
        #         |����232415|
        #         +----------+
        #         ���̈ʒu�Ɍ����J�����ꍇ�C���̃T�C�Y�͏㉺���E�ɂ���
        #         ���̃T�C�Y�Ɏ����̕��𑫂��� 9 �ɂȂ�B
        #   
        #   ��Q�F+----------+
        #         |0102030405|
        #         |0607080910|
        #         |11����1415|
        #         |16����1920|
        #         |2122232415|
        #         +----------+
        #         �P���Ɂ��̏㉺���E�̌��̃T�C�Y�𑫂��� 6 �ɂȂ�B
        #         ���̂悤�ȏd��������邽�ߌ��̃T�C�Y�ɃL�[���������C
        #         �����L�[�������̃T�C�Y�͑����Ȃ��悤�ɂ���B
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
  # �V���Ȍ��̃T�C�Y���㉺���E�̃}�X�ɓ`�d���C���̃T�C�Y���X�V����B
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
# �e�g���~�m�t�B���^��\���N���X�B
# 
class Filter < Cells
  # 
  # �e�g���~�m "I" ��\���t�B���^��Ԃ��B
  # 
  def self.I()
    return Filter.new("I", Cells.new("0,1,0/1,2,1/1,2,1/1,2,1/1,2,1/0,1,0") { |e| e.to_i })
  end
  
  # 
  # �e�g���~�m "L" ��\���t�B���^��Ԃ��B
  # 
  def self.L()
    return Filter.new("L", Cells.new("0,1,0,0/1,2,1,0/1,2,1,0/1,2,2,1/0,1,1,0") { |e| e.to_i })
  end
  
  # 
  # �e�g���~�m "O" ��\���t�B���^��Ԃ��B
  # 
  def self.O()
    return Filter.new("O", Cells.new("0,1,1,0/1,2,2,1/1,2,2,1/0,1,1,0") { |e| e.to_i })
  end
  
  # 
  # �e�g���~�m "S" ��\���t�B���^��Ԃ��B
  # 
  def self.S()
    return Filter.new("S", Cells.new("0,0,1,0/0,1,2,1/1,2,2,1/1,2,1,0/0,1,0,0") { |e| e.to_i })
  end
  
  # 
  # �e�g���~�m "T" ��\���t�B���^��Ԃ��B
  # 
  def self.T()
    return Filter.new("T", Cells.new("0,1,1,1,0/1,2,2,2,1/0,1,2,1,0/0,0,1,0,0") { |e| e.to_i })
  end
  
  # 
  # �e�e�g���~�m�t�B���^�C����т������`�C�t�]�����č����
  # �S�Ẵt�B���^��Ԃ��B
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
  # �e�g���~�m�t�B���^���쐬����B
  # 
  def initialize(name, cells)
    super(cells)
    @name = name
    
    # �}�b�`����̂ɕK�v�Ȍ��̊J���Ă���}�X�̐��𒲂ׂ�B
    @hole_count = 0
    coords.each { |x, y|
      @hole_count += 1 if self[x, y] == 2
    }
    
    # �}�b�`����̂ɍŒ���K�v�Ȍ��̊J���Ă��Ȃ��}�X�̐��𒲂ׂ�B
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
  # �e�g���~�m�t�B���^�̏܂�\�������B
  # 
  attr_accessor :name
  
  # 
  # ���v���� 90 �x��]�������e�g���~�m�t�B���^��Ԃ��B
  # 
  def rotate()
    Filter.new(self.name, super)
  end
  
  # 
  # ���E�t�]�������e�g���~�m�t�B���^��Ԃ��B
  # 
  def invert()
    Filter.new(self.name, super)
  end
  
  # 
  # ����ȍ~�̒T���Ńt�B���^�Ƀ}�b�`����\�����Ȃ����𒲂ׂ�B
  # �\�����Ȃ���� true�C����� false ��Ԃ��B
  # 
  def truncated?(card)
    return card.plain_count < @min_plain_count
  end
  
  # 
  # �J�[�h�̌����e�g���~�m�t�B���^�Ƀ}�b�`���邩���ׂ�B
  # �}�b�`����͓̂Ɨ������e�g���~�m�̌`���������݂̂ł���B
  # �傫�Ȍ��̈ꕔ���e�g���~�m�̌`�����Ă��Ă��}�b�`���Ȃ��B
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
  # ���e�����������𒲂ׂ�B
  # 
  def ==(other)
    return eql?(other)
  end
  
  # 
  # ���e�����������𒲂ׂ�B
  # 
  def eql?(other)
    return (self.name == other.name) && super(other)
  end
  
  # 
  # �n�b�V���l��Ԃ��B
  # 
  def hash()
    return to_s.hash
  end
  
  # 
  # �e�g���~�m�t�B���^�̓��e�𕶎���ŕԂ��B
  # 
  def to_s()
    return @name + ":" + super.to_s
  end
  
  # 
  # �e�g���~�m�t�B���^�̓��e��l�Ԃ����₷��������ŕԂ��B
  # 
  def inspect()
    return @name + "\n" + super.inspect.gsub(/"/, "").gsub(/\\n/, "\n")
  end
end

main()
