module Compiler
	class Function				
		name as string
		binding as string

		returnKey as string
		returnType as Type

		block as Block

		type as Type
		
		level as int
		
		arguments as Field()
		argumentCount as int
		_argumentSize as int
		
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
			isUsed = false
			
			name = functionName

			block = Block.new(this)
			
			fmodule = null
			fclass = null
			
			arguments = Field(10)
			argumentCount = 0
			
			_argumentSize = -1
			
			setterArgument = null
			setterTypeName = "void"
			binding = string.empty
			
			returnKey = "void"
			returnType = null
			
			type = null
			level = 0
			
			("Function : " + qualifiedName).print
		end

		def new(functionName as string, functionModule as Module)
			isStatic = false
			isUsed = false
			
			name = functionName

			block = Block.new(this)
			
			fmodule = functionModule
			fclass = null
			
			arguments = Field(10)
			argumentCount = 0
			
			_argumentSize = -1
			
			setterArgument = null
			setterTypeName = "void"
			binding = string.empty
         
			returnKey = "void"
			returnType = null
			
			type = null
			level = 0
			
			("Function : " + qualifiedName).print
		end

		def new(functionName as string, functionModule as Module, functionClass as Class)
			isStatic = false
			isUsed = false

			name = functionName

			block = Block.new(this)
			
			fmodule = functionModule
			fclass = functionClass
			
			arguments = Field(10)
			argumentCount = 0
			
			_argumentSize = -1
			
			setterArgument = null
			setterTypeName = "void"
			binding = string.empty
         
			returnKey = "void"
			returnType = null
			
			type = null
			level = 0
			
			("Function : " + qualifiedName).print
		end
		
		def mangledName as string
			mangling = "def_" + qualifiedName
			mangling = mangling.replace(".", "_")
			mangling = mangling.lower
			
			i = 0
			while i < argumentCount
				mangling = mangling + "_" + arguments(i).type.id.string
				i++
			end
			
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
		
		def createAnonymousArgument(typeName as string) as Field
			argName = "arg_" + argumentCount.string
			
			argument = Field.new(argName)
			argument.key = typeName
			
			arguments(argumentCount) = argument
			argumentCount++
			
			return argument
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
		
		def argumentSize as int
			if _argumentSize == -1
				_argumentSize = 0
				
				// Adding every argument to determine the stack size needed for the arguments.
				i = 0
				while i < argumentCount
					_argumentSize = _argumentSize + arguments(i).type.size
					i++
				end
				
				// Add setter argument.
				//if isSetter then argumentsize = argumentSize + setterArgument.type.size
			end
			
			return _argumentSize
		end
		
		// Links types to every usage.
		def linkTypes
			i = 0
              
			while i < argumentCount         
				arguments(i).type = fmodule.getType(arguments(i).key)
				i++
			end
                  
			// Links the return type.
			returnType = fmodule.getType(returnKey)
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
			offset = -8
			
			// Adding all the variables from the arguments.
			i = 0
			while i < argumentCount
				block.createArgumentVariable(arguments(i).name, arguments(i).type, arguments(i).level, offset)
				offset = offset - arguments(i).type.size
				i++
			end
						
			// If the function is inside a class, its fields and the special variable "this" are added.
			if fclass != null
			//	if fclass.type.id == BaseType.Int.int
					block.createArgumentVariable("this", fclass.type, 1, offset)
			//	else
			//		block.createArgumentVariable("this", fclass.type, 1, offset)
			//	end
				
				i = 0
				while i < fclass.fieldCount
					f = fclass.fields
					block.createInstanceVariable(f(i))
					i++
				end
			end
		end
		
		def acceptTypes(types as Type(), typeCount as int) as bool
			// Number of arguments not matching : not ok.
			if typeCount != argumentCount then return false
			
			// No arguments : accepted.
			if typeCount == 0 then return true
			
			i = 0
			while i < argumentCount
				if arguments(i).type.id != types(i).id then return false
				i++
			end
			
			return true
		end
	end
end