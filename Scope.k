module Compiler
	/// <summary>
	/// Existing scopes of elements like methods or variables.
	/// </summary>
	enum Scope
	
		/// <summary>
		/// Class scope for classes elements (static).
		/// </summary>
		Class,
		
		/// <summary>
		/// Instance scope for object related elements.
		/// </summary>
		Instance,
		
		/// <summary>
		/// Local scope for method related elements.
		/// </summary>
		Local
	end
end