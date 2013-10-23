# coding: windows-31j

# 使い方：ruby heiseihenkan.rb BEFORE AFTER
#           BEFORE ... 初期値
#           AFTER  ... BEFORE を平成変換で変換した後の値
# 使用例：> ruby heiseihenkan.rb 2014 26
#         step=13
#         2014->20[14]->201(9)6->201(36)->20[16]->(2025)6->4[5]6->4(256)->[41]6->16(81)6->(16)(9)6->(4)(36)->26

# 平成変換式を評価し，括弧の展開結果を返す。
# 平成変換式の BNF は次のとおりである。
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

# 配列の要素を平成変換の演算子で飾った後に連結し，
# その結果を result に格納する。
def decorate_expression(array, result, work = [])
	if array.empty?
		expression = ""
		work.each do |w|
			expression << w
		end
		result << expression
	else
		[["", ""], ["[", "]"], ["(", ")"]].each do |decoration|
			# 数字の先頭が '0' である平成変換式は不正である。
			if array[0][0] == "0"
				break
			end
			
			work << decoration[0] + array[0] + decoration[1]
			decorate_expression(array[1 .. array.length], result, work)
			work.delete_at(-1)
			
			# "1" と "[1]"，"(1)" は等価であるため，候補に入れなくてよい。
			if array[0] == "1"
				break
			end
		end
	end
end

# 平成変換式の候補を配列 result に格納する。
def get_candidate_expressions_internal(source, result, work = [])
	for i in 1 .. source.length - 1
		work << source[0, i]
		get_candidate_expressions_internal(source[i, source.length], result, work)
		work.delete_at(-1)
	end
	
	decorate_expression(work + [source], result)
end

# 平成変換式の候補を配列で返す。
# 本関数が返すのは，value から作ることのできる全ての平成変換式である。
# ただし，"(1)"，"[1]" は "1" と等価であるため，"(1)"，"[1]" を含む平成変換式は返さない。
# また，平方根が整数とならない (不正な) 平成変換式を返す場合がある。
def get_candidate_expressions(source)
	result = []
	get_candidate_expressions_internal(source, result)
	return result.uniq
end

# 平成変換の候補に入れるかを評価する。
# 候補に入れる場合は，次のように処理する。
#     - candidates (配列) に new_record を追加する。
#     - records (連想配列) のキー new_record[:value] に new_record を追加する。
def evaluate(candidates, records, new_record)
	if new_record[:value].length <= 5
		candidates << new_record
		records[new_record[:value]] = new_record
	end
end

# before から after に平成変換で変換する手順を配列で返す。
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
					# expression 中の平方根した結果が整数ではなかった場合に例外が発生する。
					# 何もしない。
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
