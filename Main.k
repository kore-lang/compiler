using Kore

module Compiler
	def main
		code = CodeLine(2000)

		i = 0
		count = 0
		
		files = Directory.files("k")
		while not files(i).isNull
			("Loading source " + files(i)).print
		
			j = 0
				
			file = File.new(files(i), FileMode.Read)
			
			source = Source.new(files(i))
			
			while not file.eof			
				j++
				code(count + j - 1) = CodeLine.new(source, file.readString, j)	
			end
					
			count = count + j
			i++
		end
		
		Console.next
		
		("Analyzing " + count.string + " lines").print
		
		Console.next
				
		program = Program.new

		lexer = Lexer.new(code, count)
		lexer.lex

		parser = Parser.new(lexer)
		parser.parse(program)
	end
end