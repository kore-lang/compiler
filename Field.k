module Compiler
	/// <summary>
	/// Represents a memory field of a structure.
	/// </summary>
	class Field						
		/// <summary>
		///	Variable's name.
		/// </summary>
		name as string
				
		/// <summary>
		///	Memory offset of the variable in its parent context.
		/// </summary>
		offset as int
		
		/// <summary>
		///	Indirect level of the variable. Typically, 0 = value type, 1 = object, 2 and above = array.
		/// </summary>
		level as int
		
		/// <summary>
		/// Type of the variable.
		/// </summary>
		type as Type
		key as string
		
		fclass as Class		
	
		/// <summary>
		///	Indicates whether the variable is nullable or not.
		/// </summary>
		isNullable as bool
		
		// Constructs a new field.
		def new(fieldName as string)
			name = fieldName
			
			offset = 0
			level = 0
			
			key = "void"
			type = null
			
			isNullable = false
			
			fclass = null
		end
		
		/// <summary>
		///	Simple constructor with field name.
		/// </summary>
		/// <param name="fieldName">Name of the field to create.</param>
		def new(fieldName as string, fieldClass as Class)
			name = fieldName
			
			offset = 0
			level = 0
			
			key = "void"
			type = null
			
			isNullable = false
			
			fclass = fieldClass
			
			("Field : " + qualifiedName).print
		end
		
		def qualifiedName as string
			if fclass != null then return fclass.qualifiedName + "." + name
		end
		
		// Create an instance variable from the field.
		def createVariable as Variable
			variable = Variable.new(name)
			variable.type = type
			variable.offset = offset
			variable.level = level
			variable.scope = Scope.Instance
			
			return variable
		end
	end
end