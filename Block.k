module Compiler
	class Block
		id as int
		stack as int

		tokens as LexToken()
		tokenCount as int
		
		depthes as Depth()
		depthCount as int

		variables as Variable()
		variableCount as int

		def new
			tokens = LexToken(1000)
			tokenCount = 0

			depthes = Depth(100)
			depthCount = 0

			variable = Variable(100)
			variableCount = 0
		end

		def addToken(token as LexToken)
			tokens(tokenCount) = token
			tokenCount++
		end
	end
end