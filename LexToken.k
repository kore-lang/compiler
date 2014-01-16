module Compiler
	class LexToken
		token as Token
		value as string
		line as CodeLine

		def new(lexToken as Token, lexValue as string)
			token = lexToken
			value = lexValue
			line = null
		end
		
		def new(lexToken as Token, lexValue as string, lexLine as CodeLine)
			token = lexToken
			value = lexValue
			line = lexLine

			if token == Token.Error then this.print
		end

		def print
			(value + " : " + token.string).print
		end
		
		def error(message as string)
			("Error in " + line.source.name + " at line " + line.number.string + " : " + message).print
		end
	end
end