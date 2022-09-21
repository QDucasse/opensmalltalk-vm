Class {
	#name : #CogRiscV64Compiler,
	#superclass : #CogAbstractInstruction,
	#instVars : [
		'conditionOrNil',
		'previousOperands',
		'previousOpcode'
	],
	#classVars : [
		'BrEqualRR',
		'CArg0Reg',
		'CArg1Reg',
		'CArg2Reg',
		'CArg3Reg',
		'CMPMULOverflow',
		'ConcreteCarryReg',
		'ConcreteIPFPReg',
		'ConcreteIPFPReg2',
		'ConcreteIPReg',
		'ConcreteIPReg2',
		'ConcreteIPReg3',
		'ConcreteOverflowReg',
		'ConcretePCReg',
		'ConcreteSignReg',
		'ConcreteVarBaseReg',
		'ConcreteZeroReg',
		'DivRR',
		'EQ',
		'F0',
		'F1',
		'F2',
		'F3',
		'F4',
		'F5',
		'F6',
		'F7',
		'FP',
		'GE',
		'GEU',
		'LR',
		'LT',
		'LTU',
		'MSTATUS',
		'MSUB',
		'MUL',
		'MulRR',
		'NE',
		'PC',
		'RemRR',
		'SDIV',
		'SMULH',
		'SP',
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
		'X28',
		'X29',
		'X3',
		'X30',
		'X31',
		'X4',
		'X5',
		'X6',
		'X7',
		'X8',
		'X9'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #accessing }
CogRiscV64Compiler class >> IPReg [
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

	"The possible preprocessor definitions are: (extracted from https://github.com/riscv-non-isa/riscv-toolchain-conventions)
	__riscv: defined for any RISC-V target. Older versions of the GCC toolchain defined __riscv__.
	__riscv_xlen: 32 for RV32 and 64 for RV64.
	__riscv_float_abi_soft, __riscv_float_abi_single, __riscv_float_abi_double: one of these three will be defined, depending on target ABI.
	__riscv_cmodel_medlow, __riscv_cmodel_medany: one of these two will be defined, depending on the target code model.
	__riscv_mul: defined when targeting the 'M' ISA extension.
	__riscv_muldiv: defined when targeting the 'M' ISA extension and -mno-div has not been used.
	__riscv_div: defined when targeting the 'M' ISA extension and -mno-div has not been used.
	__riscv_atomic: defined when targeting the 'A' ISA extension.
	__riscv_flen: 32 when targeting the 'F' ISA extension (but not 'D') and 64 when targeting 'FD'.
	__riscv_fdiv: defined when targeting the 'F' or 'D' ISA extensions and -mno-fdiv has not been used.
	__riscv_fsqrt: defined when targeting the 'F' or 'D' ISA extensions and -mno-fdiv has not been used.
	__riscv_compressed: defined when targeting the 'C' ISA extension.	"
	^#('__riscv__' '__riscv')
]

