module Compiler
	class Context		
		type as Type
		
		level as int
		
		isAssignable as bool
		isAddress as bool
		isNullable as bool
		
		def new(contextType as Type)
			type = contextType
			
			isAssignable = true
			isAddress = false
			isNullable = false
		end
		
		def new(contextSource as Context)			
			type = contextSource.type
			
			level = contextSource.level
		
			isAssignable = contextSource.isAssignable
			isAddress = contextSource.isAddress
			isNullable = contextSource.isNullable
		end
	end
end