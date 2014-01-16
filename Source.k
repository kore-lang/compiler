module Compiler
	class Source
		fileName as string
		name as string
		
		lines as CodeLine()
		lineCount as int
		
		def new(sourceFile as string)
			fileName = sourceFile
			name = fileName.lastSegment("\\")
			
			lines = CodeLine(1000)
			lineCount = 0
		end
		
		def addLine(line as CodeLine)
			lines(lineCount) = line
			lineCount++
		end
		
		self def load(sourceFile as string) as Source
			source = Source.new(sourceFile)
						
			file = File.new(sourceFile, FileMode.Read)
			
			i = 0
			while not file.eof
				i++
				source.addLine(CodeLine.new(source, file.readString, i))
			end
			
			("Loaded " + sourceFile).print
			
			return source
		end
	end
end