module Compiler
	class Program
		pool as ClassPool
	
		modules as Module()
		moduleCount as int

		usings as string()
		usingCount as int

		def new
			pool = ClassPool.new
			
			modules = Module(10)
			moduleCount = 0

			usings = string(10)
			usingCount = 0
		end

		def addModule(name as string) as Module

			newModule = getModule(name)

			if newModule == null
				newModule = Module.new(name)
				modules(moduleCount) = newModule 
				moduleCount++
			end			

			return newModule
		end

		def getModule(name as string) as Module
			i = 0
			while i < moduleCount
				if modules(i).name == name then return modules(i)
				i++
			end

			return null
		end

		// Add a module name.
		def addUsing(name as string)
			usings(usingCount) = name
			usingCount++
		end
	end
end