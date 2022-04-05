"
RISCV64 JIT Compiler using duplicated memory access instructions:
- for loads: lb, lh, lw, ld, lhu, lwu
- for stores: sb, sh, sw, sd

"
Class {
	#name : #CogOutOfLineLiteralsRiscV64RIMICompiler,
	#superclass : #CogOutOfLineLiteralsRiscV64Compiler,
	#category : #'VMMaker-JIT'
}

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> loadDoubleWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"ld1: Loads eight bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31           20 19     15 14    12 11     7 6          0
	|  	offset[11:0  |   rs1   |  011   |   rd   |   0000011  | -> 0001011
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r011 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011)
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> loadUnsignedByteFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lbu1: Loads one byte from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result.
	
	 31            20 19    15 14    12 11     7 6         0
	|  	offset[11:0]  |  rs1   |  100   |   rd   |   0000011  | -> 0001011
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r100 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> loadUnsignedHalfWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lhu1: Loads two bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result.
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  101   |   rd   |   0000011  | -> 0001011
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r101 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> loadUnsignedWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lwu: Loads four bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  110   |   rd   |   0000011  | -> 0001011
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> storeByteFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sb1: Stores the least-significant byte in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  000   |  offset[4:0]  |   0100011  | -> 0101011
	"

	| signExtendedOffset |
	self flag: #DONE.	
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  offset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r000 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> storeDoubleWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sd: Stores the eight bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  011   |   offset[4:0]   |   0100011  | -> 0101011
	"

	| signExtendedOffset |
	self flag: #DONE.	
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  signExtendedOffset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20)
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r011 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> storeHalfWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sw1: Stores the two lteast-significant bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  001   |  offset[4:0]  |   0100011  | -> 0101011
	"

	| signExtendedOffset |
	self flag: #DONE.	
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  offset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r001 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]

{ #category : #'machine code instruction' }
CogOutOfLineLiteralsRiscV64RIMICompiler >> storeWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sw: Stores the four lteast-significant bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  010   |  offset[4:0]  |   0100011  | -> 0101011
	"

	| signExtendedOffset |
	self flag: #DONE.	
	"Check for sign and size"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ ((((((
	  offset >> 5 bitAnd: 16r7f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r010 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100011
]
