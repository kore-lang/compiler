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
			
			("Create program " + name).print
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
				newModule = Module.new(moduleName)
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

		// Add a module name.
		def addUsing(usingName as string)
			usings(usingCount) = usingName
			usingCount++
			("Using " + usingName).print
		end
		
		def loadBaseTypes
			pool.addClass(Class.new("void", Type.new(BaseType.Void.int, "void", 0)))
		//	pool.addClass(Class.new("bool", Type.new(1, "void", 0)))
		//	pool.addClass(Class.new("void", Type.new(2, "void", 0)))
		//	pool.addClass(Class.new("void", Type.new(3, "void", 0)))
		//	pool.addClass(Class.new("void", Type.new(4, "void", 0)))
		//	pool.addClass(Class.new("void", Type.new(5, "void", 0)))
		//	pool.addClass(Class.new("void", Type.new(6, "void", 0)))
		end
		
		def loadUsing
			i = 0
			j = 0
			usings(0).print
			
			while i < usingCount
				usings(i).print
				while j < moduleCount
					if usings(i) == modules(j).name
						("load " + modules(j).name + " into " + modules(0).name).print
						modules(0).loadModule(modules(j))
					end
					j++
				end
				i++
			end
		end
		
		def build
			
		end
		
		def assemble
			"Assembling...".print
			
			fileName = path + "/" + name + ".asm"
			fileName.print
		end
		
		def link
			"Linking...".print
			
			command = path + "/" + name + ".obj"
			command.print
			
			i = 0
			
			while i < pathCount
				command = command + " /LIBPATH:" + pathes(i)
				i++
			end
			
			command = command + " Core\\Jade_Core.obj"
            command = command + " Core\\Jade_String.lib"
            command = command + " Core\\Kore_Int.lib"
            command = command + " Core\\Kore_Directory.lib "
			
			command = command + " /SUBSYSTEM:CONSOLE /FORCE:MULTIPLE"
			
			command.print
		end
		
		def execute
			"Executing...".print
		end
		
		self def load(appPath as string) as Program
			return Program.new(appPath, appPath)
		end
	end
end