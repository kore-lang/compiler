module Compiler
	class Lexer
		inString as bool

		pointer as int

		code as string()
		lines as int

		tokens as LexToken()

		line as string

		token as Token
		value as string

		def new(lexCode as string(), size as int)
			inString = false
			pointer = 0

			tokens = LexToken(10000)
			code = lexCode
	
			lines = size
		end

		def lex
			currentLine = 0

			tokens(pointer) = LexToken.new(Token.EOL, string.empty)

			// Going through each line of code.
			while currentLine < lines
				line = code(currentLine)

				// Extract all tokens from the current line.
				repeat
					pointer++
					tokens(pointer) = LexToken.new(getToken, value)
					value = string.empty
				until tokens(pointer).token == Token.EOL

				currentLine++
			end
		end

		// Get the next code token, ignoring spaces.
		def getToken as Token
			if line.length == 0
				"END".print
				return Token.EOL
			end

			if not inString
				line = line.leftTrim
				if line.length == 0 then return Token.EOL
			end

			next = string.empty
			ch = line.get(0)
			line = line.erase(1)

			value = ch

			if line.length > 0 then next = line.get(0)

			switch ch
				case "(" 
					if next == ")"
						line.erase(1)
						return Token.Array
					end

					return Token.LP
				end

				case ")" then return Token.RP

				case "+" then return Token.Plus
				case "-" then return Token.Minus

				case "*" then return Token.Mul
				case "/" 
					if next == "/" then return Token.EOL

					return Token.Div
				end
					
				case "." then return Token.Dot

				case "!" then return Token.Not

				case "=" 
					if next == "=" then return Token.EQ
				
					return Token.Assign
				end

				case ">"
					if next == "=" then return Token.GTE
					
					return Token.GT
				end

				case "<"
					if next == "=" then return Token.LTE
	
					return Token.LT
				end
				
				case ":" then return Token.Colon

				case "," then return Token.Comma

				case "0", "1", "2", "3", "4", "5", "6", "7", "8"
					value = value + ch

					while line.get(0).isNumeric
						value = value + line.get(0)
						line = line.erase(1)
					end

					return Token.Int
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

					if (line.length > 0) then line = line.erase(1)

					return Token.String
				end

				default
					if ch.isAlpha or ch == "_"

						while line.get(0).isAlpha
							value = value + line.get(0)
							line = line.erase(1)					
						end

						switch value
							case "end" then return Token.End

							case "module" then return Token.Module
							case "class" then return Token.Class
							case "enum" then return Token.Enum
	
							case "new" then return Token.New

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

							case "true" then return Token.True
							case "false" then return Token.False

							case "not" then return Token.Not
							case "or" then return Token.Or
							case "xor" then return Token.Xor
							case "and" then return Token.And

							case "include" then return Token.Include
							case "using" then return Token.Using

							default then return Token.Name	
						end
					end
				end
			end

			return Token.Error
		end
	end
end