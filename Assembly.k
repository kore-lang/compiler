module Compiler
	class Assembly
		lines as string()
		lineCount as int
		
		limit as int
		
		def new
			limit = 20000
		
			lines = string(limit)
			lineCount = 0
		end
	
		def write(line as string)
			lines(lineCount) = line
			lineCount++
			
			if (lineCount == limit) then ("require assembly extension above " + limit.string).print
		end
		
		def write(line as string, number as int)
			lines(number) = line
		end
		
		def print
			i = 0
			while i < lineCount
				lines(i).print
				i++
			end
		end
		
		def save(fileName as string)
			file = File.new(fileName, FileMode.Write)
			
			i = 0
			while i < lineCount
				file.write(lines(i) + string.newLine)
				i++
			end
			
			file.close
		end
		
		// Jump over a line.
		def jump as int
			lines(lineCount) = string.empty
			lineCount++
			
			return lineCount - 1
		end
	end
end