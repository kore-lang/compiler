module Compiler
	class Lexer
		inString as bool

		pointer as int

		/// <summary>
		/// Source code for the whole program.
		/// </summary>
		code as CodeLine()
		lines as int

		tokens as LexToken()

		line as string

		token as Token
		value as string

		def new(lexCode as CodeLine(), size as int)
			inString = false
			pointer = 0

			tokens = LexToken(10000)
			code = lexCode
	
			lines = size
		end

		def lex
			currentLine = 0

			tokens(pointer) = LexToken.new(Token.Eol, string.empty, code(0))

			// Going through each line of code.
			while currentLine < lines
				line = code(currentLine).text
				
				// Extract all tokens from the current line.
				repeat
					pointer++
					tokens(pointer) = LexToken.new(getToken, value, code(currentLine))
					value = string.empty
				until tokens(pointer).token == Token.Eol

				currentLine++
			end
		end

		// Get the next code token, ignoring spaces.
		def getToken as Token
			if line.length == 0 then return Token.Eol

			if not inString
				line = line.leftTrim
				if line.length == 0 then return Token.Eol
			end

			next = string.empty
			ch = line.get(0)
			line = line.erase(1)

			value = ch

			if line.length > 0 then next = line.get(0)

			switch ch
				case "(" 
					if next == ")"
						line = line.erase(1)
						return Token.Array
					end

					return Token.Lp
				end

				case ")" then return Token.Rp

				case "+"
					if next == "=" then return Token.SelfAdd
					
					return Token.Plus
				end
				
				case "-" 
					if next == "=" then return Token.SelfSub
					
					return Token.Minus
				end

				case "*" 
					if next == "=" then return Token.SelfMul
				
					return Token.Mul
				end
					
				case "/" 
					if next == "=" then return Token.SelfDiv
					if next == "/" then return Token.Eol

					return Token.Div
				end
					
				case "." then return Token.Dot

				case "!" 
					if next == "=" then return Token.Neq
					
					return Token.Not
				end
					

				case "=" 
					if next == "=" then return Token.Eq
				
					return Token.Assign
				end

				case ">"
					if next == "=" then return Token.Gte
					
					return Token.Gt
				end

				case "<"
					if next == "=" then return Token.Lte
	
					return Token.Lt
				end
				
				case ":" then return Token.Colon

				case "," then return Token.Comma

				case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
					//hasDot = false
				
					while line.length > 0 and line.get(0).isNumeric
						//if line.get(0) == "." then hasDot = true
					
						value = value + line.get(0)
						line = line.erase(1)
					end

					return Token.Integer
				end

				case "\""
					value = string.empty

					while line.length > 0 and line.get(0) != "\""

						// When encountering a backslash, the characters are escaped.
						if line.get(0) == "\\"
							line = line.erase(1)
							value = value + line.get(0)
						end

						value = value + line.get(0)
						line = line.erase(1)
					end

					// Remove the second quotation mark.
					if (line.length > 0) then line = line.erase(1)

					return Token.String
				end

				default
					if ch.isAlpha or ch == "_"

						// Getting the full alpha token.
						while line.get(0).isAlpha
							value = value + line.get(0)
							line = line.erase(1)						
						end

						switch value
							case "end" then return Token.End
							
							case "alias" then return Token.Alias

							case "module" then return Token.Module
							case "class" then return Token.Class
							case "enum" then return Token.Enum
		
							case "new" then return Token.New
							case "delete" then return Token.Delete

							case "def" then return Token.Def
							case "return" then return Token.Return

							case "if" then return Token.If
							case "elsif" then return Token.Elsif
							case "else" then return Token.Else
	
							case "then" then return Token.Then

							case "switch" then return Token.Switch
							case "case" then return Token.Case
							case "default" then return Token.Default

							case "as" then return Token.As

							case "do" then return Token.Do
							case "loop" then return Token.Loop
							case "while" then return Token.While
							case "repeat" then return Token.Repeat
							case "until" then return Token.Until

							case "true" then return Token.Boolean
							case "false" then return Token.Boolean

							case "not" then return Token.Not
							case "or" then return Token.Or
							case "xor" then return Token.Xor
							case "and" then return Token.And

							case "include" then return Token.Include
							case "using" then return Token.Using
							
							case "self" then return Token.Static

							default then return Token.Name	
						end
					end
				end
			end

			return Token.Error
		end
	end
end