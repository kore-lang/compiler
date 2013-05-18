module Compiler
	class Class
		name as string

		fields as Field()
		fieldCount as int
		
		functions as Function()
		functionCount as int

		assembly as string()

		cmodule as Module

		contentKey as string
		contentType as Type

		inheritKey as string
		inheritType as Type

		def new(className as string, classModule as Module)
			name = className	
			cmodule = classModule
			
			fields = Field(100)
			fieldCount = 0
			
			functions = Function(100)
			functionCount = 0
		end

		def new(className as string, classType as Type)
			name = className
			type = classType

			fields = Field(100)
			fieldCount = 0
			
			functions = Function(100)
			functionCount = 0
			
			("Create class " + className).print
		end
		
		def addField(fieldName as string) as Field
			field = getField(fieldName)
			if field == null
				field = Field.new(fieldName)
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
		
		def addFunction(functionName as string, functionModule as Module, functionClass as Class) as Function
			function = getFunction(functionName)
			if function == null
				function = Function.new(functionName, functionModule, functionClass)
				functions(functionCount) = function
				functionCount++
			else
				"func exists".print
			end
			
			return function
		end
		
		def getFunction(functionName as string) as Function
			i = 0
			while i < functionCount
				if functions(i).name == functionName return functions(i)
				i++
			end
			
			return null
		end
	end
end