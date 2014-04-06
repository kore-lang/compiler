module Compiler
	class Source
		fileName as string
		name as string
		
		lines as CodeLine()
		lineCount as int
		
		def new(sourceFile as string)
			fileName = sourceFile
			name = fileName.lastSegment("\\")
			
			lines = CodeLine(2000)
			lineCount = 0
		end
		
		def addLine(line as CodeLine)
			lines(lineCount) = line
			lineCount++
		end
		
		self def load(sourceFile as string, program as Program) as Source
			source = Source.new(sourceFile)
						
			file = File.new(sourceFile, FileMode.Read)
			
         usingLoad = 0
			i = 0
			while not file.eof
				i++
            
            // Reads the line.
            line = file.readString
             
            // If it's an using, it's part of the config.
            if usingLoad == 0 
               if line.subString(0, 5) == "using"
                  use = string.empty
                  j = 6
                  while j < line.length
                     if !line.get(j).isSpace
                        use = use + line.get(j)
                     end
                     j++
                  end
                  
                  program.addUsing(use)
               else 
                  usingLoad = 1
			         source.addLine(CodeLine.new(source, line, i))
               end
            else            
			      source.addLine(CodeLine.new(source, line, i))
            end
			end
			
			("Loaded " + sourceFile).print
			
			return source
		end
	end
end