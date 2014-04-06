module Compiler
	class Class
		name as string

		fields as Field()
		fieldCount as int
		
		functions as Function()
		functionCount as int

		cmodule as Module

		contentKey as string
		contentType as Type

		inheritKey as string
		inheritType as Type
		
		// Class type.
		type as Type
		
		// Size of the class on the heap.
		size as int

		def new(className as string, classModule as Module)
			name = className	
			cmodule = classModule
			type = null
			
			fields = Field(100)
			fieldCount = 0
						
			functions = Function(100)
			functionCount = 0
			
			inheritKey = "void"
			inheritType = null
			
			size = 0
			
			("Class : " + qualifiedName).print
		end

		def new(className as string, classType as Type)
			name = className
			cmodule = null
			type = classType

			fields = Field(100)
			fieldCount = 0
			
			functions = Function(100)
			functionCount = 0
			
			inheritKey = "void"
			inheritType = null
			
			size = 0
						
			("Class : " + qualifiedName).print
		end
		
		def qualifiedName as string
			return cmodule.qualifiedName + "." + name
		end
		
		def addField(fieldName as string) as Field
			field = getField(fieldName)
			if field == null
				field = Field.new(fieldName, this)
				fields(fieldCount) = field
				fieldCount++
			end
			
			return field
		end
		
		def getField(fieldName as string) as Field
			i = 0
			while i < fieldCount
				if fields(i).name == fieldName then return fields(i)
				i++
			end
			
			return null
		end
		
		def fieldExists(fieldName as string) as bool
			i = 0
			while i < fieldCount
				if fields(i).name == fieldName then return true
				i++
			end
			
			return false
		end
		
		def addFunction(functionName as string, functionModule as Module, functionClass as Class) as Function
			function = Function.new(functionName, functionModule, functionClass)
			functions(functionCount) = function
			functionCount++
			
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
		
		def getFunction(functionName as string, types as Type(), typeCount as int) as Function
			i = 0
			while i < functionCount
				if functions(i).name == functionName
					if functions(i).acceptTypes(types, typeCount) == true
						return functions(i)
					end
				end
				i++
			end
			
			return null
		end
		
		def functionExists(functionName as string) as bool
			i = 0
			while i < functionCount
				if functions(i).name == functionName then return true
				i++
			end
			
			return false
		end
		
		def linkTypes			
			// Associate each field with its type.
			i = 0
			while i < fieldCount
				fields(i).type = cmodule.getType(fields(i).key)
				i++
			end
						
			// Compute field offset.
			i = 0
			while i < fieldCount
				fields(i).offset = size
				size = size + fields(i).type.size
				i++
			end
			
			// Function linking.
			i = 0
			while i < functionCount
				functions(i).linkTypes
				i++
			end
			
			type.isValid = true
		end
		
		// Build the class content.
		def build(assembly as Assembly)
			i = 0
			while i < functionCount
				if not functions(i).isAlias then functions(i).build(assembly)
				i++
			end
		end
		
		def appendCallCode(assembly as Assembly)
			i = 0
			while i < functionCount				
				if functions(i).isUsed and functions(i).isAlias 
					assembly.write("extrn '" + functions(i).binding + "' as " + functions(i).mangledName + ":dword")
				end
				i++
			end
		end
	end
end