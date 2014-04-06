module Compiler
	class Using
		isLoaded as bool
		
		name as string
		
		def new(usingName as string)
			name = usingName
			
			isLoaded = false
		end
	end
end