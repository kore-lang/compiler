module Compiler
	class Assembly
	
		// Buffers list.
		buffers as AssemblyBuffer()
		bufferCount as int
		
		def new
			limit = 20000
		
			buffers = AssemblyBuffer(100)
			buffers(0) = AssemblyBuffer.new(limit)
			bufferCount = 1
		end
	
		// Write the line to the end of the current buffer.
		def write(line as string)
			buffers(bufferCount - 1).write(line)
		end
		
		// Write the line at the specified buffer's position.
		def write(line as string, number as int)		
			buffers(bufferCount - 1).write(line, number)
		end
		
		// Write the assembly to another one.
		def writeTo(assembly as Assembly)		
			i = 0
			while i < lineCount
				assembly.write(lines(i))
				i++
			end			
		end
		
		// Return the line count for the current buffer.
		def lineCount as int
			return buffers(bufferCount - 1).lineCount
		end
				
		// Return the specified line of the current buffer.
		def lines(i as int) as string
			l = buffers(bufferCount - 1).lines		
			return l(i)
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
			return buffers(bufferCount - 1).jump
		end
		
		// Starts a new buffer.
		def startBuffer
			bufferCount++
			buffers(bufferCount - 1) = AssemblyBuffer.new(100)
			
		//	("Increased assembly buffers to " + bufferCount.string).print
		end
		
		// End the current buffer and returns it.
		def stopBuffer as AssemblyBuffer
			buffer = buffers(bufferCount - 1)
			bufferCount--
			
		//	("Reduced assembly buffers to " + bufferCount.string).print
			
			return buffer
		end
	end
end