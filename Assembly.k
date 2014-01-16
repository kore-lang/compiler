module Compiler
	class Assembly
		lines as string()
		lineCount as int
		
		def new
			lines = string(10000)
			lineCount = 0
		end
	
		def write(line as string)
			lines(lineCount) = line
			lineCount++
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
	end
end