module Compiler
	/// <summary>
	/// 
	/// </summary>
	class Enum
	
		/// <summary>
		///	Define if the variable is nullable or not.
		/// </summary>
		name as string
		
		/// <summary>
		///	Current maximum value of the enum.
		/// </summary>
		value as int

		/// <summary>
		/// Array of fields.
		/// </summary>
		fields as EnumField()
		
		/// <summary>
		/// Current field count.
		/// </summary>
		fieldCount as int
		
		
		type as Type

		/// <summary>
		/// Creates a new enum from its name.
		/// </summary>
		/// <param name="enumName">Name of the enum to create.</param>
		def new(enumName as string)
			name = enumName

			fields = EnumField(100)
			fieldCount = 0

			value = 0

			("Create enum " + name).print
		end

		/// <summary>
		/// 
		/// </summary>
		def addField(fieldName as string) as EnumField
			lastValue++
			return addField(fieldName, lastVale)
		end

		/// <summary>
		/// 
		/// </summary>
		def addField(fieldName as string, fieldValue as int) as EnumField
			field = getField(fieldName)
			if field == null
				field = EnumField.new(fieldName, fieldValue)
				fields(fieldCount) = field
				fieldCount++
				lastValue = fieldValue
			else
				("error : there is already a field '" + fieldName + "' in enum '" + name + "'").print
			end

			return field
		end

		/// <summary>
		/// 
		/// </summary>
		def getField(fieldName as string) as EnumField
			i = 0
			while i < fieldCount
				if fields(i).name == fieldName then return fields(i)
				i++
			end

			return null
		end
		
		/// <summary>
		/// Determines if the value is already used by a field in the the enum.
		/// </summary>
		/// <param name="fieldValue">Value to check.</param>
		/// <returns>Returns true if the value is used, false otherwise.</returns>
		def hasValue(fieldValue as int) as bool
			i = 0
			while i < fieldCount
				if fields(i).value == fieldValue then return true
				i++
			end
			
			return false
		end
	end
end