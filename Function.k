module Compiler
	class Function
		isStatic as bool

		name as string
		alias as string

		returnKey as string

		block as Block

		type as Type
		
		fclass as Class
		fmodule as Module

		def new(functionName as string)
			name = functionName

			isStatic = false

			block = Block.new
		end

		def new(functionName as string, functionModule as Module)
			name = functionName

			isStatic = false

			block = Block.new
			
			fmodule = functionModule
		end

		def new(functionName as string, functionModule as Module, functionClass as Class)
			name = functionName

			isStatic = false

			block = Block.new
			
			fmodule = functionModule
			fclass = functionClass
			
			("Create function " + functionName).print
		end
	end
end