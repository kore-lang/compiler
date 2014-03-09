module Compiler
	class Depth
		type as Token
		pointer as int
		
		assembly as Assembly
		
		def new(token as Token, value as int)
			type = token
			pointer = value
			
			assembly = Assembly.new
		end
	end
end