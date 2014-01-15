module Compiler
	class ClassPool
		classes as Class()
		count as int

		def new
			classes = Class(100)
		end

		def addClass(poolClass as Class)
			classes(count) = poolClass
			count++
		end
	end
end