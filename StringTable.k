module Compiler
	// String table for storing string/string data.
	class StringTable
		count as int
		
		keys as string()		
		values as string()
	
		def new			
			count = 0
			
			keys = string(100)
			values = string(100)
		end
		
		def add(key as string, value as string)
         (key.upperFirst + " = " + value).print
			keys(count) = key
			values(count) = value
			count++
		end
		
		def get(key as string) as string
			i = 0
			while i < count
				if keys(i) == key then return values(i)
				i++				
			end
			
			return null
		end
      
      def hasKey(key as string) as bool
			i = 0
			while i < count
				if keys(i) == key then return true
				i++				
			end
			
			return false
      end
	end
end