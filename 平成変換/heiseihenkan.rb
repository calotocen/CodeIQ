# coding: windows-31j

# �g�����Fruby heiseihenkan.rb BEFORE AFTER
#           BEFORE ... �����l
#           AFTER  ... BEFORE �𕽐��ϊ��ŕϊ�������̒l
# �g�p��F> ruby heiseihenkan.rb 2014 26
#         step=13
#         2014->20[14]->201(9)6->201(36)->20[16]->(2025)6->4[5]6->4(256)->[41]6->16(81)6->(16)(9)6->(4)(36)->26

# �����ϊ�����]�����C���ʂ̓W�J���ʂ�Ԃ��B
# �����ϊ����� BNF �͎��̂Ƃ���ł���B
#     <expression> ::= (<number> | <square> | <square root>)+
#     <number> ::= ['1'-'9']+ ['0'-'9']*
#     <square> ::= '[' <number> ']'
#     <square root> ::= '(' <number> ')'
def convertUsingHeiseiConversion(expression)
	if !expression.is_a?(String)
		raise ArgumentError, "expression is not String"
	elsif expression.empty?
		raise ArgumentError "expression is empty"
	end
	
	work = expression
	result = ""
	until work.empty?
		case work
		when /^([1-9][0-9]*)(.*)/
			result << $1
		when /^\[([1-9][0-9]*)\](.*)/
			result << ($1.to_i ** 2).to_s
		when /^\(([1-9][0-9]*)\)(.*)/
			value = $1.to_i
			square_root_value_float = Math.sqrt(value)
			square_root_value_int = square_root_value_float.to_i
			if (square_root_value_int ** 2) != value
				raise RuntimeError, "square root is not integer: expression=\"" + expression + "\",cause=\"(" + $1 + ")\""
			end
			
			result << square_root_value_int.to_s
		else
			raise RuntimeError, "expression is wrong: expression=\"" + expression + "\",cause=\"" + work + "\""
		end
		
		work = $2
	end
	
	return result
end

# �z��̗v�f�𕽐��ϊ��̉��Z�q�ŏ�������ɘA�����C
# ���̌��ʂ� result �Ɋi�[����B
def decorate_expression(array, result, work = [])
	if array.empty?
		expression = ""
		work.each do |w|
			expression << w
		end
		result << expression
	else
		[["", ""], ["[", "]"], ["(", ")"]].each do |decoration|
			# �����̐擪�� '0' �ł��镽���ϊ����͕s���ł���B
			if array[0][0] == "0"
				break
			end
			
			work << decoration[0] + array[0] + decoration[1]
			decorate_expression(array[1 .. array.length], result, work)
			work.delete_at(-1)
			
			# "1" �� "[1]"�C"(1)" �͓����ł��邽�߁C���ɓ���Ȃ��Ă悢�B
			if array[0] == "1"
				break
			end
		end
	end
end

# �����ϊ����̌���z�� result �Ɋi�[����B
def get_candidate_expressions_internal(source, result, work = [])
	for i in 1 .. source.length - 1
		work << source[0, i]
		get_candidate_expressions_internal(source[i, source.length], result, work)
		work.delete_at(-1)
	end
	
	decorate_expression(work + [source], result)
end

# �����ϊ����̌���z��ŕԂ��B
# �{�֐����Ԃ��̂́Cvalue �����邱�Ƃ̂ł���S�Ă̕����ϊ����ł���B
# �������C"(1)"�C"[1]" �� "1" �Ɠ����ł��邽�߁C"(1)"�C"[1]" ���܂ޕ����ϊ����͕Ԃ��Ȃ��B
# �܂��C�������������ƂȂ�Ȃ� (�s����) �����ϊ�����Ԃ��ꍇ������B
def get_candidate_expressions(source)
	result = []
	get_candidate_expressions_internal(source, result)
	return result.uniq
end

# �����ϊ��̌��ɓ���邩��]������B
# ���ɓ����ꍇ�́C���̂悤�ɏ�������B
#     - candidates (�z��) �� new_record ��ǉ�����B
#     - records (�A�z�z��) �̃L�[ new_record[:value] �� new_record ��ǉ�����B
def evaluate(candidates, records, new_record)
	if new_record[:value].length <= 5
		candidates << new_record
		records[new_record[:value]] = new_record
	end
end

# before ���� after �ɕ����ϊ��ŕϊ�����菇��z��ŕԂ��B
def get_conversion_steps(before, after)
	records = {before => {:parent => nil, :value => before, :expression => before}}
	candidates = [records[before]]
	catch (:break) do
		until candidates.empty?
			candidate = candidates.shift
			candidate_expressoins = get_candidate_expressions(candidate[:value])
			candidate_expressoins.each do |expression|
				begin
					value = convertUsingHeiseiConversion(expression)
					
					unless records.has_key?(value)
						record = {:parent => candidate, :value => value, :expression => expression}
						evaluate(candidates, records, record)
					end
					
					if value == after
						throw :break
					end
				rescue
					# expression ���̕������������ʂ������ł͂Ȃ������ꍇ�ɗ�O����������B
					# �������Ȃ��B
				end
			end
		end
	end
	
	conversion_steps = [after]
	step = records[after]
	until step.nil? do
		conversion_steps.unshift(step[:expression])
		step = step[:parent]
	end
	
	return conversion_steps
end


before = ARGV[0]
after = ARGV[1]

if before.nil? || after.nil?
	puts("using: ruby heiseihenkan.rb BEFORE AFTER")
	Kernel.exit(0)
end

if before !~ /[0-9]+/ || after !~ /[0-9]+/
	puts("BEFORE and AFTER need to number")
	Kernel.exit(1)
end

conversion_step = get_conversion_steps(before, after)
if conversion_step.nil?
	print("conversion step was not found: before=" + before.to_s + ",after=" + after.to_s)
	Kernel.exit(2)
end

puts("step=" + conversion_step.length.to_s)
0.upto(conversion_step.length - 1) do |i|
	print(conversion_step[i] + ((i < conversion_step.length - 1) ? "->" : "\n"))
end
