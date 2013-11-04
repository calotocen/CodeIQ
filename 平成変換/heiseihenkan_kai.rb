#!ruby -EWindows-31J
# coding: Windows-31J

#
# = �����ϊ�(�������x�����)
#
# Authors:: calotocen(�J�g�[)
#
# == �g����
#     heiseihenkan_kai [options] BEFORE AFTER
#     BEFORE     �ϊ��O�̒l
#     AFTER      �ϊ���̒l
#     -b         �x���`�}�[�N��\������B
#     -e N       N �X�e�b�v�̉���������܂ŁC�T���𑱂���B
#     -l SIZE    �T���ΏۂƂ��鍀�̍ő啶���񒷂��w�肷�� (�f�t�H���g�F9 ����)�B
#
# == �g�p��
#     > ruby heiseihenkan_kai.rb -b 2014 26
#           user     system      total        real
#       3.359000   0.015000   3.374000 (  3.468750)
#     2014->[2]0[14]->[4019]6->1[6]152(361)6->136(1521)(9)6->1(36)[3](9)(36)->(16)(9)(36)->(4)(36)->26
#     7 steps
# 
# == �����o�[�W����(heiseihenkan.rb)����̕ύX�_
# 1. �ϊ��O�̒l�ƕϊ���̒l�̗�������T������悤�ɂ��C��T�����Ԃ̒Z�k��}�����B
# 2. ������؂� (String#stable_permutation) �̏�������������l���C�������x���ᖡ�����B
#    �ڍׂ́Ccreate_subvalues_list_benchmark.rb �ɋL�ڂ��Ă���B
# 3. ������ (ExpressionFactory#expressions) �̏�������������l���C�������x���ᖡ�����B
#    �ڍׂ́Ccreate_expressions.rb �ɋL�ڂ��Ă���B
# 4. �������̌��ʂ������łȂ��ꍇ�̒T���ł��؂蔻����ŏ�ʊ֐� (solve ��) ����C
#    �������� (ExpressionFactory#expressions_internal ��) �ɕύX���邱�Ƃŕs�v�Ȏ����������炵�C
#    ���������Ԃ̒Z�k��}���� (���������Ԃ� 60% �قǍ팸)�B
# 5. �ő啶���񒷂̑ł��؂蔻����ŏ�ʊ֐� (solve ��) ����C
#    �������� (ExpressionFactory#expressions_internal ��) �ɕύX���邱�Ƃŕs�v�Ȏ����������炵�C
#    ���������Ԃ̒Z�k��}���� (���������Ԃ� 10% �قǍ팸)�B
# 6. ���̕\�����ŏI�`�� ("[2]0(14)" �Ȃ�) ����
#    ���Ԍ`�� (["2", 1], ["0", 0], ["14", -1] �Ȃ�) �ɂ��邱�ƂŁC
#    ���������Ԃ̒Z�k��}���� (���������Ԃ� 5% �قǍ팸)�B
# 7. �d������������������Ȃ��悤�ɂ��邱�Ƃŕs�v�Ȏ��ύX�����炵�C
#    ���������Ԃ̒Z�k��}���� (���������Ԃ� 5% �قǍ팸)�B
#    (�C���O�́C�Ⴆ�� ["2", "0", "14"] �� ["20", "14"] �̗������� "20(14)" �Ȃǂ��������ꂽ)�B
# 8. ���ʂ̒��オ "0" �ƂȂ鎮�𐶐�����悤�Ɏ������������C������ (�o�O�C��)�B
#    (�C���O�́C"2014" ���� "[2]014" �̂悤�Ȏ��𐶐��ł��Ȃ�����)�B
# 9. �R�}���h���C�������Ńx���`�}�[�N�\���L���Ȃǂ��w��ł���悤�ɂ����B
# 10. �\�[�X�R�[�h�S�̂����t�@�N�^�����O�����B
# 
# == �������x�̌���ɂ���
# ��T�������̑啔���͎����������ŁC���̏����Ɉ�Ԏ��Ԃ��g���B
# ����āC�������鎮�̐�ΐ������Ȃ����� (��L�ύX�_ (1)) ���ƂƁC
# �����������𑁂����� (��L�ύX�_ (2) �` (7)) ���������̌��ł��� (�Ǝv��)�B
# �Q�l�܂łɖ{�v���O�����̎��s���v���t�@�C�������Ɏ����B
# (BEFORE=2014, AFTER=26 �͎��Ԃ�������̂ŁCBEFORE=62196, AFTER=6 ��p����)�B
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
#     �� 1 �` 4 �ʂ� 6 �ʂ��������p�֐��ł��� (���ɂ�����炵�����̂����邪�C
#        �ǂ̏����Ŏg���Ă���̂��͔��f�s�\�ł���)�B
#        ������͈͂ł��������������S�̂� 57.59% ���߂Ă���B
# 
# == ����̓W�]�ɂ���
# �{�v���O�����ŒT�����������ŒZ�X�e�b�v�ł͂Ȃ��ꍇ������B
# �Ⴆ�΁C`ruby heiseihenkan_kai.rb -l 8 2014 26` �œ�������� 8 �X�e�b�v�ł���
# (�ŒZ���͂V�X�e�b�v)�B
# ���̖��́C�ϊ��O�ƕϊ���̗�������T�����Ă��āC
# �Ȃ����C�e�X�e�b�v���Ō�܂ŒT�����Ȃ����߂ɔ�������B
# ���D��T�����s���Ă��邽�߁C�ʏ�͍ŒZ���������邪�C
# �o�����T���ł͈ȉ��̂悤�ȏ󋵂ōŒZ���ȊO�̉���������B
#     �ϊ��O�̒l����̒T��   �ϊ���̒l����̒T��
#                +---           ---+
#     1 �ï�߂̉�|                 |1 �ï�߂̉�
#                +---           ---+
#                +---           ---+
#     2 �ï�߂̉�|                 |2 �ï�߂̉�
#                |   <---(2)-+     |
#                +---        |  ---+
#                +---        |  ---+
#     3 �ï�߂̉�|   <---(1)-o->   |3 �ï�߂̉�
#                |           |  
#                |           +->
#                +---           
#     �� �}�� (1) �̎��_�ŉ� (6 �X�e�b�v) �����������̂ŒT����ł��؂邪�C
#        (2) �̂悤�ȉ� (5 �X�e�b�v) �𓾂���\���͂���B
# 
# ��L�̖����������邽�߂ɂ́C�T���ɃX�e�b�v�̊T�O�𓱓����C
# �X�e�b�v��S�ĒT������悤�ɂ���΂悢�B
# (�{�v���O�����͒T�����x��D�悵�I�v�V���� -e �����ɗ��߂����C
# �{���̎�|���猾���΁C���߂������K���ŒZ���̕����悢�B
# �Ȃ��C-e �I�v�V�������g���ꍇ�C��̗Ⴞ��
# `ruby heiseihenkan_kai.rb -l 8 -e 7 2014 26` �ōŒZ�������߂���)�B
#


