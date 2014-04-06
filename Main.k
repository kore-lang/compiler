using Kore

module Compiler
	def main(argc as int, argv as string())
		"Kore Compiler - v0.100".print
		
		Console.next
      
		arguments = StringTable.new
		      
		// Keep the compiler path.
      path = Directory.current
      arguments.add("path", path)
			  
		// Build the compiler arguments table.
		i = 1
		while i < argc
			argument = argv(i)
         
			// Checks that we received real arguments.
			if argument.get(0) == "/"
				splitterIndex = argument.indexOf(":")
				
				// Retrieves key and value for the argument.
				if splitterIndex == -1
					argumentKey = argument.subString(1)
					argumentValue = string.empty
				else
					argumentKey = argument.subString(1, splitterIndex - 1)
					argumentValue = argument.subString(splitterIndex + 1, argument.length - splitterIndex -1)
				end
				
				// Add key/value argument.
				arguments.add(argumentKey, argumentValue)
			else
			   ("Unknown argument : " + argument).print
			end
         
			i++
		end
      
		// Compiler development test config.
		arguments.add("project", "F:\\kore-lang\\kore\\projects\\sample")
		arguments.add("libpath", "F:\\kore-lang\\kore\\libraries")
		arguments.add("platform", "windows")
		arguments.add("execute", string.empty)
      
		Console.next
	
		entry = "_main"
	
      // Try to compile only if we have a project path.
      project = arguments.get("project")
      if !project.isNull
	  
   		// Removes the terminating slash/backslash if there is one.
   		if project.get(project.length - 1) == "\\" or project.get(project.length - 1) == "/" 
   			project = project.subString(0, project.length - 1)
   		end			

   		program = Program.load(project)
   		
   		Console.next
   		"Loading...".print
           
         // Adds the using for the current platform.
         program.addUsing(arguments.get("platform").upperFirst)
         
         // Loads the libraries.
         program.loadLibraries(arguments.get("libpath"))

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
   		
         // Try to build the sources only if the type check is valid.
   		if appModule.checkTypes
         
            // Links type usage to their types.
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
   			
   			assembly.write("extrn '_malloc' as malloc:dword")
   			assembly.write("extrn '_String_Add' as _add_string:dword")
   			assembly.write("extrn '_String_Compare' as _cmp_string:dword")
   			assembly.write("extrn '_String_ToInt' as _string_toint:dword")
   			assembly.write("extrn '_Int_ToString' as _int_tostring:dword")
   						
   			program.includeString = appModule.includeString
   						
   			program.assemble("Tools\\fasm.exe", assembly)
   			program.link("Tools\\polink.exe", arguments.get("libpath"))
            
            // Executes the program only if asked.
            if arguments.hasKey("execute") then program.execute
   		end
      else
         "A project path is required".print
      end
	end
end