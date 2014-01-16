module Compiler
	class Function				
		name as string
		binding as string

		returnArgument as Field
		returnKey as string

		block as Block

		type as Type
		
		level as int
		
		arguments as Field()
		argumentCount as int
		
		setterArgument as Field
		setterTypeName as string
		
		fclass as Class
		fmodule as Module
		
		isConstructor as bool
		isDestructor as bool
		isThis as bool		
		isStatic as bool
		isUsed as bool
		isCompiled as bool

		def new(functionName as string)
			isStatic = false
			
			name = functionName

			block = Block.new(this)
			
			fmodule = null
			fclass = null
			
			arguments = Field(10)
			argumentCount = 0
			
			setterArgument = null
			binding = string.empty
			
			("Function : " + qualifiedName).print
		end

		def new(functionName as string, functionModule as Module)
			isStatic = false
			
			name = functionName

			block = Block.new(this)
			
			fmodule = functionModule
			fclass = null
			
			arguments = Field(10)
			argumentCount = 0
			
			setterArgument = null
			binding = string.empty
			
			("Function : " + qualifiedName).print
		end

		def new(functionName as string, functionModule as Module, functionClass as Class)
			isStatic = false

			name = functionName

			block = Block.new(this)
			
			fmodule = functionModule
			fclass = functionClass
			
			arguments = Field(10)
			argumentCount = 0
			
			setterArgument = null
			binding = string.empty
			
			("Function : " + qualifiedName).print
		end
		
		def mangledName as string
			mangling = "def_" + qualifiedName
			mangling = mangling.replace(".", "_")
			mangling = mangling.lower
			
			return mangling
		end
		
		def qualifiedName as string
			if fclass == null
				return fmodule.qualifiedName + "." + name
			else
				return fclass.qualifiedName + "." + name
			end
		end
		
		def isAlias as bool
			return binding != string.empty
		end
		
		def isSetter as bool
			return setterArgument != null
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
		
		def linkTypes
			i = 0
			while i < argumentCount
				arguments(i).type = fmodule.getType(arguments(i).key)
				i++
			end
			
			
		end
		
		def build(assembly as Assembly)
			loadVariables
			
			assembly.write(mangledName + ":")
			assembly.write("push ebp")
			assembly.write("mov ebp,esp")
			
			block.build(assembly)
			
			assembly.write("pop ebp")
			assembly.write("ret")
			
			isCompiled = true
		end
		
		def loadVariables
		
		end
	end
end