require 'benchmark'
require 'optparse'

#
# �g������ String �N���X
#
class String
  #
  # ������ێ�����������̏���𐶐����邽�߂̍ċA�p�֐��ł���B
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
  # ������ێ�����������̏���𐶐�����B�����鏇��̏����͕s��ł���B
  # - �u���b�N���w�肳�ꂽ�ꍇ�C������������̊e�l�������Ƃ��ău���b�N�����s����B
  #   ���̏ꍇ�C�߂�l�Ƃ��Ď������g��Ԃ��B
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
  # - �u���b�N���w�肳��Ȃ������ꍇ�C����𐶐����� Enumerator �I�u�W�F�N�g��Ԃ��B
  #     e = "12".stable_permutation()
  #     e.each { |strs| p strs }
  #     ->["1", "2"]
  #       ["12"]
  #
  def stable_permutation(&block) # :yield: strs
    return to_enum :stable_permutation unless block_given?
    
    unless self.empty?
      # �S�Ă̕����񕪉����ċA�p�N���X�ōs���ƁC
      # �ċA�̓s����C�������̕����񂪕������������B
      # �����h�����߁C�ŏ��̕����͍ċA�֐��̌Ăяo�����ōs���B
      (1 ... self.size).each { |i|
        stable_permutation_internal(self[i ... self.size], [self[0, i]], block)
      }
      
      # ��L�̏����ł͖������̕����񂪐�������Ȃ����߁C
      # �����Ŗ������̕��������������B
      block.call([self])
    end
    
    return self
  end
