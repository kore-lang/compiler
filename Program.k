module Compiler
	class Program
		name as string
		path as string
	
		pool as ClassPool
	
		modules as Module()
		moduleCount as int

		// Used module names.
		usings as string()
		usingCount as int
		
		// Library pathes.
		pathes as string()
		pathCount as int
		
		// Source files.
		sources as Source()
		sourceCount as int
		
		count as int
		
		typeCount as int
		
		includeString as string

		def new(appName as string, appPath as string)
			name = appName
			path = appPath
		
			pool = ClassPool.new
			
			modules = Module(10)
			moduleCount = 0

			usings = string(10)
			usingCount = 0
			
			pathes = string(10)
			pathCount = 0
			
			sources = Source(100)
			sourceCount = 0
			
			count = 0
						
			m = addModule("Kore")
			m.loadBaseTypes
			
			typeCount = m.typeCount
			
			("Create program " + name).print
		end
		
		// Get the next type ID.
		def nextTypeId as int
			a = typeCount
			typeCount++
			
			return a
		end
		
		def addSource(source as Source)
			sources(sourceCount) = source
			sourceCount++
		end
		
		def loadSources(sourcePath as string)
			i = 0
			
			files = Directory.files(sourcePath, "*.k")
			while not files(i).isNull
				this.addSource(Source.load(sourcePath + files(i)))
				i++
			end
		end
		
		def lines as CodeLine()
			i = 0
			k = 0
			
			while i < sourceCount
				count = count + sources(i).lineCount
				i++
			end
		
			("Lines : " + count.string + " in " + sourceCount.string + " files").print
			
			codeLines = CodeLine(count)
		
			i = 0
			while i < sourceCount
				j = 0
				e = sources(i).lineCount
				while j < e
					l = sources(i).lines
					codeLines(k + j) = l(j)
					j++
				end
				i++
				k = k + j
			end
						
			return codeLines
		end
		
		def addLibraryPath(libPath as string)
			pathes(pathCount) = libPath
			pathCount++
		end
		
		def loadLibraries(libPath as string)
			this.loadSources(libPath)
		end

		def addModule(moduleName as string) as Module

			newModule = getModule(moduleName)

			if newModule == null
				newModule = Module.new(moduleName, this)
				modules(moduleCount) = newModule
				moduleCount++
			end			

			return newModule
		end

		def getModule(moduleName as string) as Module
			i = 0
			while i < moduleCount
				if modules(i).name == moduleName then return modules(i)
				i++
			end

			return null
		end
		
		def getAppModule as Module
			return getModule(name.upperFirst)
		end

		// Add a module name.
		def addUsing(usingName as string)
			usings(usingCount) = usingName
			usingCount++
			("Using " + usingName).print
		end
		
		def loadUsing(appModule as Module)
			i = 0
			j = 0
			
			while i < usingCount
				sourceModule = getModule(usings(i))
				if sourceModule != null
					appModule.loadModule(sourceModule)
				else
					("there is no module " + usings(i)).print
				end
				i++
			end
		end
		
		def build
			
		end
		
		def assemble(assembler as string, assembly as Assembly)
			Console.next
			"Assembling...".print
			
			fileName = path + "\\" + name + ".asm"
			
			assembly.save(fileName)
			
			// Execute the selected assembler.
			process = Process.new(assembler)
			process.execute(fileName)
		end
		
		def link(linker as string)
			Console.next
			"Linking...".print
			
			command = path + "\\" + name + ".obj"
			
			i = 0
			
			while i < pathCount
				command = command + " /LIBPATH:" + pathes(i)
				i++
			end
			
			command = command + " Core\\Jade_Core.obj"
            command = command + " Core\\Jade_String.lib"
            command = command + " Core\\Kore_Int.lib"
			
			command = command + includeString
			
			command = command + " /SUBSYSTEM:CONSOLE /FORCE:MULTIPLE"
												
			// Execute the linker
			process = Process.new(linker, "F:\\JadeBasic\\JadeBasic\\JadeBasic\\")
			process.execute(command)
		end
		
		def execute
			Console.next
			"Executing...".print
						
			fileName = path + "\\" + name + ".exe"
			
			// Execute the program.
			process = Process.new(fileName, path)
			process.execute(string.empty)
		end
		
		self def load(appPath as string) as Program
			program = Program.new(appPath.lastSegment("\\"), appPath)
			program.loadSources(appPath + "\\")
			return program
		end
	end
end