module Compiler
	/// <summary>
	/// List of Kore tokens.
	/// </summary>
	enum Token
		As			// Typing keyword.

		Alias		// Call redirect.
		Def			// Function definition.
		Return		// Function exit.

		Module		// Module.
		Class		// Class.
		Enum		// Enumeration.

		End			// End keyword for most code structures.
		
		New			// Instanciation.
		Delete		// Deletion.

		ProgEnd		// End of program/source.
		Eol

		Lp
		Rp

		Comma
		Colon

		Assign
	
		Plus
		Minus
		Mul
		Div

		SelfAdd		// Add to itself.
		SelfSub		// Substract from itself.
		SelfMul		// Multiply itself by.
		SelfDiv		// Divide itself by.
		
		Not
		Or
		Xor
		And

		Eq
		Neq
		Gte
		Gt
		Lte
		Lt

		Name

		Boolean

		Bool
		Integer
		Float
		String

		Array
		Nullable

		If
		Then
		Elsif
		Else

		Switch
		Case
		Default

		Foreach
		For
		To
		In
		Yield

		Dot	

		Do
		Loop

		While

		Repeat
		Until

		Include
		Using

		Error
		
		Static
	end
end