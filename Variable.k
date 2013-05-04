module Compiler
	/// <summary>
	/// Representation of a block variable.
	/// </summary>
	class Variable
			
		/// <summary>
		/// Indicates if the variable is assigned.
		/// </summary>
		assigned as bool
		
		/// <summary>
		/// Indicates if the variable is nullable.
		/// </summary>
		nullable as bool
				
		/// <summary>
		/// Indicates if the variable is used.
		/// </summary>
		used as bool
		
		/// <summary>
		/// Memory offset of the variable in its parent context.
		/// </summary>
		offset as int
				
		/// <summary>
		/// Variable's scope.
		/// </summary>
		scope as Scope
		
		/// <summary>
		/// Variable's type.
		/// </summary>
		type as Type
	end
end