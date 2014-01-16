using Kore

module Compiler
	def main	
		entry = "_main"
	
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
			
			assembly.write("section '.code' code readable writeable")
			
			assembly.write("public " + entry)
			assembly.write("extrn __fltused")

			assembly.write(entry + ":")
				
			appModule.build(assembly)
			
			assembly.write("extrn '_malloc' as malloc:dword")
			assembly.write("extrn '_core_array_start' as array:dword")
			assembly.write("extrn '_String_Add' as _add_string:dword")
			assembly.write("extrn '_String_Compare' as _cmp_string:dword")
			assembly.write("extrn '_String_ToInt' as _string_toint:dword")
			assembly.write("extrn '_Int_ToString' as _int_tostring:dword")
			
			assembly.save("compiler2.asm")
			
			program.assemble
			program.link
			program.execute
		end
		
		//program.loadUsing
	end
end