{ #category : #'class initialization' }
CogRiscV64Compiler class >> initialize [

	"Initialize various RISCV instruction-related constants."
	"CogRTLOpcodes initialize"
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
	X28 := 28.
	X29 := 29.
	X30 := 30.
	X31 := 31.

	SP := X2. "Stack Pointer"
	LR := X1. "Link Register"
	FP := X8. "Frame Pointer"
	
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
	CArg0Reg := X10.
	CArg1Reg := X11.
	CArg2Reg := X12.
	CArg3Reg := X13.
	
	ConcretePCReg := PC.
	"Base register that will serve as anchor to trampoline between stacks"
	ConcreteVarBaseReg := X26.
	"X5 and X6 are temporary registers used as the intra procedural scratch registers, they are not preserved accross calls"
	ConcreteIPReg := X5.
	ConcreteIPReg2 := X6.
	ConcreteIPReg3 := X7.
	ConcreteIPFPReg := F6.
	ConcreteIPFPReg2 := F7.
	
	"Flag Register"		
	ConcreteZeroReg := X28.
	ConcreteSignReg := X29.
	ConcreteOverflowReg := X30.
	ConcreteCarryReg := X31.
	
	
	"Branch Condition Codes"
	EQ  := 2r000. "Equal"
	NE  := 2r001. "Not equal"
	GE  := 2r101. "Greater or Equal"
	GEU := 2r111. "Greater or Equal Unsigned"
	LT  := 2r100. "Less Than"
	LTU := 2r110. "Less Than Unsigned"
	
	MSTATUS := 2r001100000000. "mstatus csr"
	
	"Specific opcodes"
	self initializeSpecificOpcodes: #(MulRR DivRR RemRR BrEqualRR) 
	     in: thisContext method 
	
	"When inspecting the Assocation, use the following to add the class variable:
	(ClassVariable key: self key value: value)
    owningClass: CogRiscV64Compiler;
    become: self"
	
	
]

{ #category : #'class initialization' }
CogRiscV64Compiler class >> initializeAbstractRegisters [

	"Assign the abstract registers with the identities/indices of the relevant concrete registers."

	super 
	.

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
	X18-27 | S2-11 | Saved Registers 
	
	X1 is LR.
	X8 is SP."
	
	self flag: #TODO.
	CallerSavedRegisterMask := self registerMaskFor: 13 and: 14.

	TempReg := X22.
	ClassReg := X23.
	ReceiverResultReg := X24.
	SendNumArgsReg := X25.
	SPReg := SP. "X2 is the machine stack pointer, we use the same" self assert: SP = X2.
	FPReg := FP. "X8 as the frame pointer" self assert: FP = X8.
	Arg0Reg := X13.	 "Overlaps with last CArg" 	
	Arg1Reg := X14.
	Extra0Reg := X18.  "These are callee saved registers"
	Extra1Reg := X19.
	Extra2Reg := X20.
	VarBaseReg := X26. self assert: ConcreteVarBaseReg = X26. "Base address for calls from machine code. Must be callee saved"
	RISCTempReg := X5. self assert: ConcreteIPReg = X5.
	LinkReg := LR. "X1 is ra" self assert: LR = X1.
	PCReg := PC. "PC has its dedicated register "

	NumRegisters := 16.

	DPFPReg0 := F0.
	DPFPReg1 := F1.
	DPFPReg2 := F2.
	DPFPReg3 := F3.
	DPFPReg4 := F4.
	DPFPReg5 := F5.
	DPFPReg6 := F6.
	DPFPReg7 := F7.

	"Placeholders for now, need to add the V extension and corresponding registers"
	VReg0 := F0.
	VReg1 := F1.
	VReg2 := F2.
	VReg3 := F3.
	VReg4 := F4.
	VReg5 := F5.
	VReg6 := F6.
	VReg7 := F7.

	NumFloatRegisters := 8
]

{ #category : #testing }
CogRiscV64Compiler class >> isAbstract [
	^ self == CogRiscV64Compiler
]

{ #category : #testing }
CogRiscV64Compiler class >> isRISCTempRegister: reg [
	"For tests to filter-out bogus values left in the RISCTempRegister, if any."
	self flag: #TODO.
	^ (reg = ConcreteIPReg) or: [(reg = ConcreteIPReg2) or: (reg = ConcreteIPReg3)]
]

{ #category : #translation }
CogRiscV64Compiler class >> machineCodeDeclaration [
	"Answer the declaration for the machineCode array.
	 ARM instructions are 32-bits in length."
	^{#'unsigned int'. '[', self basicNew machineCodeWords printString, ']'}
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> addImmediate: anImmediate toRegister: sourceRegister inRegister: destinationRegister [

	"addi: Adds the sign-extended immediate to register x[rs1] and writes the result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31                 20  19   15  14  12  11  7  6         0
	|  	immediate[11:0]  |  rs1   |  000  |  rd  |  0010011  |
	"
	
	| signExtendedImmediate |
	self flag: #DONE.	
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ ((((signExtendedImmediate bitAnd: 16rfff) << 20) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> addRegister: sourceRegister1 toRegister: sourceRegister2 inRegister: destinationRegister [

	"add: Adds register x[rs2] to register x[rs1] and writes the result to x[rd]. 
	Arithmetic overflow is ignored.
	
	31        25 24   20 19   15 14  12  11  7  6         0
	|  	0000000  |  rs2  |  rs1  |  000  |  rd  |  0110011  |
	"
	
	self flag: #DONE.		
	^ ((((sourceRegister2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceRegister1 bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0110011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> addUpperImmediateToPC: anImmediate toRegister: destinationRegister [

	"auipc: Adds the sign-extended 20-bit immediate, left-shifted by 12 bits, to the pc, and writes the result to x[rd].
	
	31                  12  11    7  6         0
	|  	immediate[31:12]  |   rd   |   0010111  |
	"

	| signExtendedImmediate |
	self flag: #DONE.
	"Check size and sign"	
	self assertValue: anImmediate isContainedIn: 32.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 32.
	^ (((signExtendedImmediate bitAnd: 16rfffff) << 12) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0010111
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> addWordImmediate: anImmediate toRegister: sourceRegister inRegister: destinationRegister [

	"addiw: Adds the sign-extended immediate to register x[rs1], truncates the result to 32 bits, 
	 and writes the sign-extended result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31                20 19    15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1   |  000  |  rd  |  0011011  |
	"
	
	| signExtendedImmediate |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ ((((signExtendedImmediate bitAnd: 16rfff) << 20) 
	  bitOr: (sourceRegister bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0011011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> addWordRegister: sourceRegister1 toRegister: sourceRegister2 inRegister: destinationRegister [

	"addw: Adds register x[rs2] to register x[rs1], truncates the result to 32 bits, 
	 and writes the sign-extended result to x[rd]. 
	 Arithmetic overflow is ignored.
	
	31        25 24   20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2  |  rs1  |  000  |  rd  | 0111011  |
	"

	self flag: #DONE.
	^ ((((sourceRegister1 bitAnd: 16r1f) << 20) 
	  bitOr: (sourceRegister2 bitAnd: 16r1f) << 15) 
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7) 
	  bitOr: 2r0111011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> arithmeticShiftRightValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"srai: Shifts register x[rs1] right by shamt bit positions. 
	 The vacated bits are filled with copies of x[rs1] MSB, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  010000 |  shamt  |  rs1  |  101  |  rd  |  0010011  |
	"

	self flag: #DONE.
	^ ((((((2r1 << 30) 
	  bitOr: ((shiftAmount bitAnd: 16r3f) << 20))
	  bitOr: (sourceReg bitAnd: 16r1f) << 15))
	  bitOr: (2r101 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> arithmeticShiftRightValueInRegister: sourceReg1 byShiftAmountInRegister: sourceReg2 intoRegister: destReg [ 

	"sra: Shifts register x[rs1] right by x[rs2] bit positions. 
	 The vacated bits are filled with copies of x[rs1] MSB, and the result is written to x[rd].
	
	 31      25 24   20 19   15 14   12 11   7 6         0
	|  0100000 |  rs2  |  rs1  |  101  |  rd  |  0110011  |
	"

	self flag: #DONE.
	^ ((((((2r1 << 30) 
	  bitOr: ((sourceReg2 bitAnd: 16r3f) << 20))
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15))
	  bitOr: (2r101 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : #'helpers - size sign' }
CogRiscV64Compiler >> assertValue: aValue isContainedIn: aSize [ 

	"Checks that the given value is contained in a certain number of bits"
	self flag: #TODO.
	self assert: (self value: aValue isContainedIn: aSize)
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> bitwiseAndBetweenRegister: sourceReg andImmediate: anImmediate toRegister: destReg [
	
	"andi: Computes the bitwise AND of registers x[rs1] and sign extended immediate and writes the result to x[rd].
	
	31                20 19   15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1  |  111  |  rd  |  0010011 
	"
	| signExtendedImmediate |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ (((((signExtendedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: 2r111 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> bitwiseAndBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg [
	
	"and: Computes the bitwise AND of registers x[rs1] and x[rs2] and writes the result to x[rd].
	
	31        25 24    20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2   |  rs1  |  111  |  rd  |  0110011 
	"
	
	self flag: #DONE.
	^ (((((sourceReg2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r111 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> bitwiseOrBetweenRegister: sourceReg andImmediate: anImmediate toRegister: destReg [
	
	"ori: Computes the bitwise OR of register x[rs1] and the sign-extended immediate and writes the result to x[rd].
	
	31                20 19   15 14   12 11   7 6         0
	|  	immediate[11:0]  |  rs1  |  110  |  rd  |  0010011 
	"
	| signExtendedImmediate |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 12.	
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 12.
	^ (((((signExtendedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> bitwiseOrBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg [
	
	"or: Computes the bitwise OR of registers x[rs1] and x[rs2] and writes the result to x[rd].
	
	31        25 24    20 19   15 14   12 11   7 6         0
	|  	0000000  |  rs2   |  rs1  |  110  |  rd  |  0110011 
	"
	
	self flag: #DONE.
	^ (((((sourceReg2 bitAnd: 16r1f) << 20)
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> bitwiseXorBetweenRegister: srcReg andImmediate: immediate intoRegister: destReg [

	"xori: Computes the bitwise exclusive-OR of the sign-extended immediate
	 and register x[rs1] and writes the result to x[rd]
	
	 31               20 19   15 14   12 11     7 6         0
	|  	immediate[11:0]  |  rs1  |  100  |   rd   |  0010011  |
	"

	| signExtendedImmediate |
	self flag: #DONE.	
	"Check for sign and size"
	self assertValue: immediate isContainedIn: 12.	
	signExtendedImmediate :=	self computeSignedValueOf: immediate ofSize: 12.
	^ (((((signExtendedImmediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> bitwiseXorBetweenRegister: srcReg1 andRegister: srcReg2 intoRegister: destReg [

	"xor: Computes the bitwise exclusive-OR of registers x[rs1] and x[rs2] 
	 and writes the result to x[rd]
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0000000  |  rs2  |  rs1  |  100  |   rd   |  0110011  |
	"

	self flag: #DONE.	
	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifCondition: condition betweenRegister: srcReg1 andRegister: srcReg2 [ 

	"Offset handling common to all branches. The condition is the three bit code.
	
	31                25 24   20 19   15 14         12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  condition  | offset[4:1|11] | 1100011 
	"	

	| signExtendedOffset |
	self flag: #DONE.
	 "Check size and sign"	
	self assertValue: offset isContainedIn: 13.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 13.
	^ (((((((((signExtendedOffset >> 12) bitAnd: 16r1) << 31)
	  bitOr: ((signExtendedOffset >> 5) bitAnd: 16r3f)  << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f)  << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f)  << 15)
	  bitOr: (condition bitAnd: 16r7) << 12)
	  bitOr: ((signExtendedOffset >> 1) bitAnd: 16rf)   << 8)
	  bitOr: ((signExtendedOffset >> 11) bitAnd: 16r1)  << 7)
	  bitOr: 2r1100011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isEqualToRegisterValue: srcReg2 [
	
	"beq: If register x[rs1] equals x[rs2], set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  000  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: EQ betweenRegister: srcReg1 andRegister: srcReg2
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isGreaterThanOrEqualRegisterValue: srcReg2 [
	
	"bge: If register x[rs1] is greater than or equal x[rs2], treating the values as two's complement numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  101  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GE betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isGreaterThanRegisterValue: srcReg2 [
	
	"bgt: Pseudo-instruction that adds the offset to the PC if x[rs1] > x[rs2] 
	 Expands to blt rs2, rs1, offset
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: LT betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isLessThanOrEqualRegisterValue: srcReg2 [
	
	"ble: Pseudo-instruction that adds the offset to the PC if x[rs1] <= x[rs2] 
	 Expands to bge rs2, rs1, offset
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GE betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isLessThanRegisterValue: srcReg2 [
	
	"blt: If register x[rs1] is less than x[rs2], treating the values as two's complement numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  100  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: LT betweenRegister: srcReg1 andRegister: srcReg2
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValue: srcReg1 isNotEqualToRegisterValue: srcReg2 [
	
	"bne: If register x[rs1] does not equal x[rs2], set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  001  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: NE betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueIsEqualToZero: srcReg [
	
	"beqz: Pseudo instruction that branches to the offset if the value in the register is 0
	Expands to beq x[rs1], x0, offset
 	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: EQ betweenRegister: srcReg andRegister: X0
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueIsNegative: srcReg [
	
	"bltz: Pseudo instruction that branches to the offset if the value in the register is < 0
	Expands to blt x[rs1], x0, offset
 	"
	self flag: #DONE.
	^ self branchTo: offset ifRegisterValue: srcReg isLessThanRegisterValue: X0
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueIsNonNegative: srcReg [
	
	"bgtz: Pseudo instruction that branches to the offset if the value in the register is > 0
	Expands to blt x0, x[rs1], offset
 	"
	self flag: #DONE.
	^ self branchTo: offset ifRegisterValue: X0 isLessThanRegisterValue: srcReg
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueIsNotEqualToZero: srcReg [
	
	"bnez: Pseudo instruction that branches to the offset if the value in the register is not 0
	Expands to bne x[rs1], x0, offset
 	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: NE betweenRegister: srcReg andRegister: X0
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isGreaterThanOrEqualRegisterValueUnsigned: srcReg2 [
	
	"bgeu: If register x[rs1] is greater than or equal x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	
	31                25 24   20 19   15 14   12 11             7 6         0
	|  	offset[12|10:5]  |  rs2  |  rs1  |  111  | offset[4:1|11] | 1100011 
	"
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GEU betweenRegister: srcReg1 andRegister: srcReg2
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isGreaterThanRegisterValueUnsigned: srcReg2 [

	"bgtu: If register x[rs1] is greater than x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	Expands to: bltu x[rs2], x[rs1], offset
	"
	
	self flag: #DONE.
	^ self branchTo: offset ifCondition: LTU betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> branchTo: offset ifRegisterValueUnsigned: srcReg1 isLessThanOrEqualRegisterValueUnsigned: srcReg2 [

	"bleu If register x[rs1] is less than or equal x[rs2], treating the values as unsigned numbers,
	 set the PC to the current PC plus the sign-extended offset
	Expands to: bgeu x[rs2], x[rs1], offset
	"
	
	self flag: #DONE.
	^ self branchTo: offset ifCondition: GEU betweenRegister: srcReg2 andRegister: srcReg1
	
	
]

{ #category : #'machine code instruction' }
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

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForADDCq [
	
	self flag: #TODO.
	dependent
		ifNil: [ | cq |
			cq := operands at: 0.
			self assertValue: cq isContainedIn: 12.
			"Immediate that can be encoded in andi" 
			^ self bytesForArithmeticFlagUpdateWithImmediate + self bytesForADDOverflowCheck + 4 ]
		ifNotNil: [ "Literal load" 
			^ self literalLoadInstructionBytes + self bytesForArithmeticFlagUpdateWithMov + self bytesForADDOverflowCheck + 4 ]	
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForADDOverflowCheck [ 

	self flag: #TODO.
	^ 12
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForArithmeticFlagUpdate [ 
	"Return the number of bytes needed to update the flags, 
     zero flag setting 
     carry flag setting 
     sign flag setting"
	self flag: #TODO.
	^ 12
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForArithmeticFlagUpdateWithImmediate [
	"Return the number of bytes needed to update the flags, 
	  load immediate,
     zero flag setting 
     carry flag setting 
     sign flag setting"
	self flag: #TODO.
	^ 16
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForArithmeticFlagUpdateWithMov [
	"Return the number of bytes needed to update the flags, 
     zero flag setting 
     carry flag setting 
     sign flag setting
	  move result to destination"
	self flag: #TODO.
	^ 16
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForCMPCq [
	
	| loadOffset | 
	self flag: #TODO.
	(self value: (operands at: 0) isContainedIn: 12)
		ifTrue: [ loadOffset := self bytesToLoadImmediate: (operands at: 0) ] "Immediate embedded in operations" 
		ifFalse: [ loadOffset := self literalLoadInstructionBytes ].
	^ loadOffset + self bytesForSUBOverflowCheck + self bytesForArithmeticFlagUpdate + 4

	
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForDataLoadOperationOfSize: operationSize andImmediateOperationSize: immOperationSize [
	
	"When loading, the offset is operands at 0"
	self flag: #TODO.
	dependent
		ifNil: [ 
			self assertValue: (operands at: 0) isContainedIn: 12.
			^ immOperationSize ].
	^ self literalLoadInstructionBytes + operationSize 
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForDataStoreOperationOfSize: operationSize andImmediateOperationSize: immOperationSize [
	
	"When storing, the offset is operands at 1"
	self flag: #TODO.
	dependent
		ifNil: [ 
			self assertValue: (operands at: 1) isContainedIn: 12.
			^ immOperationSize ].
	^ self literalLoadInstructionBytes + operationSize 
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForFloatingPointADDOverflowCheck [ 

	self flag: #TODO.
	^ 20
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForFloatingPointArithmeticFlagUpdate [ 
	"Return the number of bytes needed to update the flags, 
     zero flag setting 
     carry flag setting "
	self flag: #TODO.
	^ 8
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForFloatingPointOverflowCheck [ 

	self flag: #TODO.
	^ 20
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForFloatingPointSUBOverflowCheck [ 

	self flag: #TODO.
	^ 16
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForLoadEffectiveAddress [
	
	| cq |
	self flag: #TODO.	
	cq := operands at: 0.
	dependent ifNil: [   
			self assertValue: cq isContainedIn: 12.
			^ 4 ] .
	^ self literalLoadInstructionBytes + 4
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForLogicCqOperation [

	"Use 4 as the default size"
	self flag: #TODO.
	^ self bytesForLogicCqOperationOfSize: 4
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForLogicCqOperationOfSize: operationSize [

	"Immediate and register operations have the same size"
	self flag: #TODO.
	^ self bytesForLogicCqOperationOfSize: operationSize andImmediateOperationSize: operationSize
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForLogicCqOperationOfSize: operationSize andImmediateOperationSize: immOperationSize [
	
	"This method is used in the case of an operation where the OPRI and OPRR have different lengths 
	 example: ROT"
	self flag: #TODO.
	dependent
		ifNil: [ | cq |
			cq := operands at: 0.
			self assertValue: cq isContainedIn: 12.
			"Immediate that can be encoded in andi" 
			^ self bytesForLogicFlagUpdate + immOperationSize ].
	^ self literalLoadInstructionBytes + self bytesForLogicFlagUpdate + operationSize 
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForLogicFlagUpdate [ 
	"Return the number of bytes needed to update the flags, 
     overflow set to 0
     + carry set to 0
     + sign flag setting
     + zero flag setting"
	self flag: #TODO.
	^ 16
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForSUBCq [
	
	"Used for SUB as there is no SUBI"
	| loadOffset | 
	self flag: #TODO.
	^ self literalLoadInstructionBytes + self bytesForSUBOverflowCheck + self bytesForArithmeticFlagUpdateWithMov + 4
	
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesForSUBOverflowCheck [ 

	self flag: #TODO.
	^ 16
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> bytesToLoadImmediate: anImmediate [ 

	"Returns the number of bytes (instructions * 4) needed to generate"
	<inline:true>
	self flag: #TODO.
	^ 8
]

{ #category : #abi }
CogRiscV64Compiler >> cResultRegister [
	"Answer the register through which C funcitons return integral results."
	<inline: true>
	^X10
]

{ #category : #accessing }
CogRiscV64Compiler >> cStackPointer [
	
	^ SP
]

{ #category : #accessing }
CogRiscV64Compiler >> callInstructionByteSize [

	self flag: #TODO.
	^ 8
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> callTargetFromReturnAddress: callSiteReturnAddress [
	"Answer the address that the call immediately preceding callSiteReturnAddress will jump to."
	| callAddress callInstruction callDistance |
	self flag: #TODO.
	callAddress := self instructionAddressBefore: callSiteReturnAddress.
	callInstruction := objectMemory long32At: callAddress.
	self assert: (self instructionIsJALR: callInstruction).
	callDistance := self extractOffsetFromCall: callAddress.
	^ callAddress + callDistance - 4
	
	
	
	
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

{ #category : #concretization }
CogRiscV64Compiler >> checkADDFloatingPointOverflowWithSourceReg1: srcReg1 sourceReg2: srcReg2 andResultReg: destReg startingAtIndex: index [
	"Check for the overflow
	 add    res,  src1,  src2 
  	 fcvt   tfp,  x0,    tfp      # put 0 in tfp  
	 flt.d  t1,   src2,  tfp      # t1 = (src2 < 0)
    flt.d  t2,   res,   src1     # t2 = (src1 + src2 < res)
    bne    t1,   t2,    offset   # overflow if (src2 < 0) && (src1 + src2 >= res)  case 1 0 (underflow)
                                            || (src2 >= 0) && (src1 + src2 < res)  case 0 1 (overflow) 

	Except the branching is a verification for equality (equal => no overflow)"
	self flag: #TODO.
	"As there is no hardwire fp zero we need to get one by converting X0"
	self machineCodeAt: index put: (self fConvertLongSignedInRegister: X0 toDoublePrecisionInRegister: ConcreteIPFPReg).
   "1. Check if one operand is negative"
	self machineCodeAt: index + 4 put: (self fSetOneIn: ConcreteIPReg2 ifRegisterValue: srcReg2 isLessThanRegisterValue: ConcreteIPFPReg).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 8 put: (self fSetOneIn: ConcreteIPReg3 ifRegisterValue: destReg isLessThanRegisterValue: srcReg1).
	"Check if both registers are equal -> xor and complement"
	self machineCodeAt: index + 12 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg).
	self machineCodeAt: index + 16 put: (self setOneIn: ConcreteOverflowReg ifValueInRegisterIsEqualToZero: ConcreteOverflowReg).
	^ machineCodeSize := 20
	  
]

{ #category : #concretization }
CogRiscV64Compiler >> checkADDOverflowWithSourceReg1: srcReg1 sourceReg2: srcReg2 andResultReg: destReg startingAtIndex: index [
	"Check for the overflow, as according to the example in the book: 
	 add   res,  src1,  src2 
    slti  t1,   src2,  0       # t1 = (src2 < 0)
    slt   t2,   res,   src1    # t2 = (src1 + src2 < res)
    bne   t1,   t2,    offset  # overflow if (src2 < 0) && (src1 + src2 >= res)  case 1 0 (underflow)
                                          || (src2 >= 0) && (src1 + src2 < res)  case 0 1 (overflow) 

	As we will not branch directly, we need to check if the two conditions are equal 
	and set the overflow flag acordingly: equal => no overflow"
	self flag: #TODO.
   "1. Check if one operand is negative"
	self machineCodeAt: index put: (self setOneIn: ConcreteIPReg2 ifValueIn: srcReg2 isLessThanImmediate: 0).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteIPReg3 ifValueIn: destReg isLessThanValueIn: srcReg1).
	"Put one if t2 = t3, xor"
	self machineCodeAt: index + 8 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg). 
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> checkADDOverflowWithSourceReg: srcReg immediate: immediate andResultReg: destReg startingAtIndex: index [
	"Check for the overflow, as according to the example in the book: 
	 add   res,  imm,  src 
    slti  t1,   src,   0       # t1 = (src < 0)
    slt   t2,   res,   imm     # t2 = (src + imm < res)
    bne   t1,   t2,    offset  # overflow if (src < 0) && (src + imm >= res)  case 1 0 (underflow)
                                          || (src >= 0) && (src + imm < t0)   case 0 1 (overflow) 

	As we will not branch directly, we need to check if the two conditions are equal 
	and set the overflow flag acordingly: equal => no overflow"
	self flag: #TODO.
   "1. Check if one operand is negative"
	self machineCodeAt: index put: (self setOneIn: ConcreteIPReg2 ifValueIn: srcReg isLessThanImmediate: 0).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteIPReg3 ifValueIn: destReg isLessThanImmediate: immediate).
	"Put one if t2 = t3, xor and complement"
	self machineCodeAt: index + 8 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg). 
	^ machineCodeSize := 12
	  
]

{ #category : #concretization }
CogRiscV64Compiler >> checkSUBFloatingPointOverflowWithSourceReg1: srcReg1 sourceReg2: srcReg2 andResultReg: destReg startingAtIndex: index [
	"Check for the overflow
	 sub    res,  src1,  src2 
  	 fcvt   tfp,  x0,    tfp      # put 0 in tfp  
	 flt.d  t1,   src2,  tfp      # t1 = (src2 < 0)
    flt.d  t2,   res,   src1     # t2 = (src1 - src2 < res)
    bne    t1,   t2,    offset   # overflow if (src2 < 0) && (src1 + src2 < res)    case 1 1 (underflow)
                                            || (src2 >= 0) && (src1 + src2 >= res)  case 0 0 (overflow) 

	Except the branching is a verification for equality (not equal => overflow)"
	self flag: #TODO.
	"As there is no hardwire fp zero we need to get one by converting X0"
	self machineCodeAt: index put: (self fConvertLongSignedInRegister: X0 toDoublePrecisionInRegister: ConcreteIPFPReg).
	"1. Check if one operand is negative"
	self machineCodeAt: index + 4 put: (self fSetOneIn: ConcreteIPReg2 ifRegisterValue: srcReg2 isLessThanRegisterValue: ConcreteIPFPReg).
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 8 put: (self fSetOneIn: ConcreteIPReg3 ifRegisterValue: destReg isLessThanRegisterValue: srcReg1).
	"Check if both registers are equal -> xor and complement"
	self machineCodeAt: index + 12 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg).
	^ machineCodeSize := 16
	  
]

{ #category : #concretization }
CogRiscV64Compiler >> checkSUBOverflowWithSourceReg1: srcReg1 sourceReg2: srcReg2 andResultReg: destReg startingAtIndex: index [
	"Check for the overflow, as according to the example in the book: 
	 sub   res,  src1,  src2    # res = src1 - src2 
    slti  t1,   src2,  0       # t1 = (src2 < 0)
    slt   t2,   res,   src1    # t2 = (src1 - src2 < res)
    be    t1,   t2,    offset  # overflow if (src2 < 0) && (src1 + src2 < res)    case 1 1 (overflow)
                                          || (src2 >= 0) && (src1 + src2 >= res)  case 0 0 (underflow) 

	As we will not branch directly, we need to check if the two conditions are equal 
	and set the overflow flag acordingly: different => no overflow"
	self flag: #TODO.
   "1. Check if one operand is negative, OR EQUAL TO ZERO"
	self machineCodeAt: index put: (self setOneIn: ConcreteIPReg2 ifValueIn: srcReg2 isLessThanImmediate: 1). 
	"2. Check if the sum is smaller than one operand"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteIPReg3 ifValueIn: destReg isLessThanValueIn: srcReg1).
	"Put one if t2 = t3, xor and complement"
	self machineCodeAt: index + 8 put: (self bitwiseXorBetweenRegister: ConcreteIPReg2 andRegister: ConcreteIPReg3 intoRegister: ConcreteOverflowReg).
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteOverflowReg ifValueInRegisterIsEqualToZero: ConcreteOverflowReg).
	^ machineCodeSize := 16 
	  
]

{ #category : #accessing }
CogRiscV64Compiler >> codeGranularity [
	"Answer the size in bytes of a unit of machine code."
	<inline: true>
	^4
]

{ #category : #concretization }
CogRiscV64Compiler >> computeMaximumSize [

	"Because we don't use Thumb, each ARM instruction has 4 bytes. Many
	 abstract opcodes need more than one instruction. Instructions that refer
	 to constants and/or literals depend on literals being stored in-line or out-of-line.

	 N.B.  The ^N forms are to get around the bytecode compiler's long branch
	 limits which are exceeded when each case jumps around the otherwise."

	self flag: #TODO.
	opcode caseOf: { 
			([ Label ] -> [ ^ 0 ]).
			([ Literal ] -> [ ^ 8 ]).
			([ AlignmentNops ] -> [ ^ (operands at: 0) - 4 ]).
			([ Fill32 ] -> [ ^ 4 ]). "DONE"
			([ Nop ] -> [ ^ 4 ]). "DONE"
			"Branches"
			([ BrEqualRR ] -> [ ^ 4 ]). "TODO"
			"Control"
			([ Call ] -> [ ^ self callInstructionByteSize ]). "TODO"
			([ CallFull ] -> [ ^ self literalLoadInstructionBytes + 4 ]). "TODO"
			([ JumpR ] -> [ ^ 4 ]). "DONE"
			([ Jump ] -> [ ^ 4 ]). "DONE"
			([ JumpFull ] -> [ ^ self literalLoadInstructionBytes + 4 ]). "TODO"
			([ JumpLong ] -> [ ^ self jumpLongByteSize ]). "TODO"
			([ JumpZero ] -> [ ^ 4 ]). "DONE"
			([ JumpNonZero ] -> [ ^ 4 ]). "DONE"
			([ JumpNegative ] -> [ ^ 4 ]). "DONE"
			([ JumpNonNegative ] -> [ ^ 4 ]). "DONE"
			([ JumpOverflow ] -> [ ^ 4 ]). "DONE"
			([ JumpNoOverflow ] -> [ ^ 4 ]). "DONE"
			([ JumpCarry ] -> [ ^ 4 ]). "DONE"
			([ JumpNoCarry ] -> [ ^ 4 ]). "DONE"
			([ JumpLess ] -> [ ^ 4 ]). "DONE"
			([ JumpGreaterOrEqual ] -> [ ^ 4 ]). "DONE"
			([ JumpGreater ] -> [ ^ 20 ]). "DONE"
			([ JumpLessOrEqual ] -> [ ^ 12 ]). "DONE"
			([ JumpBelow ] -> [ ^ 4 ]). "DONE"
			([ JumpAboveOrEqual ] -> [ ^ 4 ]). "DONE"
			([ JumpAbove ] -> [ ^ 8 ]). "DONE"
			([ JumpBelowOrEqual ] -> [ ^ 8 ]). "DONE"
			([ JumpLongZero ] -> [ ^ self jumpLongConditionalByteSize ]). "TODO"
			([ JumpLongNonZero ] -> [ ^ self jumpLongConditionalByteSize ]). "TODO"
			([ JumpFPEqual ] -> [ ^ 4 ]). "DONE"
			([ JumpFPNotEqual ] -> [ ^ 4 ]). "DONE"
			([ JumpFPLess ] -> [ ^ 4 ]). "DONE"
			([ JumpFPGreaterOrEqual ] -> [ ^ 4 ]). "DONE"
			([ JumpFPGreater ] -> [ ^ 8 ]). "DONE"
			([ JumpFPLessOrEqual ] -> [ ^ 8 ]). "TODO"
			([ JumpFPOrdered ] -> [ ^ self notYetImplemented ]). "TODO"
			([ JumpFPUnordered ] -> [ ^ self notYetImplemented ]). "TODO"
			([ RetN ] -> [ 
			 ^ (operands at: 0) = 0
				   ifTrue: [ 4 ]
				   ifFalse: [ 8 ] ]). "DONE"
			([ Stop ] -> [ ^ 4 ]). "DONE"

			"Logic"
			([ AndCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"
			([ AndCqRR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"
			([ OrCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"
			([ TstCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"
			([ XorCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"

			"Arithmetic"
			([ AddCqR ] -> [ ^ self bytesForADDCq ]). "DONE"
			([ CmpCqR ] -> [ ^ self bytesForCMPCq ]). "DONE"
			([ CmpC32R ] -> [ ^ self bytesForCMPCq ]). "DONE"
			([ SubCqR ] -> [ ^ self bytesForADDCq ]). "DONE"
			([ LoadEffectiveAddressMwrR ]
			 -> [ ^ self bytesForLoadEffectiveAddress ]). "DONE"

			"Arithmetic with an ensured literal load"
			([ AddCwR ] -> [ 
			 ^ self literalLoadInstructionBytes + self bytesForADDOverflowCheck
			   + self bytesForArithmeticFlagUpdateWithMov + 4 ]). "DONE"
			([ SubCwR ] -> [ 
			 ^ self literalLoadInstructionBytes + self bytesForSUBOverflowCheck
			   + self bytesForArithmeticFlagUpdateWithMov + 4 ]). "DONE"
			([ CmpCwR ] -> [ 
			 ^ self literalLoadInstructionBytes + self bytesForSUBOverflowCheck
			   + self bytesForArithmeticFlagUpdate + 4 ]). "DONE"
			([ AndCwR ] -> [ 
			 ^ self literalLoadInstructionBytes + self bytesForLogicFlagUpdate
			   + 4 ]). "DONE"
			([ OrCwR ] -> [ 
			 ^ self literalLoadInstructionBytes + self bytesForLogicFlagUpdate
			   + 4 ]). "DONE"
			([ XorCwR ] -> [ 
			 ^ self literalLoadInstructionBytes + self bytesForLogicFlagUpdate
			   + 4 ]). "DONE"

			"Arithmetic Register-Only"
			([ AddRR ] -> [ 
			 ^ self bytesForADDOverflowCheck
			   + self bytesForArithmeticFlagUpdateWithMov + 4 ]). "DONE"
			([ SubRR ] -> [ 
			 ^ self bytesForSUBOverflowCheck
			   + self bytesForArithmeticFlagUpdateWithMov + 4 ]). "DONE"
			([ CmpRR ] -> [ 
			 ^ self bytesForSUBOverflowCheck
			   + self bytesForArithmeticFlagUpdate + 4 ]). "DONE"
			([ AndRR ] -> [ ^ self bytesForLogicFlagUpdate + 4 ]). "DONE"
			([ OrRR ] -> [ ^ self bytesForLogicFlagUpdate + 4 ]). "DONE"
			([ XorRR ] -> [ ^ self bytesForLogicFlagUpdate + 4 ]). "DONE"
			([ MulRR ] -> [ ^ 28 ]). "TODO"
			([ DivRR ] -> [ ^ 4 ]). "TODO"
			([ RemRR ] -> [ ^ 4 ]). "TODO"
			([ NegateR ] -> [ ^ 4 ]). "DONE"

			"Bit shifts"
			([ LogicalShiftLeftCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"
			([ LogicalShiftRightCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"
			([ ArithmeticShiftRightCqR ] -> [ ^ self bytesForLogicCqOperation ]). "DONE"

			([ LogicalShiftLeftRR ] -> [ ^ self bytesForLogicFlagUpdate + 4 ]). "DONE"
			([ LogicalShiftRightRR ] -> [ ^ self bytesForLogicFlagUpdate + 4 ]). "DONE"
			([ ArithmeticShiftRightRR ]
			 -> [ ^ self bytesForLogicFlagUpdate + 4 ]). "DONE"

			"Rotates"
			([ RotateLeftCqR ] -> [ 
			 ^ self
				   bytesForLogicCqOperationOfSize: 16
				   andImmediateOperationSize: 12 ]). "DONE"
			([ RotateRightCqR ] -> [ 
			 ^ self
				   bytesForLogicCqOperationOfSize: 16
				   andImmediateOperationSize: 12 ]). "DONE"

			"Floating point operations"
			([ AddRdRd ]
			 -> [ ^ self bytesForFloatingPointADDOverflowCheck + 12 ]). "DONE"
			([ SubRdRd ]
			 -> [ ^ self bytesForFloatingPointSUBOverflowCheck + 12 ]). "DONE"
			([ CmpRdRd ] -> [ ^ 8 ]). "DONE"
			([ MulRdRd ] -> [ ^ 8 ]). "DONE"
			([ DivRdRd ] -> [ ^ 8 ]). "DONE"
			([ SqrtRd ] -> [ ^ 4 ]). "DONE"
			([ XorRdRd ] -> [ ^ 4 ]). "DONE"

			"Data Movement - Basic"
			([ MoveCqR ] -> [ 
			 dependent
				 ifNil: [ 
					 | cq |
					 cq := operands at: 0.
					 self assertValue: cq isContainedIn: 12.
					 ^ self bytesToLoadImmediate: cq ]
				 ifNotNil: [ "Literal load" ^ self literalLoadInstructionBytes ] ]). "DONE"
			([ MoveC32R ] -> [ ^ 0 ]). "shouldBeImplemented"
			([ MoveCwR ] -> [ ^ 8 "always a auipc addi/ld sequence" ]). "DONE"
			([ MoveRR ] -> [ ^ 4 ]). "DONE"

			"Data movement - Absolute addresses"
			([ MoveAwR ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 0))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).
			([ MoveRAw ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 1))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).
			([ MoveAbR ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 0))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).
			([ MoveRAb ] -> [ 
			 (self isAddressRelativeToVarBase: (operands at: 1))
				 ifTrue: [ ^ 4 ]
				 ifFalse: [ ^ self literalLoadInstructionBytes + 4 ] ]).

			"Data Movement - Stores"
			([ MoveRM8r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveRMbr ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveRM16r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveRM32r ] -> [ 
			^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveRMwr ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveRsM32r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveRdM64r ] -> [ 
			 ^ self
				   bytesForDataStoreOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"

			"Data Movement - Loads"
			([ MoveM8rR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveMbrR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveM16rR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveM32rR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveMwrR ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveM32rRs ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"
			([ MoveM64rRd ] -> [ 
			 ^ self
				   bytesForDataLoadOperationOfSize: 8
				   andImmediateOperationSize: 4 ]). "DONE"

			"Data Movement - Relative addresses with multiply"
			([ MoveXbrRR ] -> [ ^ 8 ]). "DONE"
			([ MoveX32rRR ] -> [ ^ 12 ]). "DONE"
			([ MoveXwrRR ] -> [ ^ 12 ]). "DONE"
			([ MoveRX32rR ] -> [ ^ 12 ]). "DONE"
			([ MoveRXbrR ] -> [ ^ 8 ]). "DONE"
			([ MoveRXwrR ] -> [ ^ 12 ]). "DONE"

			"Pop/Push"
			([ PopR ] -> [ ^ 8 ]). "DONE"
			([ PushR ] -> [ ^ 8 ]). "DONE"
			([ PushCw ] -> [ ^ self literalLoadInstructionBytes + 8 ]). "DONE"
			([ PushCq ] -> [ 
			 dependent
				 ifNil: [ ^ (self bytesToLoadImmediate: (operands at: 0)) + 8 ]
				 ifNotNil: [ "literal load" 
				 ^ self literalLoadInstructionBytes + 8 ] ]). "DONE"

			"Conversion"
			([ ConvertRdRs ] -> [ ^ 4 ]). "DONE"
			([ ConvertRsRd ] -> [ ^ 4 ]). "DONE"
			([ ConvertRRd ] -> [ ^ 4 ]). "DONE"
			([ MoveRdR ] -> [ ^ 4 ]). "DONE"
			([ MoveRRd ] -> [ ^ 4 ]). "DONE"

			"Prefetch operation"
			([ PrefetchAw ] -> [ ^ 0 ]).

			"This is a fixed size instruction using a literal. We need exactly 2 instructions to move a literal from a PC relative position, so this takes ALWAYS 2 instructions of 4 bytes"
			([ MovePatcheableC32R ] -> [ "DONE" ^ 8 ]) }.
	"Noops & Pseudo Ops"
	^ 0 "to keep C compiler qui Unmatched "
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> computeSignedValue64Bits: aValue [ 

	self flag: #TODO.
	^ self computeSignedValueOf: aValue ofSize: 64
]

{ #category : #'helpers - size sign' }
CogRiscV64Compiler >> computeSignedValueOf: aValue ofSize: aSize [

	"If the number is negative, returns two's complement, otherwise return the value"
	self flag: #DONE.
	aValue < 0
		ifTrue: [ | mask |
			mask := (1 << aSize) - 1.
			^ mask - aValue abs + 1 ]  "Compute two's complement" 
		ifFalse: [ ^ aValue ]
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAddCqR [

	"Perform an add operation between the value of register and the value of the operand.
	
	 If the operand is smaller than 12 bits:
		addi reg, reg, cq

	 Else, use the provided literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		add reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset overflowOffset |
	self flag: #DONE.
	cq := operands at: 0.
	sourceReg := operands at: 1.
	destReg := operands at: 2.
	destReg ifNil: [ destReg := sourceReg ].
	self assert: (destReg isNotNil).
	"Load cq if needed in a register (whether big immediate or literal) 
	 or use the immediate instruction if it is a small immediate"
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Use the provided immediate instruction"
		self machineCodeAt: 0 put: (self
				 addImmediate: cq
				 toRegister: sourceReg
				 inRegister: ConcreteZeroReg).
		"Check for overflow"
		overflowOffset := self
			                  checkADDOverflowWithSourceReg: sourceReg
			                  immediate: cq
			                  andResultReg: ConcreteZeroReg
			                  startingAtIndex: 4.

		"Update flag registers"
		flagOffset := self
			              updateFlagsADDForSourceReg: sourceReg
			              resultReg: ConcreteZeroReg
			              andMoveResultTo: destReg
			              startingAtIndex: overflowOffset + 4.
		^ machineCodeSize := flagOffset + overflowOffset + 4 ].

	"Otherwise, use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the actual ADD operation"
	self machineCodeAt: loadOffset put: (self
			 addRegister: sourceReg
			 toRegister: ConcreteIPReg
			 inRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkADDOverflowWithSourceReg1: sourceReg
		                  sourceReg2: ConcreteIPReg
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: loadOffset + 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsADDForSourceReg: sourceReg
		              resultReg: ConcreteZeroReg
		              andMoveResultTo: destReg
		              startingAtIndex: loadOffset + overflowOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + overflowOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAddCwR [

	<inline: true>
	| sourceReg destReg loadOffset flagOffset overflowOffset |
	self flag: #DONE.
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.
	"Load Cw in register then perform the add"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.

	"Perform the actual ADD operation"
	self machineCodeAt: loadOffset put: (self
			 addRegister: sourceReg
			 toRegister: ConcreteIPReg
			 inRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkADDOverflowWithSourceReg1: sourceReg
		                  sourceReg2: ConcreteIPReg
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: loadOffset + 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsADDForSourceReg: ConcreteIPReg
		              resultReg: ConcreteZeroReg
		              andMoveResultTo: destReg
		              startingAtIndex: loadOffset + overflowOffset + 4.

	^ machineCodeSize := loadOffset + flagOffset + overflowOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAddRR [

	<inline: true>
	| srcReg1 srcReg2 destReg flagOffset overflowOffset |
	self flag: #DONE.
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Perform the ADD operation"
	self machineCodeAt: 0 put: (self
			 addRegister: srcReg1
			 toRegister: srcReg2
			 inRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkADDOverflowWithSourceReg1: srcReg1
		                  sourceReg2: srcReg2
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsADDForSourceReg: srcReg1
		              resultReg: ConcreteZeroReg
		              andMoveResultTo: destReg
		              startingAtIndex: overflowOffset + 4.

	^ machineCodeSize := flagOffset + overflowOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAddRdRd [

	<inline: true>
	| srcReg1 srcReg2 destReg overflowOffset |
	self flag: #TODO.
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	
	"Carry flag: Carry in FP is a simple comparison (note that 0 will be put if any of the two is NaN)"		
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteCarryReg  
		ifRegisterValue: srcReg2 
		isLessThanRegisterValue: srcReg1
	).	

	"Perform the ADD operation"
	self machineCodeAt: 4 put: (self
		fAddRegister: srcReg1 
		toRegister: srcReg2 
		intoRegister: ConcreteIPFPReg2
	).
	
	"Check for overflow"
	overflowOffset := self
		checkADDFloatingPointOverflowWithSourceReg1: srcReg1 
		sourceReg2: srcReg2
		andResultReg: ConcreteIPFPReg2
		startingAtIndex: 8.

	"Move result to destination"
	self machineCodeAt: overflowOffset + 8 put: (self 
		fMoveDoubleWordInFRegister: ConcreteIPFPReg2 
		toFRegister: destReg		 
	).
	
	^ machineCodeSize := overflowOffset + 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAlignmentNops [

	"Fill any empty slots with NOPs"
	<inline: true>
	self flag: #DONE.
	self assert: machineCodeSize \\ 4 = 0.
	0 to: machineCodeSize - 1 by: 4 do: [ :p | self machineCodeAt: p put: self nop ]
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAndCqR [

	"Perform a bitwise and between the value of register and the value of the operand.
	
	 If the operand is smaller than 12 bits:
		andi reg, reg, cq

	 Else, use the provided literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		and reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset |
	self flag: #TODO.
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	"Use immediate with quick or literal load"
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Use the provided immediate instruction"
		self machineCodeAt: 0 put: (self
				 bitwiseAndBetweenRegister: sourceReg
				 andImmediate: cq
				 toRegister: destReg).
		flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].

	"If the value is a literal, load it in a given register"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the AND operation"
	self machineCodeAt: loadOffset put: (self
			 bitwiseAndBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	"Update the flag registers"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAndCqRR [

	"Perform a bitwise and between the value of register and the value of the operand.
	
	 If the operand is smaller than 12 bits:
		andi reg, reg, cq

	 Else, use the provided literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		and reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset |
	self flag: #TODO.
	cq := operands at: 0.
	sourceReg := operands at: 1.
	destReg := operands at: 2.
	"Use immediate with quick or literal load"
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Use the provided immediate instruction"
		self machineCodeAt: 0 put: (self
				 bitwiseAndBetweenRegister: sourceReg
				 andImmediate: cq
				 toRegister: destReg).
		flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].

	"If the value is a literal, load it in a given register"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the AND operation"
	self machineCodeAt: loadOffset put: (self
			 bitwiseAndBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	"Update the flag registers"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAndCwR [
	
	<inline: true>
	| sourceReg destReg loadOffset flagOffset |
	self flag: #TODO.
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.	
	"Load Cw in register then perform the add"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the AND operation"
	self machineCodeAt: loadOffset put: (self
	      	 bitwiseAndBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	"Update flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
			
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAndRR [

	<inline: true>
	| srcReg1 srcReg2 destReg flagOffset |
	self flag: #TODO.
	srcReg1 := operands at: 0.
	destReg := srcReg2 := operands at: 1.
	"Perform the ADD operation"
	self machineCodeAt: 0 put: (self bitwiseAndBetweenRegister: srcReg1 andRegister: srcReg2 toRegister: destReg).	
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
	^ machineCodeSize := flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeArithmeticShiftRightCqR [

	"Perform an arithmetic shift right between the value of register and the value of the operand.
	
	 If the operand is not a literal:
		srai reg, reg, cq

	 Otherwise load the value in a register:
		li ConcreteIPReg, cq 
		sra reg, reg, ConcreteIPReg 

	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		sra reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset |
	self flag: #DONE.
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate ASRLI"
		self machineCodeAt: 0 put: (self
				 arithmeticShiftRightValueInRegister: sourceReg
				 byShiftAmount: cq
				 intoRegister: destReg).
		flagOffset := self
			              updateFlagsLogicForResultReg: destReg
			              startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the ASR operation"
	self machineCodeAt: loadOffset put: (self
			 arithmeticShiftRightValueInRegister: sourceReg
			 byShiftAmountInRegister: ConcreteIPReg
			 intoRegister: destReg).
	"Update the flags"
	flagOffset := self
		              updateFlagsLogicForResultReg: destReg
		              startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeArithmeticShiftRightRR [

	<inline:true>
	| srcReg shiftReg destReg flagOffset |
	self flag: #TODO.
	shiftReg := operands at: 0.
	destReg := srcReg := operands at: 1.
	"Perform ASR operation"
	self machineCodeAt: 0 put: (self arithmeticShiftRightValueInRegister: srcReg byShiftAmountInRegister: shiftReg intoRegister: destReg).
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
	^ machineCodeSize := flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeAt: actualAddress [
	"Generate concrete machine code for the instruction at actualAddress,
	 setting machineCodeSize, and answer the following address."

	self assert: actualAddress \\ 4 = 0.
	^ super concretizeAt: actualAddress
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeBrEqualRR [ 

	<inline: true>
	| offset left right |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
	left := operands at: 1.
	right := operands at: 2.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if the zero flag is set to 1"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValue: left isEqualToRegisterValue: right).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCall [
	"Will get inlined into concretizeAt: switch."

	"Call is used only for calls within code-space, See CallFull for general anywhere in address space calling"
	
	<inline: true>
	| offset offsetHigh offsetLow |
	self flag: #TODO.
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the PC"
   offset := (operands at: 0) signedIntFromLong - address signedIntFromLong.
	self assert: (self isInLongJumpCallRange: offset).
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset  bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: LR).
	^ machineCodeSize := 8

]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCallFull [
	"Will get inlined into concretizeAt: switch."

	"Sizing/generating calls.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	<var: #jumpTarget type: #'AbstractInstruction *'>
	| jumpTarget instrOffset |
	self flag: #TODO.
	jumpTarget := self longJumpTargetAddress.
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: instrOffset put: (self jumpTo: ConcreteIPReg withOffset: 0 andStorePreviousPCPlus4in: LR). 
	^ machineCodeSize := instrOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCmpC32R [

	<inline: true>
	self flag: #TODO.
	^ self concretizeCmpCwR.
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCmpCqR [

	<var: #cq type: #sqInt>
	<inline: true>
	| srcReg cq loadOffset flagOffset overflowOffset |
	self flag: #TODO.
	cq := operands at: 0.
	srcReg := operands at: 1.
	"Note: There is no sub immediate"
	dependent 
		ifNil: [ "Move to a register using immediate operations (no subi but will avoid having too much literals)"
			loadOffset := self loadImmediate: cq inRegister: ConcreteIPReg]
		ifNotNil: [ "Literal -> compute the distance, load the actual value then and between the 2 registers" 
			loadOffset := self loadLiteralInRegister: ConcreteIPReg ].
	"Perform the subtraction"
	self machineCodeAt: loadOffset put: (self
			 subtractRegister: ConcreteIPReg
			 fromRegister: srcReg
			 intoRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkSUBOverflowWithSourceReg1: srcReg
		                  sourceReg2: ConcreteIPReg
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: loadOffset + 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsCMPForSourceReg: srcReg
		              resultReg: ConcreteZeroReg
		              startingAtIndex: loadOffset + overflowOffset + 4.

	^ machineCodeSize := loadOffset + overflowOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCmpCwR [

	"Perform a cmp operation (sub discarding the result) and between the value of register and the value of the operand.
	 The result is discarded. The instruction is used with a Jump next to it, for example: CmpCqR JumpEquals(label) .
	 No immediate possibility because no subi instruction exists.
	
	 As no immediate can be provided (no subi), all cmp use the instruction sequence:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		sub  ConcreteFlagReg, ConcreteIPReg, reg 
		
		(beq ConcreteFlagReg, ConcreteIPReg, label)"

	<inline: true>
	| loadOffset srcReg flagOffset overflowOffset |
	self flag: #TODO.
	self assert: dependent notNil.
	srcReg := operands at: 1. "operands at 0 is the Cw"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the subtraction"
	self machineCodeAt: loadOffset put: (self
			 subtractRegister: ConcreteIPReg
			 fromRegister: srcReg
			 intoRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkSUBOverflowWithSourceReg1: srcReg
		                  sourceReg2: ConcreteIPReg
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: loadOffset + 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsCMPForSourceReg: srcReg
		              resultReg: ConcreteZeroReg
		              startingAtIndex: loadOffset + overflowOffset + 4.

	^ machineCodeSize := loadOffset + overflowOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCmpRR [

	"CMP is a SUB operation where the result is discarded (here saved in the zero flag register)
	 CMP o1 o2 means o2-o1"

	<inline: true>
	| srcReg1 srcReg2 flagOffset overflowOffset |
	self flag: #DONE.
	srcReg1 := operands at: 0.
	srcReg2 := operands at: 1.
	"Perform the SUB operation"
	self machineCodeAt: 0 put: (self
			 subtractRegister: srcReg1
			 fromRegister: srcReg2
			 intoRegister: ConcreteZeroReg).
	"Check for overflow"
	overflowOffset := self
		                  checkSUBOverflowWithSourceReg1: srcReg2
		                  sourceReg2: srcReg1
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsCMPForSourceReg: srcReg2
		              resultReg: ConcreteZeroReg
		              startingAtIndex: overflowOffset + 4.
	^ machineCodeSize := flagOffset + overflowOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeCmpRdRd [
	
	"For floating points, we only need to change the ZF and CF flags by comparing them
	 The jumps then process along the table in
	https://stackoverflow.com/questions/7057501/x86-assembler-floating-point-compare
	"
	<inline: true>
	| srcReg1 srcReg2 flagOffset |
	self flag: #TODO.
	srcReg1 := operands at: 0.
	srcReg2 := operands at: 1.
	"1. Zero Flag: Test Equality (note that 0 will be put if any of the two is NaN)"	
	self machineCodeAt: 0 put: (self fSetOneIn: ConcreteZeroReg  ifRegisterValue: srcReg2 isEqualToRegisterValue: srcReg1).
	"2. Carry flag: Carry in FP is a simple comparison (note that 0 will be put if any of the two is NaN)"		
	self machineCodeAt: 4 put: (self fSetOneIn: ConcreteCarryReg  ifRegisterValue: srcReg2 isLessThanRegisterValue: srcReg1).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeConvertRRd [
 
	"Convert an integer value into a double precision float value"

	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := operands at:0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
	    fConvertLongSignedInRegister: srcReg 
	    toDoublePrecisionInRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeConvertRdRs [

	"Convert a double precision float to a single precision float in a register"

	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := operands at:0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
	    fConvertDoublePrecisionInRegister: srcReg 
	    toSinglePrecisionInRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeConvertRsRd [

	"Convert a single precision float to a double precision float in a register"

	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := operands at:0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
	    fConvertSinglePrecisionInRegister: srcReg 
	    toDoublePrecisionInRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeDivRR [ 

	<inline: true>
	| regNumerator regDenominator regDestination |
	self flag: #TODO.
	regNumerator := operands at: 0.
	regDenominator := operands at: 1.
	regDestination := operands at: 2. 
	"Perform the DIV operation (signed division)"
	self machineCodeAt: 0 put: (self 
		divideRegisterValue: regNumerator 
		byRegisterValue: regDenominator  
		intoRegister: regDestination).

	"flagOffset := self machineCodeWriteInstructions: (self
			updateFlagsArithmeticForSourceReg1: regNumerator 
			sourceReg2: regDenominator 
			andResultReg: regDestination
		) startingAtIndex: 4."
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeDivRdRd [

	"FP divide regLHS by regRHS and stick result in regLHS"

	<inline: true>
	| srcReg1 srcReg2 destReg flagOffset |
	self flag: #TODO.
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Carry flag: Carry in FP is a simple comparison (note that 0 will be put if any of the two is NaN)"		
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteCarryReg  
		ifRegisterValue: srcReg2 
		isLessThanRegisterValue: srcReg1
	).	
	"Perform DIV operation"
	self machineCodeAt: 4 put: (self fDivideRegister: srcReg2 byRegister: srcReg1 intoRegister: destReg).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeFill32 [
	"fill with operand 0 according to the processor's endianness, here little-endian"

	self flag: #DONE.
	self machineCodeAt: 0 put: (operands at: 0).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJump [ 

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateJumpRange: offset).
	self machineCodeAt: 0 put: (self jumpToOffset: offset).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpAbove [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 4.
	self assert: (self isInImmediateBranchRange: offset).
	"Check the condition!"
	"Jump Above means jump if 	CF=0 and ZF=0"
	self machineCodeAt: 0 put: (self bitwiseOrBetweenRegister: ConcreteCarryReg 
	                               andRegister: ConcreteZeroReg 
	                               toRegister: ConcreteIPReg).
	"The previous instruction should have put 0 in ipreg if both cf and zf are equal to 0"
	self machineCodeAt: 4 put: (self branchTo: offset 
	                                 ifRegisterValueIsEqualToZero: ConcreteIPReg).
	^ machineCodeSize := 8.
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpAboveOrEqual [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
	self assert: (self isInImmediateBranchRange: offset).
	"Jump above or equal translates to jump if CF=0"
	self machineCodeAt: 0 put: (self branchTo: offset 
   				                     ifRegisterValueIsEqualToZero: ConcreteCarryReg).
	^ machineCodeSize := 4 
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpBelow [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Below translates to jump if Carry = 1"
	self machineCodeAt: 0 put: (self branchTo: offset 
	                                 ifRegisterValueIsNotEqualToZero: ConcreteCarryReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpBelowOrEqual [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 4.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Below or Equal translates to jump if 	CF=1 or ZF=1"
	self machineCodeAt: 0 put: (self bitwiseOrBetweenRegister: ConcreteCarryReg 
	                                 andRegister: ConcreteZeroReg
	                                 toRegister: ConcreteIPReg).
	"Or the two registers and check that the result is not 0"
	self machineCodeAt: 4 put: (self branchTo: offset 
	                                 ifRegisterValueIsNotEqualToZero: ConcreteIPReg).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpCarry [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Carry set if carry register at 1"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsNotEqualToZero: ConcreteCarryReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPEqual [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Equal for floating points means jump if the zero flag is set to 1"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsNotEqualToZero: ConcreteZeroReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPGreater [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 4.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Greater for floating points means jump if ZF = 0 and CF = 0"
	"Perform an OR operation between the two registers"
	self machineCodeAt: 0 put: (self bitwiseOrBetweenRegister: ConcreteZeroReg
											  andRegister: ConcreteCarryReg
											  toRegister: ConcreteIPReg).
	"Jump if it is equal to 0 (i.e. both were equal to 0"
	self machineCodeAt: 4 put: (self branchTo: offset
											  ifRegisterValueIsEqualToZero: ConcreteIPReg).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPGreaterOrEqual [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Greater or Equal for floating points means jump if the carry flag is not set"
	self machineCodeAt: 0 put: (self branchTo: offset 
											  ifRegisterValueIsEqualToZero: ConcreteCarryReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPLess [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Less for floating points means jump if CF = 1"
	self machineCodeAt: 0 put: (self branchTo: offset 
											  ifRegisterValueIsNotEqualToZero: ConcreteCarryReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPLessOrEqual [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 4.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Less or Equal for floating points means jump if ZF = 1 or CF = 1"
	"Perform an OR operation between the two registers"
	self machineCodeAt: 0 put: (self bitwiseOrBetweenRegister: ConcreteZeroReg
											  andRegister: ConcreteCarryReg
											  toRegister: ConcreteIPReg).
	"Jump if it is equal to 1 (i.e. at least one was 1)"
	self machineCodeAt: 4 put: (self branchTo: offset
											  ifRegisterValueIsNotEqualToZero: ConcreteIPReg).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPNotEqual [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Not Equal for floating points means jump if the zero flag register is set to 0"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsEqualToZero: ConcreteZeroReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPOrdered [

	<inline:true>
	1halt.
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFPUnordered [

	<inline:true>
	1halt.
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpFull [
"Will get inlined into concretizeAt: switch."

	"Sizing/generating calls.
		Jump targets can be to absolute addresses or other abstract instructions.
		Generating initial trampolines instructions may have no maxSize and be to absolute addresses.
		Otherwise instructions must have a machineCodeSize which must be kept to."

	<inline: true>
	<var: #jumpTarget type: #'AbstractInstruction *'>
	| loadOffset jumpTarget |
	self flag: #TODO.	
	jumpTarget := self longJumpTargetAddress.
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self jumpToRegisterValue: ConcreteIPReg).
	^ machineCodeSize := loadOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpGreater [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
	self assert: (self isInImmediateBranchRange: offset).
	"Jump Greater means jump if ZF = 0 and SF = OF"
	"Check if SF and OF are different with a XOR (1 if different)"
	self machineCodeAt: 0 put: (self bitwiseXorBetweenRegister: ConcreteSignReg  
											  andRegister: ConcreteOverflowReg 
											  intoRegister: ConcreteIPReg).
	"Or will set 1 if SF is different from OF or if ZF=1"
	self machineCodeAt: 4 put: (self bitwiseOrBetweenRegister: ConcreteIPReg 
											  andRegister: ConcreteZeroReg 
											  toRegister: ConcreteIPReg).
	"Jump if the result is 0"
	self machineCodeAt: 8 put: (self branchTo: offset
											  ifRegisterValueIsEqualToZero: ConcreteIPReg).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpGreaterOrEqual [ 

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Greater or Equal means jump if SF = OF"
	self machineCodeAt: 0 put: (self branchTo: offset 
											  ifRegisterValue: ConcreteSignReg 
	                                 isEqualToRegisterValue: ConcreteOverflowReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpLess [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Less means jump if SF different from 	OF"
	self machineCodeAt: 0 put: (self branchTo: offset 
	                                 ifRegisterValue: ConcreteSignReg 
	                                 isNotEqualToRegisterValue: ConcreteOverflowReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpLessOrEqual [ 

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 8.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump Less or Equal means jump if SF different from 	OF or 	ZF=1"
	"Check if SF and OF are different with a XOR"
	self machineCodeAt: 0 put: (self bitwiseXorBetweenRegister: ConcreteSignReg  
											  andRegister: ConcreteOverflowReg 
											  intoRegister: ConcreteIPReg).
	"Or to check if it is different or zf=1"
	self machineCodeAt: 4 put: (self bitwiseOrBetweenRegister: ConcreteIPReg 
											  andRegister: ConcreteZeroReg 
											  toRegister: ConcreteIPReg).
	"Jump if the result is One"
	self machineCodeAt: 8 put: (self branchTo: offset
											  ifRegisterValueIsNotEqualToZero: ConcreteIPReg).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpLong [

	"JumpLong works the same way as a Call buts does not store the return address"
	<inline: true>
	| offset offsetHigh offsetLow |
	self flag: #TODO.
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the address of the first instruction (auipc)"
   offset := (operands at: 0) signedIntFromLong - address signedIntFromLong.
	self assert: (self isInLongJumpCallRange: offset).
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpLongGreater [

	"JumpLong works the same way as a Call buts does not store the return address"
	<inline: true>
	| offset offsetHigh offsetLow |
	self flag: #TODO.
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the address of the first instruction (auipc)"
	offset := (operands at: 0) signedIntFromLong - address signedIntFromLong - 4.
	self assert: (self isInLongJumpCallRange: offset).
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	"Jump Greater means jump if ZF = 0 and SF = OF"
	"Check if SF and OF are different with a XOR (1 if different)"
	self machineCodeAt: 0 put: (self bitwiseXorBetweenRegister: ConcreteSignReg  
											  andRegister: ConcreteOverflowReg 
											  intoRegister: ConcreteIPReg).
	"Or will set 1 if SF is different from OF or if ZF=1"
	self machineCodeAt: 4 put: (self bitwiseOrBetweenRegister: ConcreteIPReg 
											  andRegister: ConcreteZeroReg 
											  toRegister: ConcreteIPReg).
	"Branch over the jump if the condition is not met -> Here the condition is greater if ConcreteIPReg = 0 and it should proceed to the big jump"
	self machineCodeAt: 8 put: (self  branchTo: 12 ifRegisterValueIsNotEqualToZero: ConcreteIPReg "should jump after the jump").
	"Perform the actual jump"
	self machineCodeAt: 12 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 16 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 20
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpLongNonZero [

	"JumpLong works the same way as a Call buts does not store the return address"
	<inline: true>
	| offset offsetHigh offsetLow |
	self flag: #TODO.
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the address of the first instruction (auipc)"
	offset := (operands at: 0) signedIntFromLong - address signedIntFromLong - 4.
	self assert: (self isInLongJumpCallRange: offset).
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	"Branch over the jump if the condition is not met"
	self machineCodeAt: 0 put: (self  branchTo: 12 ifRegisterValueIsNotEqualToZero: ConcreteZeroReg "should jump after the jump").
	"Perform the actual jump"
	self machineCodeAt: 4 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 8 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpLongZero [

	"JumpLong works the same way as a Call buts does not store the return address"
	<inline: true>	
	| offset offsetHigh offsetLow |
	self flag: #TODO.
	self assert: (operands at: 0) ~= 0.
	self assert: (operands at: 0) \\ 4 = 0.
	"Compute the offset from the address of the first instruction (auipc)"
	offset := (operands at: 0) signedIntFromLong - address signedIntFromLong - 4. 
	self assert: (self isInLongJumpCallRange: offset).

	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (offset bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: offset) + 16r800) >> 12) bitAnd: 16rFFFFF.
	
	"Branch over the jump if the condition is not met"
	self machineCodeAt: 0 put: (self  branchTo: 12 ifRegisterValueIsEqualToZero: ConcreteZeroReg "should jump after the jump").
	"Perform the actual jump"
	self machineCodeAt: 4 put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	self machineCodeAt: 8 put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpNegative [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if sign register is set to 1"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsNotEqualToZero: ConcreteSignReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpNoCarry [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if carry register set to 0"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsEqualToZero: ConcreteCarryReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpNoOverflow [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if the overflow flag register is not set"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsEqualToZero: ConcreteOverflowReg).
	^ machineCodeSize := 4	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpNonNegative [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if Sign flag is set to 0"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsEqualToZero: ConcreteSignReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpNonZero [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if the zero flag register is set to 0"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsEqualToZero: ConcreteZeroReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpOverflow [

	<inline:true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if the overflow register flag is set to 1"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsNotEqualToZero: ConcreteOverflowReg).
	^ machineCodeSize := 4	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpR [

	<inline: true>
	| reg|
	self flag: #TODO.
	reg := operands at: 0.
	self machineCodeAt: 0 put: (self jumpToRegisterValue: reg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeJumpZero [

	<inline: true>
	| offset |
	self flag: #TODO.
	offset := self computeJumpTargetOffsetPlus: 0.
 	self assert: (self isInImmediateBranchRange: offset).
	"Jump if the zero flag is set to 1"
	self machineCodeAt: 0 put: (self branchTo: offset ifRegisterValueIsNotEqualToZero: ConcreteZeroReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeLiteral [

	<doNotGenerate>
	self subclassResponsibility 
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeLoadEffectiveAddressMwrR [

	"destReg = srcReg (which contains an address) + offset"
	"Is it really the same thing as an AddCqR where cq would be the offset? 
	 Yes but the conditional flags are not affected!"
		
	<inline: true>
	| offset destReg sourceReg loadOffset |
	self flag: #TODO.
	offset := operands at: 0.
	sourceReg := operands at: 1.
	destReg := operands at: 2.
	dependent ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
					 addImmediate: offset
					 toRegister: sourceReg
					 inRegister: destReg).
			^ machineCodeSize := 4 ].
	"Literal -> compute the distance, load the actual value then and between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 addRegister: sourceReg
			 toRegister: ConcreteIPReg
			 inRegister: destReg).
	^ machineCodeSize := loadOffset + 4.
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeLogicalShiftLeftCqR [

	"Perform a logical shift left operation between the value of register and the value of the operand.
	
	 If the operand is not a literal:
		slli reg, reg, cq

	 Otherwise load the value in a register:
		li ConcreteIPReg, cq 
		sll reg, reg, ConcreteIPReg 	
			
	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		sll reg, reg, ConcreteIPReg 
		"

	<inline: true>
	<var: #cq type: #sqInt>
	| cq destReg sourceReg loadOffset flagOffset |
	self flag: #DONE.
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 shiftLeftValueInRegister: sourceReg
				 byShiftAmount: cq
				 intoRegister: destReg).
		"Update the flags"
		flagOffset := self
			              updateFlagsLogicForResultReg: destReg
			              startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the SL operation"
	self machineCodeAt: loadOffset put: (self
			 shiftLeftValueInRegister: sourceReg
			 byShiftAmountInRegister: ConcreteIPReg
			 intoRegister: destReg).
	"Update the flags"
	flagOffset := self
		              updateFlagsLogicForResultReg: destReg
		              startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeLogicalShiftLeftRR [
	
	<inline: true>
	| shiftReg srcReg destReg flagOffset |
	self flag: #TODO.
	shiftReg := operands at: 0.
	srcReg := destReg := operands at: 1.
	"Perform the SLR operation"
	self machineCodeAt: 0 put: (self shiftLeftValueInRegister: srcReg byShiftAmountInRegister: shiftReg intoRegister: destReg).
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
	^ machineCodeSize := flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeLogicalShiftRightCqR [

	"Perform a logical shift right operation between the value of register and the value of the operand.
	
	 If the operand is not a literal:
		srli reg, reg, cq

	 Otherwise load the value in a register:
		li ConcreteIPReg, cq 
		srl reg, reg, ConcreteIPReg 	
			
	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		srl reg, reg, ConcreteIPReg 
		"

	<inline: true>
	<var: #cq type: #sqInt>
	| cq destReg sourceReg instrOffset flagOffset |
	self flag: #DONE.
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate SRLI"
		self machineCodeAt: 0 put: (self
				 shiftRightValueInRegister: sourceReg
				 byShiftAmount: cq
				 intoRegister: destReg).
		flagOffset := self
			              updateFlagsLogicForResultReg: destReg
			              startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].
	"Otherwise use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the SR operation"
	self machineCodeAt: instrOffset put: (self
			 shiftRightValueInRegister: sourceReg
			 byShiftAmountInRegister: ConcreteIPReg
			 intoRegister: destReg).
	"Update the flags"
	flagOffset := self
		              updateFlagsLogicForResultReg: destReg
		              startingAtIndex: instrOffset + 4.
	^ machineCodeSize := instrOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeLogicalShiftRightRR [
	
	<inline: true>
	| srcReg shiftReg destReg flagOffset |
	self flag: #TODO.
	shiftReg := operands at: 0.
	srcReg := destReg := operands at: 1.
	"Perform the SRR operation"
	self machineCodeAt: 0 put: (self shiftRightValueInRegister: srcReg byShiftAmountInRegister: shiftReg intoRegister: destReg).
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
	^ machineCodeSize := flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveAbR [

	"Loads a byte (8 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"
	
	<inline: true>
	| srcAddr destReg instrOffset |
	self flag: #TODO.
	srcAddr := operands at: 0.
	destReg := operands at: 1.
	(self isAddressRelativeToVarBase: srcAddr) ifTrue: [ "Direct encoding as offset"
		self machineCodeAt: 0 put: (self
				 loadUnsignedByteFromAddressInRegister: ConcreteVarBaseReg
				 withOffset: srcAddr - cogit varBaseAddress
				 toRegister: destReg).
		^ machineCodeSize := 4 ].

	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.

	self machineCodeAt: instrOffset put: (self
			 loadUnsignedByteFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).
	^ machineCodeSize := instrOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveAwR [

	"Loads a word (64 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"

	<inline: true>
	| srcAddr destReg instrOffset |
	self flag: #TODO.
	srcAddr := operands at: 0.
	destReg := operands at: 1.
	(self isAddressRelativeToVarBase: srcAddr) ifTrue: [ "Direct encoding as offset"
		self machineCodeAt: 0 put: (self
				 loadDoubleWordFromAddressInRegister: ConcreteVarBaseReg
				 withOffset: srcAddr - cogit varBaseAddress
				 toRegister: destReg).
		^ machineCodeSize := 4 ].

	"load the address into ConcreteIPReg"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.

	self machineCodeAt: instrOffset put: (self
			 loadDoubleWordFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).

	^ machineCodeSize := instrOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveC32R [
	
	self flag: #TODO.
	self shouldBeImplemented.
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveCqR [

	<inline: true>
	<var: #cq type: #sqInt>
	| cq reg |
	self flag: #TODO.
	cq := operands at: 0.
	reg := operands at: 1.
	dependent ifNil: [ "Immediate value"
		^ machineCodeSize := self loadImmediate: cq inRegister: reg].
	"use the provided literal"
	^ machineCodeSize := self loadLiteralInRegister: reg
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveCwR [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	self flag: #DONE.
	^ machineCodeSize := self loadCwInto: (operands at: 1)
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveM16rR [

	"Load a half-word (2 bytes) from memory where the address is at a constant offset from an address in a register
	 The offset can be either encoded immediately or loaded 
	 Expands to: lh rs2, offset(rs1)"

	<inline: true>
	<var: #cq type: #sqInt>
	| baseReg offset destReg instrOffset |
	self flag: #TODO.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				loadUnsignedHalfWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self
			loadUnsignedHalfWordFromAddressInRegister: ConcreteIPReg  
			withOffset: 0 
			toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveM32rR [

	"Load a word (4 bytes) from memory where the address is at a constant offset from an address in a register
	 Expands to: lw rs2, offset(rs1)"

	<inline: true>
	<var: #cq type: #sqInt>
	| baseReg offset destReg instrOffset |
	self flag: #TODO.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				loadUnsignedWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset :=  self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self
			 loadUnsignedWordFromAddressInRegister: ConcreteIPReg 
			 withOffset: 0 
			 toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveM32rRs [
	
	"Load a single-precision float from srcReg+offset into FP destReg"

	<inline: true>
	| baseReg offset destReg instrOffset |
	self flag: #TODO.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				fLoadWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self 
		fLoadWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0
		toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveM64rRd [
	
	"Load a double-precision float from srcReg+offset into FP destReg"
	<inline: true>
	| baseReg offset destReg instrOffset |
	self flag: #TODO.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				fLoadDoubleWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ] .
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"	
	self machineCodeAt: instrOffset + 4 put: (self 
		fLoadDoubleWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0
		toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveMbrR [

	"Load a byte (8 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: lb rd, rs1(offset)"

	<var: #offset type: #sqInt>
	<inline: true>
	| baseReg offset destReg loadOffset |
	self flag: #TODO.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				loadUnsignedByteFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 loadUnsignedByteFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).
	^ machineCodeSize := loadOffset + 8	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveMwrR [

	"Load a vm word (double word 64 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: ld rd, rs1(offset)"

	<var: #offset type: #sqInt>
	<inline: true>
	| baseReg offset destReg instrOffset |
	self flag: #TODO.
	offset := operands at: 0.
	baseReg := operands at: 1.
	destReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				loadDoubleWordFromAddressInRegister: baseReg 
				withOffset: offset 
				toRegister: destReg). 
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: instrOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: instrOffset + 4 put: (self
			 loadDoubleWordFromAddressInRegister: ConcreteIPReg
			 withOffset: 0
			 toRegister: destReg).
	^ machineCodeSize := instrOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRAb [

	"Stores a byte (8 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"

	<inline: true>
	| srcReg destAddress instrOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	destAddress := operands at: 1.
	(self isAddressRelativeToVarBase: destAddress) ifTrue: [ 
		self machineCodeAt: 0 put: (self
				 storeByteFromRegister: srcReg
				 toAddressInRegister: ConcreteVarBaseReg
				 withOffset: destAddress - cogit varBaseAddress).
		^ machineCodeSize := 4 ].
	"Load provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: instrOffset put: (self
			 storeByteFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := instrOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRAw [

	"Stores a word (64 bits) from memory where the address is an absolute address. 
	 Tries to use var base first otherwise use the provided literal"

	<inline: true>
	| srcReg destAddress instrOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	destAddress := operands at: 1.
	(self isAddressRelativeToVarBase: destAddress) ifTrue: [ 
		self machineCodeAt: 0 put: (self
				 storeDoubleWordFromRegister: srcReg
				 toAddressInRegister: ConcreteVarBaseReg
				 withOffset: destAddress - cogit varBaseAddress).
		^ machineCodeSize := 4 ].
	"Load provided literal"
	instrOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: instrOffset put: (self
			 storeDoubleWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := instrOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRM16r [

	"Store a half word (2 bytes) from memory where the address is at a constant offset from an address in a register
	 Expands to: sh rs2, offset(rs1)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				 storeHalfWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			 ^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeHalfWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRM32r [

	"Store a word (4 bytes) from memory where the address is at a constant offset from an address in a register
	 Expands to: sw rs2, offset(rs1)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				 storeWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRMbr [

	"Stores a byte (8 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: sb rs2, rs1(offset)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12. 
			self machineCodeAt: 0 put: (self
				 storeByteFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			^ machineCodeSize := 4 ] .
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeByteFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRMwr [

	"Stores a vm word (64 bits) from memory where the address is at a constant offset from an address in a register
	 Expands to: sd rs2, offset(rs1)"

	<var: #offset type: #sqInt>
	<inline: true>
	| srcReg offset baseReg loadOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent 
		ifNil: [ 
			self assertValue: offset isContainedIn: 12.
			self machineCodeAt: 0 put: (self
				 storeDoubleWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
			^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self 
			addRegister: baseReg 
			toRegister: ConcreteIPReg 
			inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 storeDoubleWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRR [

	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := operands at: 0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self moveRegister: srcReg toRegister: destReg). 
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRRd [

	"fmv.d.x: Floating point move doubleword from integer
    Copies the double-precision floating-point number in x[rs1] to f[rd]"
	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := operands at: 0.
	destReg := operands at: 1.
	self machineCodeAt: 0 put: (self
			fMoveDoubleWordInXRegister: srcReg 
			toFRegister: destReg 
	).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRX32rR [

	"Write the half word in R(src) into memory at address (base + word size * index)"

	<inline: true>
	| indexReg baseReg srcReg |
	self flag: #TODO.
	srcReg := operands at: 0.
	indexReg := operands at: 1. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 2.	
	"Shift by 2 (*4) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 2
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Store the value"
	self machineCodeAt: 8 put: (self 
		storeWordFromRegister: srcReg 
		toAddressInRegister: ConcreteIPReg 
		withOffset: 0).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRXbrR [

	"Write the byte in R(src) into memory at address (base + word size * index)"

		<inline: true>
	| indexReg baseReg srcReg |
	self flag: #TODO.
	srcReg := operands at: 0.
	indexReg := operands at: 1. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 2.	
	"No need to shift for a byte!"
	"Add the offset to the base address register"
	self machineCodeAt: 0 put: (self 
		addRegister: indexReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Store the value"
	self machineCodeAt: 4 put: (self 
		storeByteFromRegister: srcReg 
		toAddressInRegister: ConcreteIPReg 
		withOffset: 0).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRXwrR [

	"Write the word in R(src) into memory at address (base + word size * index)"

		<inline: true>
	| indexReg baseReg srcReg |
	self flag: #TODO.
	srcReg := operands at: 0.
	indexReg := operands at: 1. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 2.	
	"Shift by 3 (*8) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 3 
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Store the value"
	self machineCodeAt: 8 put: (self 
		storeDoubleWordFromRegister: srcReg 
		toAddressInRegister: ConcreteIPReg 
		withOffset: 0).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRdM64r [

	"Store double-precision floating-point number in register to base+offset"

	<inline: true>
	| offset baseReg srcReg loadOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent ifNil: [ 
		self assertValue: offset isContainedIn: 12.
		self machineCodeAt: 0 put: (self
				 fStoreDoubleWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
		^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self
			 addRegister: baseReg
			 toRegister: ConcreteIPReg
			 inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 fStoreDoubleWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRdR [

	"fmv.x.d: Floating point move doubleword to integer,
    copies the double-precision floating-point number in register f[rs1] to x[rd]"

	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := operands at: 0.
	destReg := operands at: 1.
	self
		machineCodeAt: 0
		put: (self fMoveDoubleWordInFRegister: srcReg toXRegister: destReg).
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveRsM32r [

	"Store single-precision floating-point number in register to base+offset"

	<inline: true>
	| offset baseReg srcReg loadOffset |
	self flag: #TODO.
	srcReg := operands at: 0.
	offset := operands at: 1.
	baseReg := operands at: 2.
	dependent ifNil: [ 
		self assertValue: offset isContainedIn: 12.
		self machineCodeAt: 0 put: (self
				 fStoreWordFromRegister: srcReg
				 toAddressInRegister: baseReg
				 withOffset: offset).
		^ machineCodeSize := 4 ].
	"Use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Add the offset to the base address register"
	self machineCodeAt: loadOffset put: (self
			 addRegister: baseReg
			 toRegister: ConcreteIPReg
			 inRegister: ConcreteIPReg).
	"Load the value"
	self machineCodeAt: loadOffset + 4 put: (self
			 fStoreWordFromRegister: srcReg
			 toAddressInRegister: ConcreteIPReg
			 withOffset: 0).
	^ machineCodeSize := loadOffset + 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveX32rRR [

	"Read a half word in in memory at address (base + word size *index) into R(dest)"

	<inline: true>
	| indexReg baseReg destReg |
	self flag: #TODO.
	indexReg := operands at: 0. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 1.
	destReg := operands at: 2.
	"Shift by 2 (*4) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 2 
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Load the value"
	self machineCodeAt: 8 put: (self 
		loadUnsignedWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0 
		toRegister: destReg).
	^ machineCodeSize := 12
	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveXbrRR [

	"Read a byte in in memory at address (base + word size *index) into R(dest)"

	<inline: true>
	| indexReg baseReg destReg |
	self flag: #TODO.
	indexReg := operands at: 0. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 1.
	destReg := operands at: 2.
	"No need to shift for a byte!"
	"Add the offset to the base address register"
	self machineCodeAt: 0 put: (self 
		addRegister: indexReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Load the value"
	self machineCodeAt: 4 put: (self 
		loadUnsignedByteFromAddressInRegister: ConcreteIPReg 
		withOffset: 0 
		toRegister: destReg).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMoveXwrRR [
	
	"Read a word in in memory at address (base + word size *index) into R(dest)"

	<inline: true>
	| indexReg baseReg destReg |
	self flag: #TODO.
	indexReg := operands at: 0. "index is number of words = size of word * bytes, in 64 bits -> * 8"
	baseReg := operands at: 1.
	destReg := operands at: 2.
	"Shift by 3 (*8) the index reg"
	self machineCodeAt: 0 put: (self 
		shiftLeftValueInRegister: indexReg 
		byShiftAmount: 3
		intoRegister: ConcreteIPReg).
	"Add the offset to the base address register"
	self machineCodeAt: 4 put: (self 
		addRegister: ConcreteIPReg 
		toRegister: baseReg 
		inRegister: ConcreteIPReg). 
	"Load the value"
	self machineCodeAt: 8 put: (self 
		loadDoubleWordFromAddressInRegister: ConcreteIPReg 
		withOffset: 0 
		toRegister: destReg).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMulRR [ 

	<inline:true>
	| srcReg1 srcReg2 destReg | 
	self flag: #TODO.
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Multiply the two registers and store the higher half in a temp register (here overflow 1)
	 Note that the mul high is performed first to avoid overwriting one operand (2-address code here)"
	self machineCodeAt: 0 put: (self 
		multiplyHighRegisterValue: srcReg1
		byRegisterValue: srcReg2
		inRegister: ConcreteIPReg
	).
	
	"Multiply and store the lower part in the destination register"
	self machineCodeAt: 4 put: (self 
		multiplyRegisterValue: srcReg1
		byRegisterValue: srcReg2 
		inRegister: destReg
	).
			
	"Create a temp register to be either all 0s or all 1s depending on the result sign
	 An arithmetic shift of 63 on the result will produce such a value"
	self machineCodeAt: 8 put: (self
		arithmeticShiftRightValueInRegister: destReg
		byShiftAmount: 63
		intoRegister: ConcreteOverflowReg
	).
	"Compare the high result to the 'sign' reg -> if equal no overflow.
	 First sub then set one if not equal to zero!"
	self machineCodeAt: 12 put: (self
		subtractRegister: ConcreteIPReg 
		fromRegister: ConcreteOverflowReg 
		intoRegister: ConcreteOverflowReg 
	).
	"Set one if the result is not null (i.e. not equal -> overflow)"
	self machineCodeAt: 16 put: (self
		setOneIn: ConcreteOverflowReg 
		ifValueInRegisterIsNotEqualToZero: ConcreteOverflowReg 
	).
	"Update the sign flag"
	self machineCodeAt: 20 put: (self
		setOneIn: ConcreteSignReg 
		ifValueIn: destReg 
		isLessThanImmediate: 0
	).
	"Update the zero flag"
	self machineCodeAt: 24 put: (self
		setOneIn: ConcreteZeroReg 
		ifValueInRegisterIsEqualToZero: destReg
	).
^ machineCodeSize := 28
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeMulRdRd [

	"Perform a floating-point double precision sub operation between the value of register and the value of another register"

	<inline: true>
	| destReg sourceReg1 sourceReg2 flagOffset |
	self flag: #TODO.
	sourceReg1 := operands at: 0.
	sourceReg2 := destReg := operands at: 1.
	"Carry flag: Carry in FP is a simple comparison (note that 0 will be put if any of the two is NaN)"		
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteCarryReg  
		ifRegisterValue: sourceReg2 
		isLessThanRegisterValue: sourceReg1
	).	
	"Perform MUL operation"
	self machineCodeAt: 4 put: (self fMultiplyRegister: sourceReg2 fromRegister: sourceReg1 intoRegister: destReg).
	^ machineCodeSize := 8 
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeNegateR [

	<inline: true>
	| srcReg destReg flagOffset |
	self flag: #TODO.
	srcReg := destReg := operands at: 0.
	"Perform a SUB operation with X0"
	self machineCodeAt: 0 put: (self negateValueInRegister: srcReg intoRegister: destReg).
	"Update flags"
	"flagOffset := self machineCodeWriteInstructions: (self
			updateFlagsArithmeticForSourceReg1: srcReg 
			sourceReg2: X0 
			andResultReg: destReg
		) startingAtIndex: 4."
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeNop [

	<inline: true>
	self flag: #DONE.
	self machineCodeAt: 0 put: self nop.
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeOrCqR [

	"Perform a bitwise or between the value of register and the value of the operand.
	
	 If the operand fits in under 12 bits:
		ori reg, reg, cq
		
	 Else load the provided literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		or reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset |
	self flag: #TODO.
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 bitwiseOrBetweenRegister: sourceReg
				 andImmediate: cq
				 toRegister: destReg).
		"Update flags"
		flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].


	"Literal -> compute the distance, load the actual value then and between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the OR operation"
	self machineCodeAt: loadOffset put: (self
			 bitwiseOrBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	"Update the flags according to a logic operation"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeOrCwR [
	
	<inline: true>
	| sourceReg destReg loadOffset flagOffset |
	self flag: #TODO.
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.	
	"Load Cw in register then perform the add"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the OR operation"
	self machineCodeAt: loadOffset put: (self
	      	 bitwiseOrBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 toRegister: destReg).
	"Update the flags"
	flagOffset :=  self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4	
			
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeOrRR [

	<inline: true>
	| sourceReg1 sourceReg2 destReg flagOffset |
	self flag: #DONE.
	sourceReg1 := operands at: 0.
	sourceReg2 := destReg := operands at: 1.
	"Perform the OR operation"
	self machineCodeAt: 0 put: (self bitwiseOrBetweenRegister: sourceReg1 andRegister: sourceReg2 toRegister: destReg).
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
	^ machineCodeSize := flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizePopR [
	
	"Load the content of the stack pointer in the given register then decrease (+8 because downwards) the stack pointer.
	   ld destReg, 0(sp)
	   addi sp, sp, 8
	"

	<inline: true>
	| destReg offset |
	self flag: #TODO.
	destReg := operands at: 0.
	offset := self computeSignedValueOf: 8 ofSize: 12.
	self machineCodeAt: 0 put: (self loadDoubleWordFromAddressInRegister: SPReg withOffset: 0 toRegister: destReg).	
	self machineCodeAt: 4 put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizePrefetchAw [
	"Will get inlined into concretizeAt: switch."

	<inline: true>
	self flag: #TODO.
	"No prefetch routine at the point of writing"
	^ machineCodeSize := 0.
	
	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizePushCq [

	"Push (store) a double word at the position of the stack pointer if the constant is not a literal
		li  ConcreteIPReg, cq 
		addi sp, sp, -8
		sd  ConcreteIPReg, 0(sp)
	
	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
	   addi sp, sp, -8
	   sd  ConcreteIPReg, 0(sp)
		"
	<var: #cq type: #sqInt>
	<inline: true>
	| cq instrOffset offset |
	self flag: #DONE.
	cq := operands at: 0.
	dependent
		ifNil: [ 
			"No literal -> Direct load into a scratch register, number of instructions depends on immediate size"
			instrOffset := self loadImmediate: cq inRegister: ConcreteIPReg ]
		ifNotNil: [ 
			"Literal -> Compute the distance from the current address and add auipc then ld instructions"
			instrOffset := self loadLiteralInRegister: ConcreteIPReg ].
	
	"Push the loaded value to the stack"
	offset := self computeSignedValueOf: -8 ofSize: 12.
	self machineCodeAt: instrOffset put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
   self machineCodeAt: instrOffset + 4 put: (self storeDoubleWordFromRegister: ConcreteIPReg toAddressInRegister: SPReg withOffset: 0).

	^ machineCodeSize := instrOffset + 8 
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizePushCw [

	"Will get inlined into concretizeAt: switch."

	<inline: true>
	| word instrOffset offset |
	self flag: #TODO.
	word := operands at: 0.
	instrOffset := self loadCwInto: ConcreteIPReg.
	offset := self computeSignedValueOf: -8 ofSize: 12.
	self machineCodeAt: instrOffset put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
   self machineCodeAt: instrOffset + 4 put: (self storeDoubleWordFromRegister: ConcreteIPReg toAddressInRegister: SPReg withOffset: 0).
	^ machineCodeSize := instrOffset + 8 
	 
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizePushR [

	"Store the content of a register at the position of the stack pointer	  
		addi sp, sp, -8
		sd   srcReg, 0(sp)"
		
	<inline: true>
	| srcReg offset |
	self flag: #DONE.	
	srcReg := operands at: 0.
	offset := self computeSignedValueOf: -8 ofSize: 12.
	self machineCodeAt: 0 put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
   self machineCodeAt: 4 put: (self storeDoubleWordFromRegister: srcReg toAddressInRegister: SPReg withOffset: 0).
	^ machineCodeSize := 8
	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeRemRR [ 

	<inline: true>
	| regNumerator regDenominator regDestination |
	self flag: #TODO.
	regNumerator := operands at: 0.
	regDenominator := operands at: 1.
	regDestination := operands at: 2. 
	"Perform the DIV operation (signed division) for the remainder"
	self machineCodeAt: 0 put: (self 
		remainderOfDivisionRegisterValue: regNumerator 
		byRegisterValue: regDenominator  
		inRegister: regDestination).
	"
	flagOffset := self machineCodeWriteInstructions: (self
			updateFlagsArithmeticForSourceReg1: regNumerator 
			sourceReg2: regDenominator 
			andResultReg: regDestination
		) startingAtIndex: 4."
		
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeRetN [

	"Jumps to the address stored in the Link Register + a given offset.
	(ret)  jalr, x0, 0(x1)
	"
	<var: #offset type: #sqInt>
	<inline: true>
	| offset |
	self flag: #DONE.
	offset := operands at: 0.
	offset = 0
	   ifTrue: [ self machineCodeAt: 0 put: self ret.
		          ^ machineCodeSize := 4 ].
	self machineCodeAt: 0 put: (self addImmediate: offset toRegister: SPReg inRegister: SPReg).
	self machineCodeAt: 4 put: self ret.
	^ machineCodeSize := 8
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeRotateLeftCqR [

	"Perform a rotate left between the value of register and the value of the operand.
	
	 If the operand is not a literal:
		roli reg, reg, cq

	 Otherwise load the value in a register:
		li ConcreteIPReg, cq 
		rol reg, reg, ConcreteIPReg 

	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		rol reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg srcReg loadOffset rotateOffset flagOffset |
	self flag: #TODO.
	cq := operands at: 0.
	srcReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		rotateOffset := self
			                rotateLeftValueInRegister: srcReg
			                byShiftAmount: cq
			                inRegister: destReg
			                startingAtIndex: 0.
		"Update the flags"
		flagOffset := self
			              updateFlagsLogicForResultReg: destReg
			              startingAtIndex: rotateOffset.
		^ machineCodeSize := rotateOffset + flagOffset ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the different ROT operations"
	rotateOffset := self
		                rotateLeftValueInRegister: srcReg
		                byShiftAmountInRegister: ConcreteIPReg
		                inRegister: destReg
		                startingAtIndex: loadOffset.
	"Update the flags"
	flagOffset := self
		              updateFlagsLogicForResultReg: destReg
		              startingAtIndex: loadOffset + rotateOffset.
	^ machineCodeSize := loadOffset + rotateOffset + flagOffset
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeRotateRightCqR [

	"Perform a rotate right between the value of register and the value of the operand.
	
	 If the operand is not a literal:
		rori reg, reg, cq

	 Otherwise load the value in a register:
		li ConcreteIPReg, cq 
		ror reg, reg, ConcreteIPReg 

	 If it is a literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		ror reg, reg, ConcreteIPReg 
		"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg srcReg loadOffset rotateOffset flagOffset |
	self flag: #TODO.
	cq := operands at: 0.
	srcReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self value: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		rotateOffset := self
			                rotateRightValueInRegister: srcReg
			                byShiftAmount: cq
			                inRegister: destReg
			                startingAtIndex: 0.
		"Update the flags"
		flagOffset := self
			              updateFlagsLogicForResultReg: destReg
			              startingAtIndex: rotateOffset.
		^ machineCodeSize := rotateOffset + flagOffset ].
	"Otherwise use the provided literal"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the different ROT operations"
	rotateOffset := self
		                rotateRightValueInRegister: srcReg
		                byShiftAmountInRegister: ConcreteIPReg
		                inRegister: destReg
		                startingAtIndex: loadOffset.
	"Update the flags"
	flagOffset := self
		              updateFlagsLogicForResultReg: destReg
		              startingAtIndex: loadOffset + rotateOffset.
	^ machineCodeSize := loadOffset + rotateOffset + flagOffset
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeSqrtRd [

	"Square root of FP"

	<inline: true>
	| srcReg destReg |
	self flag: #TODO.
	srcReg := destReg := operands at: 0.
	self machineCodeAt: 0 put: (self fSquareRootOfRegister: srcReg inRegister: destReg).
	^ machineCodeSize := 4	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeStop [
	
	"Makes a request to the debugger by generating an ebreak instruction"
	
	<inline: true>
	self flag: #DONE.
	self machineCodeAt: 0 put: self stop.
	^ machineCodeSize := 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeSubCqR [

	"Perform a sub operation between the value of register and the value of the operand.
	 Since no subi exist in RISC-V, it simply calls addcq with the negated operand."

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset overflowOffset |
	self flag: #TODO.
	cq := operands at: 0.
	operands at: 0 put: cq negated.
	
	
	^ self concretizeAddCqR 
	
	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeSubCwR [

	<inline: true>
	| sourceReg destReg loadOffset flagOffset overflowOffset |
	self flag: #TODO.
	self assert: dependent notNil.
	sourceReg := destReg := operands at: 1.

	"Load Cw in register then perform the add"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.

	"Perform the SUB operation to a temp register (as operands AND result are needed for overflow check)"
	self machineCodeAt: loadOffset put: (self
			 subtractRegister: ConcreteIPReg
			 fromRegister: sourceReg
			 intoRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkSUBOverflowWithSourceReg1: sourceReg
		                  sourceReg2: ConcreteIPReg
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: loadOffset + 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsSUBForSourceReg: sourceReg
		              resultReg: ConcreteZeroReg
		              andMoveResultTo: destReg
		              startingAtIndex: loadOffset + overflowOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + overflowOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeSubRR [

	"Perform a sub operation between the value of register and the value of another register.	"

	<inline: true>
	| destReg rightReg leftReg flagOffset overflowOffset |
	self flag: #TODO.
	rightReg := operands at: 0.
	leftReg := destReg := operands at: 1.

	"Perform the SUB operation"
	self machineCodeAt: 0 put: (self
			 subtractRegister: rightReg
			 fromRegister: leftReg
			 intoRegister: ConcreteZeroReg).

	"Check for overflow"
	overflowOffset := self
		                  checkSUBOverflowWithSourceReg1: leftReg
		                  sourceReg2: rightReg
		                  andResultReg: ConcreteZeroReg
		                  startingAtIndex: 4.

	"Update flag registers"
	flagOffset := self
		              updateFlagsSUBForSourceReg: leftReg
		              resultReg: ConcreteZeroReg
		              andMoveResultTo: destReg
		              startingAtIndex: overflowOffset + 4.
	^ machineCodeSize := flagOffset + overflowOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeSubRdRd [

	"Perform a floating-point double precision sub operation between the value of register and the value of another register.	"

	<inline: true>
	| destReg rightReg leftReg flagOffset overflowOffset |
	self flag: #TODO.
	rightReg := operands at: 0.
	leftReg := destReg := operands at: 1.
	
	"Carry flag: Carry in FP is a simple comparison (note that 0 will be put if any of the two is NaN)"		
	self machineCodeAt: 0 put: (self 
		fSetOneIn: ConcreteCarryReg  
		ifRegisterValue: leftReg 
		isLessThanRegisterValue: rightReg
	).	

	"Perform SUB operation"
	self machineCodeAt: 4 put: (self fSubtractRegister: rightReg fromRegister: leftReg intoRegister: ConcreteIPFPReg2).

	"Check for overflow"
	overflowOffset := self 
		checkSUBFloatingPointOverflowWithSourceReg1: leftReg 
		sourceReg2: rightReg 
		andResultReg: ConcreteIPFPReg2
	   startingAtIndex: 8.

	"Move result to destination"
	self machineCodeAt: overflowOffset + 8 put: (self 
		fMoveDoubleWordInFRegister: ConcreteIPFPReg2 
		toFRegister: destReg		 
	).
	^ machineCodeSize := overflowOffset + 12
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeTstCqR [

	"Perform a cmp operation (sub discarding the result) and between the value of register and the value of the operand.
	 The result is discarded. The instruction is used with a Jump next to it, for example: TstCqR JumpEquals(label) .
	 No immediate possibility because no subi instruction exists.

	 If the operand fits in 12 bits:
		andi ConcreteFlagReg, reg, cq

		(beq ConcreteFlagReg, ConcreteIPReg, label)
	
	 Else load the provided literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		and  ConcreteFlagReg, ConcreteIPReg, reg 
		
		(beq ConcreteFlagReg, ConcreteIPReg, label)"

	<var: #cq type: #sqInt>
	<inline: true>
	| srcReg cq loadOffset flagOffset |
	self flag: #TODO.
	cq := operands at: 0.
	srcReg := operands at: 1.
	dependent ifNil: [ "If the cq fits in 12 bits, encode it directly"
		self assertValue: cq abs isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 bitwiseAndBetweenRegister: srcReg
				 andImmediate: cq
				 toRegister: ConcreteZeroReg).
		"Update flag registers, here no difference between immediate or not"
		flagOffset := self updateFlagsLogicForResultReg: ConcreteZeroReg startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].
	"Literal -> compute the distance, load the actual value then and between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	self machineCodeAt: loadOffset put: (self
			 bitwiseAndBetweenRegister: srcReg
			 andRegister: ConcreteIPReg
			 toRegister: ConcreteZeroReg).
	"Check and update the flags"
	flagOffset := self updateFlagsLogicForResultReg: ConcreteZeroReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeXorCqR [

	"Perform a xor operation between the value of register and the value of the operand.
	
	 If the operands fits in 12 bits:
		xori reg, reg, cq
			
	 Else load the provided literal:
	   auipc ConcreteIPReg, 0
	   ld ConcreteIPReg, cqdistance(ConcreteIPReg)
		xor reg, reg, ConcreteIPReg"

	<var: #cq type: #sqInt>
	<inline: true>
	| cq destReg sourceReg loadOffset flagOffset |
	self flag: #DONE.
	cq := operands at: 0.
	sourceReg := destReg := operands at: 1.
	dependent ifNil: [ 
		self assertValue: cq isContainedIn: 12.
		"Direct encoding as an immediate"
		self machineCodeAt: 0 put: (self
				 bitwiseXorBetweenRegister: sourceReg
				 andImmediate: cq
				 intoRegister: destReg).
		flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
		^ machineCodeSize := flagOffset + 4 ].

	"Literal -> compute the distance, load the actual value then XOR between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.

	"Perform the XOR operation"
	self machineCodeAt: loadOffset put: (self
			 bitwiseXorBetweenRegister: sourceReg
			 andRegister: ConcreteIPReg
			 intoRegister: destReg).
	"Update the affected flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeXorCwR [

	"XOR operation after loading the value in a register"

		
	<inline: true>
	| destReg sourceReg loadOffset flagOffset |
	self flag: #TODO.		
	self assert: dependent isNotNil.
	sourceReg := destReg := operands at: 1.
   "Literal -> compute the distance, load the actual value then xor between the 2 registers"
	loadOffset := self loadLiteralInRegister: ConcreteIPReg.
	"Perform the XOR operation"
	self machineCodeAt: loadOffset put: (self
					bitwiseXorBetweenRegister: sourceReg  
					andRegister: ConcreteIPReg 
					intoRegister: destReg).
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: loadOffset + 4.
	^ machineCodeSize := loadOffset + flagOffset + 4
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeXorRR [ 
	
	<inline: true>
	| srcReg1 srcReg2 destReg flagOffset |
	self flag: #TODO.
	srcReg1 := operands at: 0.
	srcReg2 := destReg := operands at: 1.
	"Perform the XOR operation"
	self machineCodeAt: 0 put: (self bitwiseXorBetweenRegister: srcReg1 andRegister: srcReg2 intoRegister: destReg).
	"Update the flags"
	flagOffset := self updateFlagsLogicForResultReg: destReg startingAtIndex: 4.
	^ machineCodeSize := flagOffset + 4
	
]

{ #category : #concretization }
CogRiscV64Compiler >> concretizeXorRdRd [
	
	"This concretization is only used in the primitive small float to zero out a register. 
	 Rather than using this, we will convert X0 (hardwired 0) to the corresponding register"
	<inline: true>
	| srcReg1 srcReg2 |
	self flag: #TODO.
	srcReg1 := operands at: 0.
	srcReg2 := operands at: 1.
	self assert: (srcReg1 = srcReg2).
	self machineCodeAt: 0 put: (self fConvertLongSignedInRegister: X0 toDoublePrecisionInRegister: srcReg1).
	^ machineCodeSize := 4
	
]

{ #category : #concretization }
CogRiscV64Compiler >> dispatchConcretize [
	"Attempt to generate concrete machine code for the instruction at address.
	 This is the inner dispatch of concretizeAt: actualAddress which exists only
	 to get around the branch size limits in the SqueakV3 (blue book derived)
	 bytecode set."
	<returnTypeC: #void>
	self flag: #TODO.
	opcode caseOf: {
		"Noops & Pseudo Ops"
		[Label]			 -> [ ^ self concretizeLabel ].
		[Literal]		 	 -> [ ^ self concretizeLiteral ].
		[AlignmentNops]	 -> [ ^ self concretizeAlignmentNops ].
		[Fill32]			 -> [ ^ self concretizeFill32 ].
		[Nop]				 -> [ ^ self concretizeNop ].
		"Branches"
		[ BrEqualRR ]      -> [ ^self concretizeBrEqualRR ].
		"Control"
		[Call]					-> [ ^ self concretizeCall ]. "call code within code space"
		[CallFull]			-> [ ^ self concretizeCallFull ]. "call code anywhere in address space"
		[JumpR]				-> [ ^ self concretizeJumpR ].
		[JumpFull]			-> [ ^ self concretizeJumpFull ]."jump within address space"
		[JumpLong]			-> [ ^ self concretizeJumpLong ]."jumps witihn code space"
		[JumpLongZero]	   -> [ ^ self concretizeJumpLongZero ].
		[JumpLongNonZero]	-> [ ^ self concretizeJumpLongNonZero ].
		[Jump]				   -> [ ^ self concretizeJump ].
		[JumpZero]			-> [ ^ self concretizeJumpZero ].
		[JumpNonZero]		-> [ ^ self concretizeJumpNonZero ].
		[JumpNegative]		-> [ ^ self concretizeJumpNegative ].
		[JumpNonNegative]	-> [ ^ self concretizeJumpNonNegative ].
		[JumpOverflow]		-> [ ^ self concretizeJumpOverflow ].
		[JumpNoOverflow]	-> [ ^ self concretizeJumpNoOverflow ].
		[JumpCarry]			-> [ ^ self concretizeJumpCarry ].
		[JumpNoCarry]		-> [ ^ self concretizeJumpNoCarry ].
		[JumpLess]			-> [ ^ self concretizeJumpLess ].
		[JumpGreaterOrEqual]	-> [ ^ self concretizeJumpGreaterOrEqual ].
		[JumpGreater]			-> [ ^ self concretizeJumpLongGreater ].
		[JumpLessOrEqual]		-> [ ^ self concretizeJumpLessOrEqual ].
		[JumpBelow]				-> [ ^ self concretizeJumpBelow ]. "unsigned lower"
		[JumpAboveOrEqual]		-> [ ^ self concretizeJumpAboveOrEqual ]. "unsigned greater or equal"
		[JumpAbove]				-> [ ^ self concretizeJumpAbove ].
		[JumpBelowOrEqual]		-> [ ^ self concretizeJumpBelowOrEqual ].
		[JumpFPEqual]			-> [ ^ self concretizeJumpFPEqual ].
		[JumpFPNotEqual]		-> [ ^ self concretizeJumpFPNotEqual ].
		[JumpFPLess]				-> [ ^ self concretizeJumpFPLess ].
		[JumpFPGreaterOrEqual]	-> [ ^ self concretizeJumpFPGreaterOrEqual ].
		[JumpFPGreater]				-> [ ^ self concretizeJumpFPGreater ].
		[JumpFPLessOrEqual]		-> [ ^ self concretizeJumpFPLessOrEqual ].
		[JumpFPOrdered]				-> [ ^ self concretizeJumpFPOrdered ].
		[JumpFPUnordered]			-> [ ^ self concretizeJumpFPUnordered ].
		[RetN]	 -> [ ^ self concretizeRetN ].
		[Stop]	 -> [ ^ self concretizeStop ].
							
		"Logic"						
		[AndCqR]		-> [ ^ self concretizeAndCqR ].
		[AndCqRR]		-> [ ^ self concretizeAndCqRR ].
		[OrCqR]		-> [ ^ self concretizeOrCqR ].
		[TstCqR]		-> [ ^ self concretizeTstCqR ].
		[XorCqR]		-> [ ^ self concretizeXorCqR ].	
		
		"Arithmetic"				
		[AddCqR]	 -> [ ^ self concretizeAddCqR ].
		[CmpCqR]	 -> [ ^ self concretizeCmpCqR ].
		[SubCqR]	 -> [ ^ self concretizeSubCqR ].
		[CmpC32R]	 -> [ ^ self concretizeCmpC32R ].
		[LoadEffectiveAddressMwrR]	-> [ ^ self concretizeLoadEffectiveAddressMwrR ].

		"Arithmetic with an ensured literal load"
		[AddCwR]	-> [^self concretizeAddCwR ].
		[AndCwR]	-> [^self concretizeAndCwR ].
		[CmpCwR]	-> [^self concretizeCmpCwR ].
		[OrCwR]	-> [^self concretizeOrCwR ].
		[SubCwR]	-> [^self concretizeSubCwR ].
		[XorCwR]	-> [^self concretizeXorCwR].
		
		"Arithmetic Register-only"
		[AddRR]	 -> [ ^ self concretizeAddRR ].
		[AndRR]	 -> [ ^ self concretizeAndRR ].
		[CmpRR]	 -> [ ^ self concretizeCmpRR ].
		[OrRR]		 -> [ ^ self concretizeOrRR ].
		[SubRR]	 -> [ ^ self concretizeSubRR ].
		[XorRR]	 -> [ ^ self concretizeXorRR ].
		[MulRR] 	 -> [ ^ self concretizeMulRR ].
		[DivRR]	 -> [ ^ self concretizeDivRR ].
		[RemRR]  	 -> [ ^ self concretizeRemRR ].
		[NegateR]	 -> [ ^ self concretizeNegateR ].
		
		"Bit shifts"
		[LogicalShiftRightCqR]   	-> [ ^ self concretizeLogicalShiftRightCqR ].
		[LogicalShiftLeftCqR]			-> [ ^ self concretizeLogicalShiftLeftCqR ].
		[LogicalShiftLeftRR]			-> [ ^ self concretizeLogicalShiftLeftRR ].
		[LogicalShiftRightRR]			-> [ ^ self concretizeLogicalShiftRightRR ].
		[ArithmeticShiftRightRR]		-> [ ^ self concretizeArithmeticShiftRightRR ].
		[ArithmeticShiftRightCqR]	-> [ ^ self concretizeArithmeticShiftRightCqR ].

		"Rotates"
		[RotateLeftCqR]  ->	[ ^ self concretizeRotateLeftCqR ].
		[RotateRightCqR] ->	[ ^ self concretizeRotateRightCqR ].
		
		"Floating point operations"
		[AddRdRd] -> [ ^ self concretizeAddRdRd ].
		[CmpRdRd]	 -> [ ^ self concretizeCmpRdRd ].
		[DivRdRd]	 -> [ ^ self concretizeDivRdRd ].
		[MulRdRd]	 -> [ ^ self concretizeMulRdRd ].
		[SubRdRd]	 -> [ ^ self concretizeSubRdRd ].
		[SqrtRd]	 -> [ ^ self concretizeSqrtRd ].
		[XorRdRd]	 -> [ ^ self concretizeXorRdRd ].

		"Data Movement - basic"
		[MoveCqR]			-> [^self concretizeMoveCqR].
		[MoveCwR]			-> [^self concretizeMoveCwR].
		[MoveC32R]		-> [^self concretizeMoveC32R].
		[MoveRR]			-> [^self concretizeMoveRR].
		
		"Data Movement - Absolute addresses"
		[MoveAwR]			-> [ ^ self concretizeMoveAwR ].
		[MoveRAw]			-> [ ^ self concretizeMoveRAw ].
		[MoveAbR] 		-> [ ^ self concretizeMoveAbR ].
 		[MoveRAb]			-> [ ^ self concretizeMoveRAb ].
			
		"Data Movement - Stores"
		[MoveRM8r]		-> [ ^ self concretizeMoveRMbr ].
		[MoveRMbr]		-> [ ^ self concretizeMoveRMbr ].
		[MoveRM16r]		-> [ ^ self concretizeMoveRM16r ].
		[MoveRM32r]		-> [ ^ self concretizeMoveRM32r ].
		[MoveRMwr]		-> [ ^ self concretizeMoveRMwr ].
		[MoveRsM32r]		-> [ ^ self concretizeMoveRsM32r ].
		[MoveRdM64r]		-> [ ^ self concretizeMoveRdM64r ].
	
		"Data Movement - Loads"
		[MoveM8rR]    	-> [ ^ self concretizeMoveMbrR ].
		[MoveMbrR]		-> [ ^ self concretizeMoveMbrR ].		
		[MoveM16rR]		-> [ ^ self concretizeMoveM16rR ].
		[MoveM32rR]		-> [ ^ self concretizeMoveM32rR ].
		[MoveMwrR]		-> [ ^ self concretizeMoveMwrR ].
		[MoveM32rRs]		-> [ ^ self concretizeMoveM32rRs ].
		[MoveM64rRd]		-> [ ^ self concretizeMoveM64rRd ].
		
		"Data Movement - Relative Addresses with multiply"
		[MoveXbrRR]		-> [ ^ self concretizeMoveXbrRR].
		[MoveX32rRR]		-> [ ^ self concretizeMoveX32rRR].
		[MoveXwrRR]		-> [ ^ self concretizeMoveXwrRR].	
		[MoveRXbrR]		-> [ ^ self concretizeMoveRXbrR].
		[MoveRX32rR]		-> [ ^ self concretizeMoveRX32rR].
		[MoveRXwrR]		-> [ ^ self concretizeMoveRXwrR].
			
		"Pop/Push"
		[PopR]				-> [ ^ self concretizePopR ].
		[PushR]		 	-> [ ^ self concretizePushR ].
		[PushCq]			-> [ ^ self concretizePushCq ].
		[PushCw]			-> [ ^ self concretizePushCw ].
		[PrefetchAw]		-> [ ^ self concretizePrefetchAw ].
			
		"Conversion"
		[ConvertRdRs]	-> [ ^ self concretizeConvertRdRs ].
		[ConvertRsRd]	-> [ ^ self concretizeConvertRsRd ].
		[ConvertRRd]		-> [ ^ self concretizeConvertRRd ].
		[MoveRdR]			-> [ ^ self concretizeMoveRdR ].
		[MoveRRd]			-> [ ^ self concretizeMoveRRd ].
		
		"Patcheable literal instruction"
		[ MovePatcheableC32R ] -> [ ^ self concretizeMovePatcheableC32R ]
		}
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> divideRegisterValue: srcReg1 byRegisterValue: srcReg2 intoRegister: destReg [

	"div: Divides x[rs1] by x[rs2], rounding towards zero, treating the values as two's complement numbers 
			and writes the quotient to x[rd]

	 31      25 24   20 19    15 14   12 11     7 6         0
	| 0000001  |  rs2  |  rs1   |  100  |   rd   |  0110011  |
	"

	self flag: #DONE.
	"Actual bit instruction"
	^ (((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r100 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 

]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> divideRegisterValueUnsigned: srcReg1 byRegisterValueUnsigned: srcReg2 intoRegister: destReg [

	"divu: Divides x[rs1] by x[rs2], rounding towards zero, treating the values as unsigned numbers 
			and writes the quotient to x[rd]

	 31      25 24   20 19    15 14   12 11     7 6         0
	| 0000001  |  rs2  |  rs1   |  101  |   rd   |  0110011  |
	"

	self flag: #DONE.
	"Actual bit instruction"
	^ (((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 

]

{ #category : #'instruction extraction' }
CogRiscV64Compiler >> extractConditionFromZeroConditionalBranch: instruction [ 

	self flag: #TODO.
	^ instruction >> 12 bitAnd: 16r7
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> extractOffsetFromAUIPC: instruction [ 

	self flag: #TODO.
	^ self signExtendValue: ((instruction >> 12) bitAnd: 16rFFFFF) << 12 forSize: 32
]

{ #category : #'instruction extraction' }
CogRiscV64Compiler >> extractOffsetFromCall: callAddress [ 

	| instAUIPC offsetAUIPC instJALR offsetJALR |
	"A call consists of auipc + jalr"
	self flag: #TODO.	
	"AUIPC"
	instAUIPC := objectMemory long32At: callAddress - 4.
	self assert: (self instructionIsAUIPC: instAUIPC).
	offsetAUIPC := self extractOffsetFromAUIPC: instAUIPC.
	"JALR"
	instJALR := objectMemory long32At: callAddress.
	self assert: (self instructionIsJALR: instJALR).
	offsetJALR := self extractOffsetFromJALR: instJALR.
	
	^ offsetAUIPC + offsetJALR
]

{ #category : #'instruction extraction' }
CogRiscV64Compiler >> extractOffsetFromConditionalBranch: instruction [ 

	"Branch instruction encode the offset from bits 31->25 as 12|10:5 
	                                  and from bits 11->7  as 4:1|11"
	| offset1 offset2 |
	self flag: #TODO.
	offset1 := instruction >> 7 bitAnd: 16r1F.
	offset2 := instruction >> 25 bitAnd: 16r7F.
	^ ((((offset1 >> 6 bitAnd: 16r1) << 12) "12"
	  bitOr: ((offset2 bitAnd: 16r1) << 11)) "11"
	  bitOr: ((offset2 bitAnd: 16r3F) << 5)) "10:5"
	  bitOr: ((offset1 >> 1 bitAnd: 16rF) << 1) "4:1"
	  
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> extractOffsetFromJAL: instruction [ 

	| offset |
	self flag: #TODO.
	"JAL encodes the offset from bits 31 to 12 as: offset[20|10:1|11|19:12]"
	offset := instruction >> 12.
	^ (((((offset >> 19 bitAnd: 16r1) << 20) "20"
	  bitOr: ((offset >> 9 bitAnd: 16r3FF) << 1)) "10:1"
	  bitOr: ((offset >> 8 bitAnd: 16r1) << 11)) "11"
	  bitOr: ((offset bitAnd: 16rFF) << 12)) "19:12"
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> extractOffsetFromJALR: instruction [ 

	self flag: #TODO.
	^ self signExtendValue: ((instruction >> 20) bitAnd: 16rFFF) forSize: 12
]

{ #category : #'instruction extraction' }
CogRiscV64Compiler >> extractOffsetFromLongJump: jumpAddress [ 

	| instLUI offsetLUI instADDIW offsetADDIW |
	"A long jump expands to offset loading + jump register 
	 and the offset loading expands to lui + addiw (we need to go other the jump to reach those"
	self flag: #TODO.	
	"LUI"
	instLUI := objectMemory long32At: jumpAddress - 8.
	self assert: (self instructionIsLUI: instLUI).
	offsetLUI := self signExtendValue: (instLUI >> 12 bitAnd: 16rfffff) << 12 forSize: 32. "20 upper bits"
	"ADDIW"
	instADDIW := objectMemory long32At: jumpAddress - 4.
	self assert: (self instructionIsADDI: instADDIW).
	offsetADDIW := self signExtendValue: (instADDIW >> 20 bitAnd: 16rfff) forSize: 12. "12 lower bits"
	
	^ offsetLUI + offsetADDIW
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fAddRegister: srcReg1 toRegister: srcReg2 intoRegister: destReg [

	"fadd.d: floating point add between registers f[rs1] and f[rs2] and store the sum to f[rd]

	 31      25 24   20 19    15 14  12 11     7 6         0
	| 0000001  |  rs2  |  rs1   |  rm  |   rd   |  1010011  |
	rm = 111 by default
	"

	self flag: #DONE.
	"Actual bit instruction"
	^ (((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fConvertDoublePrecisionInRegister: srcReg toSinglePrecisionInRegister: destReg [

	"fcvt.s.d: Converts the double-precision floating-point number in f[rs1]
	 to a single-precision floating-point number and writes it to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	0100000  |  00001  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.	
	^ (((((2r0100000  << 25)
	  bitOr: 2r00001 << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fConvertLongSignedInRegister: srcReg toDoublePrecisionInRegister: destReg [

	"fcvt.d.l: Converts the 64-bit two's complement integer in x[rs1]
	 to a double precision floating-point number and writes it to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	1101001  |  00010  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.	
	^ (((((2r1101001  << 25)
	  bitOr: (2r00010 << 20))
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fConvertSinglePrecisionInRegister: srcReg toDoublePrecisionInRegister: destReg [

	"fcvt.d.s: Converts the single-precision floating-point number in f[rs1]
	 to a double precision floating-point number and writes it to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	0100001  |  00000  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.	
	^ (((((2r0100001  << 25)
	  bitOr: 2r00000 << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fDivideRegister: srcReg1 byRegister: srcReg2 intoRegister: destReg [

	"fdiv.d: Divides the double-precision floating point number in register f[rs1] by f[rs2]
	 and writes the rounded double-precision quotient to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24   20 19   15 14  12 11   7 6        0
	|  	0001101  |  rs2  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.	
	^ (((((2r0001101 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fLoadDoubleWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"fld: Loads a double-precision floating-point number from memory 
	 at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  011   |   rd   |   0000111  |
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
	  bitOr: 2r0000111) 


	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fLoadWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"flw: Loads a single-precision floating-point number from memory 
	 at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  010   |   rd   |   0000111  |
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r010 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000111) 


	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fMoveDoubleWordInFRegister: srcFRegister toFRegister: destFRegister [

	"fmv.d: Copies the double-precision floating-point number in f[rs1] to f[rd].
	 expands to fsgnj.d rd, rs1, rs1

	
	 31      25 24     20 19    15 14    12 11     7 6         0
	| 0010001  |  rs1  |  rs1   |   000  |   rd   |  1010011  |
	"

	self flag: #DONE.
	"Actual bit instruction"
	^ ((((2r0010001 << 25) 
	  bitOr: (srcFRegister bitAnd: 16r1f) << 20)
	  bitOr: (srcFRegister bitAnd: 16r1f) << 15)
	  bitOr: (destFRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fMoveDoubleWordInFRegister: fregister toXRegister: xregister [

	"fmv.x.d: Floating point move doubleword to integer,
    copies the double-precision floating-point number in register f[rs1] to x[rd]

	
	 31      25 24     20 19    15 14    12 11     7 6         0
	| 1110001  |  00000  |  rs1   |   000  |   rd   |  1010011  |
	"

	self flag: #DONE.
	"Actual bit instruction"
	^ (((2r1110001 << 25) 
	  bitOr: (fregister bitAnd: 16r1f) << 15)
	  bitOr: (xregister bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fMoveDoubleWordInXRegister: xregister toFRegister: fregister [

	"fmv.d.x: Floating point move doubleword from integer,
    copies the double-precision floating-point number in register x[rs1] to f[rd]

	
	 31      25 24     20 19    15 14    12 11     7 6         0
	| 1111001  |  00000  |  rs1   |   000  |   rd   |  1010011  |
	"

	self flag: #DONE.
	"Actual bit instruction"
	^ (((2r1111001 << 25) 
	  bitOr: (xregister bitAnd: 16r1f) << 15)
	  bitOr: (fregister bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 

]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fMultiplyRegister: srcReg1 fromRegister: srcReg2 intoRegister: destReg [

	"fmul.d: Multiplies the double-precision floating point number in registers f[rs1] and f[rs2]
	 and writes the rounded sdouble-precision difference to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24   20 19   15 14  12 11   7 6        0
	|  	0001001  |  rs2  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.	
	^ (((((2r0001001 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fSetOneIn: destReg ifRegisterValue: srcReg1 isEqualToRegisterValue: srcReg2 [

	"feq.d: Writes one to x[rd] if the double-precision floating-point number
	 in f[rs1] is equal tot he one in f[rs2], and 0 if not.
	
	 31       25 24     20 19     15 14    12 11     7 6          0
	|  1010001  |   rs2   |   rs1   |  010   |   rd   |   1010011  |
	"

	self flag: #TODO.	
	^ (((((
	  2r1010001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15) 
	  bitOr: 2r010 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r1010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fSetOneIn: destReg ifRegisterValue: srcReg1 isLessThanOrEqualToRegisterValue: srcReg2 [

	"fle.d: Writes one to x[rd] if the double-precision floating-point number
	 in f[rs1] is less than or equal to the one in f[rs2], and 0 if not.
	
	 31       25 24     20 19     15 14    12 11     7 6          0
	|  1010001  |   rs2   |   rs1   |  000   |   rd   |   1010011  |
	"
	
	self flag: #TODO.	
	^ (((((
	  2r1010001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15) 
	  bitOr: 2r000 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r1010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fSetOneIn: destReg ifRegisterValue: srcReg1 isLessThanRegisterValue: srcReg2 [

	"flt.d: Writes one to x[rd] if the double-precision floating-point number
	 in f[rs1] is less than to the one in f[rs2], and 0 if not.
	
	 31       25 24     20 19     15 14    12 11     7 6          0
	|  1010001  |   rs2   |   rs1   |  001   |   rd   |   1010011  |
	"

	self flag: #TODO.	
	^ (((((
	  2r1010001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15) 
	  bitOr: 2r001 << 12)
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r1010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fSquareRootOfRegister: srcReg inRegister: destReg [

	"fsqrt.d: Computes the square root of the double-precision floating-point number in register f[rs1]
	 and writes the rounded double-precision result to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24     20 19   15 14  12 11   7 6        0
	|  	0101101  |  00000  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.	
	^ ((((2r0101101 << 25)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fStoreDoubleWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"fsd: Stores the double-precision floating-point number in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  011   |   offset[4:0]   |   0100111  |
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
	  bitOr: 2r0100111
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fStoreWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"fsw: Stores the single-precision floating-point number in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  010   |   offset[4:0]   |   0100111  |
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
	  bitOr: 2r010 << 12)
	  bitOr: (signExtendedOffset bitAnd: 16r1f) << 7) 
	  bitOr: 2r0100111
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> fSubtractRegister: srcReg2 fromRegister: srcReg1 intoRegister: destReg [

	"fsub.d: Substracts the double-precision floating point number in register f[rs2] from register f[rs1] 
	 and writes the rounded sdouble-precision difference to f[rd].
 	 rm is set to 111 (dynamic rounding mode by default)
	
	 31       25 24   20 19   15 14  12 11   7 6        0
	|  	0000101  |  rs2  |  rs1  |  rm  |  rd  |  1010011  |
	"

	self flag: #TODO.		
	^ (((((2r0000101 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r111 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r1010011
]

{ #category : #abi }
CogRiscV64Compiler >> fullCallsAreRelative [
	"Answer if CallFull and/or JumpFull are relative and hence need relocating on method
	 compation. If so, they are annotated with IsRelativeCall in methods and relocated in
	 relocateIfCallOrMethodReference:mcpc:delta:"
	^false
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> genCaptureCStackPointers: captureFramePointer [

	"Save the register to a caller-saved register.
	The caller may have been using the same register for something else.
	So we need to save it and restore it later.
	Make sure to reuse a caller-saved register: we can reuse it freely"
	self hasVarBaseRegister ifTrue:
		[cogit
			MoveR: VarBaseReg R: ConcreteIPReg;
			MoveCq: cogit varBaseAddress R: VarBaseReg].
	captureFramePointer ifTrue:
		[cogit MoveR: FPReg Aw: cogit cFramePointerAddress].

	"Capture the stack pointer prior to the call"
	cogit MoveR: self cStackPointer Aw: cogit cStackPointerAddress.
	
	"Restore the base register for our caller"
	self hasVarBaseRegister ifTrue:
		[cogit MoveR: ConcreteIPReg R: VarBaseReg].

	cogit RetN: 0.
]

{ #category : #'abstract instructions' }
CogRiscV64Compiler >> genDivR: abstractRegDenominator R: abstractRegNumerator Quo: abstractRegQuotient Rem: abstractRegRemainder [

	"As the two operations will perform a division, one to get the quotient, the other to get the remainder,
	 the quotient reg cannot be the same as the source regs. 
	 The recommended sequence is: 
		DIV rdq, rs1, rs2
		REM rdr, rs1, rs2"
	self flag: #TODO.
	cogit gen: DivRR operand: abstractRegNumerator operand: abstractRegDenominator operand: ConcreteIPReg.
	cogit gen: RemRR operand: abstractRegNumerator operand: abstractRegDenominator operand: abstractRegRemainder.
	cogit MoveR: ConcreteIPReg R: abstractRegQuotient

]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genLoadCStackPointer [
	"Load the stack pointer register with that of the C stack, effecting
	 a switch to the C stack.  Used when machine code calls into the
	 CoInterpreter run-time (e.g. to invoke interpreter primitives)."
	cogit MoveAw: cogit cStackPointerAddress R: SPReg.
	^0
]

{ #category : #'smalltalk calling convention' }
CogRiscV64Compiler >> genLoadCStackPointers [
	"Load the frame and stack pointer registers with those of the C stack,
	 effecting a switch to the C stack.  Used when machine code calls into
	 the CoInterpreter run-time (e.g. to invoke interpreter primitives)."
	cogit MoveAw: cogit cStackPointerAddress R: SPReg.
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
		=> the number lower part is negative (sign = 1) and the higher part is all 1s
	"
	
	self flag: #TODO.
	^ cogit gen: MulRR operand: regSource operand: regDest
]

{ #category : #alignment }
CogRiscV64Compiler >> genNopsForEntries [

	"Generate the correct amount of nops to disalign the cog entry and no check entry
	 (see genGetInlineCacheClassTagFromgenGetInlineCacheClassTagFrom:  into:  forEntry:)"
	
	self flag: #DONE.
	cogit Nop.
	cogit Nop.
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
	"This is a no-op on RISCV since the ABI passes up to 8 args in registers and trampolines currently observe that limit."
	<inline: true>
	self assert: n <= 4.
	^0
]

{ #category : #abi }
CogRiscV64Compiler >> genRestoreRegs: regMask [
	"Restore the registers in regMask as saved by genSaveRegs:."
	<inline: true>
	| registerCount |
	self flag: #TODO.
	self assert: (X17 > X10 and: [X17 - X10 + 1 = 8]).
	"self deny: (regMask anyMask: (cogit registerMaskFor: SPReg and: FPReg))."
	
	registerCount := 0.
	X10 to: X17 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[registerCount := registerCount + 1]].
	
	X10 to: X17 do:
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
	self flag: #TODO.
	self assert: (X17 > X10 and: [X17 - X10 + 1 = 8]).
	self deny: (regMask anyMask: (cogit registerMaskFor: SPReg and: FPReg)).
	
	registerCount := 0.
	X17 to: X10 by: -1 do:
		[:reg|
		 (regMask anyMask: (cogit registerMaskFor: reg)) ifTrue:
			[registerCount := registerCount + 1]].
	
	"If we are saving an odd number of registers, this would unalign the stack.
	Then, lets save an extra thing to force the stack alignment"
	registerCount \\ 2 == 0
		ifFalse: [ cogit PushCq: 16rBEEF "Marker smallinteger to generate a valid stack" ].
	
	X17 to: X10 by: -1 do:
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

{ #category : #printing }
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
	^true "x1/ra"
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
	 the base of commonly-accessed variables. On RISCV we use X26 for this."
	^true "x26/s10"
]

{ #category : #initialization }
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

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsADDI: instruction [

	self flag: #TODO.
	^ ((instruction >> 12 bitAnd: 16r7) = 0) and: [(instruction bitAnd: 16r7F) = 2r0010011].

]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsADDIW: instruction [

	self flag: #DONE.
	"Check bits 12 to 14 null"
	^ ((instruction >> 12 bitAnd: 16r7) = 0) and: [(instruction bitAnd: 16r7F) = 2r0011011].
]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsAUIPC: instruction [

	self flag: #DONE.
	^ (instruction bitAnd: 16r7F) = 2r0010111.

]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> instructionIsConditionalBranch: instruction [
	
	
	self flag: #TODO.
	^ (instruction bitAnd: 16r7F) = 2r1100011
]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsConditionalZeroBranch: instruction [ 

	"Check that the instruction is a conditional branch and that it focuses on the concretezeroreg"
	self flag: #TODO.
	^ ((instruction bitAnd: 16r7F) = 2r1100011) and: [(instruction >> 15 bitAnd: 16r1F) = ConcreteZeroReg]
]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsJAL: instruction [

	self flag: #DONE.
	^ (instruction bitAnd: 16r7F) = 2r1101111.

]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsJALR: instruction [

	self flag: #DONE.
	"Check bits 12 to 14 null"
	^ ((instruction >> 12 bitAnd: 16r7) = 0) and: [(instruction bitAnd: 16r7F) = 2r1100111].

]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsLD: instruction [ 

	self flag: #TODO.
	^ ((instruction >> 12 bitAnd: 2r111) = 2r011) and: [(instruction bitAnd: 2r1111111) = 2r0000011]
]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsLUI: instruction [

	self flag: #DONE.
	^ (instruction bitAnd: 16r7F) = 2r0110111.
]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsNOP: instruction [

	self flag: #DONE.
	^ ((instruction >> 7 bitAnd: 16rFFFFFF8) = 0) and: [(instruction bitAnd: 16r7F) = 2r0010011].

]

{ #category : #'instruction detection' }
CogRiscV64Compiler >> instructionIsSD: instruction [  

	self flag: #DONE.
	^ ((instruction >> 12 bitAnd: 16r7) = 2r011) and: [(instruction bitAnd: 16r7F) = 2r0100011].
]

{ #category : #testing }
CogRiscV64Compiler >> instructionSizeAt: pc [
	"Answer the instruction size at pc"
	self flag: #DONE.
	^4
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
	"RISCV is little endian"
	^false
]

{ #category : #testing }
CogRiscV64Compiler >> isCallPrecedingReturnPC: mcpc [
	"Assuming mcpc is a send return pc answer if the instruction before it is a call (not a CallFull)."
	"There are two types of calls: BL and/BLX encoding"
	| call |
	self flag: #TODO.
	call := self instructionBeforeAddress: mcpc.
	^(self instructionIsJALR: call)
]

{ #category : #testing }
CogRiscV64Compiler >> isInImmediateBranchRange: operand [
	"RISC-V branches can use immediates of max size 13 bits"
	<var: #operand type: #'usqIntptr_t'>
	self flag: #TODO.
	^ self value: operand isContainedIn: 13
]

{ #category : #testing }
CogRiscV64Compiler >> isInImmediateCallRange: operand [
	"RISC-V calls and jumps can use immediates of max size 20 bits"
	<var: #operand type: #'usqIntptr_t'>
	self flag: #TODO.
	^ self value: operand isContainedIn: 32
]

{ #category : #testing }
CogRiscV64Compiler >> isInImmediateJumpRange: operand [
	"RISC-V jal and jalr can use immediates of max size 21 bits"
	<var: #operand type: #'usqIntptr_t'>
	self flag: #TODO.
	^ self value: operand isContainedIn: 21
]

{ #category : #testing }
CogRiscV64Compiler >> isInLongJumpCallRange: offset [
	"RISC-V calls and jumps can use values of max size 32 bits through auipc / jal|jalr"
	<var: #operand type: #'usqIntptr_t'>
	self flag: #TODO.
	^ self value: offset isContainedIn: 32
]

{ #category : #testing }
CogRiscV64Compiler >> isJumpAt: pc [
	| instr |
	self flag: #TODO.
	instr := objectMemory long32At: pc.
	^(self instructionIsJAL: instr)
	  or: [self instructionIsJALR: instr]
]

{ #category : #testing }
CogRiscV64Compiler >> isRelativeLiteralLoad: followingAddress [
	
	"Need renaming"
	self flag: #TODO.	
	^ (self instructionIsAUIPC: (self instructionBeforeAddress: followingAddress - 4)) 
		and: [self instructionIsLD: (self instructionBeforeAddress: followingAddress)]
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> jumpLongByteSize [
"	Branch/Call ranges.  Jump[Cond] can be generated as short as possible.  Call/Jump[Cond]Long must be generated
	in the same number of bytes irrespective of displacement since their targets may be updated, but they need only
	span 16Mb, the maximum size of the code zone.  This allows e.g. ARM to use single-word call and jump instructions
	for most calls and jumps.  CallFull/JumpFull must also be generated in the same number of bytes irrespective of
	displacement for the same reason, but they must be able to span the full (32-bit or 64-bit) address space because
	they are used to call code in the C runtime, which may be distant from the code zone"
	
	"Jump long will load a pc-relative offset within 32-bits (enough for the 16mb required for the code space) then jump 
	 using a total of two instructions: auipc + jalr (same as call but does not store the return address)"
	self flag: #TODO.
	^8
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> jumpLongConditionalByteSize [
	" RISCV-64 does not have conditional long jumps. 
	 Be a short conditional jump (over the long jump instruction) and a long jump "
	self flag: #TODO.
	^ self jumpLongByteSize + 4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> jumpLongTargetBeforeFollowingAddress: mcpc [ 
	"Answer the target address for the long jump immediately preceding mcpc"
	self flag: #TODO.
	^self callTargetFromReturnAddress: mcpc
]

{ #category : #'instruction extraction' }
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> jumpTo: sourceRegisterValueAddress withOffset: offset andStorePreviousPCPlus4in: destinationRegister [ 
	"jalr: Sets the pc to x[rs1] + sign-extend(offset), masking off the least-significant bit of the computed address, 
	 then writes the previous pc+4 to x[rd]. If rd is omitted, x1 is assumed.
	
	 31             20  19    15  14   12  11    7  6         0
	|  	offset[11:0]  |   rs1   |  000   |   rd   |   1100111  |
	"

	| signExtendedOffset |
	self flag: #DONE.	
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	^ (((((signExtendedOffset bitAnd: 16rfff) << 20)
		bitOr: (sourceRegisterValueAddress bitAnd: 16r1f) << 15)
		bitOr: (destinationRegister bitAnd: 16r1f) << 7)
		bitOr: 2r1100111)
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> jumpToOffset: offset [
	"j: Pseudo-instruction that writes PC+offset to the PC 
	 Expands to jal, x0, offset
	"
	self flag: #DONE.
	^ self jumpToOffset: offset andStorePreviousPCPlus4in: X0
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> jumpToOffset: offset andStorePreviousPCPlus4in: destinationRegister [ 
	"jal: Writes the address of the next instruction (pc+4) to x[rd],
	 then sets the pc to the current pc plus the sign-extended offset. 
	 If rd is omitted, x1 is assumed
	
	 31                          12 11     7 6         0
	|  	 offset[20|10:1|11|19:12]   |   rd   |   1101111  |
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"	
	self assertValue: offset isContainedIn: 21.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 21.
	^  (((((((signExtendedOffset >> 20)  bitAnd: 16r1) << 31) 
		bitOr: ((signExtendedOffset >> 1) bitAnd: 16r3ff) << 21)
		bitOr: ((signExtendedOffset >> 11) bitAnd: 16r1) << 20)
		bitOr: ((signExtendedOffset >> 12) bitAnd: 16rff) << 12)
		bitOr: (destinationRegister bitAnd: 16r1f) << 7)
		bitOr: 2r1101111
]

{ #category : #'machine code instruction' }
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

{ #category : #'concretization helpers - mc size' }
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> load12BitsImmediate: anImmediate inRegister: aRegisterID [

	"li: Load immediate for sub-12bits immediate is an addi with register X0 (always holding the value 0)"

	self flag: #DONE.
	^ self
		  addImmediate: anImmediate
		  toRegister: X0
		  inRegister: aRegisterID
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadByteFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lb: Loads one byte from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], sign-extending the result.
	
	 31            20 19    15 14    12 11     7 6         0
	|  	offset[11:0]  |  rs1   |  000   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r000 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : #concretization }
CogRiscV64Compiler >> loadCwInto: destReg [

	| operand distance offsetLow offsetHigh |
	self flag: #TODO.
	operand := operands at: 0.
	self
		cCode: [  ]
		inSmalltalk: [ operand := operand bitAnd: 16rFFFFFFFF ]. "Need to clamp the value to a word size since one or two usages actually generate double sized values and rely upon the C code to narrow it within the running VM"
	(self isAnInstruction:
		 (cogit cCoerceSimple: operand to: #'AbstractInstruction *')) 
		ifTrue: [ 
			operand := (cogit
				            cCoerceSimple: operand
				            to: #'AbstractInstruction *') address ].
	"Try to encode the Cw as a pc-relative first"
	(cogit addressIsInCurrentCompilation: operand)
		ifTrue: [ 
			distance := operand signedIntFromLong - address signedIntFromLong.
			"Check if the absolute distance fits in 12 bits or produce a way to split the distance between the two instructions
		 https://forums.sifive.com/t/bit-11-of-jalr-sign-extened-for-call-auipc-jalr/1950"
			self
				assertValue: distance isContainedIn: 32.
					"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
			offsetLow := self computeSignedValue64Bits: (distance  bitAnd: 16rFFF).
			offsetHigh := (((self computeSignedValue64Bits: distance) + 16r800) >> 12) bitAnd: 16rFFFFF.
			self
				machineCodeAt: 0
				put: (self addUpperImmediateToPC: offsetHigh toRegister: destReg).
			self
				machineCodeAt: 4
				put:
				(self
					 addImmediate: offsetLow
					 toRegister: destReg
					 inRegister: destReg).
			^ machineCodeSize := 8 ].
	"Otherwise, load the literal in a register"
	^ self loadLiteralInRegister: destReg
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadDoubleWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"ld: Loads eight bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd].
	
	 31           20 19     15 14    12 11     7 6          0
	|  	offset[11:0  |   rs1   |  011   |   rd   |   0000011  |
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
CogRiscV64Compiler >> loadHalfWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lh: Loads two bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], sign-extending the result.
	
	 31           20 19     15 14    12 11     7 6          0
	|  	offset[11:0  |   rs1   |  001   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r001 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadImmediate: immediate inRegister: destReg [

	"Uses an addi instruction to load an 11-bit long immediate. If 12 bit long, it will get sign-extended and incorrect"
	self flag: #DONE.
	self assertValue: immediate isContainedIn: 11.
	self machineCodeAt: 0 put: (self addImmediate: immediate toRegister: X0 inRegister: destReg).
	^ machineCodeSize := 4
	
	
	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadLiteralInRegister: destReg [

	self flag: #TODO.
	^ self loadLiteralInRegister: destReg startingAtIndex: 0 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadLiteralInRegister: destReg startingAtIndex: index [

	| literalAddress distance |
	"Compute the distance from the current address
	- auipc to get the PC
	- ld    to load relative to the PC"
	self flag: #DONE.
	"Several guard are checked"
	self assert: dependent isNotNil.
	self assert: dependent opcode = Literal.
	self assert: (cogit addressIsInCurrentCompilation: dependent address).
	literalAddress := (cogit cCoerceSimple: dependent to: #'AbstractInstruction *') address.
	distance := literalAddress - address.
	self assertValue: distance isContainedIn: 12.
	self machineCodeAt: index put: (self addUpperImmediateToPC: 0 toRegister: destReg).
   	self machineCodeAt: index + 4 put: (self loadDoubleWordFromAddressInRegister: destReg withOffset: distance toRegister: destReg).
	^ machineCodeSize := 8

]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> loadPICLiteralByteSize [
	"Answer the byte size of a MoveCwR opcode's corresponding machine code
	 when the argument is a PIC.  This is for the self-reference at the end of a
	 closed PIC.  On RISC-V this is a two instructions pc-relative register load."
	self flag: #TODO.
	^8
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadUnsignedByteFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lbu: Loads one byte from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result.
	
	 31            20 19    15 14    12 11     7 6         0
	|  	offset[11:0]  |  rs1   |  100   |   rd   |   0000011  |
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
CogRiscV64Compiler >> loadUnsignedHalfWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lhu: Loads two bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result.
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  101   |   rd   |   0000011  |
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
CogRiscV64Compiler >> loadUnsignedWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lwu: Loads four bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], zero-extending the result
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  110   |   rd   |   0000011  |
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
CogRiscV64Compiler >> loadUpperImmediate: anImmediate inRegister: destReg [

	"lui: Writes the sign-extended 20-bit immediate, left-shifted by 12 bits,
	 to x[rd], zeroing the lower 12 bits
	
	31                 12 11   7 6         0
	|  	immediate[31:12]  |  rd  |  0110111  |
	"

	| signExtendedImmediate |
	self flag: #DONE.	
	"Check size and sign"
	self assertValue: anImmediate isContainedIn: 20.	
	signExtendedImmediate := self computeSignedValueOf: anImmediate ofSize: 20.
	^ (((signExtendedImmediate bitAnd: 16rfffff) << 12) 
	  bitOr: (destReg bitAnd: 16r1f) << 7) 
	  bitOr: 2r0110111
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> loadWordFromAddressInRegister: baseRegister withOffset: offset toRegister: destinationRegister [ 

	"lw: Loads four bytes from memory at address x[rs1] + sign-extend(offset) and writes them to x[rd], sign-extending the result.
	
	 31            20 19     15 14    12 11     7 6          0
	|  	offset[11:0]  |   rs1   |  010   |   rd   |   0000011  |
	"

	| signExtendedOffset |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: offset isContainedIn: 12.	
	signExtendedOffset := self computeSignedValueOf: offset ofSize: 12.
	"Actual bit instruction"
	^ ((((((signExtendedOffset bitAnd: 16rfff) << 20) 
	  bitOr: (baseRegister bitAnd: 16r1f) << 15)
	  bitOr: 2r010 << 	12)
	  bitOr: (destinationRegister bitAnd: 16r1f) << 7)
	  bitOr: 2r0000011) 


	
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> machineCodeAt: anOffset [

	"read aWord from machineCode, with little endian"

	<inline: true>
	^ machineCode at: anOffset // 4
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> machineCodeAt: anOffset put: aWord [
	"add aWord to machineCode, with little endian"
	<inline: true>
	self haltIf: [ aWord highBit > 32 ].
	machineCode at: anOffset // 4 put: aWord
]

{ #category : #'concretization helpers - mc size' }
CogRiscV64Compiler >> machineCodeBytes [
	"Answer the maximum number of bytes of machine code generated for any abstract instruction.
	 e.g. **CwR =>
			load full immediate (32) 
			operation (sub/add/...)"
	self flag: #TODO.
	^ 36
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> machineCodeWords [
	"Answer the maximum number of words of machine code generated for any abstract instruction.
	 e.g. CmpCwR =>
			mov R3, #<addressByte1>, 12
			orr R3, R3, #<addressByte2>, 8
			orr R3, R3, #<addressByte3>, 4
			orr R3, R3, #<addressByte4>, 0
			cmp R?, R3"
	self flag: #TODO.
	^ 15
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> moveRegister: srcReg toRegister: destReg [

	"mv is pseudo instruction that expands to addi rd, rs1, 0"	
	self flag: #DONE.
	^ self addImmediate: 0 toRegister: srcReg inRegister: destReg
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> multiplyHighRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"mulh: multiplies x[rs1] by x[rs2] treating the values as two's complement numbers, 
			 and writes the upper half of the product to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  010  |   rd   |   0110011   |
	"

	self flag: #TODO.
	"Actual bit instruction"
	^ ((((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r001 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011) 


	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> multiplyRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"mul: multiplies x[rs1] by x[rs2] treating the values as two's complement numbers, 
			 and writes the upper half of the product to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  000  |   rd   |   0110011   |
	"

	self flag: #TODO.
	"Actual bit instruction"
	^ ((((((2r1 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r000 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011) 


	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> multiplyWordRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"mulw: multiplies x[rs1] by x[rs2] truncates the product to 32 bits, 
			 and writes the sign-extended value to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  000  |   rd   |   0111011   |
	"

	self flag: #TODO.
	"Actual bit instruction"
	^ ((((((2r0000001 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r000 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0111011) 


	
]

{ #category : #printing }
CogRiscV64Compiler >> nameForFPRegister: reg [ "<Integer>"
	<doNotGenerate>
	self flag: #TODO.
	(reg between: 0 and: 7) ifTrue:
		[^#(D0 D1 D2 D3 D4 D5 D6 D7) at: reg + 1].
	^super nameForFPRegister: reg
]

{ #category : #printing }
CogRiscV64Compiler >> nameForRegister: reg [ "<Integer>"
	<doNotGenerate>
	| default |
	self flag: #TODO.
	default := super nameForRegister: reg.
	^default last = $?
		ifTrue:
			[#(LR SP PC CArg0Reg CArg0Reg CArg1Reg CArg2Reg CArg3Reg)
				detect: [:sym| (thisContext method methodClass classPool at: sym) = reg] 
				ifNone: [default]]
		ifFalse:
			[default]
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> negateValueInRegister: srcReg intoRegister: destReg [ 

	"neg: Negate value in register x[rs1] and stores it in x[rd].
	 Expands to sub rd, x0, rs"
	
	self flag: #TODO.
	^ self subtractRegister: srcReg fromRegister: X0 intoRegister: destReg

	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> nop [
	
	"nop: Pseudoinstruction that expands to addi x0, 0(x0)"
	self flag: #DONE.
	^ self addImmediate: 0 toRegister: X0 inRegister: X0 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> noteFollowingConditionalBranch: branch [
	"Support for processors without condition codes, such as the MIPS.
	 Answer the branch opcode.  Modify the receiver and the branch to
	 implement a suitable conditional branch that doesn't depend on
	 condition codes being set by the receiver."
	<returnTypeC: #'AbstractInstruction *'>
	<var: #branch type: #'AbstractInstruction *'>
	| newBranchLeft newBranchOpcode newBranchRight |
	
	"Specific for overflow"
	"((branch opcode = JumpOverflow) or: [branch opcode = JumpNoOverflow]) 
		ifTrue: [^self noteFollowingOverflowBranch: branch]."
	
	((opcode = CmpRR) and: (branch opcode = JumpZero)) ifFalse: [ ^ branch ].
	1halt.
	opcode caseOf: {
		"[BrEqualRR]	->	[""I.e., two jumps after a compare.""
						newBranchLeft := operands at: 1.
						newBranchRight := operands at: 2].
		[BrUnsignedLessRR]	->	[""I.e., two jumps after a compare.""
						newBranchLeft := operands at: 1.
						newBranchRight := operands at: 2]."

		[CmpRR] 	-> 	[newBranchLeft := operands at: 1.
						 newBranchRight := operands at: 0.
						 opcode := Label].

		"[CmpCqR]	-> 	[newBranchLeft := operands at: 1.
						 newBranchRight := AT.
						 opcode := MoveCqR.
						 operands at: 1 put: AT].
		[CmpCwR]	-> 	[newBranchLeft := operands at: 1.
						 newBranchRight := AT.
						 opcode := MoveCwR.
						 operands at: 1 put: AT].
		[TstCqR]	->	[newBranchLeft := Cmp.
						 newBranchRight := ZR].
		[AndCqR]	->	[newBranchLeft := operands at: 1.
						 newBranchRight := ZR].
		[AndCqRR]	->	[newBranchLeft := operands at: 2.
						 newBranchRight := ZR].
		[OrRR]	->		[newBranchLeft := operands at: 1.
						 newBranchRight := ZR].
		[XorRR]	->		[newBranchLeft := operands at: 1.
						 newBranchRight := ZR].
		[SubCwR]	->	[newBranchLeft := operands at: 1.
						 newBranchRight := ZR].
		[SubCqR]	->	[newBranchLeft := operands at: 1.
						 newBranchRight := ZR].
		[ArithmeticShiftRightCqR]	->	[newBranchLeft := operands at: 1.
						 newBranchRight := ZR]."
	} otherwise: [self unreachable].
	
	newBranchOpcode := branch opcode caseOf: {
		[JumpZero] 			-> [BrEqualRR].
		"[JumpNonZero]			-> [BrNotEqualRR].
		[JumpBelow]			-> [BrUnsignedLessRR].
		[JumpBelowOrEqual]	-> [BrUnsignedLessEqualRR].
		[JumpAbove]			-> [BrUnsignedGreaterRR].
		[JumpAboveOrEqual]	-> [BrUnsignedGreaterEqualRR].
		[JumpLess]				-> [BrSignedLessRR].
		[JumpLessOrEqual]		-> [BrSignedLessEqualRR].
		[JumpGreater]			-> [BrSignedGreaterRR].
		[JumpGreaterOrEqual]	-> [BrSignedGreaterEqualRR].
		[JumpLongZero] 		-> [BrLongEqualRR].
		[JumpLongNonZero]	-> [BrLongNotEqualRR].
		[JumpNegative]			-> [BrSignedLessRR]."
	} otherwise: [self unreachable. 0].

	branch rewriteOpcode: newBranchOpcode with: newBranchLeft with: newBranchRight.
	^branch
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> noteFollowingOverflowBranch: branch [
	"Support for processors without condition codes, such as the MIPS.
	 Answer the branch opcode.  Modify the receiver and the branch to
	 implement a suitable conditional branch that doesn't depend on
	 condition codes being set by the receiver."
	<var: #branch type: #'AbstractInstruction *'>
	| newBranchOpcode |
	^ branch
	
	"
	(opcode = MulRR) ifTrue:
		[opcode := MulCheckOverflowRR.
		 newBranchOpcode := branch opcode caseOf: {
			[JumpOverflow]		-> [BrNotEqualRR].
			[JumpNoOverflow]	-> [BrEqualRR].
		 } otherwise: [self unreachable. 0].
		 branch rewriteOpcode: newBranchOpcode with: OverflowTemp1 with: OverflowTemp2.
		 ^branch].


	opcode := opcode caseOf: {
		[AddCqR]	-> [AddCheckOverflowCqR].
		[AddRR]		-> [AddCheckOverflowRR].
		[SubCqR]	-> [SubCheckOverflowCqR].
		[SubRR]		-> [SubCheckOverflowRR].
	} otherwise: [self unreachable. 0].

	newBranchOpcode := branch opcode caseOf: {
		[JumpOverflow]		-> [BrSignedLessRR].
		[JumpNoOverflow]	-> [BrSignedGreaterEqualRR].
	} otherwise: [self unreachable. 0].
	branch rewriteOpcode: newBranchOpcode with: Overflow with: ZR.
	^branch"

	
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> numICacheFlushOpcodes [
	"ARM needs to do icache flushing when code is written"
	"for now return 0 to skip it and probably blow up"
	^0
	
]

{ #category : #accessing }
CogRiscV64Compiler >> numIntRegArgs [
	^8
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> outputMachineCodeAt: targetAddress [
	"Override to move machine code a word at a time."
	<inline: true>
	0 to: machineCodeSize - 1 by: 4 do:
		[:j|
		objectMemory uint32AtPointer: targetAddress + j put: (machineCode at: j // 4)]
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> padIfPossibleWithStopsFrom: startAddr to: endAddr [
	| nullBytes |
	nullBytes := (endAddr - startAddr + 1) \\ 4.
	self stopsFrom: startAddr to: endAddr - nullBytes.
	endAddr - nullBytes + 1 to: endAddr 
		do: [ :p | objectMemory byteAt: p put: 16rFF]
]

{ #category : #'calling C function in Smalltalk stack' }
CogRiscV64Compiler >> prepareStackToCallCFunctionInSmalltalkStack: anObject [ 

	self flag: #TODO.
	cogit MoveR: SPReg R: Extra2Reg.
	cogit AndCq: ((1 << 64) - 16) R: Extra2Reg. 
	cogit MoveR: Extra2Reg R: SP.
]

{ #category : #accessing }
CogRiscV64Compiler >> pushLinkRegisterByteSize [
	
	self flag: #TODO.
	^8
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> relocateCallBeforeReturnPC: retpc by: delta [
	
	| offset |
	"1halt."
	self assert: delta \\ 4 = 0.
	delta ~= 0 ifTrue:
		[ offset := self callTargetFromReturnAddress: retpc.
		  self rewriteCallAt: retpc target: offset + delta]
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> remainderOfDivisionRegisterValue: srcReg1 byRegisterValue: srcReg2 inRegister: destReg [

	"rem Divides x[rs1] by x[rs2], rounding towards 0, treating the values as two's complement numbers
	 and writes the remainder to x[rd]
	
	 31       25 24     20 19     15 14   12 11     7 6           0
	|  	0000001  |   rs2   |   rs1   |  110  |   rd   |   0110011   |
	"

	self flag: #TODO.
	"Actual bit instruction"
	^ ((((((2r1 << 25) 
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: 2r110 << 	12)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011) 


	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> ret [
	
	"ret: Pseudoinstruction that expands to jalr, x0, 0(x1)"
	self flag: #DONE.
   ^ self jumpTo: LR  withOffset: 0 andStorePreviousPCPlus4in: X0
	
]

{ #category : #'calling C function in Smalltalk stack' }
CogRiscV64Compiler >> returnFromCallCFunctionInSmalltalkStack: anObject [

	cogit MoveR: Extra2Reg R: SPReg.

]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteCPICJumpAt: jumpReturnAddress target: jumpTargetAddress [

	"Rewrite a jump instruction to call a different target.  This variant is used to reset the 
	jumps in the prototype CPIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."

	<var: #jumpReturnAddress type: #usqInt>
	<var: #jumpTargetAddress type: #usqInt>
	| jumpDistance instr |
	self flag: #TODO.
	"1halt."
	jumpTargetAddress >= cogit minCallAddress ifFalse: [ 
		self error: 'linking callsite to invalid address' ].

	jumpDistance := jumpTargetAddress - (jumpReturnAddress - 12). "return offset"
	self assert: (self isInLongJumpCallRange: jumpDistance). 

	instr := self instructionBeforeAddress: jumpReturnAddress.
	self assert: (self instructionIsConditionalBranch: instr).
	self assert: (self instructionIsConditionalZeroBranch: instr).

	objectMemory
		long32At: (self instructionAddressBefore: jumpReturnAddress)
		put: (self
				 zeroConditionalBranch:
				 (self extractConditionFromZeroConditionalBranch: instr)
				 withOffset: jumpDistance).

	self assert: (self extractOffsetFromConditionalBranch: (self
				  zeroConditionalBranch:
				  (self extractConditionFromZeroConditionalBranch: instr)
				  withOffset: jumpDistance)) = jumpDistance.
	^ 4
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteCallAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a call/jump instruction to call a different target.  This variant is used to link PICs
	 in ceSendMiss et al, and to rewrite call/jumps in CPICs.
	Answer the extent of
	 the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| callDistance offsetLow offsetHigh instr |

	self flag: #TODO.
	callTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].

	callDistance := (callTargetAddress - (callSiteReturnAddress - 8 "return offset")).
	self assert: (self isInImmediateCallRange: callDistance). "we don't support long call updates, yet"

	instr := self instructionBeforeAddress: callSiteReturnAddress.
	self assert: (self instructionIsJALR: instr).
	"Need to modify the whole instructions -> auipc + jalr"
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (callDistance bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: callDistance) + 16r800) >> 12) bitAnd: 16rFFFFF.

	"auipc"
	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress - 4)
		put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	"jalr"
	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress)
		put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: LR).

	self assert: (self callTargetFromReturnAddress: callSiteReturnAddress) = callTargetAddress.

	^8
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteCallFullAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a full call instruction to jump to a different target.  This variant
	 is used to rewrite cached primitive calls where we load the target address into ip
	 and use the 'blx ip' instruction for the actual call.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."

	"This is the assembled instruction jr ip. 
	 This will break if we change the assignment of registers
	 It can be obtained with 
		self jumpTo: ConcreteIPReg withOffset: 0 andStorePreviousPCPlus4in: LR"

	<inline: true>
	self flag: #TODO.
	^ self
		rewriteFullTransferAt: callSiteReturnAddress
		target: callTargetAddress
		expectedInstruction: 16rE12FFF3C
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteConditionalJumpLongAt: callSiteReturnAddress target: callTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to reset the 
	jumps in the prototype CPIC to suit each use,.   
	Answer the extent of the code change which is used to compute the range of the icache to flush."
	self flag: #TODO.
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
CogRiscV64Compiler >> rewriteJumpFullAt: jumpFullReturnAddress target: jumpFullTargetAddress [
	"Rewrite a full jump instruction to jump to a different target.  This variant
	 is used to rewrite cached primitive calls where we load the target address into ip
	 and use the 'jr ip' instruction for the actual jump.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."
	
	"This is the assembled instruction jr ip. 
	 This will break if we change the assignment of registers
	 It can be obtained with 
		self jumpToRegisterValue: ConcreteIPReg."
		
	<inline: true>
	self flag: #TODO.
	"1halt."
	^ self
		rewriteFullTransferAt: jumpFullReturnAddress 
		target: jumpFullTargetAddress
		expectedInstruction: 16r00028067 

]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> rewriteJumpLongAt: jumpReturnAddress target: jumpTargetAddress [
	"Rewrite a jump instruction to call a different target.  This variant is used to link PICs 
	 in ceSendMiss et al, and to rewrite jumps in CPICs.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| jumpDistance offsetLow offsetHigh instr |
	self flag: #TODO.
	jumpTargetAddress >= cogit minCallAddress
		ifFalse: [self error: 'linking callsite to invalid address'].
	jumpDistance := (jumpTargetAddress - (jumpReturnAddress - 8 "return offset")).
	self assert: (self isInLongJumpCallRange: jumpDistance).

	instr := self instructionBeforeAddress: jumpReturnAddress.
	self assert: (self instructionIsJALR: instr).
	"Need to modify the whole instructions -> auipc + jalr"
	
	"This mangling avoid having to bias the 11th bit in case of a negative value
	 it is also used in loadImmediate:inRegister:"
	"https://github.com/llvm/llvm-project/blob/4c3d916c4bd2a392101c74dd270bd1e6a4fec15b/llvm/lib/Target/RISCV/MCTargetDesc/RISCVMatInt.cpp"
	offsetLow := self computeSignedValue64Bits: (jumpDistance bitAnd: 16rFFF).
	offsetHigh := (((self computeSignedValue64Bits: jumpDistance) + 16r800) >> 12) bitAnd: 16rFFFFF.

	"auipc"
	objectMemory
		long32At: (self instructionAddressBefore: jumpReturnAddress - 4)
		put: (self addUpperImmediateToPC: offsetHigh toRegister: ConcreteIPReg).
	"jalr"
	objectMemory
		long32At: (self instructionAddressBefore: jumpReturnAddress)
		put: (self jumpTo: ConcreteIPReg withOffset: offsetLow andStorePreviousPCPlus4in: X0).

	self assert: (self jumpLongTargetBeforeFollowingAddress: jumpReturnAddress) = jumpTargetAddress.
	
	^8
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> rewriteOpcode: anOpcode with: left with: right [
	<inline: true>
	opcode := anOpcode.
	operands
		"0 is target"
		at: 1 put: left;
		at: 2 put: right
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> rotateLeftValueInRegister: srcReg byShiftAmount: shamt inRegister: destReg startingAtIndex: index [

	"roli: not defined in RISCV64G but can expand to: 
	slli rd, rs1, shamt           | x[rs1] >> shamt             (1)
	srli temp, rs1, (-shamt & 63) | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp               | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	"https://stackoverflow.com/questions/55394123/how-do-i-write-rotation-operation-for-the-risc-vassembly-language-do-we-have-a"
	self assert: shamt > 0.
	self assertValue: shamt isContainedIn: 6. "6 bits for RV64, 5 or RV32"
	self flag: #TODO.
	"Notice that srcReg is the same as destReg"
	self machineCodeAt: index put: (self shiftLeftValueInRegister: srcReg byShiftAmount: shamt intoRegister: ConcreteIPReg2).
	self machineCodeAt: index + 4 put: (self shiftRightValueInRegister: srcReg byShiftAmount: (shamt negated bitAnd: 16r3f) intoRegister: destReg). 
	self machineCodeAt: index + 8 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 12
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> rotateLeftValueInRegister: srcReg byShiftAmountInRegister: shamtReg inRegister: destReg startingAtIndex: index [

	"rol: not defined in RISCV64G but can expand to: 
	sll rd, rs1, rshamt          | x[rs1] >> shamt             (1)
	sub temp, zero, rshamt       | 
	srl temp, rs1, temp          | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp              | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	
	self flag: #TODO.
	self machineCodeAt: 0 put: (self shiftLeftValueInRegister: srcReg byShiftAmountInRegister: shamtReg intoRegister: ConcreteIPReg2).
	self machineCodeAt: 4 put: (self negateValueInRegister: shamtReg intoRegister: destReg).
	self machineCodeAt: 8 put: (self shiftRightValueInRegister: srcReg byShiftAmountInRegister: destReg intoRegister: destReg).
	self machineCodeAt: 12 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 16
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> rotateRightValueInRegister: srcReg byShiftAmount: shamt inRegister: destReg startingAtIndex: index [

	"rori: not defined in RISCV64G but can expand to: 
	srli rd, rs1, shamt           | x[rs1] >> shamt             (1)
	slli temp, rs1, (-shamt & 63) | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp               | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	| negatedShamt |
	"https://stackoverflow.com/questions/55394123/how-do-i-write-rotation-operation-for-the-risc-vassembly-language-do-we-have-a"
	self assert: shamt > 0.
	self assertValue: shamt isContainedIn: 6. "6 bits for RV64, 5 or RV32"
	self flag: #TODO.
	self machineCodeAt: 0 put: (self shiftRightValueInRegister: srcReg byShiftAmount: shamt intoRegister: ConcreteIPReg2).
	self machineCodeAt: 4 put: (self shiftLeftValueInRegister: srcReg byShiftAmount: (shamt negated bitAnd: 16r3f) intoRegister: destReg).
	self machineCodeAt: 8 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 12
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> rotateRightValueInRegister: srcReg byShiftAmountInRegister: shamtReg inRegister: destReg startingAtIndex: index [

	"ror: not defined in RISCV64G but can expand to: 
	srl rd, rs1, rshamt          | x[rs1] >> shamt             (1)
	sub temp, zero, rshamt       | 
	sll temp, rs1, temp          | x[rs1] << (xlen - shamt)    (2)
	or rd, rd, temp              | (1) or (2)
	
	Note only the lowest 6 bits of the shamt are taken in consideration.
	Note ConcreteIPReg2 is used because the concretization uses ConcreteIPReg to load the immediate/literal if needed.
	"
	
	self flag: #TODO.
	self machineCodeAt: 0 put: (self shiftRightValueInRegister: srcReg byShiftAmountInRegister: shamtReg intoRegister: ConcreteIPReg2).
	self machineCodeAt: 4 put: (self negateValueInRegister: shamtReg intoRegister: destReg).
	self machineCodeAt: 8 put: (self shiftLeftValueInRegister: srcReg byShiftAmount: destReg intoRegister: destReg).
	self machineCodeAt: 12 put: (self bitwiseOrBetweenRegister: ConcreteIPReg2 andRegister: destReg toRegister: destReg).
	^ machineCodeSize := 16
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> setOneIn: destReg ifUnsignedValueIn: srcReg isLessThanImmediate: anImmediate [

	"sltiu: Compares x[rs1] and the sign-extended immediate as unsigned numbers, 
	       and writes 1 to x[rd] if x[rs1] is smaller or 0 if not.
 	
	 31               20 19   15 14  12 11    7 6        0
	|  immediate[11:0]  |  rs1  |  011  |  rd  |  0010011  |
	"

	self flag: #TODO.	
	^ (((((anImmediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r011 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> setOneIn: destReg ifUnsignedValueIn: srcReg1 isLessThanUnsignedValueIn: srcReg2 [

	"sltu: Compares x[rs1] and x[rs2] as two's complement numbers, and writes 1 to x[rd]
	      if x[rs1] is smaller or 0 if not.
 	
	 31       25 24   20 19   15 14  12 11    7 6        0
	|  0000000  |  rs2  |  rs1  |  011  |  rd  |  0110011  |
	"

	self flag: #TODO.	
	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r011 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> setOneIn: destReg ifValueIn: srcReg isLessThanImmediate: anImmediate [

	"slti: Compares x[rs1] and the sign-extended immediate as two's complement numbers, 
	       and writes 1 to x[rd] if x[rs1] is smaller or 0 if not.
 	
	 31               20 19   15 14  12 11    7 6        0
	|  immediate[11:0]  |  rs1  |  010  |  rd  |  0010011  |
	"

	self flag: #TODO.	
	^ (((((anImmediate bitAnd: 16rfff) << 20)
	  bitOr: (srcReg bitAnd: 16r1f) << 15)
	  bitOr: (2r010 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> setOneIn: destReg ifValueIn: srcReg1 isLessThanValueIn: srcReg2 [

	"slt: Compares x[rs1] and x[rs2] as two's complement numbers, and writes 1 to x[rd]
	      if x[rs1] is smaller or 0 if not.
 	
	 31       25 24   20 19   15 14  12 11    7 6        0
	|  0000000  |  rs2  |  rs1  |  010  |  rd  |  0110011  |
	"

	self flag: #TODO.	
	^ (((((srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r010 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> setOneIn: destReg ifValueInRegisterIsEqualToZero: srcReg [

	"seqz: Writes 1 to x[rd] if x[rs1] is equal to 0, or 0 if not.
	 Expands to sltiu rd, rs1, 1
	"

	self flag: #TODO.	
	^ self setOneIn: destReg ifUnsignedValueIn: srcReg isLessThanImmediate: 1
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> setOneIn: destReg ifValueInRegisterIsNotEqualToZero: srcReg [

	"seqz: Writes 0 to x[rd] if x[rs1] is equal to 0, or 1 if not.
	 Expands to sltiu rd, rs1, 1
	"

	self flag: #TODO.	
	^ self setOneIn: destReg ifUnsignedValueIn: X0 isLessThanUnsignedValueIn: srcReg
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> shiftLeftValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"slli: Shifts register x[rs1] left by shamt bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  000000 |  shamt  |  rs1  |  001  |  rd  |  0010011  |
	"
	| signExtendedShamt |
	self flag: #TODO.
	"Check size and sign"
	self assertValue: shiftAmount isContainedIn: 6.
	signExtendedShamt := self computeSignedValueOf: shiftAmount ofSize: 6.
	^ (((((signExtendedShamt bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: (2r001 << 12))
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> shiftLeftValueInRegister: sourceReg1 byShiftAmountInRegister: sourceReg2 intoRegister: destReg [ 

	"sll: Shifts register x[rs1] left by x[rs2] bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31      25 24   20 19   15 14   12 11   7 6         0
	|  0000000 |  rs2  |  rs1  |  001  |  rd  |  0110011  |
	"

	self flag: #DONE.
	^ ((((2r000000 << 25
	  bitOr: (sourceReg2 bitAnd: 16r1f) << 20) 
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r001 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> shiftRightValueInRegister: sourceReg byShiftAmount: shiftAmount intoRegister: destReg [ 

	"srli: Shifts register x[rs1] right by shamt bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31     26 25     20 19   15 14   12 11   7 6         0
	|  000000 |  shamt  |  rs1  |  101  |  rd  |  0010011  |
	"
	| signExtendedShamt |
	self flag: #DONE.
	"Check size and sign"
	self assertValue: shiftAmount isContainedIn: 6.
	signExtendedShamt := self computeSignedValueOf: shiftAmount ofSize: 6.
	^ (((((signExtendedShamt bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0010011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> shiftRightValueInRegister: sourceReg1 byShiftAmountInRegister: sourceReg2 intoRegister: destReg [ 

	"srl: Shifts register x[rs1] right by x[rs2] bit positions. 
	 The vacated bits are filled with zeros, and the result is written to x[rd].
	
	 31      25 24   20 19   15 14   12 11   7 6         0
	|  0000000 |  rs2  |  rs1  |  101  |  rd  |  0110011  |
	"

	self flag: #DONE.
	^ (((((sourceReg2 bitAnd: 16r3f) << 20) 
	  bitOr: (sourceReg1 bitAnd: 16r1f) << 15)
	  bitOr: (2r101 << 12)) 
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> signExtendValue: value forSize: size [
	
	| mask |
	self flag: #TODO.
	"Reverse two's complement"
	mask := (1 << size) - 1. "check sign bit"
	^ (value allMask: (1 << (size - 1)))
		ifTrue: [ (mask - value + 1) negated ] "invert add 1 and return negated value"
		ifFalse: [ value ]
]

{ #category : #accessing }
CogRiscV64Compiler >> stackPageInterruptHeadroomBytes [
	"Return a minimum amount of headroom for each stack page (in bytes).  In a
	 JIT the stack has to have room for interrupt handlers which will run on the stack.
	According to ARM architecture v5 reference manual chapter A2.6, the basic interrupt procedure does not push anything onto the stack. It uses SPSR_err and R14_err to preserve state. Afterwards, it calls an interrupt procedure. So leave some room."
	^128 "32 words"
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> stackPointerAlignment [
	
	<doNotGenerate>
	"As for the RISC-V Architecture Reference Manual:
	In the standard RISC-V calling convention, the stack grows downward and the stack pointer is always kept 16-byte aligned"
	self flag: #DONE.
	^ 16
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> stop [

	"ebreak: Environment breakpoint, makes a request of the debugger by raising a BREAKPOINT exception" 
	self flag: #DONE.
	^ ((((2r0000000000001 << 20)
	  bitOr: 2r00000 << 15)
	  bitOr: 2r000 << 12)
	  bitOr: 2r00000 << 7)
	  bitOr: 2r1110011
]

{ #category : #'concretization helpers' }
CogRiscV64Compiler >> stopsFrom: startAddr to: endAddr [

	self flag: #TODO.
	self assert: endAddr - startAddr + 1 \\ 4 = 0.
	startAddr to: endAddr by: 4 do: 
		[:addr | objectMemory long32At: addr put: self stop].
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> storeByteFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sb: Stores the least-significant byte in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  000   |  offset[4:0]  |   0100011  |
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
CogRiscV64Compiler >> storeDoubleWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sd: Stores the eight bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11              7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  011   |   offset[4:0]   |   0100011  |
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
CogRiscV64Compiler >> storeHalfWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sw: Stores the two lteast-significant bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  001   |  offset[4:0]  |   0100011  |
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

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> storeLiteral: literal beforeFollowingAddress: followingAddress [
	"Rewrite the long constant loaded by the instruction sequence just before this address:"
	^self subclassResponsibility
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> storeWordFromRegister: sourceRegister toAddressInRegister: destinationAddressRegister withOffset: offset [

	"sw: Stores the four lteast-significant bytes in register x[rs2] to memory at address x[rs1] + sign-extend(offset).
	
	 31            25 24     20 19     15 14    12 11            7 6          0
	|  	offset[11:5]  |   rs2   |   rs1   |  010   |  offset[4:0]  |   0100011  |
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

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> subtractRegister: srcReg2 fromRegister: srcReg1 intoRegister: destReg [

	"sub: Substracts register x[rs2] from register x[rs1] and writes the result to x[rd].
	 Arithmetic overflow is ignored.
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0100000  |  rs2  |  rs1  |  000  |   rd   |  0110011  |
	"
	
	self flag: #DONE.		
	^ ((((2r0100000 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0110011 
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> subtractWordRegister: srcReg2 fromRegister: srcReg1 intoRegister: destReg [

	"subw: Substracts register x[rs2] from register x[rs1], truncates the result to 32 bits 
	 and writes the sign-extended result to x[rd].
	 Arithmetic overflow is ignored.
	
	 31       25 24   20 19   15 14   12 11     7 6         0
	|  	0100000  |  rs2  |  rs1  |  000  |   rd   |  0111011  |
	"

	self flag: #DONE.	
	^ ((((2r0100000 << 25)
	  bitOr: (srcReg2 bitAnd: 16r1f) << 20)
	  bitOr: (srcReg1 bitAnd: 16r1f) << 15)
	  bitOr: (destReg bitAnd: 16r1f) << 7)
	  bitOr: 2r0111011
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

{ #category : #concretization }
CogRiscV64Compiler >> updateFlagsADDForSourceReg: srcReg resultReg: resReg andMoveResultTo: destReg startingAtIndex: index [

	self flag: #DONE.
	"1. Carry Flag: set 1 if A is smaller than B as unsigned numbers, 0 otherwise"
	self machineCodeAt: index put: (self setOneIn: ConcreteCarryReg ifUnsignedValueIn: resReg isLessThanUnsignedValueIn: srcReg).
	"2. Sign Flag: set 1 if the most significatn bit of the result is 1 (result negative)"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"3. Move result to the destination register"
	self machineCodeAt: index + 8 put: (self moveRegister: resReg toRegister: destReg).
	"4. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 16
]

{ #category : #concretization }
CogRiscV64Compiler >> updateFlagsCMPForSourceReg: srcReg resultReg: resReg startingAtIndex: index [

	self flag: #DONE.
	"1. Carry Flag: set 1 if A is smaller than B as unsigned numbers, 0 otherwise"
	self machineCodeAt: index put: (self setOneIn: ConcreteCarryReg ifUnsignedValueIn: srcReg isLessThanUnsignedValueIn: resReg).
	"2. Sign Flag: set 1 if the most significatn bit of the result is 1 (result negative)"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"3. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 8 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 12
]

{ #category : #concretization }
CogRiscV64Compiler >> updateFlagsLogicForResultReg: resReg startingAtIndex: index [

	self flag: #TODO.
	"1. Overflow Flag: set to 0"	
	self machineCodeAt: index put: (self moveRegister: X0  toRegister: ConcreteOverflowReg).
	"2. Carry Flag: set to 0"
	self machineCodeAt: index + 4 put: (self moveRegister: X0  toRegister: ConcreteCarryReg).
	"3. Sign Flag: set it as the most significant bit of the result"
	self machineCodeAt: index + 8 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"4. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 16
]

{ #category : #concretization }
CogRiscV64Compiler >> updateFlagsSUBForSourceReg: srcReg resultReg: resReg andMoveResultTo: destReg startingAtIndex: index [

	self flag: #DONE. 
	"1. Carry Flag: set 1 if A is smaller than B as unsigned numbers, 0 otherwise"
	self machineCodeAt: index put: (self setOneIn: ConcreteCarryReg ifUnsignedValueIn: srcReg isLessThanUnsignedValueIn: resReg).
	"2. Sign Flag: set 1 if the most significatn bit of the result is 1 (result negative)"
	self machineCodeAt: index + 4 put: (self setOneIn: ConcreteSignReg ifValueIn: resReg isLessThanImmediate: 0).
	"3. Move result to the destination register"
	self machineCodeAt: index + 8 put: (self moveRegister: resReg toRegister: destReg).
	"4. Zero flag: Replace the result of the subtraction with 1 if it is 0, 0 otherwise"
	self machineCodeAt: index + 12 put: (self setOneIn: ConcreteZeroReg ifValueInRegisterIsEqualToZero: resReg).
	^ machineCodeSize := 16
	
]

{ #category : #'helpers - size sign' }
CogRiscV64Compiler >> value: value isContainedIn: size [ 

	<inline: true>
	| mask twosComplement |
	self flag: #TODO.
	mask := (1 << size) - 1.
	twosComplement := mask - value abs + 1.
	(value >= 0)
		ifTrue: [ ^ (value bitAnd: mask) = value ]
		ifFalse: [ ^ (twosComplement >= 0 and: [twosComplement <= mask]) ]	
]

{ #category : #'machine code instruction' }
CogRiscV64Compiler >> zeroConditionalBranch: condition withOffset: offset [ 

	"Return a bnez or beqz comparing with the zero flag register"
	self flag: #TODO.
	^ self branchTo: offset ifCondition: condition betweenRegister: ConcreteZeroReg andRegister: X0
]

{ #category : #'inline cacheing' }
CogRiscV64Compiler >> zoneCallsAreRelative [
	"Answer if Call and JumpLong are relative and hence need to take the caller's
	 relocation delta into account during code compaction, rather than just the
	 callee's delta."
	^true
]
