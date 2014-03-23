using Kore

module Compiler	
	def main		
		"Kore Compiler - v0.100".print
		
		Console.next
	
		entry = "_main"
	
		program = Program.load("F:\\kore-lang\\auto")
		
		Console.next
		"Loading...".print
								
		program.loadLibraries("F:\\JadeBasic\\JadeBasic\\JadeBasic\\Headers\\")
			
		program.addLibraryPath("Libraries\\DirectX9")
		program.addLibraryPath("Libraries\\JadeLibrary")
		program.addLibraryPath("Libraries\\Windows")

		Console.next
		"Lexing...".print
		
		lexer = Lexer.new(program.lines, program.count)
		lexer.lex

		Console.next
		"Parsing...".print
		
		parser = Parser.new(lexer)
		parser.parse(program)
		
		appModule = program.getAppModule
		
		program.loadUsing(appModule)
		
		if appModule.checkTypes
			appModule.linkTypes
			
			Console.next
			"Type link ok".print
			
			moduleAssembly = appModule.build
			
			Console.next
			"Program built".print
			
			Console.next
			
			assembly = Assembly.new
			
			assembly.write("format MS COFF")
			assembly.write("section '.data' data readable writeable")
			
			program.writeStrings(assembly)
			
			assembly.write("section '.code' code readable writeable")
			
			assembly.write("public " + entry)
			assembly.write("extrn __fltused")

			assembly.write(entry + ":")
			
			moduleAssembly.writeTo(assembly)
			//appModule.showTypes
			
			assembly.write("extrn '_malloc' as malloc:dword")
			assembly.write("extrn '_core_array_start' as array:dword")
			assembly.write("extrn '_String_Add' as _add_string:dword")
			assembly.write("extrn '_String_Compare' as _cmp_string:dword")
			assembly.write("extrn '_String_ToInt' as _string_toint:dword")
			assembly.write("extrn '_Int_ToString' as _int_tostring:dword")
						
			program.includeString = appModule.includeString
						
			program.assemble("F:\\JadeBasic\\JadeBasic\\JadeBasic\\FASM.EXE", assembly)
			program.link("F:\\JadeBasic\\JadeBasic\\JadeBasic\\polink.exe")
			program.execute
			
			Console.pause
		end
	end
end