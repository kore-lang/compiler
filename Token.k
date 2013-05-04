module Compiler
	/// <summary>
	/// List of Kore tokens.
	/// </summary>
	enum Token
		As,			// Typing keyword.

		Alias,		// Call redirect.
		Def,		// Function definition.
		Return,		// Function exit.

		Module,		// Module.
		Class,		// Class.
		Enum,		// Enumeration.

		End,		// End keyword for most code structures.
		
		New,		// Instanciation.
		Delete,		// Deletion.

		ProgEnd,	// End of program/source.
		EOL,

		LP,
		RP,

		Comma,
		Colon

		Assign,
	
		Plus,
		Minus,		
		Mul,
		Div,

		Not,
		Or,
		Xor,
		And,

		EQ,
		NEQ,
		GTE,
		GT,
		LTE,
		LT

		Name,

		True,
		False,

		Bool,
		Int,
		Float,
		String,

		Array,

		If,
		Then,
		Elsif,
		Else,

		Switch,
		Case,
		Default,

		Foreach,
		For,
		To,
		In,
		Yield,

		Dot,		

		Do,
		Loop,

		While,

		Repeat,
		Until,

		Include,
		Using,

		Error
	end
end