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
			id = 0
			name = string.empty
			
			objectType = ObjectType.None
			
			size = typeSize
			
			isValid = false
		end
		
		def new(typeId as int, typeName as string, typeSize as int)			
			id = typeId			
			name = typeName
			
			objectType = ObjectType.None
			
			size = typeSize
			
			isValid = false
		end
		
		def print
			(name + ":" + id.string + " of size " + size.string).print
		end
	end
end