end

#
# �����ϊ�����\���N���X
#
class Expression
  #
  # �������Ȃ����Ƃ�\�� ID
  #
  NOP_TERM_ID = 0
  
  #
  # �Q��ł̕ϊ���\�� ID
  #
  SQUARE_TERM_ID = 1
  
  #
  # �Q�捪�ł̕ϊ���\�� ID
  #
  ROOT_TERM_ID   = -1
  
  #
  # ���̕]������(String)
  #
  attr_reader :result
  
  #
  # �����ϊ����𐶐�����B
  # - ��̕����ϊ����𐶐�����B
  #     Expression.new()
  # - ���� 1 �������ϊ����𐶐����� (�㋉�Ҍ���)�B
  #   terms �ɂ́C�����\�����鍀�̔z����w�肷��B
  #   ���̌`���́C[�ϊ��O�̒l, �ϊ����@, �ϊ���̒l] �ł���B
  #   results �ɂ́C�e���̕ϊ���̒l��A�������l���w�肷��B
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
  # �ϊ��O�̒l��Ԃ��B
  #   p Expression.new().push_nop_term("3").push_root_term("121").value
  #   ->"3121"
  def value()
    value = ""
    @terms.each { |term| value << term[0] }
    return value
  end
  
  #
  # ���̖����ɍ���ǉ�����B
  #   p Expression.new().push_nop_term("3").to_s()
  #   ->"3"
  def push_nop_term(value)
    @terms  << [value, NOP_TERM_ID, value]
    @result << value
    return self
  end
  
  #
  # ���̖����ɂQ�捀��ǉ�����B
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
  # ���̖����ɂQ�捪����ǉ�����B
  # - �Q�捪�̌��ʂ������ł���ꍇ�́C����ǉ�����B
  #     p Expression.new().push_root_term("121").to_s()
  #     ->"(121)"
  # - �Q�捪�̌��ʂ������łȂ��ꍇ�́Cnil ��Ԃ��B
  #     p Expression.new().push_root_term("120")
  #     ->nil
  #
  def push_root_term(value)
    root_value_f = Math.sqrt(value.to_i())
    root_value_i = root_value_f.to_i()
    if root_value_i != root_value_f
      # �������������łȂ��B
      return nil
    end
    root_value = root_value_i.to_s()
    
    @terms  << [value, ROOT_TERM_ID, root_value]
    @result << root_value
    return self
  end
  
  #
  # ���̖����ɂ��鍀���폜������C�폜��������Ԃ��B
  # ���̌`���ɂ��ẮCExpression::new ���Q�Ƃ̂��ƁB
  #   p Expression.new().push_root_term("121").pop_term()
  #   ->["121", -1, "11"]
  #
  def pop_term()
    @result = @result[0, @result.size - @terms[-1][2].size]
    return @terms.pop()
  end
  
  #
  # �����t�]����B
  # �߂�l�́C�ϊ���̒l��ϊ��O�̒l�ɖ߂����ł���B
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
  # ���� clone ����B
  #
  def clone()
    return self.class.send(:new, @terms.clone(), @result.clone())
  end
  
  #
  # ���� dup ����B
  #
  def dup()
    return self.class.send(:new, @terms.dup(), @result.dup())
  end
  
  #
  # ������`���̎���Ԃ��B
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
  # ������`���̎���Ԃ��B
  # �߂�l�́Cto_s() �Ɠ����ł���B
  #
  def inspect()
    return to_s()
  end
end

