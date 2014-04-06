module Compiler
	class Module
		name as string

		includes as string()
		includeCount as int

		classes as Class()
		classCount as int

		functions as Function()
		functionCount as int

		enums as Enum()
		enumCount as int
		
		types as Type()
		typeCount as int
				
		program as Program

		def new(moduleName as string, moduleProgram as Program)
			name = moduleName
			
			includes = string(100)	
			includeCount = 0
			
			classes = Class(100)
			classCount = 0

			functions = Function(100)
			functionCount = 0

			enums = Enum(100)
			enumCount = 0

			types = Type(100)
			typeCount = 0
			
			program = moduleProgram
						
			("Module : " + qualifiedName).print
		end
		
		def qualifiedName as string
			return name
		end
				
		def loadBaseTypes
			addClass(Class.new("void", this), Type.new(4))
			addClass(Class.new("bool", this), Type.new(1))
			addClass(Class.new("byte", this), Type.new(1))
			addClass(Class.new("char", this), Type.new(1))
			addClass(Class.new("int", this), Type.new(4))
			addClass(Class.new("long", this), Type.new(8))
			addClass(Class.new("float", this), Type.new(4))
			addClass(Class.new("double", this), Type.new(8))
			addClass(Class.new("string", this), Type.new(4))
			addClass(Class.new("entity", this), Type.new(4))
		end
		
		def getOrCreateString(str as string) as int
			return program.getOrCreateString(str)
		end
		
		def createType(typeName as string) as Type
			type = Type.new(program.nextTypeId, typeName, 4)
			types(typeCount) = type
			typeCount++
			return type
		end
		
		def addType(type as Type)
			types(typeCount) = type
			typeCount++
		end
		
		def getType(typeName as string) as Type
			i = 0
			while i < typeCount
				if types(i).name == typeName then return types(i)
				i++
			end
			
			return null
		end
		
		def typeExists(typeName as string) as bool
			i = 0
			while i < typeCount
				if types(i).name == typeName then return true
				i++
			end
			
			return false
		end

		def addInclude(includeName as string)
			includes(includeCount) = includeName
			includeCount++
		end
		
		def includeString as string
			inc = string.empty
			
			i = 0
			while i < includeCount
				inc = inc + " " + includes(i)
				i++
			end
			
			return inc
		end
		
		def addClass(moduleClass as Class)
			classes(classCount) = moduleClass
			classCount++
		end
		
		def addClass(mclass as Class, type as Type)
			classes(classCount) = mclass
			classCount++
			
			mclass.type = type
			
			type.id = typeCount
			type.name = mclass.name
			type.objectType = ObjectType.Class
			
			types(typeCount) = type
			typeCount++
		end

		// Adds a new class to the module if possible.
		def getOrCreateClass(className as string) as Class
			mclass = getClass(className)
			if mclass == null
				mclass = Class.new(className, this)
				classes(classCount) = mclass
				classCount++
				
				// Creates a type for the class.
				type = createType(className)
				type.objectType = ObjectType.Class
				
				mclass.type = type
			end
			
			return mclass
		end
		
		def getClass(className as string) as Class
			i = 0
			while i < classCount
				if classes(i).name == className then return classes(i)
				i++
			end
			
			return null
		end

		def addFunction(functionName as string) as Function
			function = getFunction(functionName)
			if function == null
				function = Function.new(functionName, this)
				functions(functionCount) = function
				functionCount++
			else
				("There is already a function '" + functionName + "' in " + qualifiedName).print
			end

			return function
		end
		
		def addFunction(function as Function)
			functions(functionCount) = function
			functionCount++
		end

		def	functionExists(functionName as string) as bool
			i = 0
			while i < functionCount
				if functions(i).name == functionName then return true
				i++
			end
			
			return false
		end

		def getFunction(functionName as string) as Function
			i = 0
			while i < functionCount
				if functions(i).name == functionName then return functions(i)
				i++
			end

			return null
		end

		def addEnum(enumName as string) as Enum
			menum = getEnum(enumName)
			if menum == null
				menum = Enum.new(enumName)
				enums(enumCount) = menum
				enumCount++
				
				type = createType(enumName)
				type.objectType = ObjectType.Enumeration
				
				menum.type = type
			else
				("There is already an enum '" + enumName + "' in " + qualifiedName).print
			end

			return menum
		end
		
		def addEnum(moduleEnum as Enum)
			enums(enumCount) = moduleEnum
			enumCount++
		end

		def getEnum(enumName as string) as Enum
			i = 0
			while i < enumCount
				if enums(i).name == enumName then return enums(i)
				i++
			end

			return null
		end
		
		def loadModule(sourceModule as Module)
			i = 0
			while i < sourceModule.typeCount
				t = sourceModule.types
				addType(t(i))
				i++
			end
			
			i = 0
			while i < sourceModule.classCount
				c = sourceModule.classes
				addClass(c(i))
				i++
			end
			
			i = 0
			while i < sourceModule.functionCount
				f = sourceModule.functions
				addFunction(f(i))
				i++
			end
			
			i = 0
			while i < sourceModule.enumCount
				e = sourceModule.enums
				addEnum(e(i))
				i++
			end
						
			i = 0
			while i < sourceModule.includeCount
				n = sourceModule.includes
				addInclude(n(i))
				i++
			end
			
			("Module loaded : " + sourceModule.qualifiedName).print
		end
		
		def checkTypes as bool
			return true
		end
		
		def linkTypes
			linked = 0
         
			while linked < typeCount			
				linked = 0
				
				// Type linking with code structures.
				i = 0
				while i < typeCount
					if not types(i).isValid
						if types(i).objectType == ObjectType.Enumeration
							types(i).isValid = true
						else
							getClass(types(i).name).linkTypes
						end						
					end
					i++
				end
				
				// Counting linked types.
				i = 0
				while i < typeCount
					if types(i).isValid then linked = linked + 1
					i++
				end
			end
         
			// Linking module functions.
			i = 0
			while i < functionCount
				functions(i).linkTypes
				i++
			end
		end
		
		def build as Assembly
			assembly = Assembly.new
		
			assembly.write("push ebp")
			assembly.write("mov ebp,esp")
			
            if functionExists("main")
				assembly.write("push dword[ebp+12]")
				assembly.write("push dword[ebp+8]")
				assembly.write("call " + getFunction("main").mangledName)
				assembly.write("add esp,8")
			end

            assembly.write("pop ebp")
            assembly.write("ret")
			
			i = 0
			while i < functionCount
				if not functions(i).isAlias then functions(i).build(assembly)
				i++
			end
			
			i = 0
			while i < classCount
				classes(i).build(assembly)
				i++
			end
			
			appendCallCode(assembly)
			
			return assembly
		end
		
		def	appendCallCode(assembly as Assembly)
			i = 0
			while i < classCount
				classes(i).appendCallCode(assembly)
				i++
			end
		end
		
		def showTypes
			i = 0
			while i < typeCount
				("type[" + i.string + "] " + types(i).name + ":" + types(i).id.string).print
				i++
			end
		end
	end
end