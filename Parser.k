module Compiler
	class Parser
		pointer as int

		tokens as LexToken()
		count as int

		pmodule as Module

		def new(lexer as Lexer)
			tokens = lexer.tokens
			count = lexer.pointer

			pointer = 0
		end

		/// <summary>
		/// Moves the pointer to the next token/value pair and returns the result.
		/// </summary>
		def getToken as Token
			if pointer < count 
				pointer++
				return tokens(pointer).token
			else
				return Token.ProgEnd
			end
		end

		/// <summary>
		/// Returns the current token.
		/// </summary>
		def token as Token
			return tokens(pointer).token
		end

		/// <summary>
		/// Returns a token with an offset from the current one.
		/// </summary>
		/// <param name="offset">Offset from the current pointer of the token to return.</param>
		def token(offset as int) as Token
			index = pointer + offset

			if index >= 0 and index < count
				return tokens(index).token
			else
				"Internal error : token pointer out of bounds".print
				return Token.Eol
			end
		end

		/// <summary>
		/// Returns the string value of the current token.
		/// </summary>
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

		/// <summary>
		/// Whole program parser.
		/// </summary>
		/// <param name="program">Program to parse.</param>
		def parse(program as Program) as bool
			while getToken != Token.ProgEnd
				switch token
					case Token.Module
						if token(-1) == Token.Eol
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

					// Using keyword adds a module dependance to the program.
					case Token.Using
						if getToken == Token.Name
							program.addUsing(value)
						else
							error("using keyword waits for a module name")
						end
					end
				end
			end
		end

		/// <summary>
		/// Module parser.
		/// </summary>
		/// <param name="currentModule">Module in which one data will be added.</param>
		def parse(currentModule as Module) as bool
			pmodule = currentModule
						
			while getToken != Token.ProgEnd
				switch token
					case Token.End 
						return true
					end

					case Token.Include
						if getToken == Token.String
							currentModule.addInclude(value)
						else
							error("include waits for a file name")
						end
					end
				
					case Token.Def
						if token(-1) == Token.Eol
							if getToken == Token.Name
								newFunction = currentModule.addFunction(value)

								if getToken == Token.Lp
									if getToken != Token.Rp
										repeat
											if token == Token.Name		

												// Waiting for the typing of the argument.
												if token(1) == Token.As
													newArgument = newFunction.addArgument(value)
													newArgument.level = 1
													
													getToken
													
													// The type name is required.
													if getToken == Token.Name
														newArgument.key = value
														
														// If the parameter is an array, we increase its level.
														if token(1) == Token.Array
															getToken
															newArgument.level = newArgument.level + 1
														end
													else
														error("type name waited after 'as' keyword")
													end
												else
													newArgument = newFunction.createAnonymousArgument(value)
													requireAlias = true
												end
												
												// Arguments must be separated by a comma, if it's not the case, we throw an error.
												if token(1) == Token.Comma
													getToken
												elsif token(1) != Token.Rp
													error("arguments must be separated by a comma")
												end
											end
										until getToken == Token.Rp
									else
										error("argument list is empty")
									end
									
									getToken
								else
								
									// No arguments : creating an empty one.
								//	newArgument = newFunction.addArgument("")
								//	newArgument.key = "void"
								end

								// switch token
									// case Token.Alias
									// end

									// case Token.As
									// end

									// case Token.Assign
									// end
								// end

								parse(newFunction.block)
							end
						end
					end

					// Module enumeration.
					case Token.Enum
						if token(-1) == Token.Eol
							if getToken == Token.Name
								newEnum = currentModule.addEnum(value)
								parse(newEnum)
							else
								error("'enum' waits for a name")
							end
						else
							error("'enum' keyword out of place")
						end
						
						Console.next
					end

					// Parsing class structure inside module.
					case Token.Class
						if token(-1) == Token.Eol
							if getToken == Token.Name
								newClass = currentModule.getOrCreateClass(value)						
								parse(newClass)
							else
								error("'class' waits for a name")
							end
						else
							error("'class' keyword out of place")
						end
						
						Console.next
					end
				end
			end

			return false
		end
		
		def parse(currentClass as Class) as bool
			while getToken != Token.ProgEnd
				switch token
					case Token.End 
						return true
					end
					
					// When meeting a name inside a class declaration, we create a new field.
					case Token.Name
						if token(-1) == Token.Eol
							newField = currentClass.addField(value)
							newField.level = 1
							
							// A field declaration MUST be followed by its type.
							if getToken == Token.As
								getToken
								
								newField.key = value
								
								getToken
								
								// When used as array, the pointer level is increased.
								if token == Token.Array
									newField.level = newField.level + 1
									getToken
								end
								
								// When followed by a '?', the field is set as nullable.
								if token == Token.Nullable
									newField.isNullable = true
									getToken
								end								
							else
								error("a class field must be followed by its type")
							end
						else
						end
					end
					
					// Class method.
					case Token.Def
						isFunction = false
						isStaticFunction = false
					
						if (token(-1) == Token.Eol) then isFunction = true
						if (token(-1) == Token.Static and token(-2) == Token.Eol) then isStaticFunction = true

						if isFunction or isStaticFunction
							requireAlias = false
							
							getToken
							
							if token == Token.Name or token == Token.New or token == Token.Delete// or token == Token.This							
								newFunction = currentClass.addFunction(value, pmodule, currentClass)
								
								newFunction.isStatic = isStaticFunction
								
								// If this is a constructor, it returns an object of the current class.
								if token == Token.New 
									newFunction.isConstructor = true
									newFunction.returnKey = currentClass.name
								end
								
								// Destructor.
								if token == Token.Delete then newFunction.isDestructor = true
								
								// Self-getter.
								//if token == Token.This then newFunction.isThis = true
						
								// If the function creation is ok.
								if newFunction != null
									if getToken == Token.Lp
										if getToken != Token.Rp
											repeat
												if token == Token.Name		

													// Waiting for the typing of the argument.
													if token(1) == Token.As
														newArgument = newFunction.addArgument(value)
														newArgument.level = 1
														
														getToken
														
														// The type name is required.
														if getToken == Token.Name
															newArgument.key = value
															
															// If the parameter is an array, we increase its level.
															if token(1) == Token.Array
																getToken
																newArgument.level = newArgument.level + 1
															end
														else
															error("type name waited after 'as' keyword")
														end
													else
														newArgument = newFunction.createAnonymousArgument(value)
														requireAlias = true
													end
													
													// Arguments must be separated by a comma, if it's not the case, we throw an error.
													if token(1) == Token.Comma
														getToken
													elsif token(1) != Token.Rp
														error("arguments must be separated by a comma")
													end
												end
											until getToken == Token.Rp
										else
											error("argument list is empty")
										end
										
										getToken
									else
									
										// No arguments : creating an empty one.
									//	newArgument = newFunction.addArgument("")
									//	newArgument.key = "void"
									end
									
									// Typing the function's return.
									if token == Token.As
										if getToken == Token.Name
											newFunction.returnKey = value
										
											// Array : increasing pointer level.
											if token(1) == Token.Array
												getToken
												newFunction.level = newFunction.level + 1
											end
										else
											error("function return must be a type name")
										end
										
										getToken
									end
									
									// Setter function.
									if token == Token.Assign
										if getToken == Token.Name
											newFunction.setterArgument = Field.new(value)
											
											// Type of the argument.
											if getToken == Token.As											
												if getToken == Token.Name then newFunction.setterTypeName = value
												
												if token(1) == Token.Alias then getToken
											else
												error("assignation parameter must be explictly typed")
											end
										end
									end									
									
									// Aliasing the function.
									if token == Token.Alias
										if getToken == Token.String
											newFunction.binding = value
										else
											error("alias argument must be a string")
										end
									elsif requireAlias
										error("use of anonymous arguments implies an alias")
									end
								end
								
								if not newFunction.isAlias then parse(newFunction.block)
							end
						else
							error("function name waited after 'def'")
						end
					end
					
					case Token.Eol, Token.Static
					end
					
					default
						error("keyword out of place : " + value + " " + token.int.string)
					end
				end
			end
		end

		// Parsing enumeration content.
		def parse(currentEnum as Enum) as bool
			while getToken != Token.ProgEnd
				switch token
					case Token.End 
						return true
					end
		
					case Token.Name
						name = value

						// If there's an explicit assignation, we need to retrieve its value.
						if getToken == Token.Assign
							if getToken == Token.Integer
								currentEnum.addField(name, value.int)
							else
								error("only integers can be assigned to an enumeration field")
							end
						elsif token == Token.Comma or token == Token.Eol
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
			currentBlock.addToken(LexToken.new(Token.Eol, string.empty))
		
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