module Compiler
	class CodeLine
		source as Source
		text as string
		number as int
		
		def new(lineSource as Source, lineText as string, lineNumber as int)
			source = lineSource
			text = lineText
			number = lineNumber
		end
	end
end