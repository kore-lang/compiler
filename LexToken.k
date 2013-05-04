module Compiler
	class LexToken
		token as Token
		value as string

		def new(lexToken as Token, lexValue as string)
			token = lexToken
			value = lexValue

			if token == Token.Error then this.print
		end

		def print
			(value + " : " + token.string).print
		end
	end
end