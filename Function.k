module Compiler
	class Function
		isStatic as bool

		name as string
		alias as string

		returnKey as string

		block as Block

		type as Type

		def new(functionName as string)
			name = functionName

			isStatic = false

			block = Block.new
		end

		def new(functionName as string, functionModule as Module)
			name = functionName

			isStatic = false

			block = Block.new
		end

		def new(functionName as string, functionModule as Module, functionClass as Class)
			name = functionName

			isStatic = false

			block = Block.new
		end
	end
end