using Kore

module Compiler
	def main
		code = string(2000)

		file = File.new("test.jbc", FileMode.Read)

		i = 0

		while file.eof == 0
			code(i) = file.readString
			//code(i).print

			i++
		end

		program = Program.new

		lexer = Lexer.new(code, i - 1)
		lexer.lex

		parser = Parser.new(lexer)
		parser.parse(program)
	end
end