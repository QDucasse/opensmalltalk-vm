Class {
	#name : #CogRiscV64Compiler,
	#superclass : #CogAbstractInstruction,
	#instVars : [
		'conditionOrNil'
	],
	#classVars : [
		'AL',
		'AddOpcode',
		'AndOpcode',
		'BicOpcode',
		'CArg0Reg',
		'CArg1Reg',
		'CArg2Reg',
		'CArg3Reg',
		'CC',
		'CMPMULOverflow',
		'CMPSMULL',
		'CPSRReg',
		'CS',
		'CmpNotOpcode',
		'CmpOpcode',
		'ConcreteFlagReg',
		'ConcreteIPReg',
		'ConcreteIPReg2',
		'ConcretePCReg',
		'ConcreteVarBaseReg',
		'EQ',
		'F0',
		'F1',
		'F2',
		'F3',
		'F4',
		'F5',
		'F6',
		'F7',
		'GE',
		'GEU',
		'GT',
		'HI',
		'LDMFD',
		'LE',
		'LR',
		'LS',
		'LT',
		'LTU',
		'MI',
		'MRS',
		'MSR',
		'MSUB',
		'MUL',
		'MoveNotOpcode',
		'MoveOpcode',
		'NE',
		'OrOpcode',
		'OverflowFlag',
		'PC',
		'PL',
		'RsbOpcode',
		'SDIV',
		'SMLALOpcode',
		'SMULH',
		'SMULL',
		'SP',
		'STMFD',
		'SubOpcode',
		'TstOpcode',
		'VC',
		'VS',
		'X0',
		'X1',
		'X10',
		'X11',
		'X12',
		'X13',
		'X14',
		'X15',
		'X16',
		'X17',
		'X18',
		'X19',
		'X2',
		'X20',
		'X21',
		'X22',
		'X23',
		'X24',
		'X25',
		'X26',
		'X27',
		'X3',
		'X4',
		'X5',
		'X6',
		'X7',
		'X8',
		'X9',
		'XorOpcode'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #accessing }
CogRiscV64Compiler class >> IPReg [
	"Answer the number of the general temp reg in the ARM APCS convention, IP"
	^ConcreteIPReg
]

