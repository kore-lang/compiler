module Compiler
	class Block
		id as int
		stack as int

		tokens as LexToken()
		tokenCount as int
		
		depthes as Depth()
		depthCount as int

		variables as Variable()
		variableCount as int
		
		pointer as int
		
		assembly as Assembly
		
		bfunction as Function
		
		strings as string()
		stringCount as int

		def new(blockFunction as Function)
			id = 0
			stack = 0
		
			tokens = LexToken(2000)
			tokenCount = 0

			depthes = Depth(100)
			depthCount = 0

			variable = Variable(100)
			variableCount = 0
			
			strings = string(200)
			stringCount = 0
			
			pointer = 0
			
			bfunction = blockFunction
		end
		
		// Check if the variable exists or not.
		def variableExists(variableName as string) as bool
			i = 0
			while i < variableCount
				if variables(i).name == variableName then return true
				i++
			end
			
			return false
		end
		
		def addString(str as string) as int
			strings(stringCount) = str
			stringCount++
			return stringCount - 1
		end

		def addToken(blockToken as LexToken)
			tokens(tokenCount) = blockToken
			tokenCount++
			
			if tokenCount == 2000 then "token increase needed".print
		end
		
		def getType(typeName as string) as Type
			return bfunction.fmodule.getType(typeName)
		end
		
		def build(blockAssembly as Assembly)
			assembly = blockAssembly
							
			parseAndAssemble
		end
		
		def write(line as string)
			assembly.write(line)
		end
		
		def parseAndAssemble
			return
			while pointer + 1 < tokenCount
				expression(true, Context.new(getType("void")))
			end
		end
		
		// Moves the pointer to the next token and returns it.
		def getToken as Token
			t = tokenCount - 1
			if pointer < t
				pointer++
				("-> " + value).print
				return tokens(pointer).token
			end
			
			return Token.ProgEnd
		end
		
		// Returns the current token.
		def token as Token
			return tokens(pointer).token
		end
		
		// Current token with an offset.
		def token(offset as int) as Token
			if pointer + offset >= 0 and pointer + offset < tokenCount then return tokens(pointer + offset).token
			
			return Token.ProgEnd
		end
				
		// Returns the current value.
		def value as string
			return tokens(pointer).value
		end
		
		def error(message as string)
			tokens(pointer).error(message)
		end
				
		// Parse expression.
		def expression(nextToken as bool, context as Context) as Context
			andExpression(nextToken, context)
						
			do
				switch token
					case Token.Or
						write("push eax")
						andExpression(true, Context.new(context))
						write("pop ebx")
						
						write("or eax,ebx")
					end
					
					case Token.Xor
						write("push eax")
						andExpression(true, Context.new(context))
						write("pop ebx")
						
						write("xor eax,ebx")
					end
					
					default then return context
				end
			loop
		end
		
		def andExpression(nextToken as bool, context as Context) as Context
			subExpression(nextToken, context)
			
			do
				switch token
					case Token.And
						label = bfunction.mangledName + "_and" + pointer.string
					
						while getToken == Token.And
							write("cmp eax,0")
							write("je " + label)
							
							subExpression(true, context)
							
							if getToken != Token.And then write(label + ":")
						end
					end
					
					default then return context
				end
			loop
		end
		
		def subExpression(nextToken as bool, context as Context) as Context
			term(nextToken, context)
			
			do
				switch token
					case Token.Plus
						write("push eax")
						Term(true, Context.new(context))
						write("pop ebx")
						
						switch context.type.id
							case BaseType.Int.int then write("add eax,ebx")
							
							case BaseType.Float.int then write("faddp st1,st0")
							
							case BaseType.String.int
								write("push eax")
								write("push ebx")
								write("call _add_string")
								write("add esp,8")		
							end
						end
					end
					
					case Token.Minus
					end
					
					case Token.Assign
						if context.isAssignable
							context.isAssignable = false
							
                            // Keep the type of the expression result to assign.
							write("push eax")
							type = expression(true, Context.new(context)).type
							write("mov ebx,eax")
							write("pop eax")
							
                            // Use this type if the local context is not strongly typed.
							if context.type.id == BaseType.Void.int then context.type = type
							
							
						else
							error("can not assign in this context")
						end
					end
					
					default then return context
				end
			loop
		end
		
		def term(nextToken as bool, context as Context) as Context
			primary(nextToken, context)
			
			do
				switch token
				
					default then return context
				end
			loop
		end
		
		def primary(nextToken as bool, context as Context) as Context
			if nextToken.int > 0
				getToken
			end
			
			switch token
				case Token.Boolean
					write("mov ebx,eax")
				
					if value == "true"
						write("mov eax,1")
					else
						write("mov eax,0")
					end
					
					if token(1) != Token.Case then getToken
					
					overType(context, "bool")
				end
				
				case Token.String
					write("mov ebx,eax")
					write("mov eax,_S" + addString(value).string)
					
					if token(1) != Token.Case then getToken
					
					overType(context, "string")
				end
				
				case Token.Name
					arrayDeclaration = false
					variableDeclaration = false
					inDeclaration = false
				
					variableName = value
					variable = null
				
					// Creates the variable if it does not exist.
					if not variableExists(variableName)
						variableDeclaration = true
						
						// Explicit variable typing
						if token(1) == Token.As
							getToken
							
							// Variable's type.
							if getToken == Token.Name
								type = getType(value)
								
								// Array declaration.
								if token(1) == Token.Lp
									arrayDeclaration = true
									
									if token(2)
										expression(false, Context.new(context))
									end								
								elsif token(1) == Token.Dot
									write("mov ebx,eax")
									expression(true, Context.new(context))
									write("mov [ebx],eax")
								end
							end
						elsif token(1) == Token.Assign
							expression(true, context)
							"---".print
						elsif token(1) == Token.In
							expression(true, context)
							inDeclaration = true
						else
							error("can not determine type of " + variableName)
						end
					end
				end
			end
			
			return context
		end
		
		def overType(context as Context, typeName as string)
			b = 0
			b = BaseType.Void
		
			// Overwrite the current type if it is void.
			if context.type.id == b then context.type = getType(typeName)
		end
	end
end