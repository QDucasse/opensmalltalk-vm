Class {
	#name : #CogOutOfLineLiteralsRiscV64Compiler,
	#superclass : #CogRiscV64Compiler,
	#category : #'VMMaker-JIT'
}

{ #category : #'accessing class hierarchy' }
CogOutOfLineLiteralsRiscV64Compiler class >> literalsManagerClass [
	^OutOfLineLiteralsManager
]

{ #category : #accessing }
CogOutOfLineLiteralsRiscV64Compiler >> cmpC32RTempByteSize [
	^ 8
]

{ #category : #concretization }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeLiteral [
	"Generate an out-of-line literal.  Copy the value and any annotation from the stand-in in the literals manager."
	| twoComplement literal literalAsInstruction |
	self flag: #TODO.
	"Process the literal if it is an instruction"
	literalAsInstruction := cogit cCoerceSimple: (operands at: 0) to: #'AbstractInstruction *'.
	literal := (self isAnInstruction: literalAsInstruction)
				ifTrue: [literalAsInstruction address]
				ifFalse: [self cCode: [literalAsInstruction asUnsignedInteger]
							inSmalltalk: [literalAsInstruction]].
	"Get the address"
	self assert: (dependent notNil and: [dependent opcode = Literal]).
	dependent annotation ifNotNil:
	[self assert: annotation isNil.
		 annotation := dependent annotation].
	dependent address ifNotNil: [self assert: dependent address = address].
	dependent address: address.
	"Write the actual literal"
	twoComplement := literal < 0
		ifTrue: [ 16rFFFFFFFFFFFFFFFF - literal abs + 1 ]
		ifFalse: [ literal ].

	self machineCodeAt: 0 put: (twoComplement bitAnd: 16rFFFFFFFF).
	self machineCodeAt: 4 put: (twoComplement >> 32).
	machineCodeSize := 8
]

{ #category : #concretization }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMovePatcheableC32R [
	
	| literalAddress distance |
	literalAddress := (cogit cCoerceSimple: dependent to: #'AbstractInstruction *') address.
	distance := literalAddress - address.
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: 0 inRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self
	  loadDoubleWordFromAddressInRegister: ConcreteIPReg
	  withOffset: distance
     inRegister: (operands at: 1)).
	^ machineCodeSize := 8
]

{ #category : #simulation }
CogOutOfLineLiteralsRiscV64Compiler >> configureStackAlignment [
	
	<doNotGenerate>
	"Acording to RISC-V ISA description, stack should always be kept 16-byte aligned"
	self flag: #DONE.
	cogit setStackAlignment: 16 expectedSPOffset: 0 expectedFPOffset: 0.
]

{ #category : #accessing }
CogOutOfLineLiteralsRiscV64Compiler >> getDefaultCogCodeSize [
	"Return the default number of bytes to allocate for native code at startup.
	 The actual value can be set via vmParameterAt: and/or a preference in the ini file."
	<inline: true>
	^1024 * 1280
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> inlineCacheTagAt: callSiteReturnAddress [

	<inline: true>
	self flag: #TODO.
	^objectMemory unsignedLongAt: (self pcRelativeAddressAt: 
		"Need to go before the call and at the start of the literal load"
		(callSiteReturnAddress - self callInstructionByteSize - self loadLiteralByteSize) asUnsignedInteger)
]

{ #category : #testing }
CogOutOfLineLiteralsRiscV64Compiler >> isPCDependent [
	"Answer if the receiver is a pc-dependent instruction.  With out-of-line literals any instruction
	 that refers to a literal depends on the address of the literal, so add them in addition to the jumps."
	^self isJump
	  or: [opcode = AlignmentNops
	  or: [opcode ~= Literal and: [dependent notNil and: [dependent opcode = Literal]]]]
]

{ #category : #'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> isSharable [
	"Hack:  To know if a literal should be unique (not shared) mark the second operand."
	<inline: true>
	self assert: opcode = Literal.
	^operands at: 1
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> literal32BeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress.
	 Used for CMP32"
	self flag: #TODO.
	^ self literalBeforeFollowingAddress: followingAddress 
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> literalBeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress.
	 If followingAddress points to an ld instruction, it means it is loading a relative using auipc + ld.
	 If not, it is comparing to a given literal and is performing auipc + ld + cmp (expands to several instructions in riscv)"
	self flag: #TODO.
	^objectMemory long64At: (self pcRelativeAddressAt: 
		((self instructionIsLD: (self instructionBeforeAddress: followingAddress))
			ifTrue: [self instructionAddressBefore: followingAddress - 4] "need to go before auipc + ld"
			ifFalse: [ self instructionAddressBefore: followingAddress + 4 ])) "need to go in the load at the beginning of the cmp"
]

{ #category : #'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> literalOpcodeIndex [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	^(operands at: 2) asInteger
]

{ #category : #accessing }
CogOutOfLineLiteralsRiscV64Compiler >> loadLiteralByteSize [
	"Answer the byte size of a MoveCwR opcode's corresponding machine code. On ARM this is a single instruction pc-relative register load - unless we have made a mistake and not turned on the out of line literals manager"
	self flag: #DONE.
	^8
]

{ #category : #'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> mapEntryAddress [
	"Typically map entries apply to the end of an instruction, for two reasons:
	  a)	to cope with literals embedded in variable-length instructions, since, e.g.
		on x86, the literal typically comes at the end of the instruction.
	  b)	in-line cache detection is based on return addresses, which are typically
		to the instruction following a call.
	 But with out-of-line literals it is more convenient to annotate the literal itself."
	<inline: true>
	^opcode = Literal
		ifTrue: [address]
		ifFalse: [address + machineCodeSize]
]

{ #category : #'compile abstract instructions' }
CogOutOfLineLiteralsRiscV64Compiler >> outOfLineLiteralOpcodeLimit [
	"The maximum offset in a LDR is (1<<12)-1, or (1<<10)-1 instructions.
	 Be conservative.  The issue is that one abstract instruction can emit
	 multiple hardware instructions so we assume a 2 to 1 worst case of
	 hardware instructions to abstract opcodes.."
	self flag: #TODO.
	"1halt."
	^1 << (12 "12-bit offset field"
			- 3 "8 bytes per literal, so 2^3?"
			- 1 "2 hardware instructions to 1 abstract opcode") - 1
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> pcRelativeAddressAt: instrAddress [
	"Extract the address out of a pc-relative load (auipc + ld)"
	
	| instAUIPC instLD offsetAUIPC offsetLD |
	self flag: #TODO.
	"1halt."
	instAUIPC := objectMemory long32At: instrAddress.
	instLD := objectMemory long32At: instrAddress + 4.
	self assert: (self instructionIsAUIPC: instAUIPC).
	self assert: (self instructionIsLD: instLD).
	"Each offset is sign-extended then added"
	offsetAUIPC := self computeSignedValueOf: (instAUIPC >> 12 bitAnd: 16rfffff) << 12 ofSize: 32. "20 upper bits"
	offsetLD := self computeSignedValueOf: (instLD >> 20 bitAnd: 16rfff) ofSize: 32. "12 lower bits"
	"((offset allMask: (1 << 12))
						   ifTrue: [offset negated]
							ifFalse: [offset])"
	^instrAddress + offsetAUIPC + offsetLD
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> relocateMethodReferenceBeforeAddress: pc by: delta [
	"If possible we generate the method address using pc-relative addressing.
	 If so we don't need to relocate it in code.  So check if pc-relative code was
	 generated, and if not, adjust a load literal.  There are two cases, a push
	 or a register load.  If a push, then there is a register load, but in the instruction
	 before."
	| pcFollowingLoad reference litAddr |
	"PushCw expands to addi sp -8 then sd rd 0(sp)"
	pcFollowingLoad := ((self instructionIsADDI: (self instructionBeforeAddress: pc - 4)) and: 
								[ self instructionIsSD: (self instructionBeforeAddress: pc) ])
							ifTrue:  [ pc-8 ]
							ifFalse: [ pc ].
	"If the load is not done via pc-relative addressing we have to relocate."
	(self isLiteralLoad: pcFollowingLoad) 
		ifTrue: "auipc + ld"
			[litAddr := self pcRelativeAddressAt: pcFollowingLoad - self loadLiteralByteSize.
		 	 reference := objectMemory long64At: litAddr.
		    objectMemory long64At: litAddr put: reference + delta - 4]
		ifFalse: "auipc + addi"
			[ "no need to relocate"
			  self assert: (self instructionIsAUIPC: (self instructionBeforeAddress: pcFollowingLoad - 4)). 
		     self assert: (self instructionIsADDI: (self instructionBeforeAddress: pcFollowingLoad)) ]
	



]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteFullTransferAt: callSiteReturnAddress target: callTargetAddress expectedInstruction: expectedInstruction [
	"Rewrite a CallFull or JumpFull instruction to transfer to a different target.
	 This variant is used to rewrite cached primitive calls where we load the target address into ip
	 and use the 'jr ip' or 'jalr ip' instruction for the actual jump or call.
	 Answer the extent of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	self assert: (self instructionBeforeAddress: callSiteReturnAddress) = expectedInstruction.
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 12) put: callTargetAddress.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^0
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteInlineCacheAt: callSiteReturnAddress tag: cacheTag target: callTargetAddress [
	"Rewrite an inline cache to call a different target for a new tag.  This variant is used
	 to link unlinked sends in ceSend:to:numArgs: et al.  Answer the extent of the code
	 change which is used to compute the range of the icache to flush.
	
	 Call:
	 auipc offsetHigh 
	 jalr offsetLow 
	 ... <-- callSiteReturnAddress
	
	 Cache:
	 cacheTag <-- pcRelativeAddress from call"
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| codeChange |
	"Patch call"
	codeChange := self rewriteCallAt: callSiteReturnAddress target: callTargetAddress.
	"Patch tag referenced by earlier call"
	objectMemory
		longAt: (self pcRelativeAddressAt: callSiteReturnAddress - self callInstructionByteSize - self loadLiteralByteSize) 
		put: cacheTag signedIntToLong64.

	self assert: (self inlineCacheTagAt: callSiteReturnAddress) = cacheTag  signedIntToLong64.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^ codeChange
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteInlineCacheTag: cacheTag at: callSiteReturnAddress [
	"Rewrite an inline cache with a new tag.  This variant is used by the garbage collector."
	<inline: true>
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: cacheTag
]

{ #category : #'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> setLiteralOpcodeIndex: index [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	operands at: 2 put: index
]

{ #category : #'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> sizePCDependentInstructionAt: eventualAbsoluteAddress [
	"Size a jump and set its address.  The target may be another instruction
	 or an absolute address.  On entry the address inst var holds our virtual
	 address. On exit address is set to eventualAbsoluteAddress, which is
	 where this instruction will be output.  The span of a jump to a following
	 instruction is therefore between that instruction's address and this
	 instruction's address ((which are both still their virtual addresses), but the
	 span of a jump to a preceding instruction or to an absolute address is
	 between that instruction's address (which by now is its eventual absolute
	 address) or absolute address and eventualAbsoluteAddress.

	 ARM is simple; the 26-bit call/jump range means no short jumps.  This
	 routine only has to determine the targets of jumps, not determine sizes.

	 This version also deals with out-of-line literals.  If this is the real literal,
	 update the stand-in in literalsManager with the address (because instructions
	 referring to the literal are referring to the stand-in).  If this is annotated with
	 IsObjectReference transfer the annotation to the stand-in, whence it will be
	 transferred to the real literal, simplifying update of literals."

	opcode = AlignmentNops ifTrue:
		[| alignment |
		 address := eventualAbsoluteAddress.
		 alignment := operands at: 0.
		 ^machineCodeSize := (eventualAbsoluteAddress + (alignment - 1) bitAnd: alignment negated)
							   - eventualAbsoluteAddress].
	self assert: (self isJump or: [opcode = Call or: [opcode = CallFull
				or: [dependent notNil and: [dependent opcode = Literal]]]]).
	self isJump ifTrue: [self resolveJumpTarget].
	address := eventualAbsoluteAddress.
	(dependent notNil and: [dependent opcode = Literal]) ifTrue:
		[opcode = Literal ifTrue:
			[dependent address: address].
		 annotation = cogit getIsObjectReference ifTrue:
			[dependent annotation: annotation.
			 annotation := nil]].
	^machineCodeSize := maxSize
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> storeLiteral32: literal beforeFollowingAddress: followingAddress [
	"Rewrite the literal in the instruction immediately preceding followingAddress"
	^ self storeLiteral: literal beforeFollowingAddress: followingAddress
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> storeLiteral: literal beforeFollowingAddress: followingAddress [
	"Rewrite the literal referenced by the instruction immediately preceding followingAddress.
	 If followingAddress points to an ld instruction, it means it is loading a relative using auipc + ld."
	self assert: (self instructionIsAUIPC: (self instructionBeforeAddress: followingAddress - 4)).
	self assert: (self instructionIsLD: (self instructionBeforeAddress: followingAddress)).
	objectMemory
		longAt: (self pcRelativeAddressAt: (self instructionAddressBefore: followingAddress - 4))
		put: literal
]

{ #category : #'concretization helpers' }
CogOutOfLineLiteralsRiscV64Compiler >> updateLabel: labelInstruction [
	opcode ~= Literal ifTrue:
		[super updateLabel: labelInstruction]
]

{ #category : #testing }
CogOutOfLineLiteralsRiscV64Compiler >> usesOutOfLineLiteral [
	"Answer if the receiver uses an out-of-line literal.  Needs only
	 to work for the opcodes created with gen:literal:operand: et al.
	
	 Note that it will provide the 'dependent' in concretization"
	
	<var: #offset type: 'sqInt'>
	opcode
		caseOf: {
		[CallFull]		   -> [^true].
		[JumpFull]		   -> [^true].
		"CqR operations try to constant in an immediate, otherwise fallback in load literal (like Cw)"
		[AddCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not]. 
		[AddCheckOverflowCqR ] -> [^ (self value: (operands at: 0) isContainedIn: 12) not]. 
		[AndCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[AndCqRR]              -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[CmpCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 11) not]. "uses load immediate"
		[CmpC32R]              -> [^ true]. 
		[OrCqR]                -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[SubCqR]               -> [^ (self value: ((operands at: 0) negated) isContainedIn: 12) not]. 
	   [SubCheckOverflowCqR ] -> [^ (self value: ((operands at: 0) negated) isContainedIn: 12) not]. 
		[TstCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[XorCqR]               -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[LoadEffectiveAddressMwrR] -> [^ (self value: (operands at: 0) isContainedIn: 12) not]. 
		"CwR operations use a word size value and need a full literal load"
		[AddCwR]		-> [^true].
		[AndCwR]		-> [^true].
		[CmpCwR]		-> [^true].
		[OrCwR]		-> [^true].
		[SubCwR]		-> [^true].
		[XorCwR]		-> [^true].
		"Data Movement - Moves"						
		[MoveCqR]		-> [^ (self value: (operands at: 0) isContainedIn: 11) not]. "11 because uses loadImmediate:inRegister:"
		[MoveC32R]  -> [ self shouldBeImplemented ].
		"Data Movement - Absolute addresses"
		[MoveCwR]		-> [^ (self inCurrentCompilation: (operands at: 0)) not].
		[MoveAwR]		-> [^(self isAddressRelativeToVarBase: (operands at: 0)) not].
		[MoveRAw]		-> [^(self isAddressRelativeToVarBase: (operands at: 1)) not].
		[MoveAbR]		-> [^(self isAddressRelativeToVarBase: (operands at: 0)) not].
		[MoveRAb]		-> [^(self isAddressRelativeToVarBase: (operands at: 1)) not].
		"Data Movement - Stores"
		[MoveRMbr]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRM8r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRM16r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRM32r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRMwr]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not].
		[MoveRsM32r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not]. 												
		[MoveRdM64r]	-> [^ (self value: (operands at: 1) isContainedIn: 12) not]. 
		"Data Movement - Loads"
		[MoveMbrR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM8rR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM16rR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM32rR] -> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveMwrR]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM32rRs]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
		[MoveM64rRd]	-> [^ (self value: (operands at: 0) isContainedIn: 12) not].
								
		[PushCw]		-> [^ (self inCurrentCompilation: (operands at: 0)) not].
		[PushCq]		-> [^(self value: (operands at: 0) isContainedIn: 11) not]. "11 because uses loadImmediate:"
		[PrefetchAw] 	-> [^(self isAddressRelativeToVarBase: (operands at: 0)) not].

		"Patcheable instruction. Moves a literal. Uses out of line literal."
		[MovePatcheableC32R] -> [ ^ true ]
		}
		otherwise: [self error: 'We should not be here!!!'].
	^false "to keep C compiler quiet"

]
