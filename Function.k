module Compiler
	class Function
		isStatic as bool

		name as string
		alias as string

		returnKey as string

		block as Block

		type as Type
		
		level as int
		
		arguments as Field()
		argumentCount as int
		
		isConstructor as bool
		isDestructor as bool
		isThis as bool
		
		fclass as Class
		fmodule as Module

		def new(functionName as string)
			name = functionName

			isStatic = false

			block = Block.new
			
			arguments = Field(10)
			argumentCount = 0
		end

		def new(functionName as string, functionModule as Module)
			name = functionName

			isStatic = false

			block = Block.new
			
			fmodule = functionModule
			
			arguments = Field(10)
			argumentCount = 0
		end

		def new(functionName as string, functionModule as Module, functionClass as Class)
			name = functionName

			isStatic = false

			block = Block.new
			
			fmodule = functionModule
			fclass = functionClass
			
			arguments = Field(10)
			argumentCount = 0
			
			("Create function " + functionName).print
		end
		
		def addArgument(argName as string) as Field
			argument = getArgument(argName)
			if argument == null
				argument = Field.new(argName)
				arguments(argumentCount) = argument
				argumentCount++
			else
				"arg exists".print
			end
			
			return argument
		end
		
		def getArgument(argName as string) as Field
			i = 0
			while i < argumentCount
				if arguments(i).name == argName then return arguments(i)
				i++
			end
			
			return null
		end
	end
end