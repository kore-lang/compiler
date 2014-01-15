using Kore

module Compiler
	def main	
		program = Program.load("Compiler")
		
		Console.next
		"Loading...".print
				
		program.loadSources("F:\\kore-lang\\compiler\\")
		program.loadLibraries("F:\\JadeBasic\\JadeBasic\\JadeBasic\\Headers\\")
			
		program.addLibraryPath("Libraries\\DirectX9")
		program.addLibraryPath("Libraries\\Core")
		program.addLibraryPath("Libraries\\Windows")

		Console.next
		"Lexing...".print
		
		lexer = Lexer.new(program.lines, program.count)
		lexer.lex

		Console.next
		"Parsing...".print
		
		parser = Parser.new(lexer)
		parser.parse(program)
		
		appModule = program.getModule("Compiler")
		
		if (appModule.checkTypes)
			appModule.linkTypes
			
			"Type link ok".print
			
			assembly = Assembly.new
			
			assembly.write("format MS COFF")
			assembly.write("section '.data' data readable writeable")
			
			appModule.build(assembly)
			
			assembly.print
			
			program.assemble
			program.link
			program.execute
		end
		
		//program.loadUsing
	end
end