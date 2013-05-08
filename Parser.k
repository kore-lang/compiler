module Compiler
	class Parser
		pointer as int

		tokens as LexToken()
		count as int

		module as Module

		def new(lexer as Lexer)
			tokens = lexer.tokens
			count = lexer.pointer

			pointer = 0
		end

		def parse
			"PARSE".print
		end

		// Moves the pointer to the next token/value pair.
		def getToken as Token
			if pointer < count 
				pointer++
				return tokens(pointer).token
			else
				return Token.ProgEnd
			end
		end

		def token as Token
			return tokens(pointer).token
		end

		def token(offset as int) as Token
			index = pointer + offset

			if index >= 0 and index < count
				return tokens(index).token
			else
				"Internal error : token pointer out of bounds".print
				return Token.EOL
			end
		end

		def value as string
			return tokens(pointer).value
		end

		def value(offset as int) as string
			index = pointer + offset

			if index >= 0 and index < count
				return tokens(index).value
			else
				"Internal error : token pointer out of bounds".print
				return string.empty
			end
		end

		def error(message as string) as bool
			("Error : " + message).print
			//return false
		end

		def parse(program as Program) as bool
			while getToken != Token.ProgEnd
				switch token
					case Token.Module
						if token(-1) == Token.EOL
							if getToken == Token.Name
								newModule = program.addModule(value)
								parse(newModule)
							else
								error("module keyword wait for a name")
							end
						else
							error("module keyword out of place")
						end
					end

					case Token.Using
						if getToken == Token.Name
							program.addUsing(value)
						else
							error("using keyword waits for a module name")
						end
					end

					default

						//value.print
					end
				end
			end
		end

		def parse(currentModule as Module) as bool
			"big".print
			while getToken != Token.ProgEnd
				switch token
					case Token.End then return true

					case Token.Include
						if getToken == Token.String
							currentModule.addInclude(value)
						else
							error("include waits for a file name")
						end
					end
				
					case Token.Def
						if token(-1) == Token.EOL
							if getToken == Token.Name
								function = currentModule.addFunction(value)

								if getToken == Token.LP
									if getToken != Token.RP
										repeat
// PARSE ARGS
										until getToken == Token.RP

										getToken
									else
										error("argument list for " + function.name + " is empty")
									end
								else
// NO ARG
								end	

								switch token
									case Token.Alias
									end

									case Token.As
									end

									case Token.Assign
									end
								end

								parse(function.block)

"regre".print
							end
						end
					end

					case Token.Enum
"test".print
						if token(-1) == Token.EOL
							if getToken == Token.Name
								newEnum = currentModule.addEnum(value)
							else
								error("enum waits for a name")
							end
						else
							error("enum keyword out of place")
						end
					end

					case Token.Class
						error("hey")
					end
				end
			end

			return false
		end

		def parse(currentEnum as Enum) as bool
			while getToken != Token.ProgEnd
				switch token
					case Token.End then return true
		
					case Token.Name
						name = value

						if getToken == Token.Assign
							currentEnum.addField(name, value.int)
						elsif token == Token.Comma or token == Token.EOL
							currentEnum.addField(name)
						else
							error("enum fields must be separated by a comma")
						end
					end
				end
			end

			return false
		end

		def parse(currentBlock as Block) as bool
			depth = 0

			while getToken != Token.ProgEnd
				switch token
					case Token.Then, Token.End, Token.Until
						if depth == 0
							return true
						else
							depth--
						end
					end

					case Token.Case, Token.While, Token.If, Token.For, Token.Repeat, Token.Switch, Token.Default
						depth++
					end
				end

				currentBlock.addToken(tokens(pointer))
			end

			return false
		end
	end
end