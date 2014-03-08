module Compiler
	/// <summary>
	/// Represents an available type.
	/// </summary>
	class Type
		
		/// <summary>
		/// Unique ID for the type.
		/// </summary>
		id as int
		
		/// <summary>
		/// Type size in bytes.
		/// </summary>
		size as int
		
		name as string
			
		objectType as ObjectType
				
		/// <summary>
		/// Indicates whether the type is valid or not.
		/// </summary>
		isValid as bool
		
		def new(typeSize as int)
			isValid = false
			
			size = typeSize
		end
		
		def new(typeId as int, typeName as string, typeSize as int)
			isValid = false
			
			id = typeId
			name = typeName
			size = typeSize
		end
		
		def print
			(name + ":" + id.string + " of size " + size.string).print
		end
	end
end