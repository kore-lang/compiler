using Kore

module Compiler
	def main
		code = string(2000)

		i = 0
		count = 0;
		
		files = Directory.files("k")
		while files(i)
			("Loading source " + files(i)).print
		
			j = 0
				
			file = File.new(files(i), FileMode.Read)
			
			while file.eof == 0
				code(j) = file.readString
				//code(i).print

				j++
			end
			
			count = count + j
			
			i++
		end		
		
		program = Program.new

		lexer = Lexer.new(code, count - 1)
		lexer.lex

		parser = Parser.new(lexer)
		parser.parse(program)
	end
end