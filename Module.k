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

		def new(moduleName as string)
			name = moduleName

			classes = Class(100)
			classCount = 0

			functions = Function(100)
			functionCount = 0

			includes = string(100)	
			includeCount = 0

			enums = Enum(100)
			enumCount = 0

			("Create module " + name).print
		end

		def addInclude(includeName as string)
			includes(includeCount) = includeName
			includeCount++
		end

		def addClass(className as string) as Class
			mclass = getClass(className)
			if mclass == null
				mclass = Class.new(className, this)
				classes(classCount) = mclass
				classCount++
				
				("Create class " + name + "." + className).print
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
				("there is already a function with name '" + functionName + "'").print
			end

			("Create function " + name + "." + functionName).print

			return function
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
			enum = getEnum(enumName)
			if enum == null
				enum = Enum.new(enumName)
				enums(enumCount) = enum
				enumCount++
			else
				("there is already an enum with name '" + enumName + "'").print
			end

			("Create enum " + name + "." + functionName).print

			return enum
		end

		def getEnum(enumName as string) as Enum
			i = 0
			while i < enumCount
				if enums(i).name == enumName then return enums(i)
				i++
			end

			return null
		end
	end
end