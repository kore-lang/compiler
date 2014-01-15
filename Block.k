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
		
		pointer as int
		
		assembly as Assembly

		def new
			id = 0
			stack = 0
		
			tokens = LexToken(2000)
			tokenCount = 0

			depthes = Depth(100)
			depthCount = 0

			variable = Variable(100)
			variableCount = 0
			
			pointer = 0
		end

		def addToken(token as LexToken)
			tokens(tokenCount) = token
			tokenCount++
		end
		
		def write(line as string)
			assembly.write(line)
		end
		
		def encode
			while pointer + 1 < tokenCount
				expression
			end
		end
		
		def expression
			pointer = tokenCount
		end
	end
end