{ #category : #translation }
CogRiscV64Compiler class >> ISA [
	"Answer the name of the ISA the receiver implements."
	^#riscv64
]

{ #category : #accessing }
CogRiscV64Compiler class >> PCReg [
	^ConcretePCReg
]

{ #category : #accessing }
CogRiscV64Compiler class >> VarBaseReg [
	"Answer the number of the reg we use to hold the base address of CoInterpreter variables"
	^ConcreteVarBaseReg
]

{ #category : #translation }
CogRiscV64Compiler class >> defaultCompilerClass [
	^ CogOutOfLineLiteralsRiscV64Compiler
]

{ #category : #translation }
CogRiscV64Compiler class >> filteredInstVarNames [
	"Edit such that conditionOrNil is amongst the char size vars opcode machineCodeSize and maxSize."
	^(super filteredInstVarNames copyWithout: 'conditionOrNil')
		copyReplaceFrom: 5 to: 4 with: #('conditionOrNil')
]

{ #category : #translation }
CogRiscV64Compiler class >> identifyingPredefinedMacros [

	^#('__aarch64__' '_M_ARM64')
]

{ #category : #'class initialization' }
CogRiscV64Compiler class >> initialize [

	"Initialize various RISCV instruction-related constants."
	"CogRiscV64Compiler initialize might be required to make changes effective"

	super initialize.
	self ~~ CogRiscV64Compiler ifTrue: [^self].

	"RISCV general registers"
	X0 := 0.
	X1 := 1.
	X2 := 2.
	X3 := 3.
	X4 := 4.
	X5 := 5.
	X6 := 6.
	X7 := 7.
	X8 := 8.
	X9 := 9.
	X10 := 10.
	X11 := 11.
	X12 := 12.
	X13 := 13.
	X14 := 14.
	X15 := 15.
	X16 := 16.
	X17 := 17.
	X18 := 18.
	X19 := 19.
	X20 := 20.
	X21 := 21.
	X22 := 22.
	X23 := 23.
	X24 := 24.
	X25 := 25.
	X26 := 26.
	X27 := 27. "Flag register"

	SP := X2. "Stack Pointer"
	LR := X1. "Link Register"
	
	"RISCV Floating Point Registers"
	F0 := 0.
	F1 := 1.
	F2 := 2.
	F3 := 3.
	F4 := 4.
	F5 := 5.
	F6 := 6.
	F7 := 7.
	"Function arguments registers"
	CArg0Reg := 0.
	CArg1Reg := 1.
	CArg2Reg := 2.
	CArg3Reg := 3.
	
	"Base register that will serve as anchor to trampoline between stacks"
	ConcreteVarBaseReg := X26.
	"X5 and X6 are temporary registers used as the intra procedural scratch registers"
	ConcreteIPReg := X5.
	ConcreteIPReg2 := X6.

	"Flag register for conditions"
	ConcreteFlagReg := X27.
	
	"Branch Condition Codes"
	EQ  := 2r000. "Equal"
	NE  := 2r001. "Not equal"
	GE  := 2r101. "Greater or Equal"
	GEU := 2r111. "Greater or Equal Unsigned"
	LT  := 2r100. "Less Than"
	LTU := 2r110. "Less Than Unsigned"
	
	


]

{ #category : #'class initialization' }
CogRiscV64Compiler class >> initializeAbstractRegisters [

	"Assign the abstract registers with the identities/indices of the relevant concrete registers."

	super initializeAbstractRegisters.

	"https://en.wikichip.org/wiki/risc-v/registers
	Caller saved Registers:
	X1     | RA    | Return Address Register
	X5 -7  | T0-2  | Temporary Registers
	X10-11 | A0-1  | Function Arguments / Return Values Registers 
	X12-17 | A2-7  | Function Arguments 
	X28-31 | T3-6  | Temporary Registers 
	
	Callee saved registers:
	X2     | SP    | Stack Pointer 
	X8     | S0/FP | Saved Register / Frame Pointer 
	X9     | S1    | Saved Register
	X18-27 | S2-11 | Saved Regsiters 
	
	X1 is LR.
	X8 is SP."
	
	self flag: #TODO.
	CallerSavedRegisterMask := self registerMaskFor: 3 and: 4.

	TempReg := X22.
	ClassReg := X23.
	ReceiverResultReg := X24.
	SendNumArgsReg := X25.
	SPReg := X2. "X2 as the same stack pointer"
	FPReg := X8. "X8 as the frame pointer"
	Arg0Reg := X10.	 "X10/X11 function argument" 	
	Arg1Reg := X11.
	Extra0Reg := X18.  "These are callee saved registers"
	Extra1Reg := X19.
	Extra2Reg := X20.
	VarBaseReg := X26. "Base address for calls from machine code. Must be callee saved"
	self assert: ConcreteVarBaseReg = X26.
	LinkReg := X1. "X1"

	NumRegisters := 16.

	DPFPReg0 := F0.
	DPFPReg1 := F1.
	DPFPReg2 := F2.
	DPFPReg3 := F3.
	DPFPReg4 := F4.
	DPFPReg5 := F5.
	DPFPReg6 := F6.
	DPFPReg7 := F7.

	NumFloatRegisters := 8
]

{ #category : #testing }
CogRiscV64Compiler class >> isAbstract [
	^ self == CogRiscV64Compiler
]

{ #category : #testing }
CogRiscV64Compiler class >> isRISCTempRegister: reg [
	"For tests to filter-out bogus values left in the RISCTempRegister, if any."
	^reg = ConcreteIPReg
]

{ #category : #translation }
CogRiscV64Compiler class >> machineCodeDeclaration [
	"Answer the declaration for the machineCode array.
	 ARM instructions are 32-bits in length."
	^{#'unsigned int'. '[', self basicNew machineCodeWords printString, ']'}
]

{ #category : #accessing }
CogRiscV64Compiler class >> orOpcode [
	^OrOpcode
]

{ #category : #'class initialization' }
CogRiscV64Compiler class >> specificOpcodes [
	"Answer the processor-specific opcodes for this class.
	 They're all in an Array literal in the initialize method."
	^(self class >> #initialize) literals detect: [:l| l isArray and: [l includes: #LDMFD]]
]

{ #category : #translation }
CogRiscV64Compiler class >> wordSize [
	"This is a 64-bit ISA"
	^8
]

{ #category : #assembler }
CogRiscV64Compiler >> addImmediate: anImmediate toRegister: sourceRegister inRegister: destinationRegister [

	"Adds the sign-extended immediate to register x[rs1] and writes the result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31                 20  19   15  14  12  11  7  6         0
	|  	immediate[11:0]  |  rs1   |  000  |  rd  |  0010011  |
	"
	
	| riscvOpcode |
	self assert: (anImmediate bitAnd: 16rfff) = anImmediate.
	riscvOpcode := 2r0010011.
	self flag: #DONE.
	^ ((((anImmediate bitAnd: 16rfff) << 20) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: riscvOpcode
]

{ #category : #assembler }
CogRiscV64Compiler >> addUpperImmediateToPC: anImmediate toRegister: destinationRegister [

	"Adds the sign-extended 20-bit immediate, left-shifted by 12 bits, to the pc, and writes the result to x[rd].
	
	31                  12  11    7  6         0
	|  	immediate[31:12]  |   rd   |   0010111  |
	"

	| riscvOpcode signedImmediate |
	self flag: #DONE.
	self assert: (anImmediate bitAnd: 16rfffff) = anImmediate.
   "Check for sign extension"	
	signedImmediate := anImmediate < 0
		                   ifTrue: [ "Compute the two's complement" 
		                   16rfffff - anImmediate abs + 1 ]
		                   ifFalse: [ anImmediate ].
	riscvOpcode := 2r0010111.
	^ (((signedImmediate bitAnd: 16rfffff) << 12) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: riscvOpcode
]

{ #category : #assembler }
CogRiscV64Compiler >> addWordImmediate: anImmediate toRegister: sourceRegister inRegister: destinationRegister [

	"Adds the sign-extended immediate to register x[rs1], truncates the result to 32 bits, 
	 and writes the sign-extended result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31                20 19    15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1   |  000  |  rd  |  0011011  |
	"
	
	| riscvOpcode |
	self assert: (anImmediate bitAnd: 16rfff) = anImmediate.
	riscvOpcode := 2r0011011.
	self flag: #DONE.
	^ ((((anImmediate bitAnd: 16rfff) << 20) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: riscvOpcode
]

{ #category : #'register allocation' }
CogRiscV64Compiler >> availableRegisterOrNoneFor: liveRegsMask [
	"Answer an unused abstract register in the liveRegMask.
	 Subclasses with more registers can override to answer them.
	 N.B. Do /not/ allocate TempReg."
	<returnTypeC: #sqInt>
	(cogit register: Extra0Reg isInMask: liveRegsMask) ifFalse:
		[^Extra0Reg].
	(cogit register: Extra1Reg isInMask: liveRegsMask) ifFalse:
		[^Extra1Reg].
	(cogit register: Extra2Reg isInMask: liveRegsMask) ifFalse:
		[^Extra2Reg].
	^super availableRegisterOrNoneFor: liveRegsMask
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> bitwiseAndBetweenRegister: sourceReg andImmediate: anImmediate toRegister: destReg [
	
	"Computes the bitise AND of registers x[rs1] and x[rs2] and writes the result to x[rd].
	
	31                20 19   15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1  |  111  |  rd  |  0010011 
	"
	| riscvopcode signedImmediate |
	self flag: #DONE.
	riscvopcode := 2r0010011.
	"Check for sign extension"
	self assert: (anImmediate bitAnd: 16rfff) = anImmediate.
	signedImmediate := anImmediate < 0
		                   ifTrue: [ "Compute the two's complement" 
		                   16rfff - anImmediate abs + 1 ]
		                   ifFalse: [ anImmediate ].
	^ (((((signedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: 111 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvopcode
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> bitwiseAndBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg [
	
	"Computes the bitise AND of registers x[rs1] and x[rs2] and writes the result to x[rd].
	
	31        25 24    20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2   |  rs1  |  111  |  rd  |  0110011 
	"
	| riscvopcode |
	self flag: #DONE.
	riscvopcode := 2r0110011.
	^ (((((sourceReg2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: 111 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvopcode
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifCondition: condition [ 

	"The base condition checking should be between the ConcreteFlagReg and the ConcreteIPReg
	"	
	self flag: #TODO.
	self halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifCondition: condition betweenRegister: srcReg1 andRegister: srcReg2 [ 

	"Offset handling common to all branches. The condition is the three bit code.
	
	31                25 24   20 19   15 14         12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  condition  | offset[4:1|11] | 1100011 
	"	

	| riscvopcode signedOffset |
	self flag: #DONE.
	riscvopcode := 2r1100011.
	
	 "Check for sign extension"	
	signedOffset := offset < 0
		                ifTrue: [ 16r1fff - offset abs + 1 ] "Compute two's complement"
		                ifFalse: [ offset ].
	self assert: (signedOffset bitAnd: 16r1fff) = signedOffset.
	^ ((((((((signedOffset bitAnd: 16r1000) << 30)
	  bitOr: (signedOffset bitAnd: 16r7e0)  << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f)  << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f)  << 15)
	  bitOr: (condition bitAnd: 16r7) << 12)
	  bitOr: (signedOffset bitAnd: 16r1e)   << 8)
	  bitOr: (signedOffset bitAnd: 16r800)  << 7)
	  bitOr: riscvopcode 
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isEqualToRegisterValue: srcReg2 [
	
	"beq: If register x[rs1] equals x[rs2], set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  000  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: EQ betweenRegister: srcReg1 andRegister: srcReg2
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isGreaterThanOrEqualRegisterValue: srcReg2 [
	
	"bge: If register x[rs1] is greater than or equal x[rs2], treating the values as two's complement numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  101  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GE betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isGreaterThanRegisterValue: srcReg2 [
	
	"bgt: Pseudo-instruction that adds the offset to the PC if x[rs1] > x[rs2] 
	 Expands to blt rs2, rs1, offset
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: LT betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isLessThanOrEqualRegisterValue: srcReg2 [
	
	"ble: Pseudo-instruction that adds the offset to the PC if x[rs1] <= x[rs2] 
	 Expands to bge rs2, rs1, offset
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GE betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isLessThanRegisterValue: srcReg2 [
	
	"blt: If register x[rs1] is less than x[rs2], treating the values as two's complement numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  100  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: LT betweenRegister: srcReg1 andRegister: srcReg2
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isNotEqualToRegisterValue: srcReg2 [
	
	"bne: If register x[rs1] does not equal x[rs2], set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  001  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: NE betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueIsEqualToZero: srcReg [
	
	"beqz: Pseudo instruction that branches to the offset if the value in the register is 0
	Expands to beq x[rs1], x0, offset
 	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: EQ betweenRegister: srcReg andRegister: X0
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueIsNotEqualToZero: srcReg [
	
	"bnez: Pseudo instruction that branches to the offset if the value in the register is not 0
	Expands to bne x[rs1], x0, offset
 	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: NE betweenRegister: srcReg andRegister: X0
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isGreaterThanOrEqualRegisterValueUnsigned: srcReg2 [
	
	"bgeu: If register x[rs1] is greater than or equal x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  111  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GEU betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isLessThanRegisterValueUnsigned: srcReg2 [
	
	"bltu: If register x[rs1] is less than x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  110  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: LTU betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #testing }
CogRiscV64Compiler >> byteReadsZeroExtend [
	^true
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> bytesToLoadImmediate: anImmediate [ 

	"Returns the number of bytes (number of instructions * 4) to load an immediate"
	self flag: #TODO.
	^ (self loadImmediate: anImmediate inRegister: ConcreteIPReg) size * 4
]

{ #category : #abi }
CogRiscV64Compiler >> cResultRegister [
	"Answer the register through which C funcitons return integral results."
	<inline: true>
	^X0
]

{ #category : #accessing }
CogRiscV64Compiler >> cStackPointer [
	
	^ SP
]

{ #category : #accessing }
CogRiscV64Compiler >> callInstructionByteSize [
	"ARM calls and jumps span +/- 32 mb, more than enough for intra-zone calls and jumps."
	^4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> callTargetFromReturnAddress: callSiteReturnAddress [
	"Answer the address that the call immediately preceding callSiteReturnAddress will jump to."
	"this is also used by #jumpLongTargetBeforeFollowingAddress:."
	| callDistance callInstruction callAddress |
	callAddress := self instructionAddressBefore: callSiteReturnAddress.
	callInstruction := objectMemory long32At: callAddress.
	self assert: ((self instructionIsB: callInstruction) or: [self instructionIsBL: callInstruction]).
	
	callDistance := self extractOffsetFromBL: callInstruction.

	"this is the pc's offset at the branch"
	^callAddress + callDistance signedIntFromLong
]

{ #category : #testing }
CogRiscV64Compiler >> canDivQuoRem [
	^true
]

{ #category : #testing }
CogRiscV64Compiler >> canMulRR [
"we can do a MulRR be we can't simulate it correctly for some reason. More bug-fixing in the simulator one day"
	^true
]

{ #category : #accessing }
CogRiscV64Compiler >> codeGranularity [
	"Answer the size in bytes of a unit of machine code."
	<inline: true>
	^4
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> computeMaximumSize [
	"Because we don't use Thumb, each ARM instruction has 4 bytes. Many
	 abstract opcodes need more than one instruction. Instructions that refer
	 to constants and/or literals depend on literals being stored in-line or out-of-line.

	 N.B.  The ^N forms are to get around the bytecode compiler's long branch
	 limits which are exceeded when each case jumps around the otherwise."

	| offset |

	<var: #offset type: #'sqInt'>

	opcode
		caseOf: {
		"Noops & Pseudo Ops"
		[Label]					-> [^0].
		[Literal]					-> [^8].
		[AlignmentNops]		-> [^(operands at: 0) - 4].
		[Fill32]					-> [^4].
		[Nop]					-> [^4].
		"Control"
		[Call]					-> [^8].
		[CallFull]				-> [^self literalLoadInstructionBytes + 4].
		[JumpR]					-> [^4].
		[Jump]					-> [^4].
		[JumpFull]				-> [^self literalLoadInstructionBytes + 4].
		[JumpLong]				-> [^4].
		[JumpZero]				-> [^4].
		[JumpNonZero]			-> [^4].
		[JumpNegative]			-> [^4].
		[JumpNonNegative]		-> [^4].
		[JumpOverflow]			-> [^4].
		[JumpNoOverflow]		-> [^4].
		[JumpCarry]		      	-> [^4].
		[JumpNoCarry]			-> [^4].
		[JumpLess]				-> [^4].
		[JumpGreaterOrEqual]	-> [^4].
		[JumpGreater]			-> [^4].
		[JumpLessOrEqual]		-> [^4].
		[JumpBelow]			-> [^4].
		[JumpAboveOrEqual]	-> [^4].
		[JumpAbove]			-> [^4].
		[JumpBelowOrEqual]	-> [^4].
		[JumpLongZero]		-> [^self jumpLongConditionalByteSize].
		[JumpLongNonZero]	-> [^self jumpLongConditionalByteSize].
		[JumpFPEqual]			-> [^4].
		[JumpFPNotEqual]		-> [^4].
		[JumpFPLess]			-> [^4].
		[JumpFPGreaterOrEqual]-> [^4].
		[JumpFPGreater]		-> [^4].
		[JumpFPLessOrEqual]	-> [^4].
		[JumpFPOrdered]		-> [^4].
		[JumpFPUnordered]		-> [^4].
		[RetN]					-> [^(operands at: 0) = 0 ifTrue: [4] ifFalse: [8]].
		[Stop]					-> [^4].

		"Arithmetic"
		[AddCqR]				-> [
			^ ((operands at: 1) = SP)
				ifTrue: [ 12 ]
				ifFalse: [ | fits12Bits word |
					word := operands at: 0.
					fits12Bits := (word bitAnd: 16rfff) = word.
					fits12Bits ifTrue: [ 4 ] ifFalse: [ 8 ] ] ].
		[AndCqR]				-> [
						^ ((operands at: 0) bitAnd: 16rfff) ~= (operands at: 0)
							ifTrue: [20] ifFalse: [16]
						]. "If there is a literal -> 3 instructions otherwise 1" 
		[AndCqRR]				-> [^self rotateable8bitBitwiseImmediate: (operands at: 0)
										ifTrue: [:r :i :n| 4]
										ifFalse:
											[self literalLoadInstructionBytes = 4
												ifTrue: [8]
												ifFalse:
													[1 << (operands at: 0) highBit = ((operands at: 0) + 1)
														ifTrue: [8]
														ifFalse: [self literalLoadInstructionBytes + 4]]]].

		[CmpCqR]				-> [| immediate |
			immediate := (operands at: 0) abs.
			^ ((immediate bitAnd: 16rfff) = immediate
				or: [ (immediate << 12 >> 12 bitAnd: 16rFFF) = immediate ])
					ifTrue: [ 4]
					ifFalse: [self literalLoadInstructionBytes + 4]].
		[CmpC32R]				-> [^self rotateable8bitSignedImmediate: (operands at: 0)
											ifTrue: [:r :i :n| 4]
											ifFalse: [self literalLoadInstructionBytes + 4]].
		[OrCqR]				-> [
			^self
				encodeLogicalImmediate: (operands at: 0)
				registerSize: 64
				ifPossible: [ :v | 4 ]
				ifNotPossible: [ self literalLoadInstructionBytes + 4 ] ].
			
		[SubCqR]				-> [| constant |
			"If it fits in 12 bits, we can used an immediate instruction.
			Othewise we need to use a literal and load it"
			constant := operands at: 0.
			(constant bitAnd: 16rfff) = constant
				ifTrue: [ ^ 4 ]
				ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ].
		[TstCqR]				-> [ 
						^ ((operands at: 0) bitAnd: 16rfff) ~= (operands at: 0)
							ifTrue: [20] ifFalse: [16]
						]. "If there is a literal -> 3 instructions otherwise 2" 
		[XorCqR]				-> [^self rotateable8bitBitwiseImmediate: (operands at: 0)
										ifTrue: [:r :i :n| 4]
										ifFalse:
											[self literalLoadInstructionBytes = 4
												ifTrue: [8]
												ifFalse:
													[1 << (operands at: 0) highBit = ((operands at: 0) + 1)
														ifTrue: [8]
														ifFalse: [self literalLoadInstructionBytes + 4]]]].
		[AddCwR]				-> [^self literalLoadInstructionBytes + 4].
		[AndCwR]				-> [^self literalLoadInstructionBytes + 4].
		[CmpCwR]				-> [^self literalLoadInstructionBytes + 4].
		[OrCwR]				-> [^self literalLoadInstructionBytes + 4].
		[SubCwR]				-> [^self literalLoadInstructionBytes + 4].
		[XorCwR]				-> [^self literalLoadInstructionBytes + 4].
		[AddRR]					-> [^4].
		[AndRR]					-> [^4].
		[CmpRR]				-> [^(((operands at:0) = SP) or: [(operands at: 1) = SP]) ifTrue: [8] ifFalse: [4]].
		[OrRR]					-> [^4].
		[XorRR]					-> [^4].
		[SubRR]					-> [ "When the operation includes the SP, we might need two instructions" ^(operands at: 0) = SP ifTrue: [ 8 ] ifFalse: [ 4 ]].
		[NegateR]				-> [^4].
		[LoadEffectiveAddressMwrR]
									-> [^self rotateable8bitImmediate: (operands at: 0)
											ifTrue: [:r :i| 4]
											ifFalse: [self literalLoadInstructionBytes + 4]].

		[LogicalShiftLeftCqR]		-> [^4].
		[LogicalShiftRightCqR]		-> [^4].
		[ArithmeticShiftRightCqR]	-> [^4].
		[LogicalShiftLeftRR]			-> [^4].
		[LogicalShiftRightRR]		-> [^4].
		[ArithmeticShiftRightRR]		-> [^4].
		[RotateLeftCqR]					-> [^4].
		[RotateRightCqR]					-> [^4].
	
		"Floating point operations"
	
		[AddRdRd]					-> [^4].
		[CmpRdRd]					-> [^4].
		[SubRdRd]					-> [^4].
		[MulRdRd]					-> [^4].
		[DivRdRd]					-> [^4].
		[SqrtRd]					-> [^4].
		[XorRdRd]					-> [^4].
						
		"ARM Specific Arithmetic"
		[MUL]			-> [^4].
		[SMULH] 		-> 	[^4].
		[CMPMULOverflow]				-> [^4].
		[SDIV]					-> [^4].
		[MSUB]					-> [^4].
				
		"Data Movement"						
		[MoveCqR]				-> [^4].
		[MoveC32R]			-> [^4].
		[MoveCwR]				-> [^self literalLoadInstructionBytes = 4
										ifTrue: [self literalLoadInstructionBytes]
										ifFalse:
											[(self inCurrentCompilation: (operands at: 0))
												ifTrue: [4]
												ifFalse: [self literalLoadInstructionBytes]]].
		[MoveRR]				-> [^4].
		[MoveRdRd]			-> [^4].
		[MoveAwR]				-> [
			"if register is SP we need an extra move"
			^(self isAddressRelativeToVarBase: (operands at: 0))
					ifTrue: [(operands at: 1) = SP
						ifTrue: [ 8 ]
						ifFalse: [ 4 ]  ]
					ifFalse: [self literalLoadInstructionBytes + 8 ]].
		[MoveRAw]				-> [^(self isAddressRelativeToVarBase: (operands at: 1))
													ifTrue: [(operands at: 0) = SP
														ifTrue: [ 8 ]
														ifFalse: [ 4 ]]
													ifFalse: [
													 	(operands at: 0) = SP
															ifTrue: [ 4 + self literalLoadInstructionBytes + 4 ]
															ifFalse: [ self literalLoadInstructionBytes + 4 ]]].
		[MoveAbR]				-> [^(self isAddressRelativeToVarBase: (operands at: 0))
													ifTrue: [4]
													ifFalse: [self literalLoadInstructionBytes + 4]].
		[MoveRAb]				-> [^(self isAddressRelativeToVarBase: (operands at: 1))
													ifTrue: [4]
													ifFalse: [self literalLoadInstructionBytes + 4]].

		[MoveRM32r]			-> [self is9BitValue: (operands at: 1)
										ifTrue: [ :value | ^  4 ]
										ifFalse: [ self shiftable16bitImmediate: (operands at: 1) 
														ifTrue: [ :value :shift | ^  8 ] 
														ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]].

		[MoveRMwr]			-> [self is9BitValue: (operands at: 1)
										ifTrue: [ :value | ^  4 ]
										ifFalse: [ self shiftable16bitImmediate: (operands at: 1) 
														ifTrue: [ :value :shift | ^  8 ] 
														ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]].
		[MoveRsM32r]			-> [^self is12BitValue: (operands at: 1)
										ifTrue: [:u :i | 4]
										ifFalse: [self notYetImplemented. self literalLoadInstructionBytes + 4]]. 
		[MoveRdM64r]			-> [^self is12BitValue: (operands at: 1)
										ifTrue: [:u :i | 4]
										ifFalse: [self notYetImplemented. self literalLoadInstructionBytes + 4]]. 
		[MoveMbrR]			-> [^self is9BitValue: (operands at: 0)
										ifTrue: [:value | 8 "2 instrutions" ]
										ifFalse: [ self literalLoadInstructionBytes + 4 ]].

		[MoveRM8r]				-> [^self is12BitValue: (operands at: 1)
										ifTrue: [:u :i | 4]
										ifFalse: [self literalLoadInstructionBytes + 4]].
		[MoveRMbr]				-> [^self is12BitValue: (operands at: 1)
										ifTrue: [:u :i | 4]
										ifFalse: [self literalLoadInstructionBytes + 4]].

		[MoveRM16r]				-> [^self is12BitValue: (operands at: 1)
										ifTrue: [:u :i| 4]
										ifFalse: [self literalLoadInstructionBytes + 4]].
		[MoveM16rR]			-> [^self rotateable8bitImmediate: (operands at: 0)
											ifTrue: [:r :i| 4]
											ifFalse: [self literalLoadInstructionBytes + 4]].
		[MoveM32rRs]			-> [^self is12BitValue: (operands at: 0) 
										ifTrue: [:s :v| 4] ifFalse: [self notYetImplemented. 0]].
		[MoveM64rRd]			-> [^self is12BitValue: (operands at: 0) 
										ifTrue: [:s :v| 4] ifFalse: [self notYetImplemented. 0]].
		[MoveM32rR]			-> [ 			
			offset := (operands at: 0).
			(offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset ]) 
				ifTrue: [ ^ 4 ]
				ifFalse: [ 	self
									is9BitValue: offset
										ifTrue: [ :v | ^ 4 ] 
										ifFalse: [^ self literalLoadInstructionBytes + 4 ] ]].

		[MoveMwrR]			-> [ 			
			offset := (operands at: 0).
			(offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset ]) 
				ifTrue: [ ^ 4 ]
				ifFalse: [ 	self
									is9BitValue: offset
										ifTrue: [ :v | ^ 4 ] 
										ifFalse: [^ self literalLoadInstructionBytes + 4 ] ]].
		[MoveXbrRR]			-> [^4].
		[MoveX32rRR]			-> [^4].
		[MoveRX32rR]			-> [^4].
		[MoveRXbrR]			-> [^4].
		[MoveXwrRR]			-> [^4].
		[MoveRXwrR]			-> [^4].
		[PopR]					-> [^8].
		[PushR]					-> [^8].
		[PushCw]				-> [^self literalLoadInstructionBytes = 4
										ifTrue: [self literalLoadInstructionBytes + 4]
										ifFalse:
											[(self inCurrentCompilation: (operands at: 0))
												ifTrue: [8]
												ifFalse:
													[self rotateable8bitBitwiseImmediate: (operands at: 0)
														ifTrue: [:r :i :n| 8]
														ifFalse: [self literalLoadInstructionBytes + 4]]]].
		[PushCq]				  -> [ | loadOffset |
						self halt.
						loadOffset := dependent ifNil: [ self immediateLoadInstructionBytes: (operands at: 0) ] "Load immediate = 4/8/16/24 or 32"
						                        ifNotNil: [ self literalLoadInstructionBytes ]. "Load literal = 8"
						^ loadOffset + 8
						]. 
		[PrefetchAw] 			-> [^(self isAddressRelativeToVarBase: (operands at: 0))
										ifTrue: [4]
										ifFalse: [self literalLoadInstructionBytes + 4]].
		"Conversion"
		[ConvertRdRs]			-> [^4].
		[ConvertRsRd]			-> [^4].
		[ConvertRRd]			-> [^4].
		[MoveRdR]				-> [^4].
		[MoveRRd]				-> [^4].
				
		"This is a fixed size instruction using a literal. We need exactly 1 instructions to move a literal from a PC relative position, so this takes ALWAYS 1 instruction of 4 bytes"
		[MovePatcheableC32R] -> [ ^ 8 ]
		}.
	^0 "to keep C compiler quiet"

]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeAddCqR [

	<inline: true>

	1halt.

]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeAddCwR [
	
	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeAddRR [

	1halt.

]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeAddRdRd [

	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeAlignmentNops [
	"Fill any empty slots with NOPs"
	<inline: true>
	self flag: #DONE.
	self assert: machineCodeSize \\ 4 = 0.
	0 to: machineCodeSize - 1 by: 4 do: [ :p | self machineCodeAt: p put: self nop ]
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeAndCqR [

	"Will get inlined into concretizeAt: switch."

	"Perform a bitwise and between the value of register and the value of the operand.
	
	 If the operand is not a literal:
		andi reg, reg, cq
	
	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		and reg, reg, ConcreteIPReg 
		"

	<inline: true>
	| cq destReg sourceReg instrOffset |
	self flag: #TODO.
	cq := operands at: 0.
	sourceReg := operands at: 1.
	destReg := sourceReg.
	dependent
		ifNil: [ 
			cq < 16rfff
				ifTrue: [ "Direct encoding as an immediate"
					self machineCodeAt: 0 put: (self
							 bitwiseAndBetweenRegister: sourceReg
							 andImmediate: cq
							 toRegister: destReg).
					instrOffset := 4 ]
				ifFalse: [ "Move to a register before performing AND on the registers"	
					"Load the immediate to a register"
					instrOffset := self machineCodeWriteInstructions: (self loadImmediate: cq inRegister: destReg).
					self machineCodeAt: instrOffset put: (self
							 bitwiseAndBetweenRegister: sourceReg
							 andRegister: ConcreteIPReg
							 toRegister: destReg).
					instrOffset := instrOffset + 4 ] 
				]
		ifNotNil: [ "Literal -> compute the distance, load the actual value then and between the 2 registers"
			instrOffset := self machineCodeWriteInstructions: (self loadLiteralInRegister: destReg).
			self machineCodeAt: instrOffset put: (self
					 bitwiseAndBetweenRegister: sourceReg
					 andRegister: ConcreteIPReg
					 toRegister: destReg).
			instrOffset := instrOffset + 4 ].
	^ machineCodeSize := instrOffset
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeAndCqRR [
	"Will get inlined into concretizeAt: switch."

	"AND is very important since it's used to mask all sorts of flags in the jit. We take special care to try to find compact ways to make the masks"
	
	<inline: true>
	1halt.
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeAndRR [

	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeArithmeticShiftRightCqR [

	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeArithmeticShiftRightRR [

	1halt.
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> concretizeAt: actualAddress [
	"Generate concrete machine code for the instruction at actualAddress,
	 setting machineCodeSize, and answer the following address."

	self assert: actualAddress \\ 4 = 0.
	^ super concretizeAt: actualAddress
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeCMPMULOverflow [
	
	| registerA destinationRegister registerB |
	registerA := operands at: 0.
	registerB := destinationRegister := operands at: 1.
	
	self
		machineCodeAt: 0
		put: (self
			cmpSize: 1
			shiftedRegister: registerA
			shiftType: 2r10 "Arithmetic Shift Right so the sign is extended and kept"
			shiftValue: 63 "Shift all but sign"
			secondRegister: registerB).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeCall [
	"Will get inlined into concretizeAt: switch."

	"Call is used only for calls within code-space, See CallFull for general anywhere in address space calling"
	
	<inline: true>
	| offset offsetHigh offsetLow signedOffset |
	self flag: #TODO.
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the PC"
  offset := (operands at: 0) signedIntFromLong - address signedIntFromLong.
	signedOffset  := offset < 0
		                   ifTrue: [ "Compute the two's complement" 
		                   16rfffff - offset abs + 1 ]
		                   ifFalse: [ offset ].
	offsetHigh := signedOffset >> 12.
	offsetLow := signedOffset bitAnd: 16rFFF.

  offset abs >= (1 << 19) ifTrue: [ 
		"In the case the offset is larger than 20bits, more operations need to be done to handle it
		and add (or substract) it to the PC"
	  self halt.
	].

	self machineCodeAt: 0 put: (self addUpperImmediateToPC: 0 toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: LR).
	^ machineCodeSize := 8

]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeCallFull [
	"Will get inlined into concretizeAt: switch."

	"Sizing/generating calls.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	<var: #jumpTarget type: #'AbstractInstruction *'>
	| jumpTarget instrOffset |
	jumpTarget := self longJumpTargetAddress.
	instrOffset := self moveCw: jumpTarget intoR: ConcreteIPReg.
	"blx ConcreteIPReg"
	self machineCodeAt: instrOffset put: (self blr: ConcreteIPReg).
	self assert: instrOffset = self literalLoadInstructionBytes.
	^ machineCodeSize := instrOffset + 4
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> concretizeCmpC32R [

	<inline: true>
	^ self concretizeCmpCqR
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeCmpCqR [
	
	<var: #quickImmediate type: #sqInt>
	<inline: true>
	| quickImmediate registerToUse fits12Bits fitsShifted12Bits |
	quickImmediate := operands at: 0.
	registerToUse := operands at: 1.

	quickImmediate >= 0 ifTrue: [  
		fits12Bits := (quickImmediate bitAnd: 16rfff) = quickImmediate.
		fits12Bits ifTrue: [
			self
				machineCodeAt: 0
				put:
					(self cmpSize: 1 immediate12BitValue: quickImmediate shiftFlag: 0 register: registerToUse).
			^ machineCodeSize := 4 ].
		
		fitsShifted12Bits := (quickImmediate << 12 >> 12 bitAnd: 16rFFF) = quickImmediate.
		fitsShifted12Bits ifTrue: [ 
			self
				machineCodeAt: 0
				put:
					(self cmpSize: 1 immediate12BitValue: quickImmediate >> 12 shiftFlag: 1 register: registerToUse).
			^ machineCodeSize := 4
		]]
	ifFalse: [
		quickImmediate := quickImmediate abs.
		fits12Bits := (quickImmediate bitAnd: 16rfff) = quickImmediate.
		fits12Bits ifTrue: [
			self
				machineCodeAt: 0
				put:
					(self cmnSize: 1 immediate12BitValue: quickImmediate shiftFlag: 0 register: registerToUse).
			^ machineCodeSize := 4 ].
		
		fitsShifted12Bits := (quickImmediate << 12 >> 12 bitAnd: 16rFFF) = quickImmediate.
		fitsShifted12Bits ifTrue: [ 
			self
				machineCodeAt: 0
				put:
					(self cmnSize: 1 immediate12BitValue: quickImmediate >> 12 shiftFlag: 1 register: registerToUse).
			^ machineCodeSize := 4 ]].
	 
	"If the value does not fit in 12 bits, not even shifted, then use two instructions"
	self moveCw: quickImmediate intoR: ConcreteIPReg.
	self
		machineCodeAt: machineCodeSize
		put:
			(self
				cmpSize: 1
				shiftedRegister: ConcreteIPReg
				shiftType: 0
				shiftValue: 0
				secondRegister: registerToUse).
	^ machineCodeSize := machineCodeSize + 4
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeCmpCwR [
	
	self assert: dependent notNil.
	self moveCw: (operands at: 0) intoR: ConcreteIPReg.
	(operands at: 1) = SP ifTrue: [ self notYetImplemented ].	

	self
		machineCodeAt: machineCodeSize
		put:
			(self
				cmpSize: 1
				shiftedRegister: (operands at: 1)
				shiftType: 0
				shiftValue: 0
				secondRegister: ConcreteIPReg).
	^ machineCodeSize := 8
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeCmpRR [

	"CMP is a SUB operation where the result is discarded (here saved in the FLAG register)"
	<inline: true>
	| srcReg1 srcReg2 |
	self flag: #DONE.
	srcReg1 := operands at: 0.
	srcReg2 := operands at: 1.
	self machineCodeAt: 0 put: (self
			 substractValueFromRegister: srcReg1
			 toRegister: srcReg2
			 intoRegister: ConcreteFlagReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeCmpRdRd [
	"Will get inlined into concretizeAt: switch."

	"Compare FP regB with FP regA and leave the FP status reg ready to be transferred back to ARM with next instruction"

	<inline: true>
	| regB regA |
	regA := operands at: 0.
	regB := operands at: 1.
	machineCode at: 0 put: (self
		fcmpFType: 2r01 "64bit variant"
		leftRegister: regB
		rightRegister: regA).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeConditionalJump: conditionCode [
	"Will get inlined into concretizeAt: switch."

	"Sizing/generating jumps.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	| offset |
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	1 halt.
	self machineCodeAt: 0 put: (self branchTo: offset ifCondition: conditionCode).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeConvertRRd [
	"Convert an integer value into a double precision float value"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at: 0.
	destReg := operands at: 1.
	machineCode at: 0 put: (self scalarConvertSize: 1 fromScalarRegister: srcReg toDoublePrecisionFloatRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeConvertRdRs [

	"Convert a double precision float to a single precision float in a register"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at: 0.
	destReg := operands at: 1.

	machineCode at: 0 put: (self
			 fConvertSourceRegister: srcReg
			 toRegister: destReg
			 sourcePrecision: 2r01 "Double precision"
			 toPrecision: 2r00 "Single precision").
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeConvertRsRd [

	"Convert a single precision float to a double precision float in a register"

	<inline: true>
	| srcReg destReg |
	srcReg := operands at: 0.
	destReg := operands at: 1.

	machineCode at: 0 put: (self
			 fConvertSourceRegister: srcReg
			 toRegister: destReg
			 sourcePrecision: 2r00 "Single precision"
			 toPrecision: 2r01 "Double precision").
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeDataOperationCwR: armOpcode [

	self notYetImplemented.
	^ 0
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeDivRdRd [
	"FP divide regLHS by regRHS and stick result in regLHS"

	<inline: true>
	| registerA registerB destinationRegister |
	registerA := operands at: 0.
	destinationRegister := registerB := operands at: 1.
	machineCode at: 0 put: (self
		fDivFirstRegister: registerB
		secondRegister: registerA
		destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeFPConditionalJump: conditionCode [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	1halt.
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> concretizeFill32 [
	"fill with operand 0 according to the processor's endianness"

	self machineCodeAt: 0 put: (operands at: 0).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeInvertibleDataOperationCqR: armOpcode [

	self notYetImplemented.
	^ 0
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJump [ 

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self jumpToOffset: offset).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpFull [
"Will get inlined into concretizeAt: switch."

	"Sizing/generating calls.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	<var: #jumpTarget type: #'AbstractInstruction *'>
	| jumpTarget instrOffset |
	jumpTarget := self longJumpTargetAddress.
	instrOffset := self moveCw: jumpTarget intoR: ConcreteIPReg.
	self flag: #TODO.
	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpGreater [

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: ConcreteFlagReg isGreaterThanRegisterValue: ConcreteIPReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpGreaterOrEqual [ 

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: ConcreteFlagReg isGreaterThanOrEqualRegisterValue: ConcreteIPReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpLess [

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: ConcreteFlagReg isLessThanRegisterValue: ConcreteIPReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpLessOrEqual [ 

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: ConcreteFlagReg isLessThanOrEqualRegisterValue: ConcreteIPReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> concretizeJumpLong [

	| offset |
	offset := (operands at: 0) signedIntFromLong
		- address signedIntFromLong.	"normal pc offset"
	self assert: (self isInImmediateJumpRange: offset).	"+- 24Mb is plenty of range in code space"
	self machineCodeAt: 0 put: (self b: offset). 
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpLongNonZero [

	self notYetImplemented.
	^ 0
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpLongZero [
	
	"There are no conditional long jumps in AARCH64.
	Compile this to a sequence as follows:
	
		b.ne nonZero
		b target
	
		nonZero:
	
	...
	"
	
	| offset |
	"Calculate the offset between the B and the target. The B is the second instruction thus the -4"
	offset := (operands at: 0) signedIntFromLong - address signedIntFromLong - 4.
	self assert: (self isInImmediateJumpRange: offset).

	self machineCodeAt: 0 put: (self branchCondition: NE offset: 8 "should jump after the b").
	self machineCodeAt: 4 put: (self b: offset).
	
	^ machineCodeSize := 8
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpNonZero [

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsNotEqualToZero: ConcreteFlagReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpR [

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| reg|
	self flag: #TODO.
	reg := operands at: 0.
	self machineCodeAt: 0 put: (self jumpToRegisterValue: reg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeJumpZero [

	"Will get inlined into concretizeAt: switch."
	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsEqualToZero: ConcreteFlagReg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeLiteral [

	<doNotGenerate>
	self subclassResponsibility 
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeLoadEffectiveAddressMwrR [
	"Will get inlined into concretizeAt: switch."

	"destReg = srcReg (which contains an address) + offset"

	<inline: true>
	| srcReg offset destReg instrOffset |
	offset := operands at: 0.
	srcReg := operands at: 1.
	destReg := operands at: 2.
	
	self is12BitValue: offset
		ifTrue: [ :positive :value |
			self
				machineCodeAt: 0
				put: (self
					addSize: 1
					sourceRegister: srcReg
					shift: 0
					immediate12: offset
					destinationRegister: destReg).
			^ machineCodeSize := 4 ]
		ifFalse: [ self notYetImplemented ].
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeLogicalShiftLeftCqR [
	"Will get inlined into concretizeAt: switch."

	<var: #distance type: #sqInt>
	<inline: true>
	| distance reg |
	distance := (operands at: 0) min: 63.
	reg := operands at: 1.
	self
		machineCodeAt: 0
		put: (self
			logicalShiftLeftSize: 1
			sourceRegister: reg
			shiftValue: distance
			destinationRegister: reg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeLogicalShiftLeftRR [
	self 
		machineCodeAt: 0 
		put: (self
			 logicalShiftLeftSize: 1
			 sourceRegister: (operands at: 1)
			 shiftRegister: (operands at: 0)
			 destinationRegister: (operands at: 1)).
			
		
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeLogicalShiftRightCqR [
	"Will get inlined into concretizeAt: switch."

	<var: #distance type: #sqInt>
	<inline: true>
	| distance reg |
	distance := (operands at: 0) min: 63.
	reg := operands at: 1.
	self
		machineCodeAt: 0
		put: (self
			logicalShiftRightSize: 1
			sourceRegister: reg
			shiftValue: distance
			destinationRegister: reg).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeLogicalShiftRightRR [

	self notYetImplemented.
	^ 0
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMSUB [

	<inline: true>

	| minuendReg factor1Reg factor2Reg destinationReg |

	minuendReg := operands at: 0.
	factor1Reg := operands at: 1.
	factor2Reg := operands at: 2.
	destinationReg := operands at: 3.
		
	self
		machineCodeAt: 0
		put:(
			self
				msubSize: 1
				minuendReg: minuendReg
				factor1Reg: factor1Reg
				factor2Reg: factor2Reg
				destinationRegister: destinationReg).
	
	^ machineCodeSize := 4	

]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeMUL [
	
	| registerA destinationRegister registerB |
	registerA := operands at: 0.
	registerB := destinationRegister := operands at: 1.
	
	self
		machineCodeAt: 0
		put: (self
			mulSize: 1
			firstRegister: registerA
			secondRegister: registerB
			destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveAbR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| srcAddr destReg instrOffset |
	srcAddr := operands at: 0.
	destReg := operands at: 1.
	(self isAddressRelativeToVarBase: srcAddr) ifTrue: [ | offset |
		offset := srcAddr - cogit varBaseAddress.
		self assert: (offset bitAnd: 16rfff) = offset.
		self
			machineCodeAt: 0
			put: (self
				ldrbSourceRegister: ConcreteVarBaseReg
				destinationRegister: destReg
				offset: srcAddr - cogit varBaseAddress).
		^ machineCodeSize := 4 ].

	"load the address into ConcreteIPReg"
	instrOffset := self moveCw: srcAddr intoR: ConcreteIPReg.
	self
		machineCodeAt: instrOffset
		put:
			(self
				ldrbSourceRegister: ConcreteIPReg
				destinationRegister: destReg).
	^ machineCodeSize := instrOffset + 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveAwR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| srcAddr destReg instrOffset |
	srcAddr := operands at: 0.
	destReg := operands at: 1.
	(self isAddressRelativeToVarBase: srcAddr) ifTrue: [ | actualDestination |
		actualDestination := destReg = SP
			ifTrue: [ ConcreteIPReg ]
			ifFalse: [ destReg ].
		self
			machineCodeAt: 0
			put: (self
				ldrSize: 1
				baseRegister: ConcreteVarBaseReg
				unsignedOffset: srcAddr - cogit varBaseAddress
				destinationRegister: actualDestination).
		machineCodeSize := 4.
			
		destReg = SP ifTrue: [ 
			self machineCodeAt: 4 put: (self movToFromSP: SP rn: actualDestination).
			machineCodeSize := machineCodeSize + 4.
		].

		^ machineCodeSize ].
	
	"load the address into ConcreteIPReg"
	instrOffset := self moveCw: srcAddr intoR: ConcreteIPReg.
	self
		machineCodeAt: instrOffset
		put: (self ldurSize: 1
			baseRegister: ConcreteIPReg
			signedOffset: 0
			destinationRegister: ConcreteIPReg).
	self
		machineCodeAt: instrOffset + 4
		put: (self movSize: 1 sourceRegisterMaybeSP: ConcreteIPReg destinationRegisterMaybeSP: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveC32R [
	self shouldBeImplemented.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveCqR [

	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| cq reg instrOffset |
	self flag: #TODO.
	cq := operands at: 0.
	reg := operands at: 1.
	dependent
		ifNil: [ "Immediate value"
			instrOffset := self machineCodeWriteInstructions:
				               (self loadImmediate: cq inRegister: reg) ]
		ifNotNil: [ "Literal"
			instrOffset := self machineCodeWriteInstructions:
				               (self loadLiteralInRegister: reg) ].
	^ machineCodeSize := instrOffset
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveCwR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	^ machineCodeSize := self loadCwInto: (operands at: 1)
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveM16rR [
	"Will get inlined into concretizeAt: switch."

	"ldrh destReg, [srcReg, #immediate],
	or 
	move offset to ConcreteIPReg
	ldrh destReg, [srcReg, ConcreteIPReg]"

	<var: #offset type: #sqInt>
	<inline: true>
	| baseRegister offset destReg |
	offset := operands at: 0.
	baseRegister := operands at: 1.
	destReg := operands at: 2.

	(offset >= 0 and: [ (offset / 2 bitAnd: 16rFFF) = (offset / 2)]) 
		ifTrue: [ self
				machineCodeAt: 0
				put:
					(self
						ldrhBaseRegister: baseRegister
						offsetDividedBy2: offset / 2
						destinationRegister: destReg).
			^ machineCodeSize := 4  ].
	
	self notYetImplemented.
	
	^0
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveM32rR [
	"Will get inlined into concretizeAt: switch."

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset destReg instrOffset |
	offset := operands at: 0.
	srcReg := operands at: 1.
	destReg := operands at: 2.

	"If it is a positive 12 bit value this can be encoded as a LDR with a positive 12bit offset"
	(offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset ]) ifTrue: [
		self
			machineCodeAt: 0
			put:
				(self
					ldrSize: 0"is32Bits"
					baseRegister: srcReg
					unsignedOffset: offset
					destinationRegister: destReg).
		^ machineCodeSize := 4
	].
	
	"If it is negative, maybe we can encode it as a LDUR signed 9bit offset"
	self
		is9BitValue: offset
		ifTrue: [ :immediate | 
			self
				machineCodeAt: 0
				put:
					(self
						ldurSize: 0 "32bits"
						baseRegister: srcReg
						signedOffset: immediate
						destinationRegister: destReg).
			^ machineCodeSize := 4 ]
		ifFalse: [
			"Otherwise, this may be a literal"
			self assert: dependent notNil.
			instrOffset := self moveCw: offset intoR: ConcreteIPReg.
			self
				machineCodeAt: instrOffset
				put: (self ldrSize: 0 "32 bits" indexRegister: ConcreteIPReg baseRegister: srcReg destinationRegister: destReg).
			^ machineCodeSize := instrOffset + 4 ].
		
	^ 0	"to keep Slang happy"
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveM32rRs [
	"Will get inlined into concretizeAt: switch."
	"Load a float from srcReg+offset into FP destReg"

	<inline: true>
	| srcReg offset destReg |
	offset := operands at: 0.
	srcReg := operands at: 1.
	destReg := operands at: 2.
	"offset should a 12bit multiple of 8 constant"
	self assert: (offset >> 3 bitAnd: 16rfff) << 3 = offset.
	machineCode
		at: 0
		put: (self
			ldrSize: 2r10 "32bits"
			baseRegister: srcReg
			unsignedOffset: offset / 8
			destinationFloatingPointRegister: destReg
			is128BitVariant: 0).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveM64rRd [
	"Will get inlined into concretizeAt: switch."
	"Load a float from srcReg+offset into FP destReg"

	<inline: true>
	| srcReg offset destReg |
	offset := operands at: 0.
	srcReg := operands at: 1.
	destReg := operands at: 2.
	"offset should a 12bit multiple of 8 constant"
	self assert: (offset >> 3 bitAnd: 16rfff) << 3 = offset.
	machineCode
		at: 0
		put: (self
			ldrSize: 2r11 "64bits"
			baseRegister: srcReg
			unsignedOffset: offset / 8
			destinationFloatingPointRegister: destReg
			is128BitVariant: 0).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveMbrR [

	<doNotGenerate>
	self subclassResponsibility 
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveMwrR [

	"Will get inlined into concretizeAt: switch."
	"Load a word (64 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: ld rd, rs1(offset)"
	<inline: true>
	| baseReg offset destReg instrOffset |
	self flag: #DONE.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	self assert: (offset bitAnd: 16rfff) = offset.
	self machineCodeAt: 0 put: (self
			 loadDoubleWordFromAddressInRegister: baseReg
			 withOffset: offset
			 toRegister: destReg).
	^ machineCodeSize := 4.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRAb [
	"Will get inlined into concretizeAt: switch."

	"LEA ConcreteIPReg
	strb srcReg, [ConcreteIPReg]"

	<inline: true>
	| srcReg destAddr instrOffset |
	srcReg := operands at: 0.
	destAddr := operands at: 1.
	(self isAddressRelativeToVarBase: destAddr)
		ifTrue: [ | offset |
			offset := destAddr - cogit varBaseAddress.
			self assert: (offset bitAnd: 16rfff) = offset.
			self
				machineCodeAt: 0
				put: (self strbSourceRegister: srcReg destinationRegister: ConcreteVarBaseReg offset: offset).
			^ machineCodeSize := 4 ].
	"load the address into ConcreteIPReg"
	instrOffset := self moveCw: destAddr intoR: ConcreteIPReg.
	"We *could* overwrite the last instruction above with a LDR a, b, last-byte-of-srcAddr BUT that would break if we change to loading literals instead of forming long constants"
	self
		machineCodeAt: instrOffset
		put: (self strbSourceRegister: srcReg destinationRegister: ConcreteIPReg).
	^ machineCodeSize := instrOffset + 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRAw [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
		1halt
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRM16r [

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg instrOffset |
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.

	self assert: offset >= 0.
	self assert: offset \\ 2 = 0.

	self
		is12BitValue: offset / 2 
		ifTrue: [ :u :immediate | 
			self
				machineCodeAt: 0
				put: (self strhSourceRegister: srcReg destinationRegister: baseReg offset: offset / 2).
			^ machineCodeSize := 4 ]
		ifFalse: [ 
			self notYetImplemented.
			^ machineCodeSize := instrOffset + 4 ].
	^ 0	"to keep Slang happy"
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeMoveRM32r [

	<doNotGenerate>
	self subclassResponsibility 
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRMbr [
	"Will get inlined into concretizeAt: switch."

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg |
	
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	
	(offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset]) 
		ifTrue: [ self
				machineCodeAt: 0
				put:
					(self strbSourceRegister: srcReg destinationRegister: baseReg offset: offset). 
				^ machineCodeSize := 4 ]
		ifFalse: [ 
			self notYetImplemented.
			^ machineCodeSize := 4  ].
	^ 0	"to keep Slang happy"
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeMoveRMwr [

	"Stores a word (64 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: sd rd, rs1(offset)"

	<inline: true>
	| srcReg offset baseReg instrOffset |
	self flag: #DONE.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	self assert: (offset bitAnd: 16rfff) = offset.
	self machineCodeAt: 0 put: (self
			 storeDoubleWordFromRegister: srcReg
			 toAddressInRegister: baseReg
			 withOffset: offset).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	1halt
]

{ #category : #concretize }
CogRiscV64Compiler >> concretizeMoveRRd [

	<inline: true>
	| sourceRegister destinationRegister |
	sourceRegister := operands at: 0.
	destinationRegister := operands at: 1.

	self
		machineCodeAt: 0
		put: (self
			fMoveSize: 1
			fromScalarRegister: sourceRegister
			toDoublePrecisionFloatRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeMoveRX32rR [

	"Write the word in R(src) into memory at address (base+4*index)"

	<inline: true>
	| index base src |
	src := operands at: 0.
	index := operands at: 1.	"index is number of *words* = 4* bytes"
	base := operands at: 2.
	
	self
		machineCodeAt: 0
		put: (self
			strSize: 0
			baseRegister: base
			offsetRegister: index
			extension: 3 shift: 1
			storedRegister: src).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRXbrR [
	"Will get inlined into concretizeAt: switch."

	"Write the word in R(src) into memory at address (base+1*index)"

	<inline: true>
	| index base src |
	src := operands at: 0.
	index := operands at: 1.
	base := operands at: 2.

	self machineCodeAt: 0 put: (self strbBaseRegister: base offsetRegister: index extension: 3 shift: 1 srcRegister: src).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRXwrR [
	"Will get inlined into concretizeAt: switch."

	"Write the word in R(src) into memory at address (base+8*index)"

	<inline: true>
	| index base src |
	src := operands at: 0.
	index := operands at: 1.	"index is number of *words* = 8* bytes"
	base := operands at: 2.
	"str		src, [base, +index, LSL #2]"
	"cond 011 1100 0 base srcR 00010 00 0 inde"
	
	self
		machineCodeAt: 0
		put: (self
			strSize: 1
			baseRegister: base
			offsetRegister: index
			extension: 3 shift: 1
			storedRegister: src).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRdM64r [

	"Will get inlined into concretizeAt: switch."

	"Store FP fpReg to dstReg+offset"

	<inline: true>
	| baseRegister offset fpReg |
	fpReg := operands at: 0.
	offset := operands at: 1.
	baseRegister := operands at: 2.

	self assert: offset >= 0.

	self machineCodeAt: 0 put: (self
			 strBaseRegister: baseRegister
			 positiveOffset: offset
			 sourceFloatingPointRegister: fpReg
			 precision: 2r11). "64 bits"
	^ machineCodeSize := 4
]

{ #category : #concretize }
CogRiscV64Compiler >> concretizeMoveRdR [
	<inline: true>
	| sourceDoublePrecisionRegister destinationScalerRegister |
	sourceDoublePrecisionRegister := operands at: 0.
	destinationScalerRegister := operands at: 1.

	self
		machineCodeAt: 0
		put: (self
			fMoveSize: 1
			fromDoublePrecisionFloatRegister: sourceDoublePrecisionRegister
			toScalarRegister: destinationScalerRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveRsM32r [

	"Will get inlined into concretizeAt: switch."

	"Store FP fpReg to dstReg+offset"

	<inline: true>
	| baseRegister offset fpReg |
	fpReg := operands at: 0.
	offset := operands at: 1.
	baseRegister := operands at: 2.

	self assert: offset >= 0.

	self machineCodeAt: 0 put: (self
			 strBaseRegister: baseRegister
			 positiveOffset: offset
			 sourceFloatingPointRegister: fpReg
			 precision: 2r10). "32 bits"
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveX32rRR [

	"Will get inlined into concretizeAt: switch."

	"This Instruction as all the memory access should Zero-Extend the value"

	<inline: true>
	| index base dest |
	index := operands at: 0.
	base := operands at: 1.
	dest := operands at: 2.
	
	self machineCodeAt: 0 put: (self
			 ldrSize: 0
			 indexRegister: index
			 option: 2r011 "LSL"
			 scale: 1
			 baseRegister: base
			 destinationRegister: dest). "32bits"

	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveXbrRR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| index base dest |
	index := operands at: 0.
	base := operands at: 1.
	dest := operands at: 2.
	self machineCodeAt: 0 put: (self
		ldrbSourceRegister: base
		offsetRegister: index
		destinationRegister: dest).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMoveXwrRR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| indexRegister baseRegister destinationRegister |
	indexRegister := operands at: 0.
	baseRegister := operands at: 1.
	destinationRegister := operands at: 2.

	self
		machineCodeAt: 0
		put: (
			self
				ldrSize: 1
				indexRegister: indexRegister
				option: 2r011 "LSL"
				scale: 1
				baseRegister: baseRegister
				destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeMulRdRd [
	"FP multiply regLHS by regRHS and stick result in regLHS"

	<inline: true>
	| registerA registerB destinationRegister |
	registerA := operands at: 0.
	destinationRegister := registerB := operands at: 1.
	machineCode at: 0 put: (self
		fMulFirstRegister: registerA
		secondRegister: registerB
		destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeNegateR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	self machineCodeAt: 0 put: 
		(self negateSize: 1
			sourceRegister: (operands at: 0)
			sourceRegisterShiftType: 0 "LSL"
			sourceRegisterShift: 0 "no shift"
			destinationRegister: (operands at: 0)).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeNop [

	<inline: true>
	self flag: #DONE.
	self machineCodeAt: 0 put: self nop.
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeOrCqR [
	<var: #val type: #sqInt>
	<inline: true>
	| val rd rn |
	val := operands at: 0.
	
	"Both source and destination register are the same..."
	rn := operands at: 1.
	rd := rn.
	self
		encodeLogicalImmediate: val
		registerSize: 64
		ifPossible: [ :encodedValue |
			self
				machineCodeAt: 0
				put: (self
					orSize: 1
					immediate13bitValue: encodedValue
					sourceRegister: rn
					destinationRegister: rd).
			^ machineCodeSize := 4
		] ifNotPossible: [
			"If this does not fit in a logical immediate value => Try to move it to a register, then AND the registers"
			self moveCw: val intoR: ConcreteIPReg.
			self
				machineCodeAt: 4
				put: (self
					orSize: 1
					shiftedRegister: ConcreteIPReg
					shiftType: 0
					shiftValue: 0
					withRegister: rn
					destinationRegister: rd).
			machineCodeSize := 8 "A move and an AND"
		].
	^ 0	"to keep Slang happy"
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeOrRR [

	self machineCodeAt: 0 put: (self
			 inclusiveOrSize: 1
			 firstRegister: (operands at: 0)
			 secondRegister: (operands at: 1)
			 destinationRegister: (operands at: 1)).
			
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizePopR [
	"Will get inlined into concretizeAt: switch."
	
	"Load the content of the stack pointer in the given register then decrease the stack pointer.
	   ld destReg, 0(sp)
	   addi sp, sp, -8
	"

	<inline: true>
	| destReg |
	self flag: #TODO.
	destReg := operands at: 0.
	self machineCodeAt: 0 put: (self loadDoubleWordFromAddressInRegister: SP withOffset: 0 toRegister: destReg).	
	self machineCodeAt: 4	put: (self addImmediate: (16rFFF - 8 abs + 1) toRegister: SP inRegister: SP).
	^ machineCodeSize := 8	
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizePrefetchAw [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| addressOperand instrOffset |
	addressOperand := operands at: 0.
	(self isAddressRelativeToVarBase: addressOperand)
		ifTrue: [ | offset |
			offset := addressOperand - cogit varBaseAddress.
			self
				machineCodeAt: 0
				put:
					(self
						prefetchMemory: 0 "prefetchFlags: load in L1 KEEP" 
						sourceRegister: ConcreteVarBaseReg
						offset: addressOperand - cogit varBaseAddress).
			^ machineCodeSize := 4 ].
	
	instrOffset := self moveCw: addressOperand intoR: ConcreteIPReg.
	"We fetch using the ConcreteIPReg"

	self
		machineCodeAt: instrOffset
		put: (self
						prefetchMemory: 0 "prefetchFlags: load in L1 KEEP" 
						sourceRegister: ConcreteIPReg
						offset: 0).
	^ machineCodeSize := instrOffset + 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizePushCq [

	"Will get inlined into concretizeAt: switch."
	"Push (store) a double word at the position of the stack pointer if the constant is not a literal  
		li  ConcreteIPReg, cq (or up to li addiw slli addi slli addi slli addi)
		addi sp, sp, 8
		sd  ConcreteIPReg, 0(sp)
	
	If it is a literal:
	  auipc ConcreteIPReg, 0
	  ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		addi sp, sp, 8
		sd  ConcreteIPReg, 0(sp)
		"
	<inline: true>
	| cq instrOffset |
	self flag: #DONE.
	cq := operands at: 0.
	dependent
		ifNil: [ 
			"No literal -> Direct load into a scratch register, number of instructions depends on immediate size"
			instrOffset := self machineCodeWriteInstructions: (self loadImmediate: cq inRegister: ConcreteIPReg)
			]
		ifNotNil: [ 
			"Literal -> Compute the distance from the current address and add auipc then ld instructions"
			instrOffset := self machineCodeWriteInstructions: (self loadLiteralInRegister: ConcreteIPReg) 
			].
	self
		machineCodeAt: instrOffset
		put: (self addImmediate: 8 toRegister: SP inRegister: SP).
	self machineCodeAt: instrOffset + 4 put: (self
			 storeDoubleWordFromRegister: ConcreteIPReg
			 toAddressInRegister: SP
			 withOffset: 0).
	self halt.
	^ machineCodeSize := instrOffset + 8
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizePushCw [

	"Will get inlined into concretizeAt: switch."

	<inline: true>
	self halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizePushR [
	"Will get inlined into concretizeAt: switch."
	"Store the content of a register at the position of the stack pointer	  
		addi sp, sp, 8
		sd   srcReg, 0(sp)"
	<inline: true>
	| srcReg |
	self flag: #DONE.	
	srcReg := operands at: 0.
	self machineCodeAt: 0 put: (self addImmediate: 8 toRegister: SP inRegister: SP).
	self machineCodeAt: 4 put: (self
			 storeDoubleWordFromRegister: srcReg
			 toAddressInRegister: SP
			 withOffset: 0).	
	^ machineCodeSize := 8
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeRetN [

	"Will get inlined into concretizeAt: switch."
	"Jumps to the address stored in the Link Register + a given offset.
	If the offset is 0:
	(ret)	jalr, x0, 0(LR)
	Else, the offset is added to the LR before the jump:
	       addi, LR, offset(LR)
	(ret)  jalr, x0, 0(LR)
	"
	<inline: true>
	| offset instrOffset |
	self flag: #DONE.
	instrOffset := 0.
	offset := operands at: 0.
	"If the offset is different than 0, an addimmediate instruction is used on the stack pointer"
	offset = 0 ifFalse: [ 
		self assert: (offset bitAnd: 16rfff) = offset.
		self
			machineCodeAt: instrOffset
			put: (self addImmediate: offset toRegister: SP inRegister: SP).
		instrOffset := 4 ].

	self machineCodeAt: instrOffset put: self ret.
	^ machineCodeSize := instrOffset + 4
]

{ #category : #concretize }
CogRiscV64Compiler >> concretizeRotateLeftCqR [
	<var: #rotation type: #sqInt>
	<inline: true>
	| rotation sourceRegister destinationRegister |
	rotation := operands at: 0.
	destinationRegister := sourceRegister := operands at: 1.
	self machineCodeAt: 0 put: (self
		rorSize: 1
		sourceRegister: sourceRegister
		rotationBits: 64 - rotation "We rotate right by the inverse number of bits..."
		destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #concretize }
CogRiscV64Compiler >> concretizeRotateRightCqR [
	<var: #rotation type: #sqInt>
	<inline: true>
	| rotation sourceRegister destinationRegister |
	rotation := operands at: 0.
	destinationRegister := sourceRegister := operands at: 1.
	self machineCodeAt: 0 put: (self
		rorSize: 1
		sourceRegister: sourceRegister
		rotationBits: rotation
		destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeSDIV [
	<inline: true>

	| regNumerator regDenominator regDestination |
	regNumerator := operands at: 0.
	regDenominator := operands at: 1. 
	regDestination := operands at: 2.

	self 
		machineCodeAt: 0 
		put: (self
			 sdivSize: 1
			 numeratorReg: regNumerator
			 denominatorReg: regDenominator
			 destinationRegister: regDestination).

	^ machineCodeSize := 4
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeSMULH [
	
	| registerA destinationRegister registerB |
	registerA := operands at: 0.
	registerB := operands at: 1.
	destinationRegister := operands at: 2.
	
	self
		machineCodeAt: 0
		put: (self
			smulhSize: 1
			firstRegister: registerA
			secondRegister: registerB
			destinationRegister: destinationRegister).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeSqrtRd [
	"Will get inlined into concretizeAt: switch."

	"Square root of FP regLHS into regLHS"

	<inline: true>
	| regLHS |
	
	regLHS := operands at: 0.
	machineCode at: 0 put: (self fSqrtd: regLHS destinationRegister: regLHS).
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeStop [
	<inline: true>
	self machineCodeAt: 0 put: self stop.
	^ machineCodeSize := 4
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeSubCqR [
	"Will get inlined into concretizeAt: switch."

	"Try whether the quick constant is a small negative number. If it is, optimize."

	<inline: true>
	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeSubRR [

	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeSubRdRd [
	"FP substract registerA from registerB and stick result in registerB"

	<inline: true>
	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeTstCqR [

	"Will get inlined into concretizeAt: switch."

	"Perform a bitwise and between the value of register and the value of the operand. The result is discarded.
	
	For example if the instruction is used as: TstCqR JumpEquals(label) 
	
	If the operand is not a literal:
		andi ConcreteFlagReg, reg, cq
		li ConcreteIPReg, cq
		
		(beq ConcreteFlagReg,  ConcreteIPReg, label)
	
	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		and  ConcreteFlagReg, ConcreteIPReg, reg 
		
		(beq ConcreteFlagReg, ConcreteIPReg, label)
		"

	<inline: true>
	| register cq instrOffset literalAddress distance |
	self flag: #TODO.
	cq := operands at: 0.
	register := operands at: 1.

	dependent
		ifNil: [ "No literal -> and immediate then load the immediate to register (for further checks)"
			self machineCodeAt: 0 put: (self
					 bitwiseAndBetweenRegister: register
					 andImmediate: cq
					 toRegister: ConcreteFlagReg).
			self machineCodeAt: 4 put: (self load12BitsImmediate: cq inRegister: ConcreteIPReg).
			instrOffset := 8 ]
		ifNotNil: [ "Literal -> compute the distance, load the actual value then and between the 2 registers"
			literalAddress := (cogit  cCoerceSimple: dependent to: #'AbstractInstruction *') address.
			distance := literalAddress - address.
			self machineCodeAt: 0 put: (self addUpperImmediateToPC: 0 toRegister: ConcreteIPReg).
			self machineCodeAt: 4 put: (self
					 loadDoubleWordFromAddressInRegister: ConcreteIPReg
					 withOffset: distance
					 toRegister: ConcreteIPReg).
			self machineCodeAt: 8 put: (self
					 bitwiseAndBetweenRegister: register
					 andRegister: ConcreteIPReg
					 toRegister: ConcreteFlagReg).
			instrOffset := 12].
	^ machineCodeSize := instrOffset
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeXorCwR [

	1halt.
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> concretizeXorRR [

	1halt.
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> concretizeXorRdRd [
	
	1halt.
]

{ #category : #encoding }
CogRiscV64Compiler >> cond: c br: link offset: offset [
	"c : 4 bit, opcode = 10 bitOr: link, offset >>2, limited to 24 bits (which are sign-extended, shifted left 2 and added to 8 + pc to make the resulting address)"
	"single instr Branch, no link"
	<inline: true>
	^ c << 28 bitOr: (((2r1010 bitOr: (link bitAnd: 1)) << 24) bitOr: (offset >> 2 bitAnd: 16r00FFFFFF))
]

{ #category : #encoding }
CogRiscV64Compiler >> cond: c bx: link target: targetReg [
	"c : 4 bit, opcode = 10 bitOr: link, offset >>2, limited to 24 bits (which are sign-extended, shifted left 2 and added to 8 + pc to make the resulting address)"
	"BX targetReg or BLX targetReg"
	<inline: true>
	^ c << 28 bitOr: ( (16r12FFF10  bitOr: (link bitAnd: 1) <<5 ) bitOr: targetReg)
]

{ #category : #encoding }
CogRiscV64Compiler >> cond: conditionCode type: type op: flagsOrOpcode set: doUpdateStatusRegister rn:  sourceRegister rd: targetRegister [
"build an instruction - cccctttoooo + source + target"
	<inline: true>
	^(self cond: conditionCode type: type op: flagsOrOpcode set: doUpdateStatusRegister) 
		bitOr: (sourceRegister << 16 bitOr: targetRegister << 12)
]

{ #category : #encoding }
CogRiscV64Compiler >> cond: conditionCode type: type op: flagsOrOpcode set: doUpdateStatusRegister rn:  sourceRegister rd: targetRegister shifterOperand: so [
"build an instruction - cccctttoooo + source + target + shifter op"
	<inline: true>
	^(self cond: conditionCode type: type op: flagsOrOpcode set: doUpdateStatusRegister rn: sourceRegister rd: targetRegister) bitOr: (so bitAnd: 16rFFF)
]

{ #category : #testing }
CogRiscV64Compiler >> conditionIsNotNever: instr [
	"test for the NV condition code; this isn't allowed as an actual condition and is used to encdoe many of the newer instructions"
	^instr >> 28 < 16rF 
]

{ #category : #accessing }
CogRiscV64Compiler >> conditionOrNil [
"has to be named oddly like this to satisfay i-var code gen translating rules"
	^conditionOrNil
]

{ #category : #accessing }
CogRiscV64Compiler >> conditionOrNil: condCode [
"has to be named oddly like this to satisfay i-var code gen translating rules"
	^conditionOrNil := condCode
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> dispatchConcretize [
	"Attempt to generate concrete machine code for the instruction at address.
	 This is the inner dispatch of concretizeAt: actualAddress which exists only
	 to get around the branch size limits in the SqueakV3 (blue book derived)
	 bytecode set."
	<returnTypeC: #void>
	conditionOrNil ifNotNil:
		[self error: 'ARMv8 / aarch64 does not support conditions encoded in the instruction'.
		 ^self].
		 
	opcode caseOf: {
		"Noops & Pseudo Ops"
		[Label]					-> [^self concretizeLabel].
		[Literal]					-> [^self concretizeLiteral].
		[AlignmentNops]		-> [^self concretizeAlignmentNops].
		[Fill32]					-> [^self concretizeFill32].
		[Nop]					-> [^self concretizeNop].
		"Control"
		[Call]						-> [^self concretizeCall]. "call code within code space"
		[CallFull]					-> [^self concretizeCallFull]. "call code anywhere in address space"
		[JumpR]						-> [^self concretizeJumpR].
		[JumpFull]					-> [^self concretizeJumpFull]."jump within address space"
		[JumpLong]					-> [^self concretizeJumpLong]."jumps witihn code space"
		[JumpLongZero]			   -> [^self concretizeJumpLongZero].
		[JumpLongNonZero]	     	-> [^self concretizeJumpLongNonZero].
		[Jump]				     		-> [^self concretizeJump].
		[JumpZero]					-> [^self concretizeJumpZero ].
		[JumpNonZero]				-> [^self concretizeJumpNonZero ].
		[JumpNegative]				-> [^self concretizeConditionalJump: MI].
		[JumpNonNegative]			-> [^self concretizeConditionalJump: PL].
		[JumpOverflow]				-> [^self concretizeConditionalJump: VS].
		[JumpNoOverflow]			-> [^self concretizeConditionalJump: VC].
		[JumpCarry]				-> [^self concretizeConditionalJump: CS].
		[JumpNoCarry]				-> [^self concretizeConditionalJump: CC].
		[JumpLess]					-> [^self concretizeJumpLess ].
		[JumpGreaterOrEqual]		-> [^self concretizeJumpGreaterOrEqual ].
		[JumpGreater]				-> [^self concretizeJumpGreater ].
		[JumpLessOrEqual]			-> [^self concretizeJumpLessOrEqual ].
		[JumpBelow]				-> [^self concretizeConditionalJump: CC]. "unsigned lower"
		[JumpAboveOrEqual]		-> [^self concretizeConditionalJump: CS]. "unsigned greater or equal"
		[JumpAbove]				-> [^self concretizeConditionalJump: HI].
		[JumpBelowOrEqual]		-> [^self concretizeConditionalJump: LS].
		[JumpFPEqual]				-> [^self concretizeFPConditionalJump: EQ].
		[JumpFPNotEqual]			-> [^self concretizeFPConditionalJump: NE].
		[JumpFPLess]				-> [^self concretizeFPConditionalJump: LT].
		[JumpFPGreaterOrEqual]	-> [^self concretizeFPConditionalJump: GE].
		[JumpFPGreater]			-> [^self concretizeFPConditionalJump: GT].
		[JumpFPLessOrEqual]		-> [^self concretizeFPConditionalJump: LE].
		[JumpFPOrdered]			-> [^self concretizeFPConditionalJump: VC].
		[JumpFPUnordered]			-> [^self concretizeFPConditionalJump: VS].
		[RetN]						-> [^self concretizeRetN].
		[Stop]						-> [^self concretizeStop].
		"Arithmetic"
		[AddCqR]					-> [^self concretizeAddCqR].
		[AndCqR]					-> [^self concretizeAndCqR].
		[AndCqRR]					-> [^self concretizeAndCqRR].
		[CmpCqR]					-> [^self concretizeCmpCqR].
		[OrCqR]						-> [^self concretizeOrCqR].
		[SubCqR]					-> [^self concretizeSubCqR].
		[TstCqR]					-> [^self concretizeTstCqR].
		[XorCqR]					-> [^self concretizeInvertibleDataOperationCqR: XorOpcode].
		[AddCwR]					-> [^self concretizeDataOperationCwR: AddOpcode].
		[AndCwR]					-> [^self concretizeDataOperationCwR: AndOpcode].
		[CmpCwR]					-> [^self concretizeCmpCwR].
		[CmpC32R]					-> [^self concretizeCmpC32R].
		[OrCwR]					-> [^self concretizeDataOperationCwR: OrOpcode].
		[SubCwR]					-> [^self concretizeDataOperationCwR: SubOpcode].
		[XorCwR]					-> [^self concretizeXorCwR].
		[AddRR]						-> [^self concretizeAddRR].
		[AndRR]						-> [^self concretizeAndRR].
		[CmpRR]					-> [^self concretizeCmpRR].
		[OrRR]						-> [^self concretizeOrRR].
		[SubRR]						-> [^self concretizeSubRR].
		[XorRR]						-> [^self concretizeXorRR].

		"Floating point operations"
	
		[AddRdRd]					-> [^self concretizeAddRdRd].
		[CmpRdRd]					-> [^self concretizeCmpRdRd].
		[DivRdRd]					-> [^self concretizeDivRdRd].
		[MulRdRd]					-> [^self concretizeMulRdRd].
		[SubRdRd]					-> [^self concretizeSubRdRd].
		[SqrtRd]					-> [^self concretizeSqrtRd].
		[XorRdRd]					-> [^self concretizeXorRdRd].

		[NegateR]						-> [^self concretizeNegateR].
		[LoadEffectiveAddressMwrR]	-> [^self concretizeLoadEffectiveAddressMwrR].
		[ArithmeticShiftRightCqR]		-> [^self concretizeArithmeticShiftRightCqR].
		[LogicalShiftRightCqR]			-> [^self concretizeLogicalShiftRightCqR].
		[LogicalShiftLeftCqR]			-> [^self concretizeLogicalShiftLeftCqR].
		[ArithmeticShiftRightRR]			-> [^self concretizeArithmeticShiftRightRR].
		[LogicalShiftLeftRR]				-> [^self concretizeLogicalShiftLeftRR].
		[LogicalShiftRightRR]			-> [^self concretizeLogicalShiftRightRR].
		[RotateLeftCqR]					->	[^self concretizeRotateLeftCqR].
		[RotateRightCqR]				->	[^self concretizeRotateRightCqR].

		"ARM Specific Arithmetic" 
		[MUL]			-> [^self concretizeMUL].
		[SMULH]			-> [^self concretizeSMULH].
		[CMPMULOverflow]		-> [^self concretizeCMPMULOverflow].
		[SDIV]				-> [^self concretizeSDIV].
		[MSUB]				-> [^self concretizeMSUB].
		"Data Movement"
		[MoveCqR]			-> [^self concretizeMoveCqR].
		[MoveCwR]			-> [^self concretizeMoveCwR].
		[MoveC32R]		-> [^self concretizeMoveC32R].
		[MoveRR]			-> [^self concretizeMoveRR].
		[MoveAwR]			-> [^self concretizeMoveAwR].
		[MoveRAw]			-> [^self concretizeMoveRAw].
		[MoveAbR] 			 -> [^self concretizeMoveAbR].
 		[MoveRAb]			-> [^self concretizeMoveRAb].
		[MoveMbrR]			-> [^self concretizeMoveMbrR].
		[MoveRMbr]			-> [^self concretizeMoveRMbr].
		[MoveRM8r]			-> [^self concretizeMoveRMbr].
		[MoveRM16r]		-> [^self concretizeMoveRM16r].
		[MoveM16rR]		-> [^self concretizeMoveM16rR].
		[MoveM32rRs]		-> [^self concretizeMoveM32rRs].
		[MoveM64rRd]		-> [^self concretizeMoveM64rRd].
		[MoveM32rR]		-> [^self concretizeMoveM32rR].
		[MoveMwrR]		-> [^self concretizeMoveMwrR].
		[MoveXbrRR]		-> [^self concretizeMoveXbrRR].
		[MoveRXbrR]		-> [^self concretizeMoveRXbrR].
		[MoveX32rRR]		-> [^self concretizeMoveX32rRR].
		[MoveRX32rR]		-> [^self concretizeMoveRX32rR].
		[MoveXwrRR]		-> [^self concretizeMoveXwrRR].
		[MoveRXwrR]		-> [^self concretizeMoveRXwrR].
		[MoveRM32r]		-> [^self concretizeMoveRM32r].
		[MoveRMwr]		-> [^self concretizeMoveRMwr].
		[MoveRsM32r]		-> [^self concretizeMoveRsM32r].
		[MoveRdM64r]		-> [^self concretizeMoveRdM64r].
		[PopR]				-> [^self concretizePopR].
		[PushR]				-> [^self concretizePushR].
		[PushCq]			-> [^self concretizePushCq].
		[PushCw]			-> [^self concretizePushCw].
		[PrefetchAw]		-> [^self concretizePrefetchAw].
		"Conversion"
		[ConvertRdRs]		-> [^self concretizeConvertRdRs].
		[ConvertRsRd]		-> [^self concretizeConvertRsRd].
		[ConvertRRd]		-> [^self concretizeConvertRRd].
		[MoveRdR]			-> [^self concretizeMoveRdR].
		[MoveRRd]			-> [^self concretizeMoveRRd].
		
		"Patcheable literal instruction"
		[ MovePatcheableC32R ] -> [ ^ self concretizeMovePatcheableC32R ]
		}
]

{ #category : #'immediate-encodings' }
CogRiscV64Compiler >> encodeLogicalImmediate: immediate registerSize: registerSize ifPossible: aBlockWithEncoding ifNotPossible: aNotPossibleBlock [

	"https://github.com/llvm-mirror/llvm/blob/5c95b810cb3a7dee6d49c030363e5bf0bb41427e/lib/Target/AArch64/MCTargetDesc/AArch64AddressingModes.h#L213
	
	https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64/
	"
	<inline: #always>
	<var: #immediate type: 'uint64_t'>
	<var: #maskedImmediate type: 'uint64_t'>

	<var: #size type: 'uint64_t'>
	<var: #trailingZeros type: #'uint32_t'>
	<var: #trailingOnes type: #'uint32_t'>
	<var: #mask type: #'uint64_t'>
	<var: #leadingOnes type: #'uint32_t'>
	<var: #immr type: #'uint32_t'>
	<var: #nimms type: #'uint64_t'>
	<var: #n type: #'uint32_t'>

	| size mask maskedImmediate trailingZeros trailingOnes leadingOnes immr nimms n |

	(immediate = 0 or: [ 
		immediate = 0 bitInvert64
			or: [ registerSize ~= 64
				and: [ (immediate >> registerSize) ~= 0
					or: [ immediate == 0 bitInvert32 ] ] ] ])
		ifTrue: [ ^ aNotPossibleBlock value ].

	size := self sizeOf: immediate registerSize: registerSize.
	mask := 16rFFFFFFFFFFFFFFFF >> (64 - size).
	
	maskedImmediate := immediate bitAnd: mask.
	
	(self isShiftedMask: maskedImmediate) ifTrue: [
		trailingZeros := self trailingZerosOf: maskedImmediate.
		trailingOnes := self trailingOnesOf: (maskedImmediate >> trailingZeros).
	] ifFalse: [
	   maskedImmediate := maskedImmediate bitOr: mask bitInvert64.
		(self isShiftedMask: maskedImmediate bitInvert64)
			ifFalse: [ ^ aNotPossibleBlock value ].

		leadingOnes := self leadingOnesOf: maskedImmediate.
		trailingZeros := 64 "bits" - leadingOnes.
		trailingOnes := leadingOnes + (self trailingOnesOf: maskedImmediate) - (64 - size)
	].

	immr := (size - trailingZeros) bitAnd: (size - 1).
	nimms := (size-1) bitInvert64 << 1 bitAnd: 16rFFFFFFFFFFFFFFFF.
	nimms := nimms bitOr: trailingOnes - 1.
	
	n := ((nimms >> 6) bitAnd: 1) bitXor: 1.
	
	^ aBlockWithEncoding value: ((n << 12) bitOr: (immr << 6 bitOr: (nimms bitAnd: 16r3f)))
]

{ #category : #patching }
CogRiscV64Compiler >> extractConditionFromB: instruction [ 
	
	"Extract the offset inside a branch instruction of the formformat: 
	
	C6.2.25 B.cond
	
	Branch conditionally to a label at a PC-relative offset, with a hint that this is not a subroutine call or return.
	
	B.<cond> <label>
	
	The condition is encoded as the last 4 bits"
	self seeAlso: #branchCondition:offset:.
	
	^ instruction bitAnd: 16rf.
]

{ #category : #patching }
CogRiscV64Compiler >> extractOffsetFromBL: instr [
	"we are told this is a BL <offset> instruction, so work out the offset it encodes.
	
	Its offset from the address of this instruction, in the range +/-128MB, is encoded as imm26 times 4.
	So extract the immediate, and multiply it by 4.
	If negative, sign extend it."
	<inline: true>
	| relativeJump |
	relativeJump := instr bitAnd: 16r03FFFFFF.
	relativeJump := (relativeJump allMask: 1<<25)
						ifTrue: [(relativeJump bitOr: 16rFC000000) signedIntFromLong * 4]
						ifFalse: [relativeJump << 2].
	^relativeJump
]

{ #category : #patching }
CogRiscV64Compiler >> extractOffsetFromConditionalBranch: instruction [ 
	
	"Extract the offset inside a branch instruction of the formformat: 
	
	C6.2.25 B.cond
	
	Branch conditionally to a label at a PC-relative offset, with a hint that this is not a subroutine call or return.
	
	B.<cond> <label>
	
	The offset is encoded as an immediate of 19 bits that should be multiplied by 4 => so we do it by shifting it by 2
	"
	| twoComplement |
	self seeAlso: #branchCondition:offset:.
	
	twoComplement := instruction >> 5 bitAnd: 16r7FFFF.
	
	"Check if negative, if the highest bit is on"
	^ (twoComplement allMask: 1 << 18)
		ifTrue: [ self notYetImplemented  ]
		ifFalse: [ twoComplement << 2 ]
]

{ #category : #abi }
CogRiscV64Compiler >> fullCallsAreRelative [
	"Answer if CallFull and/or JumpFull are relative and hence need relocating on method
	 compation. If so, they are annotated with IsRelativeCall in methods and relocated in
	 relocateIfCallOrMethodReference:mcpc:delta:"
	^false
]

{ #category : #abi }
CogRiscV64Compiler >> genCaptureCStackPointers: captureFramePointer [

	"Save the register to a caller-saved register.
	The caller may have been using the same register for something else.
	So we need to save it and restore it later.
	Make sure to reuse a caller-saved register: we can reuse it freely"
	self hasVarBaseRegister ifTrue:
		[cogit
			MoveR: VarBaseReg R: X1;
			MoveCq: cogit varBaseAddress R: VarBaseReg].
	captureFramePointer ifTrue:
		[cogit MoveR: FPReg Aw: cogit cFramePointerAddress].

	"Capture the stack pointer prior to the call"
	cogit MoveR: self cStackPointer Aw: cogit cStackPointerAddress.
	
	"Restore the base register for our caller"
	self hasVarBaseRegister ifTrue:
		[cogit MoveR: X1 R: VarBaseReg].

	cogit RetN: 0.
]

{ #category : #'abstract instructions' }
CogRiscV64Compiler >> genDivR: abstractRegDenominator R: abstractRegNumerator Quo: abstractRegQuotient Rem: abstractRegRemainder [

	cogit gen: SDIV operand: abstractRegNumerator operand: abstractRegDenominator operand: ConcreteIPReg.
	cogit gen: MSUB operand: abstractRegNumerator operand: ConcreteIPReg operand: abstractRegDenominator operand: abstractRegRemainder.
	cogit MoveR: ConcreteIPReg R: abstractRegQuotient

]

{ #category : #'abstract instructions' }
CogRiscV64Compiler >> genJumpMultiplyOverflow: jumpTarget [
	<inline: true>
	<returnTypeC: #'AbstractInstruction *'>
	<var: #jumpTarget type: #'void *'>
	^cogit JumpNonZero: jumpTarget
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genLoadCStackPointer [
	"Load the stack pointer register with that of the C stack, effecting
	 a switch to the C stack.  Used when machine code calls into the
	 CoInterpreter run-time (e.g. to invoke interpreter primitives)."
	cogit MoveAw: cogit cStackPointerAddress R: SP.
	^0
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genLoadCStackPointers [
	"Load the frame and stack pointer registers with those of the C stack,
	 effecting a switch to the C stack.  Used when machine code calls into
	 the CoInterpreter run-time (e.g. to invoke interpreter primitives)."
	cogit MoveAw: cogit cStackPointerAddress R: SP.
	cogit MoveAw: cogit cFramePointerAddress R: FPReg.
	^0
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genLoadStackPointers [
	"Switch back to the Smalltalk stack. Assign SPReg first
	 because typically it is used immediately afterwards."
	cogit MoveAw: cogit stackPointerAddress R: SPReg.
	cogit MoveAw: cogit framePointerAddress R: FPReg.
	^0
]

{ #category : #abi }
CogRiscV64Compiler >> genMarshallNArgs: numArgs arg: regOrConst0 arg: regOrConst1 arg: regOrConst2 arg: regOrConst3 [
	"Generate the code to pass up to four arguments in a C run-time call.  Hack: each argument is
	 either a negative number, which encodes a constant, or a non-negative number, that of a register.

	 Run-time calls have no more than four arguments, so chosen so that on ARM, where in its C ABI the
	 first four integer arguments are passed in registers, all arguments can be passed in registers.  We
	 defer to the back end to generate this code not so much that the back end knows whether it uses
	 the stack or registers to pass arguments (it does, but...). In fact we defer for an extremely evil reason.
	 Doing so allows the x64 (where up to 6 args are passed) to assign the register arguments in an order
	 that allows some of the argument registers to be used for specific abstract  registers, specifically
	 ReceiverResultReg and ClassReg.  This is evil, evil, evil, but also it's really nice to keep using the old
	 register assignments the original author has grown accustomed to."
	<inline: true>
	numArgs = 0 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst0)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst0) R: CArg0Reg]
		ifFalse: [cogit MoveR: regOrConst0 R: CArg0Reg].
	numArgs = 1 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst1)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst1) R: CArg1Reg]
		ifFalse: [cogit MoveR: regOrConst1 R: CArg1Reg].
	numArgs = 2 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst2)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst2) R: CArg2Reg]
		ifFalse: [cogit MoveR: regOrConst2 R: CArg2Reg].
	numArgs = 3 ifTrue: [^self].
	(cogit isTrampolineArgConstant: regOrConst3)
		ifTrue: [cogit MoveCq: (cogit trampolineArgValue: regOrConst3) R: CArg3Reg]
		ifFalse: [cogit MoveR: regOrConst3 R: CArg3Reg]
]

{ #category : #'abstract instructions' }
CogRiscV64Compiler >> genMulR: regSource R: regDest [
	"In ARMv8 the multiplication operation (MUL) does not set the overflow flag.
	MUL multiplies two 64bit registers and produces the lower 64bit part of the 128bit result into a register.
	SMULH multiplies two 64bit registers and produces the higher 64bit part of the 128bit result into a register, sign-extended.
	An overflow happens in the higher part is just an extension of the sign of the lower part.
	In other words, an overflow does NOT happen if:
		=> the number lower part is positive (sign = 0) and the higher part is all 0s or
		=> the number lower part is negative (sign = 1) and the higher part is all 1s"
	

	<var: 'first' type: #'AbstractInstruction *'>
	| first |
	"First get the high part in a temporary register"
	cogit gen: SMULH operand: regSource operand: regDest operand: RISCTempReg.
	"Then get the low part on the destination register.
	Since this is a two-address code, destination register is the second operand too.
	Thus, writing to the destination register will override the operand:
	This is why we do this SMULH first and then MUL because both need the operands, and in this order we avoid an extra move..."
	first := cogit gen: MUL operand: regSource operand: regDest operand: regDest.
	cogit gen: CMPMULOverflow operand: regDest operand: RISCTempReg.
	^ first
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genPushRegisterArgsForAbortMissNumArgs: numArgs [
	"Ensure that the register args are pushed before the outer and
	 inner retpcs at an entry miss for arity <= self numRegArgs.  The
	 outer retpc is that of a call at a send site.  The inner is the call
	 from a method or PIC abort/miss to the trampoline."

	"Putting the receiver and args above the return address means the
	 CoInterpreter has a single machine-code frame format which saves
	 us a lot of work."

	"Iff there are register args convert
		sp		->	outerRetpc			(send site retpc)
		linkReg = innerRetpc			(PIC abort/miss retpc)
	 to
		base	->	receiver
					(arg0)
					(arg1)
		sp		->	outerRetpc			(send site retpc)
		sp		->	linkReg/innerRetpc	(PIC abort/miss retpc)"
	numArgs <= cogit numRegArgs ifTrue:
		[self assert: cogit numRegArgs <= 2.
		 cogit MoveMw: 0 r: SPReg R: TempReg. "Save return address"
		 cogit MoveR: ReceiverResultReg Mw: 0 r: SPReg.
		 numArgs > 0 ifTrue:
			[cogit PushR: Arg0Reg.
			 numArgs > 1 ifTrue:
				[cogit PushR: Arg1Reg]].
		cogit PushR: TempReg]. "push back return address"
	cogit PushR: LinkReg
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genPushRegisterArgsForNumArgs: numArgs scratchReg: ignored [
	"Ensure that the register args are pushed before the retpc for arity <= self numRegArgs."
	"This is easy on a RISC like ARM because the return address is in the link register.  Putting
	 the receiver and args above the return address means the CoInterpreter has a single
	 machine-code frame format which saves us a lot of work
	NOTA BENE: we do NOT push the return address here, which means it must be dealt with later."
	numArgs <= cogit numRegArgs ifTrue:
		[self assert: cogit numRegArgs <= 2.
		 cogit PushR: ReceiverResultReg.
		numArgs > 0 ifTrue:
			[cogit PushR: Arg0Reg.
			 numArgs > 1 ifTrue:
				[cogit PushR: Arg1Reg]]]
]

{ #category : #abi }
CogRiscV64Compiler >> genRemoveNArgsFromStack: n [
	"This is a no-op on ARM since the ABI passes up to 4 args in registers and trampolines currently observe that limit."
	<inline: true>
	self assert: n <= 4.
	^0
]

{ #category : #abi }
CogRiscV64Compiler >> genRestoreRegs: regMask [
	"Restore the registers in regMask as saved by genSaveRegs:."
	<inline: true>
	| registerCount |
	self assert: (X12 > X1 and: [X12 - X1 + 1 = 12]).
	self deny: (regMask anyMask: (cogit registerMaskFor: SPReg and: FPReg)).
	
	registerCount := 0.
	X1 to: X12 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[registerCount := registerCount + 1]].
	
	X1 to: X12 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[cogit PopR: reg]].
	
	"If we are restoring an odd number of registers, this would unalign the stack.
	Then, lets pop the extra thing to force the stack alignment"
	registerCount \\ 2 == 0
		ifFalse: [ 
			cogit PopR: X0  ].
	
	^0
]

{ #category : #abi }
CogRiscV64Compiler >> genSaveRegForCCall [
	"Save the general purpose registers for a call into the C run-time from a trampoline."
	"Save none, because the ARM ABI only defines callee saved registers, no caller-saved regs."
	"cogit gen: STMFD operand: 16r7F"
]

{ #category : #abi }
CogRiscV64Compiler >> genSaveRegs: regMask [
	"Save the registers in regMask for a call into the C run-time from a trampoline"
	<inline: true>
	| registerCount |
	self assert: (X12 > X1 and: [X12 - X1 + 1 = 12]).
	self deny: (regMask anyMask: (cogit registerMaskFor: SPReg and: FPReg)).
	
	registerCount := 0.
	X12 to: X1 by: -1 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[registerCount := registerCount + 1]].
	
	"If we are saving an odd number of registers, this would unalign the stack.
	Then, lets save an extra thing to force the stack alignment"
	registerCount \\ 2 == 0
		ifFalse: [ cogit PushCq: 16rBEEF "Marker smallinteger to generate a valid stack" ].
	
	X12 to: X1 by: -1 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[cogit PushR: reg]].
	^0
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genSaveStackPointers [
	"Save the frame and stack pointer registers to the framePointer
	 and stackPointer variables.  Used to save the machine code frame
	 for use by the run-time when calling into the CoInterpreter run-time."
	cogit MoveR: FPReg Aw: cogit framePointerAddress.
	cogit MoveR: SPReg Aw: cogit stackPointerAddress.
	^0
]

{ #category : #'abstract instructions' }
CogRiscV64Compiler >> genSubstituteReturnAddress: retpc [
	<inline: true>
	<returnTypeC: #'AbstractInstruction *'>
	^cogit MoveCw: retpc R: LR
]

{ #category : #disassembly }
CogRiscV64Compiler >> generalPurposeRegisterMap [
	<doNotGenerate>
	"Answer a Dictionary from register getter to register index."
	^Dictionary newFromPairs:
		{	#r0. X0.
			#r1. X1.
			#r2. X2.
			#r3. X3.
			#r4. X4.
			#r5. X5.
			#r6. X6.
			#r7. X7.
			#r8. X8.
			#r9. X9.
			#r10. X10.
			#r11. X11.
			#r12. X12	}
]

{ #category : #testing }
CogRiscV64Compiler >> hasConditionRegister [
	"Answer if the receiver supports, e.g., JumpOverflow after a regular AddRR"
	^true
]

{ #category : #testing }
CogRiscV64Compiler >> hasDoublePrecisionFloatingPointSupport [
	"might be true, but is for the forseeable future disabled"
	^true
]

{ #category : #testing }
CogRiscV64Compiler >> hasLinkRegister [
	^true "lr"
]

{ #category : #testing }
CogRiscV64Compiler >> hasPCDependentInstruction [
	"e.g. B, BL: Branch, Branch and Link"
	^true
]

{ #category : #testing }
CogRiscV64Compiler >> hasThreeAddressArithmetic [
	"Answer if the receiver supports three-address arithmetic instructions (currently only AndCqRR)"
	^true
]

{ #category : #testing }
CogRiscV64Compiler >> hasVarBaseRegister [
	"Answer if the processor has a dedicated callee-saved register to point to
	 the base of commonly-accessed variables. On ARM we use R10 for this."
	^true "r10/sl"
]

{ #category : #'generate machine code - concretize' }
CogRiscV64Compiler >> immediateLoadInstructionBytes: anImmediate [ 

	"Returns the number of bytes (instructions * 4) needed to generate
	 For an immediate
	 if < 16rfff                      -> addi                                    | 4 
	 else if < 16rffff ffff           -> lui addiw                               | 8
	 else if < 16rffff ffff fff       -> lui addiw slli addi                     | 16
	 else if < 16rffff ffff ffff ff   -> lui addiw slli addi slli addi           | 24
	 else if < 16rffff ffff ffff ffff -> lui addiw slli addi slli addi slli addi | 32"
	<inline:true>
	self flag: #DONE.
	anImmediate <= 16rfff ifTrue: [ ^ 4 ].
	anImmediate <= 16rffffffff ifTrue: [ ^ 8 ].
	anImmediate <= 16rfffffffffff ifTrue: [ ^ 16 ].	
	anImmediate <= 16rffffffffffffff ifTrue: [ ^ 24 ].
	anImmediate <= 16rffffffffffffffff ifTrue: [ ^ 32 ].	
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> initialize [
	"This method intializes the Smalltalk instance.  The C instance is merely a struct and doesn't need initialization."
	<doNotGenerate>
	operands := CArrayAccessor on: (Array new: NumOperands).
	machineCode := CArrayAccessor on: (Array new: self machineCodeWords)
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> inlineCacheTagAt: callSiteReturnAddress [
	"Answer the inline cache tag for the return address of a send."
	^self subclassResponsibility
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> instructionAddressBefore: followingAddress [
	"Answer the instruction address immediately preceding followingAddress."
	<inline: true>
	^followingAddress -4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> instructionBeforeAddress: followingAddress [
	"Answer the instruction immediately preceding followingAddress."
	<inline: true>
	<returnTypeC: #'uint32_t'>
	^objectMemory long32At: (self instructionAddressBefore: followingAddress)
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsB: instr [
	"is this a B <label> instruction?"
	self seeAlso: #b:.
	^ (instr bitAnd: 16r3f << 26) = (2r000101 << 26)
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsBL: instr [
	"is this a BL <label> instruction?"
	self seeAlso: #bl:.
	^ instr allMask: 2r100101 << 26
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsBLX: instr [
"is this a BLX <targetReg> instruction?"
	^(self conditionIsNotNever: instr)  and: [(instr bitAnd: 16r0FFFFFF0) = 16r12FFF30]
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsBX: instr [
"is this a BX <targetReg> instruction?"
	^(self conditionIsNotNever: instr) and: [(instr bitAnd: 16r0FFFFFF0) = 16r12FFF10]
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsCMP: instr [
	"is this a CMP instruction?"
	^(self conditionIsNotNever: instr) and: [(instr >> 21 bitAnd: 16r7F) = CmpOpcode]
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> instructionIsConditionalBranch: instruction [
	
	
	^ (instruction bitAnd: 16rFF << 24) = (2r01010100 << 24)
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsLDR: instr [

	^ instr allMask: 2r01011000 << 24
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsOR: instr [
	"is this an ORR instruction?"
	^(self conditionIsNotNever: instr)  and:[(instr >> 21 bitAnd: 16r7F) = (16r10 bitOr: OrOpcode)]
]

{ #category : #testing }
CogRiscV64Compiler >> instructionIsPush: instr [
	"is this a push R str r??, [sp, #-8] -  instruction?"
	<var: #instr type: #'uint32_t'> 
	
	^ (self pushR: 0) = (instr bitAnd: 16rFFFFFFFFFFFFFFE0)
]

{ #category : #disassembly }
CogRiscV64Compiler >> instructionSizeAt: pc [
	"Answer the instruction size at pc.Simple on ARM ;-)"
	^4
]

{ #category : #'generate machine code - support' }
CogRiscV64Compiler >> inverseOpcodeFor: armOpcode [
	"Several of the opcodes are inverses.  Answer the inverse for an opcode if it has one.
	 See Table A3-2 in sec A3.4 Data-processing instructions of the AARM."
	^armOpcode caseOf: {
			[AddOpcode]		->	[SubOpcode].
			[AndOpcode]		->	[BicOpcode].
			[BicOpcode]		->	[AndOpcode].
			[CmpOpcode]		->	[CmpNotOpcode].
			[MoveOpcode]		->	[MoveNotOpcode].
			[MoveNotOpcode]	->	[MoveOpcode].
			[SubOpcode]		->	[AddOpcode] }
		otherwise:
			[self error: 'opcode has no inverse'.
			 -1]
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> is12BitValue: constant ifTrue: aTrueBlock ifFalse: aFalseBlock [ 
	
	<inline: true>
	
	^ constant abs <= 2047 "(2 raisedTo: 11) - 1"
		ifTrue: [ | twoComplement |
			"Two complement using 12 bits"
			twoComplement := constant >= 0
				ifTrue: [ constant ]
				ifFalse: [ 16rfff - constant abs + 1 ].
			aTrueBlock value: constant >= 0 value: twoComplement ]
		ifFalse: [aFalseBlock value]
]

{ #category : #'private-bit-manipulation' }
CogRiscV64Compiler >> is64bitMask64: aMask [

	^ aMask ~= 0 and: [ ((aMask + 1) bitAnd: aMask) == 0 ]
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> is9BitValue: originalConstant ifTrue: aTrueBlock ifFalse: aFalseBlock [ 
	
	| constant |
	
	<inline: true>
	<var: #constant type: 'sqInt'>
	
	"This is needed to force the type conversion in an inlined function.
	If not... the variable is removed and using the parameter of the call site."
	constant := self cCoerce: originalConstant to: #'sqInt'.
	
	^ (constant abs <= 255 or: [ constant = -256 ]) "9 bits go from -256..255"
		ifTrue: [ | twoComplement |
			"Two complement using 9 bits"
			twoComplement := constant >= 0
				ifTrue: [ constant ]
				ifFalse: [ 16r1ff - constant abs + 1 ].
			aTrueBlock value: twoComplement ]
		ifFalse: [ aFalseBlock value ]
]

{ #category : #testing }
CogRiscV64Compiler >> isAddressRelativeToVarBase: varAddress [
	<inline: true>
	<var: #varAddress type: #usqInt>
	"Support for addressing variables off the dedicated VarBaseReg"
	^varAddress notNil
	  and: [varAddress >= cogit varBaseAddress
	  and: [varAddress - cogit varBaseAddress < (1 << 12)]]
]

{ #category : #testing }
CogRiscV64Compiler >> isBigEndian [
	^false
]

{ #category : #testing }
CogRiscV64Compiler >> isCallPrecedingReturnPC: mcpc [
	"Assuming mcpc is a send return pc answer if the instruction before it is a call (not a CallFull)."
	"There are two types of calls: BL and/BLX encoding"
	| call |
	call := self instructionBeforeAddress: mcpc.
	^(self instructionIsBL: call) or:[self instructionIsBLX: call]
]

{ #category : #testing }
CogRiscV64Compiler >> isInImmediateJumpRange: operand [
	"ARM calls and jumps span +/- 32 mb, more than enough for intra-zone calls and jumps."
	<var: #operand type: #'usqIntptr_t'>
	^operand signedIntFromLong between: -16r2000000 and: 16r1FFFFFC
]

{ #category : #testing }
CogRiscV64Compiler >> isJumpAt: pc [
	| instr |
	instr := objectMemory long32At: pc.
	^(self instructionIsB: instr)
	  or: [self instructionIsBX: instr]
]

{ #category : #testing }
CogRiscV64Compiler >> isPCRelativeValueLoad: instr [
	<var: 'instr' type: #'unsigned int'>
	"If ADR <Xd>, <label>"
	
	^ (instr bitAnd: 2r10011111 << 24) = (1 << 28)
]

{ #category : #'private-bit-manipulation' }
CogRiscV64Compiler >> isShiftedMask: aMask [

	^ aMask ~= 0 and: [ self is64bitMask64: ((aMask - 1) bitOr: aMask) ]
]

{ #category : #accessing }
CogRiscV64Compiler >> jumpLongByteSize [
"	Branch/Call ranges.  Jump[Cond] can be generated as short as possible.  Call/Jump[Cond]Long must be generated
	in the same number of bytes irrespective of displacement since their targets may be updated, but they need only
	span 16Mb, the maximum size of the code zone.  This allows e.g. ARM to use single-word call and jump instructions
	for most calls and jumps.  CallFull/JumpFull must also be generated in the same number of bytes irrespective of
	displacement for the same reason, but they must be able to span the full (32-bit or 64-bit) address space because
	they are used to call code in the C runtime, which may be distant from the code zone"
	^4
]

{ #category : #accessing }
CogRiscV64Compiler >> jumpLongConditionalByteSize [
	" AArch64 does not have conditional long jumps. Be a short conditional jump and a long jump "
	^ 8
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> jumpLongTargetBeforeFollowingAddress: mcpc [ 
	"Answer the target address for the long jump immediately preceding mcpc"
	^self callTargetFromReturnAddress: mcpc
]

{ #category : #disassembly }
CogRiscV64Compiler >> jumpTargetPCAt: pc [
	<returnTypeC: #usqInt>
	| operand word |
	word := objectMemory long32At: pc.
	operand := word bitAnd: 16rFFFFFF.
	(operand anyMask: 16r800000) ifTrue:
		[operand := operand - 16r1000000].
	^self
		cCode: [operand * 4 + pc + 8]
		inSmalltalk: [operand * 4 + pc + 8 bitAnd: cogit addressSpaceMask]
]

{ #category : #assembler }
CogRiscV64Compiler >> jumpTo: sourceRegisterValueAddress withOffset: offset andStorePreviousPCPlus4in: destinationRegister [ 
	"jalr: Sets the pc to x[rs1] + sign-extend(offset), masking off the least-significant bit of the computed address, 
	 then writes the previous pc+4 to x[rd]. If rd is omitted, x1 is assumed.
	
	 31             20  19    15  14   12  11    7  6         0
	|  	offset[11:0]  |   rs1   |  000   |   rd   |   1100111  |
	"

	| riscvOpcode |
	riscvOpcode := 2r1100111.
	self assert: (offset bitAnd: 16rfff) = offset.
	self flag: #DONE.
	^ (((((offset bitAnd: 16rfff) << 20 
		bitOr: (sourceRegisterValueAddress bitAnd: 16r1f) << 15)
		bitOr: 2r000)
		bitOr: (destinationRegister bitAnd: 16r1f) << 7)
		bitOr: riscvOpcode)
]

{ #category : #assembler }
CogRiscV64Compiler >> jumpToOffset: offset [
	"j: Pseudo-instruction that writes PC+offset to the PC 
	 Expands to jal, x0, offset
	"
	self flag: #DONE.
	^ self jumpToOffset: offset andStorePreviousPCPlus4in: X0
]

{ #category : #assembler }
CogRiscV64Compiler >> jumpToOffset: offset andStorePreviousPCPlus4in: destinationRegister [ 
	"jal: Writes the address of the next instruction (pc+4) to x[rd],
	 then sets the pc to the current pc plus the sign-extended offset. 
	 If rd is omitted, x1 is assumed
	
	 31                          12 11     7 6         0
	|  	 offset[20|10:1|11|19:12]   |   rd   |   1101111  |
	"

	| riscvOpcode signedOffset |
	riscvOpcode := 2r1101111.
	"Check for sign extension"	
	signedOffset := offset < 0
		                ifTrue: [ 16r1fff - offset abs + 1 ] "Compute two's complement"
		                ifFalse: [ offset ].
	self assert: (signedOffset bitAnd: 16r1fffff) = signedOffset.
	self flag: #DONE.
	^  ((((((signedOffset bitAnd: 16r100000) << 30) 
		bitOr: (signedOffset bitAnd: 16r7fe) << 21)
		bitOr: (signedOffset bitAnd: 16r800) << 20)
		bitOr: (signedOffset bitAnd: 16rff000) << 12)
		bitOr: (destinationRegister bitAnd: 16r1f) << 7)
		bitOr: riscvOpcode
]

{ #category : #assembler }
CogRiscV64Compiler >> jumpToRegisterValue: sourceReg [ 
	"jr: Pseudo-instruction that writes x[rs] to the PC 
	 Expands to jalr, x0, 0(rs)
	"
	self flag: #DONE.
	^ self jumpTo: sourceReg withOffset: 0 andStorePreviousPCPlus4in: X0
]

{ #category : #'private-bit-manipulation' }
CogRiscV64Compiler >> leadingOnesOf: aNumber [
	"Return how many leading ones are in the 64bit bitString representation of aNumber.
	That is, how many ones are in the most significant bits before there is a zero.
	For example, the 64bit binary number 2r11101101000110001111...00 has 3 leading ones"
	
	"Calculate it by calculating the leading zeros of the bit-inverted number"
	^ self leadingZerosOf: (aNumber bitXor: 16rFFFFFFFFFFFFFFFF)
]

{ #category : #'private-bit-manipulation' }
CogRiscV64Compiler >> leadingZerosOf: aNumber [
	"Return how many leading zeros are in the 64bit bitString representation of aNumber.
	That is, how many zeros are in the most significant bits before there is a one.
	For example, the 64bit binary number 2r00010101000110001111000...00 has 3 trailing zeros.
	
	Uses a bisect method looking at the number by halfs"
	
	"We take a look at the most significant part of the number by ignoring the lower part (shifting it).
	If the non ignored part is not all zeros, continue the procedure with the non-ignored bits.
	On each iteration, ignore less (dividing the shift by two) because there may be more leading zeros.
	"
	| zeroBits currentNumber shift shiftedValue |
	zeroBits := 0.
	currentNumber := aNumber.
	shift := 64"bits" >>1.
	[ shift ~= 0 ] whileTrue: [
		shiftedValue := currentNumber >> shift.
		(shiftedValue ~= 0)
			ifTrue: [ currentNumber := shiftedValue ]
			ifFalse: [ 
				"If we found they are all zeros, record them"
				zeroBits := zeroBits bitOr: shift ].
		shift := shift >> 1.
	].
	^ zeroBits
]

{ #category : #abi }
CogRiscV64Compiler >> leafCallStackPointerDelta [
	"Answer the delta from the stack pointer after a call to the stack pointer
	 immediately prior to the call.  This is used to compute the stack pointer
	 immediately prior to  call from within a leaf routine, which in turn is used
	 to capture the c stack pointer to use in trampolines back into the C run-time."
	"This might actually be false, since directly after a call, lr, fp and variable registers need be pushed onto the stack. It depends on the implementation of call."
	^0
]

{ #category : #accessing }
CogRiscV64Compiler >> literalLoadInstructionBytes [
	"Answer the size of a literal load instruction (which may or may not include the size of the literal).
	 This differs between in-line and out-of-line literal generation."
	<inline: true>
	self flag: #DONE.
	"Loading a literal will extend to two instructions:
		- auipc: add the pc to the upper 20-bits of the offset  - auipc rd, offsetHigh
		- ld:    load the double word from the computed address - ld    rd, offsetLow(rd)
	 This brings us to two instructions and 8 bits"
	^ 8
]

{ #category : #assembler }
CogRiscV64Compiler >> load12BitsImmediate: anImmediate inRegister: aRegisterID [

	"li: Load immediate for sub-12bits immediate is an addi with register X0 (always holding the value 0)"

	self flag: #DONE.
	^ self
		  addImmediate: anImmediate
		  toRegister: X0
		  inRegister: aRegisterID
]

{ #category : #'generate machine code - support' }
CogRiscV64Compiler >> loadCwInto: destReg [
	"Load the operand into the destination register, answering
	 the size of the instructions generated to do so."
	| operand distance |
	operand := operands at: 0.
	self cCode:[] inSmalltalk:[operand := operand bitAnd: 16rFFFFFFFFFFFFFFFF]. "Need to clamp the value to a word size since one or two usages actually generate double sized values and rely upon the C code to narrow it within the running VM"
	(self isAnInstruction: (cogit cCoerceSimple: operand to: #'AbstractInstruction *')) ifTrue:
		[operand := (cogit cCoerceSimple: operand to: #'AbstractInstruction *') address].
	"First try and encode as a pc-relative reference..."
	(cogit addressIsInCurrentCompilation: operand) ifTrue: [
		distance := operand - address.
		"Check if the absolute distance fits in 20 bits.
		We need to encode the offset in 21 bits signed, so 1 bit is for the sign."
		(distance abs bitAnd: 16rfffff) = distance abs
			ifTrue: [ 
				self machineCodeAt: 0 put: (self adrSignedImmediate21BitsValue: distance destinationRegister: destReg).
				^ machineCodeSize := 4 ]
			ifFalse: [ self notYetImplemented. ]].
	
	"If this fails, use the conventional literal load sequence."
	^self moveCw: operand intoR: destReg
]

{ #category : #assembler }
CogRiscV64Compiler >> loadDoubleWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"ld: Loads eight bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31       20  19    15  14   12  11    7  6         0
	|  	offset  |   rs1   |  001   |   rd   |   0000011  |
	"

	| riscvOpcode |
	self assert: (offset bitAnd: 16rfff) = offset.
	self flag: #DONE.
	riscvOpcode :=  2r0000011.
	^ ((((((offset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r011 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcode) 


	
]

{ #category : #assembler }
CogRiscV64Compiler >> loadImmediate: anImmediate inRegister: destReg [

	"li: Pseudo-instruction that expands to variable instructions:
	 if < 16rfff                      -> load12BitsImmediate (addi) 
	 else if < 16rffff ffff           -> lui addiw
	 else if < 16rffff ffff fff       -> lui addiw slli addi 
	 else if < 16rffff ffff ffff ff   -> lui addiw slli addi slli addi
	 else if < 16rffff ffff ffff ffff -> lui addiw slli addi slli addi slli addi"

	self flag: #TODO. "Check for sign???"
	anImmediate < 16rfff ifTrue: [ ^ { self load12BitsImmediate: anImmediate inRegister: destReg }].
	anImmediate < 16rffffffff ifTrue: [ 
		^ {  
		self loadUpperImmediate: ((anImmediate >> 12) bitAnd: 16rfffff) inRegister: destReg. 
	  	self addWordImmediate: (anImmediate bitAnd: 16rfff) toRegister: destReg inRegister: destReg
		}
	].
	anImmediate < 16rfffffffffff ifTrue: [ 
		^ {  
	 	self loadUpperImmediate: ((anImmediate >> 24) bitAnd: 16rfffff) inRegister: destReg.
		self addWordImmediate: (anImmediate bitAnd: 16rfff000) toRegister: destReg inRegister: destReg.
		self shiftLeftValueInRegister: destReg byShiftAmount: 12 intoRegister: destReg.
		self addImmediate: (anImmediate bitAnd: 16rfff) toRegister: destReg inRegister: destReg
		}
	].
	anImmediate < 16rffffffffffffff ifTrue: [ 
		^ { 
	 	self loadUpperImmediate: ((anImmediate >> 36) bitAnd: 16rfffff) inRegister: destReg.
		self addWordImmediate: (anImmediate bitAnd: 16rfff000000) toRegister: destReg inRegister: destReg.
		self shiftLeftValueInRegister: destReg byShiftAmount: 12 intoRegister: destReg.
		self addImmediate: (anImmediate bitAnd: 16rfff000) toRegister: destReg inRegister: destReg.	
		self shiftLeftValueInRegister: destReg byShiftAmount: 12 intoRegister: destReg.
		self addImmediate: (anImmediate bitAnd: 16rfff) toRegister: destReg inRegister: destReg
		}
   ].

	^ { 
	self loadUpperImmediate: ((anImmediate >> 48) bitAnd: 16rfffff) inRegister: destReg.
	self addWordImmediate: (anImmediate bitAnd: 16rfff000000000) toRegister: destReg inRegister: destReg.
	self shiftLeftValueInRegister: destReg byShiftAmount: 12 intoRegister: destReg.
	self addImmediate: (anImmediate bitAnd: 16rfff000000) toRegister: destReg inRegister: destReg.	
	self shiftLeftValueInRegister: destReg byShiftAmount: 12 intoRegister: destReg.
	self addImmediate: (anImmediate bitAnd: 16rfff000) toRegister: destReg inRegister: destReg.	
	self shiftLeftValueInRegister: destReg byShiftAmount: 12 intoRegister: destReg.
	self addImmediate: (anImmediate bitAnd: 16rfff) toRegister: destReg inRegister: destReg
	}


]

{ #category : #assembler }
CogRiscV64Compiler >> loadLiteralInRegister: destReg [

	| literalAddress distance |
	"Compute the distance from the current address
	- auipc to get the PC
	- ld    to load relative to the PC"
	self flag: #DONE.
	literalAddress := (cogit cCoerceSimple: dependent to: #'AbstractInstruction *') address.
	distance := literalAddress - address.
	^ {  
		self addUpperImmediateToPC: 0 toRegister: destReg.
   		self loadDoubleWordFromAddressInRegister: destReg withOffset: distance toRegister: destReg
	}

]

{ #category : #accessing }
CogRiscV64Compiler >> loadPICLiteralByteSize [
	"Answer the byte size of a MoveCwR opcode's corresponding machine code
	 when the argument is a PIC.  This is for the self-reference at the end of a
	 closed PIC.  On ARM this is a single instruction pc-relative register load."
	^4
]

{ #category : #assembler }
CogRiscV64Compiler >> loadUpperImmediate: anImmediate inRegister: destReg [

	"lui: Writes the sign-extended 20-bit immediate, let-shifted by 12 bits,
	 to x[rd], zeroing the lower 12 bits
	
	31                 12 11   7 6         0
	|  	immediate[31:12]  |  rd  |  0110111  |
	"

	| riscvOpcode signedImmediate |
	self flag: #DONE.	
	self assert: (anImmediate bitAnd: 16rfffff) = anImmediate.
	signedImmediate := anImmediate < 0
		                   ifTrue: [ "Compute the two's complement" 
		                   16rfffff - anImmediate abs + 1 ]
		                   ifFalse: [ anImmediate ].
	riscvOpcode := 2r0110111.
	^ (((anImmediate bitAnd: 16rfffff) << 12) 
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: riscvOpcode
]

{ #category : #accessing }
CogRiscV64Compiler >> machineCodeAt: anOffset [

	"read aWord from machineCode, with little endian"

	<inline: true>
	^ machineCode at: anOffset // 4
]

{ #category : #accessing }
CogRiscV64Compiler >> machineCodeAt: anOffset put: aWord [
	"add aWord to machineCode, with little endian"
	<inline: true>
	self haltIf: [ aWord highBit > 32 ].
	machineCode at: anOffset // 4 put: aWord
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> machineCodeBytes [
	"Answer the maximum number of bytes of machine code generated for any abstract instruction.
	 e.g. CmpCwR =>
			mov R3, #<addressByte1>, 12
			orr R3, R3, #<addressByte2>, 8
			orr R3, R3, #<addressByte3>, 4
			orr R3, R3, #<addressByte4>, 0
			cmp R?, R3"
	self flag: #TODO.
	^20
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> machineCodeWords [
	"Answer the maximum number of words of machine code generated for any abstract instruction.
	 e.g. CmpCwR =>
			mov R3, #<addressByte1>, 12
			orr R3, R3, #<addressByte2>, 8
			orr R3, R3, #<addressByte3>, 4
			orr R3, R3, #<addressByte4>, 0
			cmp R?, R3"
	self flag: #TODO.
	^5
]

{ #category : #assembler }
CogRiscV64Compiler >> machineCodeWriteInstructions: anInstructionCollection [

	"Write the machine code instructions and returns the correct offset"
	self flag: #TODO.	
	anInstructionCollection doWithIndex: [ :each :i | self machineCodeAt: i put: each ].
	^ anInstructionCollection size * 4

]

{ #category : #'generate machine code - support' }
CogRiscV64Compiler >> moveCw: constant intoR: destReg [
	"Emit a load of aWord into destReg.  Answer the number of bytes of machine code generated."
	 <var: 'constant' type: #usqInt>
	<inline: true>
	^self subclassResponsibility
]

{ #category : #'ARM convenience instructions' }
CogRiscV64Compiler >> moveRegister: srcReg toRegister: destReg [

	"mv is pseudo instruction for addi rd, rs1, 0"	
	self flag: #DONE.
	^ self addImmediate: 0 toRegister: srcReg inRegister: destReg
]

{ #category : #printing }
CogRiscV64Compiler >> nameForFPRegister: reg [ "<Integer>"
	<doNotGenerate>
	(reg between: 0 and: 7) ifTrue:
		[^#(D0 D1 D2 D3 D4 D5 D6 D7) at: reg + 1].
	^super nameForFPRegister: reg
]

{ #category : #printing }
CogRiscV64Compiler >> nameForRegister: reg [ "<Integer>"
	<doNotGenerate>
	| default |
	default := super nameForRegister: reg.
	^default last = $?
		ifTrue:
			[#(LR SP PC CArg0Reg CArg0Reg CArg1Reg CArg2Reg CArg3Reg)
				detect: [:sym| (thisContext method methodClass classPool at: sym) = reg] 
				ifNone: [default]]
		ifFalse:
			[default]
]

{ #category : #assembler }
CogRiscV64Compiler >> nop [
	
	"nop: Pseudoinstruction that expands to addi x0, 0(x0)"
	self flag: #DONE.
	^ self addImmediate: 0 toRegister: X0 inRegister: X0 
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> numICacheFlushOpcodes [
	"ARM needs to do icache flushing when code is written"
	"for now return 0 to skip it and probably blow up"
	^0
	
]

{ #category : #accessing }
CogRiscV64Compiler >> numIntRegArgs [
	^4
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> outputMachineCodeAt: targetAddress [
	"Override to move machine code a word at a time."
	<inline: true>
	0 to: machineCodeSize - 1 by: 4 do:
		[:j|
		objectMemory uint32AtPointer: targetAddress + j put: (machineCode at: j // 4)]
]

{ #category : #'generate machine code' }
CogRiscV64Compiler >> padIfPossibleWithStopsFrom: startAddr to: endAddr [
	| nullBytes |
	nullBytes := (endAddr - startAddr + 1) \\ 4.
	self stopsFrom: startAddr to: endAddr - nullBytes.
	endAddr - nullBytes + 1 to: endAddr 
		do: [ :p | objectMemory byteAt: p put: 16rFF]
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> prefetchMemory: prefetchOperationFlags sourceRegister: sourceRegister offset: offset [
	
	"C6.2.212 PRFM (immediate)
	
	Prefetch Memory (immediate) signals the memory system that data memory accesses from a specified address are likely to occur in the near future. The memory system can respond by taking actions that are expected to speed up the memory accesses when they do occur, such as preloading the cache line containing the specified address into one or more caches.
	
	PRFM (<prfop>|#<imm5>), [<Xn|SP>{, #<pimm>}]"
	
	^ 2r1111100110 << 22
		bitOr: ((offset bitAnd: 16rfff) << 10
		bitOr: ((sourceRegister bitAnd: 16r1f) << 5
		bitOr: (prefetchOperationFlags bitAnd: 16r1f)))
]

{ #category : #'calling C function in Smalltalk stack' }
CogRiscV64Compiler >> prepareStackToCallCFunctionInSmalltalkStack: anObject [ 

	"In ARMv8 we are using an alternative SPReg that is not the machine SP.
	We need to sync the SP register to the Smalltalk stackPointer, so the called function 
	will execute correctly."
	
	cogit MoveR: SPReg R: Extra2Reg.

	"ARMv8 should be aligned to 16 bytes"

	cogit AndCq: ((1 << 64) - 16) R: Extra2Reg. 
	cogit MoveR: Extra2Reg R: SP.
]

{ #category : #accessing }
CogRiscV64Compiler >> pushLinkRegisterByteSize [
	^4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> relocateCallBeforeReturnPC: retpc by: delta [
	| instr distanceDiv4 |
	self assert: delta \\ 4 = 0.
	delta ~= 0 ifTrue:
		[instr := self instructionBeforeAddress: retpc.
		 self assert: ((self instructionIsB: instr) or: [self instructionIsBL: instr]).
		 distanceDiv4 := instr bitAnd: 16rFFFFFF.
		 distanceDiv4 := distanceDiv4 + (delta // 4).
		 objectMemory long32At: (self instructionAddressBefore: retpc ) put: ((instr bitAnd: 16rFF000000) bitOr: (distanceDiv4 bitAnd: 16rFFFFFF))]
]

{ #category : #assembler }
CogRiscV64Compiler >> ret [
	
	"ret: Pseudoinstruction that expands to jalr, x0, 0(x1)"
	self flag: #DONE.
   ^ self jumpTo: LR  withOffset: 0 andStorePreviousPCPlus4in: X0
	
]

{ #category : #'calling C function in Smalltalk stack' }
CogRiscV64Compiler >> returnFromCallCFunctionInSmalltalkStack: anObject [ 

	"In ARMv8 I don't need to do nothing"

]

{ #category : #patching }
CogRiscV64Compiler >> rewriteBranch: conditionalBranch withNewOffset: newOffset [
	
	"Rewrite the offset inside a branch instruction of the form: 
	26-bit signed PC-relative branch offset variant
	
	B <label>
	
	<label> Is the program label to be unconditionally branched to. Its offset from the address of this instruction, in the range +/-128MB, is encoded as imm26 times 4."
	
	self seeAlso: #b:.
	^ self b: newOffset
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteCPICJumpAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to reset the 
	jumps in the prototype CPIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| callDistance instr |

	callTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].

	callDistance := (callTargetAddress - (callSiteReturnAddress - 4 "return offset")).
	self assert: (self isInImmediateJumpRange: callDistance). "we don't support long call updates, yet"

	instr := self instructionBeforeAddress: callSiteReturnAddress.
	self assert: (self instructionIsConditionalBranch: instr).

	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress)
		put: (self branchCondition: (self extractConditionFromB: instr) offset: callDistance).

	self assert: (self extractOffsetFromConditionalBranch: ((self branchCondition: (self extractConditionFromB: instr) offset: callDistance))) = callDistance.
	^4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteCallAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a call instruction to call a different target.  This variant is used to link PICs
	 in ceSendMiss et al,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	^self rewriteTransferAt: callSiteReturnAddress target: callTargetAddress
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteCallFullAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a callFull instruction to jump to a different target.  This variant
	 is used to rewrite cached primitive calls where we load the target address into ip
	and use the 'blx ip' instruction for the actual call.
	Answer the extent of the
	 code change which is used to compute the range of the icache to flush."
	<inline: true>
	^self
		rewriteFullTransferAt: callSiteReturnAddress
		target: callTargetAddress
		expectedInstruction: 16rE12FFF3C
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteConditionalJumpLongAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to reset the 
	jumps in the prototype CPIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| callDistance instr |

	callTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].

	callDistance := (callTargetAddress - (callSiteReturnAddress - 4 "return offset")).
	self assert: (self isInImmediateJumpRange: callDistance). "we don't support long call updates, yet"

	instr := self instructionBeforeAddress: callSiteReturnAddress.
	self assert: (self instructionIsConditionalBranch: instr).

	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress)
		put: (self branchCondition: (self extractConditionFromB: instr) offset: callDistance).

	self assert: (self extractOffsetFromConditionalBranch: ((self branchCondition: (self extractConditionFromB: instr) offset: callDistance))) = callDistance.
	^4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteFullTransferAt: callSiteReturnAddress target: callTargetAddress expectedInstruction: expectedInstruction [
	"Rewrite a CallFull or JumpFull instruction to transfer to a different target.
	 This variant is used to rewrite cached primitive calls.   Answer the extent
	 of the code change which is used to compute the range of the icache to flush."
	^self subclassResponsibility
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteInlineCacheAt: callSiteReturnAddress tag: cacheTag target: callTargetAddress [
	"Rewrite an inline cache to call a different target for a new tag.  This variant is used
	 to link unlinked sends in ceSend:to:numArgs: et al.  Answer the extent of the code
	 change which is used to compute the range of the icache to flush."
	
	^self subclassResponsibility
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteJumpFullAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a full jump instruction to jump to a different target.  This variant
	 is used to rewrite cached primitive calls where we load the target address into ip
	and use the 'bx ip' instruction for the actual jump.
	Answer the extent of the
	 code change which is used to compute the range of the icache to flush."
	<inline: true>
	
	^self
		rewriteFullTransferAt: callSiteReturnAddress
		target: callTargetAddress
		expectedInstruction: 16rD61F0200 "This is the assembled instruction br x16. This will break if we change the assignment of registers"
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteJumpLongAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to reset the 
	jumps in the prototype CPIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	^self rewriteTransferAt: callSiteReturnAddress target: callTargetAddress
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteTransferAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a call/jump instruction to call a different target.  This variant is used to link PICs
	 in ceSendMiss et al, and to rewrite call/jumps in CPICs.
	Answer the extent of
	 the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| callDistance instr |

	callTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].

	callDistance := (callTargetAddress - (callSiteReturnAddress - 4 "return offset")).
	self assert: (self isInImmediateJumpRange: callDistance). "we don't support long call updates, yet"

	instr := self instructionBeforeAddress: callSiteReturnAddress.
	self assert: ((self instructionIsB: instr) or: [self instructionIsBL: instr]).

	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress)
		put: (self b: callDistance withLink: (self instructionIsBL: instr)).

	self assert: (self callTargetFromReturnAddress: callSiteReturnAddress) = callTargetAddress.

	^4
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> rightShiftSize: is64Bits sourceRegister: sourceRegister shiftValue: shiftValue shiftType: shiftType destinationRegister: destinationRegister [
	
	"C3.3.9 Shift (immediate)
	
	Shifts and rotates by a constant amount are implemented as aliases of the Bitfield move or Extract register instructions. The shift or rotate amount must be in the range 0 to one less than the register width of the instruction, inclusive.
	
	LSR <Xd>, <Xn>, #<shift>  => shiftType = 10
	ASR <Xd>, <Xn>, #<shift>  => shiftType = 00
	
	"
	
	^ (is64Bits bitAnd: 1) << 31
		bitOr: ((shiftType bitAnd: 2r11) << 29
		bitOr: (2r100110 << 23
		bitOr: ((is64Bits bitAnd: 1) << 31
		bitOr: ((shiftValue bitAnd: 2r111111) << 16
		bitOr: ((2r11111 << 10)
		bitOr: ((sourceRegister bitAnd: 2r11111) << 5
		bitOr: (destinationRegister bitAnd: 2r11111)))))))
]

{ #category : #testing }
CogRiscV64Compiler >> rotateable8bitBitwiseImmediate: constant ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [
	<inline: true>
	"Invoke trueAlternativeBlock with shift, value and inverted if constant can be represented
	 by a possibly rotated 8-bit constant, otherwise invoke falseAlternativeBlock. For data
	 processing operands, there is the immediate shifter_operand variant,  where an 8 bit value
	 is ring shifted _right_ by i. This is only suitable for quick constants (Cq), which won't change."
	| value |
	value := constant.
	[(value bitAnd: 16rFF) = value ifTrue:
		[^trueAlternativeBlock value: 0 value: value value: constant ~= value].
	 2 to: 30 by: 2 do:
		[:i |
		(value bitAnd: ((16rFF <<i bitAnd:16rFFFFFFFF) bitOr: 16rFF>>(32-i))) = value ifTrue:
			[^trueAlternativeBlock
				value: 32 - i
				value: ((value >> i) bitOr: (value <<(32 - i) bitAnd:16rFFFFFFFF))
				value: constant ~= value]].
	 value = constant]
		whileTrue:
			[value := constant < 0
						ifTrue:[-1 - constant]
						ifFalse:[constant bitInvert32]].
	^falseAlternativeBlock value
]

{ #category : #testing }
CogRiscV64Compiler >> rotateable8bitImmediate: constant ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [
	<inline: true>
	"For data processing operands, there is the immediate shifter_operand variant, 
	 where an 8 bit value is ring shifted _right_ by i.
	 This is only suitable for quick constants(Cq), which won't change."
	
	(constant bitAnd: 16rFF) = constant ifTrue:
		[^trueAlternativeBlock value: 0 value: constant].
	2 to: 30 by: 2 do:
		[:i |
		(constant bitAnd: ((16rFF <<i bitAnd:16rFFFFFFFF) bitOr: 16rFF>>(32-i))) = constant ifTrue:
			[^trueAlternativeBlock value: 32 - i value: ((constant >> i) bitOr: (constant <<(32 - i) bitAnd:16rFFFFFFFF))]].
	^falseAlternativeBlock value
]

{ #category : #testing }
CogRiscV64Compiler >> rotateable8bitSignedImmediate: constant ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [
	<inline: true>
	"Invoke trueAlternativeBlock with shift, value and negated if constant can be represented
	 by a possibly rotated 8-bit constant, otherwise invoke falseAlternativeBlock. For data
	 processing operands, there is the immediate shifter_operand variant,  where an 8 bit value
	 is ring shifted _right_ by i. This is only suitable for quick constants (Cq), which won't change."
	| value |
	value := constant.
	[(value bitAnd: 16rFF) = value ifTrue:
		[^trueAlternativeBlock value: 0 value: value value: constant ~= value].
	 2 to: 30 by: 2 do:
		[:i |
		(value bitAnd: ((16rFF <<i bitAnd:16rFFFFFFFF) bitOr: 16rFF>>(32-i))) = value ifTrue:
			[^trueAlternativeBlock
				value: 32 - i
				value: ((value >> i) bitOr: (value <<(32 - i) bitAnd:16rFFFFFFFF))
				value: constant ~= value]].
	 value = constant and: [constant ~= 0]]
		whileTrue:
			[value := constant negated].
	^falseAlternativeBlock value
]

{ #category : #abi }
CogRiscV64Compiler >> saveAndRestoreLinkRegAround: aBlock [
	"If the processor's ABI includes a link register, generate instructions
	 to save and restore it around aBlock, which is assumed to generate code."
	<inline: true>
	| inst |
	inst := cogit PushR: LinkReg.
	aBlock value.
	cogit PopR: LinkReg.
	^inst
]

{ #category : #testing }
CogRiscV64Compiler >> setsConditionCodesFor: aConditionalJumpOpcode [
	<inline: false> "to save Slang from having to be a real compiler (it can't inline switches that return)"
	"Answer if the receiver's opcode sets the condition codes correctly for the given conditional jump opcode.
	ARM has to check carefully since the V flag is not affected by non-comparison instructions"
	^opcode caseOf:
		{	[ArithmeticShiftRightCqR]	->	[false].
			[ArithmeticShiftRightRR]		->	[false].
			[LogicalShiftLeftCqR]			->	[false].
			[LogicalShiftLeftRR]			->	[false].
			[LogicalShiftRightCqR]		->	[false].
			[XorRR]							->	[false]
		}
		otherwise: [self logError: 'unhandled opcode in setsConditionCodesFor:'. self abort. false]
]

{ #category : #testing }
CogRiscV64Compiler >> shiftLeftValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"slli: Shifts register x[rs1] left by shamt bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  000000 |  shamt  |  rs1  |  001  |  rd  |  0010011  |
	"

	| riscvOpcode |
	self flag: #DONE.
	riscvOpcode := 2r0010011.
	^ (((((shiftAmount bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: (2r001 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcode
]

{ #category : #testing }
CogRiscV64Compiler >> shiftRightValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"slli: Shifts register x[rs1] right by shamt bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  000000 |  shamt  |  rs1  |  101  |  rd  |  0010011  |
	"

	| riscvOpcode |
	self flag: #DONE.
	riscvOpcode := 2r0010011.
	^ (((((shiftAmount bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcode
]

{ #category : #testing }
CogRiscV64Compiler >> shiftSetsConditionCodesFor: aConditionalJumpOpcode [
	"check what flags the opcdoe needs setting - ARM doesn't set V when simply MOVing"
		^aConditionalJumpOpcode caseOf:
		{	[JumpNegative]	->	[true].
			[JumpZero]	->	[true].
			[JumpLess]	->	[true].
		}
		otherwise: [self halt: 'unhandled opcode in setsConditionCodesFor:'. false]
]

{ #category : #testing }
CogRiscV64Compiler >> shiftable16bitImmediate: constant ifTrue: trueAlternativeBlock ifFalse: falseAlternativeBlock [
	<inline: true>
	"For data processing operands, there is the immediate shifter_operand variant, 
	 where an 16 bit value is left shifted by i.
	 This is only suitable for quick constants(Cq), which won't change."
	
	(constant bitAnd: 16rFFFF) = constant ifTrue:
		[^trueAlternativeBlock value: 0 value: constant].
	0 to: 2 do: [:i | | shiftedValue shiftMagnitude |
		shiftMagnitude := (1 << i) * 16.
		shiftedValue := constant >> shiftMagnitude.
		(shiftedValue << shiftMagnitude = constant and: [ (shiftedValue bitAnd: 16rFFFF) = shiftedValue ])
			ifTrue: [ ^ trueAlternativeBlock
					value: shiftMagnitude
					value: shiftedValue ] ].
	^falseAlternativeBlock value
]

{ #category : #accessing }
CogRiscV64Compiler >> stackPageInterruptHeadroomBytes [
	"Return a minimum amount of headroom for each stack page (in bytes).  In a
	 JIT the stack has to have room for interrupt handlers which will run on the stack.
	According to ARM architecture v5 reference manual chapter A2.6, the basic interrupt procedure does not push anything onto the stack. It uses SPSR_err and R14_err to preserve state. Afterwards, it calls an interrupt procedure. So leave some room."
	^128 "32 words"
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> stackPointerAlignment [
	
	<doNotGenerate>
	"As for the ARMv8 Arm® Architecture Reference Manual
	
	D1.8.2 SP alignment checking
	A misaligned stack pointer is where bits[3:0] of the stack pointer are not 0b0000, when the stack pointer is used as the base address of the calculation, regardless of any offset applied by the instruction.
	
	Meaning that the stack should be aligned to 16 bytes"

	^ 16
]

{ #category : #encoding }
CogRiscV64Compiler >> stop [

	"C6.2.38 BRK
	
	Breakpoint instruction. A BRK instruction generates a Breakpoint Instruction exception.
	
	BRK #<imm>"
	
	"This is a BRK 0..."
	^ 2r11010100001 << 21
]

{ #category : #'generate machine code - support' }
CogRiscV64Compiler >> stopsFrom: startAddr to: endAddr [
	self assert: endAddr - startAddr + 1 \\ 4 = 0.
	startAddr to: endAddr by: 4 do: 
		[:addr | objectMemory long32At: addr put: self stop].
]

{ #category : #assembler }
CogRiscV64Compiler >> storeDoubleWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sd: Stores the eight bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31             25  24    20  19    15  14   12  11             7  6         0
	|  	offset[11:5]  |   rs2   |   rs1   |  011   |   offset[4:0]   |   0100011  |
	"

	| riscvOpcodePart1 |
	"The offset can hold up to 12 bits"
	self assert: (offset bitAnd: 16rfff) = offset.
	riscvOpcodePart1 := 2r0100011.	
	self flag: #DONE.
	^ ((((((
	  offset >> 5 bitAnd: 16r3f) << 25) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 20 )
	  bitOr: (destinationAddressRegister bitAnd: 16r1f) << 15) 
	  bitOr: 2r011 << 12)
	  bitOr: (offset bitAnd: 16r1f) << 7) 
	  bitOr: riscvOpcodePart1
	
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> storeLiteral: literal beforeFollowingAddress: followingAddress [
	"Rewrite the long constant loaded by the instruction sequence just before this address:"
	^self subclassResponsibility
]

{ #category : #assembler }
CogRiscV64Compiler >> substractValueFromRegister: srcReg2 toRegister: srcReg1 intoRegister: destReg [

	"sub: Substracts register x[rs2] from register x[rs1] and writes the result to x[rd].
	 Arithmetic overflow is ignored.
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0100000  |  rs2  |  rs1  |  000  |   rd   |  0110011  |
	"

	| riscvOpcodePart1 |
	"The offset can hold up to 12 bits"
	riscvOpcodePart1 := 2r0110011.	
	self flag: #TODO.
	^ ((((2r0100000 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcodePart1 
]

{ #category : #assembler }
CogRiscV64Compiler >> substractWordValueFromRegister: srcReg2 toRegister: srcReg1 intoRegister: destReg [

	"subw: Substracts register x[rs2] from register x[rs1], truncates the result to 32 bits 
	 and writes the sign-extended result to x[rd].
	 Arithmetic overflow is ignored.
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0100000  |  rs2  |  rs1  |  000  |   rd   |  0111011  |
	"

	| riscvOpcode |
	"The offset can hold up to 12 bits"
	riscvOpcode := 2r0111011.	
	self flag: #DONE.
	^ ((((2r0100000 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcode
]

{ #category : #'private-bit-manipulation' }
CogRiscV64Compiler >> trailingOnesOf: aNumber [
	"Return how many trailing ones are in the 64bit bitString representation of aNumber.
	That is, how many ones are in the least significant bits before there is a zero.
	For example, the 64bit binary number 2r10101000110001111 has 4 trailing ones"
	
	"Calculate it by calculating the trailing zeros of the bit-inverted number"
	^ self trailingZerosOf: aNumber bitInvert64
]

{ #category : #'private-bit-manipulation' }
CogRiscV64Compiler >> trailingZerosOf: aNumber [
	"Return how many trailing zeros are in the 64bit bitString representation of aNumber.
	That is, how many zeros are in the least significant bits before there is a one.
	For example, the 64bit binary number 2r10101000110001111000 has 3 trailing zeros.
	
	Uses a bisect method looking at the number by halfs"
	
	| zeroBits shift mask currentNumber |
	"First two fast cases. If 1 or 0, return some quick constants"
	aNumber = 0
		ifTrue: [ ^ 64 "bits" ].

	(aNumber bitAnd: 1) = 1
		ifTrue: [ ^ 0 ].
 
	"Otherwise calculate trailing zeros by iterating the number with a mask and accumulating a value"
	zeroBits := 0.

	"This is a bisection method to iterate a 64-long bitstring in log2.
	It will first look at the least significant half of the number using a mask of half of its size.
	If they are all zeros, taking the other half of the number by shifting it.
	Of they are not all zeros, continue with this half.
	Then iterate with half the mask and shift sizes."
	shift := 64 "bits" >> 1.
	mask := 16rFFFFFFFFFFFFFFFF >> shift.
	currentNumber := aNumber.
	
	[ shift ~= 0 ] whileTrue: [ 
		(currentNumber bitAnd: mask) = 0 ifTrue: [ 
			"If this half is all zeros, let's take the other half of the number"
			currentNumber := currentNumber >> shift.
			"Also, mark that we found zeros of the size of the current shift"
			zeroBits := zeroBits bitOr: shift.
		].
		"Continue next iterations with masks half the size"
		shift := shift >> 1.
		mask := mask >> shift.
	].

	^ zeroBits
]

{ #category : #'as yet unclassified' }
CogRiscV64Compiler >> unsignedBitfieldMoveSize: is64Bits immr: immr imms: imms sourceRegister: sourceRegister destinationRegister: destinationRegister [
	
	"C6.2.333 UBFM
	
	Unsigned Bitfield Move is usually accessed via one of its aliases, which are always preferred for disassembly.
	If <imms> is greater than or equal to <immr>, this copies a bitfield of (<imms>-<immr>+1) bits starting from bit position <immr> in the source register to the least significant bits of the destination register.
	
	If <imms> is less than <immr>, this copies a bitfield of (<imms>+1) bits from the least significant bits of the source register to bit position (regsize-<immr>) of the destination register, where regsize is the destination register size of 32 or 64 bits.
	
	In both cases the destination bits below and above the bitfield are set to zero
	
	UBFM <Xd>, <Xn>, #<immr>, #<imms>
	"
	
	^ is64Bits << 31
		bitOr: (2r10100110 << 23
		bitOr: ((is64Bits bitAnd: 1) << 22
		bitOr: ((immr bitAnd: 16r3f) << 16
		bitOr: ((imms bitAnd: 16r3f) << 10
		bitOr: ((sourceRegister bitAnd: 16r1f) << 5
		bitOr: (destinationRegister bitAnd: 16r1f))))))
]

{ #category : #simulation }
CogRiscV64Compiler >> wantsNearAddressFor: anObject [
	"A hack hook to allow ARM to override the simulated address for the short-cut trampolines"
	<doNotGenerate>
	^anObject isSymbol and: [anObject beginsWith: 'ceShortCut']
]

{ #category : #assembler }
CogRiscV64Compiler >> xorBetweenRegister: srcReg andImmediate: immediate intoRegister: destReg [

	"xori: Computes the bitwise exclusive-OR of the sign-extended immediate
	 and register x[rs1] and writes the result to x[rd]
	
	 31               20 19   15 14   12 11     7 6         0
	|  	immediate[11:0]  |  rs1  |  100  |   rd   |  0010011  |
	"

	| riscvOpcode |
	self flag: #DONE.	
	riscvOpcode := 2r0010011.	
	self assert: (immediate bitAnd: 16rfff) = immediate.
	^ (((((immediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcode
]

{ #category : #assembler }
CogRiscV64Compiler >> xorBetweenRegister: srcReg1 andRegister: srcReg2 intoRegister: destReg [

	"xor: Computes the bitwise exclusive-OR of registers x[rs1] and x[rs2] 
	 and writes the result to x[rd]
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0000000  |  rs2  |  rs1  |  100  |   rd   |  0110011  |
	"

	| riscvOpcode |
	self flag: #DONE.	
	riscvOpcode := 2r0110011.	
	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: riscvOpcode
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> zoneCallsAreRelative [
	"Answer if Call and JumpLong are relative and hence need to take the caller's
	 relocation delta into account during code compaction, rather than just the
	 callee's delta."
	^true
]
