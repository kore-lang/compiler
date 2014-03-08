module Compiler
	class AssemblyBuffer
		lines as string()
		lineCount as int
		limit as int
		
		def new(bufferSize as int)
			lines = string(bufferSize)
			lineCount = 0
			limit = bufferSize
		end
		
		
		// Add the line at the end of the buffer.
		def write(line as string)
			lines(lineCount) = line
			lineCount++
			
			if (lineCount == limit) then ("require assembly extension above " + limit.string).print
		end
		
		// Write the line at the specified position.
		def write(line as string, number as int)
			lines(number) = line
		end
	
		def writeTo(assembly as Assembly)
			i = 0
			while i < lineCount
				assembly.write(lines(i))
				i++
			end
		end
				
		def jump as int
			lines(lineCount) = string.empty
			lineCount++
			
			return lineCount - 1
		end
	end
end