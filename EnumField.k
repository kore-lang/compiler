module Compiler
	/// <summary>
	/// A simple enum field.
	/// </summary>
	class EnumField
				
		/// <summary>
		///	Value of the field.
		/// </summary>
		value as int
		
		/// <summary>
		///	Field's name.
		/// </summary>
		name as string

		/// <summary>
		///	Constructs an enum field with its name and value.
		/// </summary>
		/// <param name="fieldName">Name of the enum field to create.</param>
		/// <param name="fieldValue">Corresponding value of the field.</param>
		def new(fieldName as string, fieldValue as int)
			name = fieldName
			value = fieldValue
		end
	end
end