Kore Language Compiler
======================

How to compile ?
----------------

A Kore compiler is required to be able to compile this project. See https://github.com/kore-lang/kore for more informations.

### Documentation

#### What is the code pointer ?

The code pointer is an integer pointing to the index of a token in the token list of a block. Every token is read at least once by the code pointer.


#### What is the context ?

The context handles all the informations about the current location of the compiler's code pointer, which are :

##### Type

The current type, like "int" or "float", or any class or enumeration.

##### Level

The level indicates how many indirections are required in order to access the value of the current result.

For example, if an integer is loaded as the current result to be displayed in a console :

42.print

The value is immediately loaded, thus accessible, and does not require any indirection : the level is equal to 0. However, if we use an intermediate variable :

a = 42
a.print

What is loaded before the call to "print" is not the final value, it is the address of the variable "a". An indirection is needed : the level is equal to 1.

##### IsAssignable

In some cases, it is impossible to assign values, the assignability of the context tells if such an operation is possible.

##### IsAddress

Indicates if we want to read the address rather than the value. In such case, it means that the last level will never be indirected, so that we can have the pointer value.

##### IsNullable

Indicates if the current context is secured (not nullable), or not (nullable is true).