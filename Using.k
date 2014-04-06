module Compiler
	class Using		
		name as string
		
		isLoaded as bool
		
		def new(usingName as string)
			name = usingName
			
			isLoaded = false
		end
	end
end