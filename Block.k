module Compiler
	class Block
		id as int
		stack as int
		
		pointer as int

		tokens as LexToken()
		tokenCount as int
		
		depthes as Depth()
		depthCount as int

		variables as Variable()
		variableCount as int
		
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

			variables = Variable(100)
			variableCount = 0
			
			strings = string(200)
			stringCount = 0
			
			pointer = 0
			
			bfunction = blockFunction
		end
		
		def container as Module
			return bfunction.fmodule
		end
		
		def createVariable(name as string, type as Type, level as int) as Variable
			variable as Variable
			variable = null
			
			if !variableExists(name)
				variable = Variable.new(name)
				variable.type = type
				
				stack = stack + type.size
				
				variable.offset = stack
				variable.level = level
				variable.scope = Scope.Local
				
				variables(variableCount) = variable
				variableCount++
			else
				error("there is already a variable " + name)
			end
			
			return variable
		end
		
		def createInstanceVariable(field as Field) as Variable
			variable = field.createVariable
			
			variables(variableCount) = variable
			variableCount++
			
			return variable
		end
		
		def createArgumentVariable(name as string, type as Type, level as int, offset as int) as Variable
			variable = Variable.new(name)
			variable.type = type
			variable.offset = offset
			variable.level = level
			variable.scope = Scope.Local
			
			variables(variableCount) = variable
			variableCount++
			
			return variable
		end
		
		// Check if the variable exists or not.
		def variableExists(name as string) as bool
			i = 0
			while i < variableCount
				if variables(i).name == name then return true
				i++
			end
			
			return false
		end
		
		def getVariable(name as string) as Variable
			i = 0
			while i < variableCount
				if variables(i).name == name then return variables(i)
				i++
			end
			
			return null
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
		
		def typeExists(typeName as string) as bool
			return bfunction.fmodule.typeExists(typeName)
		end
		
		def build(blockAssembly as Assembly)
			assembly = blockAssembly
			
			stackLine = assembly.jump
			
			parseAndAssemble
			
			assembly.write("end_" + bfunction.mangledName + ":")
			
			// Reduce and increase the function stack if needed.
			if stack > 0
				assembly.write("sub esp," + stack.string, stackLine)
				assembly.write("add esp," + stack.string)
			end
		end
		
		def write(line as string)
			assembly.write(line)
		end
		
		def parseAndAssemble
			while pointer + 1 < tokenCount
				expression(true, Context.new(getType("void")))
			end
		end
		
		// Skips some tokens.
		def skipToken(quantity as int)
			pointer = pointer + quantity
		end
		
		// Moves the pointer to the next token and returns it.
		def getToken as Token
			t = tokenCount - 1
			if pointer < t
				pointer++
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
				
					// Add the next tere to the current result.
					case Token.Plus
						write("push eax")
						term(true, Context.new(context))
						write("pop ebx")
						
						switch context.type.id
							case BaseType.Int.int 
								write("add eax,ebx")
							end

							case BaseType.Float.int
								write("faddp st1,st0")
							end

							case BaseType.String.int
								write("push eax")
								write("push ebx")
								write("call _add_string")
								write("add esp,8")		
							end
						end
					end
					
					// Subtract the current result by the next term.
					case Token.Minus
						write("push eax")
						term(true, Context.new(context))
						write("pop ebx")
						
						switch context.type.id
							case BaseType.Int.int 
								write("sub ebx,eax")
								write("mov eax,ebx")
							end

							case BaseType.Float.int
								write("fsubp st1,st0")
							end
						end
					end
					
					case Token.Assign //, Token.SelfAdd, Token.SelfSub, Token.SelfMul, Token.SelfDiv
						if context.isAssignable
							context.isAssignable = false
							
                            // Keep the type of the expression result to assign.
							write("push eax")
							type = expression(true, Context.new(context)).type
							write("mov ebx,eax")
							write("pop eax")
							
                            // Use this type if the local context is not strongly typed.
							if context.type.id == BaseType.Void.int then context.type = type
							
							// Proper assignation.
							switch context.type.id
								case BaseType.Int.int
									write("mov [eax],ebx")
								end
							end
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
					case Token.Mul
						switch context.type.id
							case BaseType.Int.int
								primary(true, Context.new(context))
								write("imul ebx")
							end
							
							case BaseType.Float.int
								primary(true, Context.new(context))
								write("fmulp")
							end
						end					
					end
										
					case Token.Div
						switch context.type.id
							case BaseType.Int.int
								write("push ebx")
								
								primary(true, Context.new(context))
								
								// Invert divisor and dividend.
								write("push eax")
								write("mov eax,ebx")
								write("pop ebx")
								
								write("mov edx,0")
								write("idiv ebx")
								write("pop ebx")
							end
							
							case BaseType.Float.int
								primary(true, Context.new(context))
								write("fdivp st1,st0")
							end
						end					
					end
					
					
					case Token.Dot
						switch context.type.objectType
							// Analyzing an enumeration post-dot element.
							case ObjectType.Enumeration
							end
							
							// Analyzing a class post-dot element.
							case ObjectType.Class
								getToken								
								baseClass = container.getClass(context.type.name)
								
								isNew = false
								
								// Code for instancier call.
								if token == Token.New
									isNew = true
								end
								
								// Pointer indirection if needed.
								if context.level > 0
									write("mov eax,[eax]")
								end
								
								// Checking if we're trying to convert.
								if typeExists(value)
									"Converting".print
								elsif baseClass.fieldExists(value)
									"Field".print
								elsif baseClass.functionExists(value)
									call(context, baseClass, value)
								else
									if !isNew then error("class " + baseClass.name + " has no element " + value)
								end
							end
						end
					end
					
					default then return context
				end
			loop
		end
		
		def primary(nextToken as bool, context as Context) as Context
			if nextToken.int > 0 then getToken
			
			switch token
				case Token.Boolean
					write("mov ebx,eax")
				
					if value == "true"
						write("mov eax,1")
					else
						write("mov eax,0")
					end
					
					if token(-1) != Token.Case then getToken
					
					overType(context, "bool")
				end
				
				case Token.Integer
					write("mov ebx,eax")
					write("mov eax," + value)
					
					//switch context.type.id
					//end
					
					if token(-1) != Token.Case then getToken
					
					overType(context, "int")
				end
				
				case Token.String
					write("mov ebx,eax")
					write("mov eax,_S" + addString(value).string)
					
					if token(-1) != Token.Case then getToken
					
					overType(context, "string")
				end
								
				case Token.Name
					name = value
					
					// Loading the dectected type as the default one. 
					if typeExists(name)
						type = getType(name)
						
						// Array instanciation
						if getToken == Token.Lp
						else
							context.type = type
						end
						
						context.level = 0
						
					// If nothing works, check variables.
					else
						arrayDeclaration = false
						variableDeclaration = false
						inDeclaration = false
					
						variable as Variable
						variable = null
						
						buffer as AssemblyBuffer
						buffer = null
						
						// If there isn't any variable of this name, try to create it.
						if not variableExists(name)
							variableDeclaration = true
							
							assembly.startBuffer
							
							// Explicit variable typing.
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
								//skipToken(1)
								
								expression(true, context)
							elsif token(1) == Token.In
								expression(true, context)
								inDeclaration = true
							else
								error("can not determine type of " + name)
							end
							
							buffer = assembly.stopBuffer
														
							// Effectively creates the new variable.
							variable = createVariable(name, context.type, 1)
							
							//variable.offset
						else
							variable = getVariable(name)
						end
						
						context.type = variable.type
						context.level = variable.level
						
						// Loading the variable address (either stack or heap).
						switch variable.scope
							case Scope.Local, Scope.Class
								write("mov ebx,eax")
								write("lea eax,[ebp-" + variable.offset.string + "]")
							end
							
							case Scope.Instance
							end
						end
						
						// Get the next token if we're not declaring a variable.
						if !variableDeclaration then getToken
						
						// Update the buffer with assignation content.
						if variableDeclaration then buffer.writeTo(assembly)
						
                        // Transforms address into data if the next token isn't some kind of assignation.
						if token != Token.Dot && token != Token.Assign
							switch variable.type.id
								case BaseType.Bool.int
									write("movzx eax,byte[eax]")
								end
								
								case BaseType.Int.int								
									write("mov eax,[eax]")									
								end
							end
							
							context.level = context.level - 1
						end
					end
				end
				
				// Starts a new expression when encoutering a parenthesis.
				case Token.Lp
					//subContext = Context.new(context)
					//subContext.level = 0
					
					expression(true, context)
					
					if token != Token.Rp then error("irregular number of brackets")
					
					getToken
				end
			end
			
			return context
		end
		
		// Overwrites the current type if it is void.
		def overType(context as Context, typeName as string)
			if context.type.id == BaseType.Void.int then context.type = getType(typeName)
		end
		
		def call(context as Context, baseClass as Class, name as string)
			function as Function
			function = null
			
			context.isAssignable = false
		
			if context.type.id == BaseType.Float.int
			else
				write("push ebx")
				write("push eax")
			end
			
			line = assembly.jump
			
			argument = 0
			stackSize = 0
			
			getToken
			
			types = Type(10)
			typeCount = 0
			
			// Parameters list.
			if token == Token.Lp
				while token != Token.Eol
					
					// Check for the end of parameters list.
					if token == Token.Rp then break
					
					// Comma : going to the next argument.
					if token == Token.Comma
						// Check is there was a previous argument
						if argument == 0
							error("first parameter is empty")
						else
							argument++
						end
					end
					
					// Read the type emitted for each argument.
					type = expression(true, Context.new(getType("void"))).type
					
					if type.id != BaseType.Void.int
						types(typeCount) = type
						typeCount++
					else
						error("invalid argument")
					end
					
					
					write("mov dword [esp+" + stackSize.string + "],eax");
					
					stackSize = stackSize + type.size
					
					// switch type.id
					
						// case BaseType.Bool.int, BaseType.Int.int, BaseType.String.int
						// end
					
						
					// end
				end
			end
			
			// Setter function
			if token == Token.Assign
			end
			
			function = baseClass.getFunction(name, types, typeCount)
			
			// Calling the function if not null.
			if function != null
			
				// Increase stack size to allow arguments. Written at the position of the jumped line.
				if function.argumentSize > 0 then assembly.write("sub esp," + function.argumentSize.string, line)				
					
				function.isUsed = true
				
				write("call " + function.mangledName)
				
				// Restore stack size.
				if function.argumentSize > 0 then assembly.write("add esp," + function.argumentSize.string)				
				
				if function.name == "new" and !function.isAlias
					write("pop eax")
					write("pop ebx")
				else
					write("pop ebx")
					write("pop ebx")
				end
					
				//context.type = function.
			end
			
			// If we have to perform a chained call.
			if token == Token.Dot
				term(false, context)
			end
		end
	end
end