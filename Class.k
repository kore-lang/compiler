module Compiler
	class Class
		name as string

		fields as Field()
		functions as Function()

		assembly as string()

		module as Module

		contentKey as string
		contentType as Type

		inheritKey as string
		inheritType as Type

		def new(className as string)
			name = className	
		end

		def new(className as string, classType as Type)
			name = className
			type = classType

			Log.add("Create class " + className)
		end
	end
end