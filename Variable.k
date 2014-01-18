module Compiler
	/// <summary>
	/// Representation of a block variable.
	/// </summary>
	class Variable
		name as string
		
		/// <summary>
		/// Memory offset of the variable in its parent context.
		/// </summary>
		offset as int
		
		level as int
				
		/// <summary>
		/// Variable's scope.
		/// </summary>
		scope as Scope
		
		/// <summary>
		/// Variable's type.
		/// </summary>
		type as Type
			
		/// <summary>
		/// Indicates if the variable is assigned.
		/// </summary>
		isAssigned as bool
		
		/// <summary>
		/// Indicates if the variable is nullable.
		/// </summary>
		isNullable as bool
				
		/// <summary>
		/// Indicates if the variable is used.
		/// </summary>
		isUsed as bool
		
		def new(variableName as string)
			offset = 0
			level = 0
			
			name = variableName
			
			isAssigned = false
			isNullable = false
			isUsed = false
		end
	end
end