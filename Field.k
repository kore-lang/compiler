module Compiler
	/// <summary>
	/// Represents a memory field of a structure.
	/// </summary>
	class Field
	
		/// <summary>
		///	Indicates whether the variable is nullable or not.
		/// </summary>
		nullable as bool
		
		/// <summary>
		///	Field unique ID, relative to its parent.
		/// </summary>
		id as int
		
		/// <summary>
		///	Indirect level of the variable. Typically, 0 = value type, 1 = object, 2 and above = array.
		/// </summary>
		level as int
		
		/// <summary>
		///	Memory offset of the variable in its parent context.
		/// </summary>
		offset as int
		
		/// <summary>
		///	Define if the variable is nullable or not.
		/// </summary>
		order as int
				
		/// <summary>
		/// String key of the type of the variable before type linking.
		/// </summary>
		key as string
		
		/// <summary>
		///	Variable's name.
		/// </summary>
		name as string
		
		/// <summary>
		/// Type of the variable.
		/// </summary>
		type as Type
		
		/// <summary>
		///	Simple constructor with field name.
		/// </summary>
		/// <param name="fieldName">Name of the field to create.</param>
		def new(fieldName as string)
			name = fieldName
			
			offset = 0
			level = 0
			
			nullable = false
		end
	end
end