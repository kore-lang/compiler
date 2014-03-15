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
			
			// Depth initialization.
			addDepth(Token.Def, 0)
		end
		
		def container as Module
			return bfunction.fmodule
		end
		
		def mangledName as string
			return bfunction.mangledName
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
		
		// Adds a new depth to the current block.
		def addDepth(depthToken as Token, depthPointer as int)
			depth = Depth.new(depthToken, depthPointer)			
			depthes(depthCount) = depth
			depthCount++
			
			assembly = depth.assembly
		end
		
		// Defines the current depth for assembly writing.
		def setWriteDepth(i as int)
			if depthCount - i >= 1
				assembly = depthes(depthCount - i - 1).assembly
			end
		end
		
		// Returns the current depth
		def getDepth(i as int) as Depth
			if depthCount >= 1
				if i < depthCount
					return depthes(depthCount - i - 1)
				else
					error("Internal error : depth overflow")
				end
			else
				error("Internal error : local block has no depth")
			end
			
			return null
		end
		
		// Delete the current depth.
		def deleteDepth
			if depthCount > 1
				// Copy its content to its predecessor.
				newAssembly = depthes(depthCount - 2).assembly
				assembly.writeTo(newAssembly)
				
				// Restore the previous depth
				depthCount--
				assembly = newAssembly
			else
				error("closing non-existing depth")
			end
		end
		
		def getType(typeName as string) as Type
			return bfunction.fmodule.getType(typeName)
		end
		
		def typeExists(typeName as string) as bool
			return bfunction.fmodule.typeExists(typeName)
		end
		
		def build(blockAssembly as Assembly)
			parseAndAssemble
			
			// Reduce the block stack if needed.
			if stack > 0 then blockAssembly.write("sub esp," + stack.string)
			
			// Copy from the local assembly to the global one.
			assembly.writeTo(blockAssembly)
			
			// Restore the stack.
			if stack > 0 then blockAssembly.write("add esp," + stack.string)
			
			blockAssembly.write("end_" + bfunction.mangledName + ":")
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
					// Or operator.
					case Token.Or
						write("push eax")
						andExpression(true, context)
						write("pop ebx")
						
						write("or eax,ebx")
						
						context.type = getType("bool")
					end
					
					// Exclusive or.
					case Token.Xor
						write("push eax")
						andExpression(true, context)
						write("pop ebx")
						
						write("xor eax,ebx")
						
						context.type = getType("bool")
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
					
						while token == Token.And
							write("cmp eax,0")
							write("je " + label)
							
							subExpression(true, context)
							
							if token != Token.And then write(label + ":")
							
							context.type = getType("bool")
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
						type = term(true, Context.new(context)).type
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
							
							default
								error("can not add types '" + context.type.name + "' and '" + type.name + "'")
							end
						end
					end
					
					// Subtract the current result by the next term.
					case Token.Minus
						write("push eax")
						type = term(true, Context.new(context)).type
						write("pop ebx")
						
						switch context.type.id
							case BaseType.Int.int 
								write("sub ebx,eax")
								write("mov eax,ebx")
							end

							case BaseType.Float.int
								write("fsubp st1,st0")
							end
							
							default
								error("can not subtract type '" + context.type.name + "' by type '" + type.name + "'")
							end
						end
					end
					
					// Variable assignation.
					case Token.Assign //, Token.SelfAdd, Token.SelfSub, Token.SelfMul, Token.SelfDiv
						if context.isAssignable
							//context.isAssignable = false
							
                            // Keep the type of the expression result to assign.
							write("push eax")
							type = expression(true, Context.new(context)).type
							write("mov ebx,eax")
							write("pop eax")
							
                            // Use this type if the local context is not strongly typed.
							if context.type.id == BaseType.Void.int then context.type = type
							
							// Proper assignation.
							switch context.type.id
								case BaseType.Bool.int
									write("mov byte[eax],bl")
								end
								
								case BaseType.Float.int
									write("fstp dword[eax]")
								end
							
								default
									write("mov [eax],ebx")
								end
							end
						else
							error("can not assign in this context")
						end
					end
					
					// Equality and non equality.
					case Token.Eq, Token.Neq
					
						// Keep the info about the operator.
						equal = token == Token.Eq
						
						write("push eax")
						subExpression(true, context)
						write("pop ebx")
						
						switch context.type.id
							case BaseType.Bool.int
								write("cmp eax,ebx")
							end
						
							case BaseType.Int.int
								write("cmp eax,ebx")
							end
							
							case BaseType.Float.int
								write("fcompp")
								write("fstsw ax")
								write("sahf")
							end
							
							case BaseType.String.int
								write("push eax")
								write("push ebx")
								write("call _cmp_string")
								write("add esp,8")
								write("cmp eax,1")
							end
						end
						
						// Clean EAX.
						write("mov eax,0")
						
						if equal
							write("sete al")
						else
							write("setne al")
						end
						
						context.type = getType("bool")
					end
					
					// For any basic comparison.
					case Token.Gte, Token.Gt, Token.Lte, Token.Lt
						operator = token
					
						term(true, context)
						
						// Performs a comparison that updates the flags.
						switch context.type.id
							case BaseType.Int.int
								write("cmp eax,ebx")
							end
							
							case BaseType.Float.int
								write("fcompp")
								write("fstsw ax")
								write("sahf")
							end
						end
						
						write("mov eax,0")
						
						// Comparison operator is translated to ASM.
						switch operator
							case Token.Gte
								write("setbe al")
							end
							case Token.Gt
								write("setb al")
							end
							case Token.Lte
								write("setae al")
							end
							case Token.Lt
								write("seta al")
							end
						end
						
						// Comparison always returns a boolean type.
						context.type = getType("bool")
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
									
									// Allocation code.
									write("push " + baseClass.size.string)
									write("call malloc")
									write("add esp,4")
									
									// Check if we explicitly implemented a 'new' method.
									if !baseClass.functionExists(value) then return context
								end
								
								// Pointer indirection if needed.
								if context.level > 0
									write("mov eax,[eax]")
								end
								
								// Checking if we're trying to convert.
								if typeExists(value)
									"Converting".print
									
								// If we're working on a member variable.
								elsif baseClass.fieldExists(value)
									field = baseClass.getField(value)
									
									// Adding field offset relatively to the "this" address.
									write("add eax," + field.offset.string)
									
									context.type = field.type
									
									// Indirects if possible.
									if token(1) == Token.Dot 
										term(true, context)
									elsif token(1) == Token.Assign 
										subExpression(true, context)
									else
										indirects(context, field.type)
									end
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
			if nextToken then getToken
			
			switch token
			
				// Null keyword loads 0.
				case Token.Null
					write("mov ebx,eax")
					write("mov eax,0")
					
					if token(-1) != Token.Case then getToken
				end
			
				// Boolean loads to 1 or 0 depending if the value is true or false.
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
				
				// Loads a plain integer.
				case Token.Integer
					write("mov ebx,eax")
					write("mov eax," + value)
					
					//switch context.type.id
					//end
					
					if token(-1) != Token.Case then getToken
					
					overType(context, "int")
				end
				
				// Floating point number.
				case Token.Float
					
				end				
				
				// Loads string pointer.
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
						
						// Array instanciation.
						if getToken == Token.Lp
						else
							context.type = type
						end
						
						context.level = 0
						
					// Checking local class methods.
					elsif bfunction.fclass != null and bfunction.fclass.functionExists(name)
						("call method " + name).print
						
					// Then checking module functions.
					elsif container.functionExists(name)
						("call function " + name).print
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
								v = getVariable("this")
								write("mov eax,[ebp-" + v.offset.string + "]")
								write("add eax," + variable.offset.string)
							end
						end
						
						// Get the next token if we're not declaring a variable.
						// Allows for example to get the assign sign.
						if !variableDeclaration then getToken
						
						// Update the buffer with assignation content.
						if variableDeclaration then buffer.writeTo(assembly)
						
                        // Transforms address into data if the next token isn't linked to some kind of pointer work.
						if token != Token.Dot and token != Token.Assign then indirects(context, variable.type)
					end
				end
				
				// Negate the value.
				case Token.Minus
					primary(true, context)
					
					switch context.type.id
						case BaseType.Bool.int
							error("can't negate 'bool' type")
						end
						
						case BaseType.Int.int
							write("neg eax")
						end
						
						case BaseType.Float.int
							write("fchs")
						end
					end
				end
				
				// Ignore a starting plus sign.
				case Token.Plus
					primary(true, context)
				end
				
				// Bits inversion.
				case Token.Not
					term(true, context)
					
					switch context.type.id
						case BaseType.Bool.int
							write("cmp eax,0")
							write("sete al")
						end
						
						case BaseType.Int.int
							write("not eax")
						end
						
						case BaseType.Float.int
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
				
				// Returns to the end of the current block.
				case Token.Return
				//	expression(true, 
					
				end
				
				// Logical test.
				case Token.If				
					addDepth(Token.If, pointer)
					
					setWriteDepth(1)
					
					// Gets the expression for the test.
					expression(true, Context.new(getType("bool")))
					
					write("cmp eax,1")
					write("je " + mangledName + "_if" + getDepth(0).pointer.string)
					
					setWriteDepth(0)
					
					write(mangledName + "_if" + getDepth(0).pointer.string + ":")
					
					if token == Token.Then then primary(false, context)
				end
				
				// Inverse condition.
				case Token.Else
					if getDepth(0).type == Token.If
						write("jmp " + mangledName + "_endif" + getDepth(0).pointer.string)
					
						setWriteDepth(1)
						write("jmp " + mangledName + "_else" + getDepth(0).pointer.string)
						
						setWriteDepth(0)
						write(mangledName + "_else" + getDepth(0).pointer.string + ":")
						
						// Check if there is a then.
						if token == Token.Then then primary(false, context)
					else
						error("'else' keyword out of place")
					end
				end
				
				// Filtered inverse condition.
				case Token.Elsif
					if getDepth(0).type == Token.If
						write("jmp " + mangledName + "_endif" + getDepth(0).pointer.string)
						
						setWriteDepth(1)
						
						context.isAssignable = false
						expression(true, Context.new(getType("void")))
						
						// Code used for the test, which must be true to continue.
						write("cmp eax,1")
						write("je " + mangledName + "_elsif" + pointer.string)
						
						setWriteDepth(0)
						
						write(mangledName + "_elsif" + pointer.string + ":")
						
						// Check if there is a then.
						if token == Token.Then
							context.isAssignable = true
							primary(false, context)
						end
					else
						error("'elsif' keyword out of place")
					end
				end
				
				// Logical test termination on a single line.
				case Token.Then
					if token(-1) != Token.Eol
						switch getDepth(0).type
							case Token.If
								setWriteDepth(1)
								
								write("jmp " + mangledName + "_endif" + getDepth(0).pointer.string)
							
								setWriteDepth(0)
							
								context.level = 0
								
								expression(true, context)
								
								write(mangledName + "_endif" + getDepth(0).pointer.string + ":")
							end
							
							case Token.Case
								context.level = 0
								
								// Compute then expression.
								expression(true, context)
								
								write("jmp " + mangledName + "_switch" + getDepth(1).pointer)
							end
						end
							
						deleteDepth
					else
						error("'then' keyword out of place")
					end
				end
				
				// While loop
				case Token.While
					addDepth(Token.While, pointer)
					
					write(mangledName + "_while" + getDepth(0).pointer.string)
					
					expression(true, context)
					
					write("cmp eax,0")
					write("je " + mangledName + "_endwhile" + getDepth(0).pointer.string)
				end
				
				// Switch opening.
				case Token.Switch
					context.isAssignable = false
					
					// Compute the expression.
					expression(true, context)
					
					// Saves the current result in the stack.
					write("push eax")
					
					addDepth(Token.Switch, pointer)
				end
				
				// Conditionnal case
				case Token.Case
					if getDepth(0).type == Token.Switch
						addDepth(Token.Case, pointer)
					
						setWriteDepth(2)
					
						// Repeating the case check for each option.
						repeat
							term(true, context)
							
							write("mov ebx,[esp]")
						
							switch context.type.id
								case BaseType.Float.int
									write("fcompp")
									write("fstsw ax")
									write("sahf")
								end
								
								case BaseType.String.int
									write("push eax")
									write("call _cmp_string")
									write("add esp,4")
									write("cmp eax,1")
								end
								
								default								
									write("cmp eax,ebx")
								end
							end
							
							write("je " + mangledName + "_case" + getDepth(0).pointer.string)
							
							// Get the next token if we have a case list.
							if token(1) == Token.Comma then getToken
							
						until token != Token.Comma
						
						setWriteDepth(0)
						
						write(mangledName + "_case" + getDepth(0).pointer.string + ":")
						write("add esp,4")
					else
						error("'case' must be included in a switch structure")
					end
				end
				
				// Switch default case
				case Token.Default
				
					// Default token is valid only in a switch block.
					if getDepth(0).type == Token.Switch
						addDepth(Token.Default, pointer)
						
						setWriteDepth(2)
						write("jmp " + mangledName + "_default" + getDepth(0).pointer.string)
						
						setWriteDepth(0)
						write(mangledName + "_default" + getDepth(0).pointer.string + ":")
						
						// Removes the push made for the switch.
						write("add esp,4")
					else
						error("'default' must be included in a switch structure")
					end
				end
				
				// End an internal structure/depth.
				case Token.End
					if getDepth(0) != null
						switch getDepth(0).type
							// Close a switch structure.
							case Token.Switch
								setWriteDepth(1)
								
								write("add esp,4")
								write("jmp " + mangledName + "_switch" + getDepth(0).pointer.string)
								
								setWriteDepth(0)
								
								write("add esp,4")
								write(mangledName + "_switch" + getDepth(0).pointer.string + ":")
							end
						
							// Closes a case of a switch.
							case Token.Case
								// Delete the depth of each extra case.
								while getDepth(1).type != Token.Switch
									deleteDepth
								end
								
								write("jmp " + mangledName + "_switch" + getDepth(1).pointer.string)
							end
						
							// Ends any depth of a logical test.
							case Token.If
								setWriteDepth(1)
								write("jmp " + mangledName + "_endif" + getDepth(0).pointer.string)
								
								setWriteDepth(0)
								write(mangledName + "_endif" + getDepth(0).pointer.string + ":")
							end
							
							// Ends a while...end loop.
							case Token.While
								write("jmp " + mangledName + "_while" + getDepth(0).pointer.string)
								write(mangledName + "_endwhile" + getDepth(0).pointer.string + ":")
							end
						end
						
						deleteDepth
					else
						error("'end' keyword out of place")
					end
				end
				
				// Inline assembler.
				case Token.Asm
					while getToken != Token.End
						write(value)
					end
				end
			end
			
			return context
		end
		
		// Overwrites the current type if it is void.
		def overType(context as Context, typeName as string)
			if context.type.id == BaseType.Void.int then context.type = getType(typeName)
		end
		
		// Adds derefencing code for the given type.
		def indirects(context as Context, type as Type)
			switch type.id
				case BaseType.Bool.int
					write("movzx eax,byte[eax]")
				end
				
				case BaseType.Int.int								
					write("mov eax,[eax]")
				end
			end
			
			context.level = context.level - 1
		end
		
		// Call a method.
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
			else
				error("type " + baseClass.name + " has no function " + name)
			end
			
			// If we have to perform a chained call.
			if token == Token.Dot
				term(false, context)
			end
		end
	end
end