#
# �����ϊ����𐶐�����N���X
#
class ExpressionFactory
  include Enumerable
  
  #
  # �����ϊ��������I�u�W�F�N�g�𐶐�����B
  # limit ���w�肵���ꍇ�́C
  # ���̕]�����ʂ̕����񒷂� limit �ȉ��ƂȂ鎮�̂ݐ�������B
  #
  def initialize(limit = Float::INFINITY)
    @limit = limit
  end
  
  #
  # �����ϊ���������𐶐����邽�߂̍ċA�p�֐��ł���B
  #
  def expressions_internal(subvalues, expression, expression_results, block)
    # ���̕]�����ʂ� limit �𒴂��Ă���ꍇ�́C�ȍ~�̏������~�߂�B
    return if expression.result.size > @limit
    
    if subvalues.size > 0
      head = subvalues[0]
      tail = subvalues[1 ... subvalues.size]
      
      if head[0] != '0' && head != "1"
        # �擪�� 0 �ł���l�Ɋ��ʂ�t����̂́C�����ϊ����̋K��ᔽ�ł���B
        # �܂��C1 ���Q��C�܂��͂Q�捪���Ă� 1 �ł���̂ŁC�K���d������������B
        # ����āC��L�Q�ɊY�����Ȃ��ꍇ�̂݁C�Q��C�Q�捪�̍����쐬����B
        
        # �Q�捪�̍���ǉ�����B
        # �Q�捪�̌��ʂ������ł������ꍇ�̂݁C���ɍ���ǉ��ł���B
        r = expression.push_root_term(head)
        unless r.nil?
          expressions_internal(tail, expression, expression_results, block)
          expression.pop_term()
        end
        
        # �Q��̍���ǉ�����B
        expression.push_square_term(head)
        expressions_internal(tail, expression, expression_results, block)
        expression.pop_term()
      end
      
      # ����ǉ�����B
      expression.push_nop_term(head)
      expressions_internal(tail, expression, expression_results, block)
      expression.pop_term()
    else
      # ���̕]�����ʂ��d�����Ă��Ȃ��ꍇ�̂݁C�u���b�N�����s����B
      unless expression_results.has_key?(expression.result)
        block.call(expression.dup())
        expression_results[expression.result] = true
      end
    end
  end
  private :expressions_internal
  
  #
  # value �����ɕ����ϊ����𐶐�����B
  # �{�֐��Ő�������鎮�̕]�����ʂ́C�d�����Ȃ�
  # (�Ⴆ�΁C"2014" ���������ꂽ��� "20(1)4" �Ȃǂ͐�������Ȃ�)�B
  # - �u���b�N���w�肳�ꂽ�ꍇ�C�������������ϊ����������Ƃ��ău���b�N�����s����B
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
  # - �u���b�N���w�肳��Ȃ������ꍇ�C�����ϊ����𐶐����� Enumerator �I�u�W�F�N�g��Ԃ��B
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
# �T���̏���ێ�����N���X
#
class Context
  #
  # before �ɕϊ��O�̒l�Cafter �ɕϊ���̒l���w�肵�āC
  # �R���e�L�X�g�𐶐�����B
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
  # �R���e�L�X�g�ɒT���Ō���������o�^����B
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
  # ���ɒT�����ׂ��l��Ԃ��B
  #
  def next_value()
    return @self_nexts.shift()
  end
  
  #
  # ���������T���ł���悤�ɂ���B
  # ���̊֐������s����ƁCfound?() �̌��ʂ� false �ɖ߂�B
  #
  def continue()
    @found = false
    return self
  end
  
  #
  # �����������ꍇ�� true ���C����ȊO�̏ꍇ�� false �Ԃ��B
  #
  def found?()
    return @found
  end
  
  #
  # �T�����I������ (�����������C�܂��͑S�Ă̒l��T������) �ꍇ�� true ���C
  # ����ȊO�̏ꍇ�� false ��Ԃ��B
  #
  def completed?()
    return @found || (@self_nexts.empty?() && @peer_nexts.empty?())
  end
  
  #
  # �T���̕�����ς���B
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
  # �ϊ����@��Ԃ��B
  # ���������Ă���ꍇ�́C�l(String)�C�܂��͎�(Expression)��
  # �\�������z���Ԃ��B
  # ���������Ă��Ȃ��ꍇ�́C��z���Ԃ��B
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
# �����ϊ��̉���T���B
# �������������ꍇ�� true ���C����ȊO�̏ꍇ�� false ��Ԃ��B
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
