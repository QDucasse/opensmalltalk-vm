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
	
	self flag: #TODO.
	1halt.
	^ 48
]

{ #category : #'generate machine code - concretize' }
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

{ #category : #'as yet unclassified' }
CogOutOfLineLiteralsRiscV64Compiler >> concretizeMovePatcheableC32R [
	
	| literalAddress distance |
	
	self flag: #TODO.
	self assert: dependent isNotNil.
	literalAddress := (cogit cCoerceSimple: dependent to: #'AbstractInstruction *') address.
	distance := literalAddress - address.
	self machineCodeAt: 0 put: (self addUpperImmediateToPC: 0 toRegister: ConcreteIPReg).
	self machineCodeAt: 4 put: (self
					 loadDoubleWordFromAddressInRegister: ConcreteIPReg
					 withOffset: distance
					 toRegister: (operands at: 1)).
	^ machineCodeSize := 8
]

{ #category : #simulation }
CogOutOfLineLiteralsRiscV64Compiler >> configureStackAlignment [
	
	<doNotGenerate>
	"Acording to RISC-V ISA description, stack should always be kept 16-byte aligned"
	cogit setStackAlignment: 16 expectedSPOffset: 0 expectedFPOffset: 0.
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> extractLiteralFromCMP32: instrAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress.
	 Used for CMP32."
	| instLUI instADDIW instSLLI instADDI offsetLUI offsetADDIW shiftAmount offsetADDI |
	self flag: #TODO.
	"Extract LUI"
	instLUI := objectMemory long32At: instrAddress.
	offsetLUI := self signExtendValue: (instLUI >> 12 bitAnd: 16rfffff) << 12 forSize: 20. "20 upper bits"
	"Extract ADDIW"
	instADDIW := objectMemory long32At: instrAddress + 4.
	offsetADDIW := self signExtendValue: (instADDIW >> 20 bitAnd: 16rfff) forSize: 12. "12 lower bits"
	"Extract SLLI"
	instSLLI := objectMemory long32At: instrAddress + 8.
	shiftAmount := instSLLI >> 20 bitAnd: 16r3F. "shift by shift amount (13)"
	"Extract ADDI"
	1halt.
	instADDI := objectMemory long32At: instrAddress + 12.
	offsetADDI := self signExtendValue: (instADDI >> 20 bitAnd: 16rfff) forSize: 12. "12 lower bits"
	"Each offset is sign-extended then added"
	^ (offsetLUI + offsetADDIW) << shiftAmount + offsetADDI
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
	^objectMemory longAt: (self pcRelativeAddressAt: (callSiteReturnAddress - 8) asUnsignedInteger)
]

{ #category : #testing }
CogOutOfLineLiteralsRiscV64Compiler >> isPCDependent [
	"Answer if the receiver is a pc-dependent instruction.  With out-of-line literals any instruction
	 that refers to a literal depends on the address of the literal, so add them in addition to the jumps."
	^self isJump
	  or: [opcode = AlignmentNops
	  or: [opcode ~= Literal and: [dependent notNil and: [dependent opcode = Literal]]]]
]

{ #category : #'generate machine code - support' }
CogOutOfLineLiteralsRiscV64Compiler >> isSharable [
	"Hack:  To know if a literal should be unique (not shared) mark the second operand."
	<inline: true>
	self assert: opcode = Literal.
	^operands at: 1
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> literal32BeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress.
	 Used for CMP32."
	self flag: #TODO.
	1halt.
	^ self extractLiteralFromCMP32: (self instructionAddressBefore: followingAddress - self cmpC32RTempByteSize + 4)
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> literalBeforeFollowingAddress: followingAddress [
	"Return the literal referenced by the instruction immediately preceding followingAddress."
	self flag: #TODO.
	^objectMemory long64At: (self pcRelativeAddressAt: 
		((self instructionIsLD: (self instructionBeforeAddress: followingAddress))
			ifTrue: [self instructionAddressBefore: followingAddress - 4] "need to go before auipc + ld"
			ifFalse: [ 1halt. ])) "need to go before cmp through literal32BeforeFollowingAddress: "
]

{ #category : #'generate machine code - support' }
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

{ #category : #'generate machine code - support' }
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

{ #category : #'generate machine code - support' }
CogOutOfLineLiteralsRiscV64Compiler >> moveCw: constant intoR: destReg [

	"Emit a load of aWord into destReg. Expands to auipc + ld. Answer the number of bytes of machine code generated.
	 Literals are stored out-of-line"
	 <var: 'constant' type: #usqInt>
	<inline: true>
	self flag: #TODO.
	^ self machineCodeWriteInstructions: (self loadLiteralInRegister: destReg)

]

{ #category : #'compile abstract instructions' }
CogOutOfLineLiteralsRiscV64Compiler >> outOfLineLiteralOpcodeLimit [
	"The maximum offset in a LDR is (1<<12)-1, or (1<<10)-1 instructions.
	 Be conservative.  The issue is that one abstract instruction can emit
	 multiple hardware instructions so we assume a 2 to 1 worst case of
	 hardware instructions to abstract opcodes.."
	^1 << (12 "12-bit offset field"
			- 3 "8 bytes per literal, so 2^3?"
			- 1 "2 hardware instructions to 1 abstract opcode") - 1
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> pcRelativeAddressAt: instrAddress [
	"Extract the address out of a pc-relative load (auipc + ld)"
	
	| instAUIPC instLD offsetAUIPC offsetLD |
	self flag: #TODO.
	1halt.
	instAUIPC := objectMemory long32At: instrAddress.
	instLD := objectMemory long32At: instrAddress + 4.
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
	| pcPrecedingLoad reference litAddr |
	pcPrecedingLoad := (self instructionIsPush: (self instructionBeforeAddress: pc))
							ifTrue: [pc - 4]
							ifFalse: [pc].
	"If the load is not done via pc-relative addressing we have to relocate."
	(self isPCRelativeValueLoad: (self instructionBeforeAddress: pcPrecedingLoad)) ifFalse:
		[litAddr := self pcRelativeAddressAt: pcPrecedingLoad.
		 reference := objectMemory long64At: litAddr.
		 objectMemory long64At: litAddr put: reference + delta - 4]
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteFullTransferAt: callSiteReturnAddress target: callTargetAddress expectedInstruction: expectedInstruction [
	"Rewrite a CallFull or JumpFull instruction to transfer to a different target.
	 This variant is used to rewrite cached primitive calls where we load the target address into ip
	and use the 'bx ip' or 'blx ip' instruction for the actual jump or call.
	Answer the extent
	 of the code change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	self assert: (self instructionBeforeAddress: callSiteReturnAddress) = expectedInstruction.
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: callTargetAddress.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^0
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteInlineCacheAt: callSiteReturnAddress tag: cacheTag target: callTargetAddress [
	"Rewrite an inline cache to call a different target for a new tag.  This variant is used
	 to link unlinked sends in ceSend:to:numArgs: et al.  Answer the extent of the code
	 change which is used to compute the range of the icache to flush."
	<var: #callSiteReturnAddress type: #usqInt>
	<var: #callTargetAddress type: #usqInt>
	| call callDistance |
	self flag: #TODO.
	callTargetAddress >= cogit minCallAddress ifFalse:
		[self error: 'linking callsite to invalid address'].
	callDistance := (callTargetAddress - (callSiteReturnAddress - 4 "return offset")).
	self assert: (self isInImmediateJumpRange: callDistance). "we don't support long call updates here"
	call := self jumpToOffset: callDistance andStorePreviousPCPlus4in: LR.
	objectMemory
		long32At: (self instructionAddressBefore: callSiteReturnAddress ) put: call;
		longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: cacheTag signedIntToLong64.
	self assert: (self inlineCacheTagAt: callSiteReturnAddress) = cacheTag  signedIntToLong64.
	"self cCode: ''
		inSmalltalk: [cogit disassembleFrom: callSiteReturnAddress - 8 to: (self pcRelativeAddressAt: callSiteReturnAddress - 8)]."
	^4
]

{ #category : #'inline cacheing' }
CogOutOfLineLiteralsRiscV64Compiler >> rewriteInlineCacheTag: cacheTag at: callSiteReturnAddress [
	"Rewrite an inline cache with a new tag.  This variant is used
	 by the garbage collector."
	<inline: true>
	objectMemory longAt: (self pcRelativeAddressAt: callSiteReturnAddress - 8) put: cacheTag
]

{ #category : #'generate machine code - support' }
CogOutOfLineLiteralsRiscV64Compiler >> setLiteralOpcodeIndex: index [
	"Hack:  To know how far away a literal is from its referencing instruction we store
	 its opcodeIndex, or -1, if as yet unassigned, in the second operand of the literal."
	<inline: true>
	self assert: opcode = Literal.
	operands at: 2 put: index
]

{ #category : #'generate machine code - support' }
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
CogOutOfLineLiteralsRiscV64Compiler >> storeLiteral: literal beforeFollowingAddress: followingAddress [
	"Rewrite the literal in the instruction immediately preceding followingAddress."
	objectMemory
		longAt: (self pcRelativeAddressAt:
					((self instructionIsLDR: (self instructionBeforeAddress: followingAddress))
						ifTrue: [self instructionAddressBefore: followingAddress]
						ifFalse: [self instructionAddressBefore: followingAddress - 4]))
		put: literal
]

{ #category : #'generate machine code - support' }
CogOutOfLineLiteralsRiscV64Compiler >> updateLabel: labelInstruction [
	opcode ~= Literal ifTrue:
		[super updateLabel: labelInstruction]
]

{ #category : #testing }
CogOutOfLineLiteralsRiscV64Compiler >> usesOutOfLineLiteral [
	"Answer if the receiver uses an out-of-line literal.  Needs only
	 to work for the opcodes created with gen:literal:operand: et al.
	
	 Note that it will provide the 'dependent' in concretization"

	| offset |
	
	<var: #offset type: 'sqInt'>
	self flag: #TODO.
	opcode
		caseOf: {
		[CallFull]		-> [^true].
		[JumpFull]		-> [^true].
		"CqR operations try to constant in an immediate, otherwise fallback in load literal (like Cw)"
		[AddCqR]	   -> [self assertValue: (operands at: 0) isContainedIn: 12 ifTrue:[^ false] ifFalse: [^ true]]. 
		[AndCqR]		-> [self assertValue: (operands at: 0) isContainedIn: 12 ifTrue:[^ false] ifFalse: [^ true]].
		[AndCqRR]		-> [self assertValue: (operands at: 0) isContainedIn: 12 ifTrue:[^ false] ifFalse: [^ true]].
		[CmpCqR]		-> [^ true]. "no subi"
		[CmpC32R]		-> [^ true]. "no subi"
		[OrCqR]		-> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"
		[SubCqR]		-> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"
		[TstCqR]		-> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"
		[XorCqR]		-> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"
		"CwR operations use a word size value and need a full literal load"
		[AddCwR]		-> [^true].
		[AndCwR]		-> [^true].
		[CmpCwR]		-> [^true].
		[OrCwR]		-> [^true].
		[SubCwR]		-> [^true].
		[XorCwR]		-> [^true].
		[LoadEffectiveAddressMwrR]
						-> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"
		"Data Movement"						
		[MoveCqR]		-> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"
		[MoveC32R]  -> [dependent ifNil:[^ false] ifNotNil: [^ true] ]. "TODO"

		[MoveCwR]		-> [^(self inCurrentCompilation: (operands at: 0)) not].
		[MoveAwR]		-> [^(self isAddressRelativeToVarBase: (operands at: 0)) ifTrue: [false] ifFalse: [true]].
		[MoveRAw]		-> [^(self isAddressRelativeToVarBase: (operands at: 1)) ifTrue: [false] ifFalse: [true]].
		[MoveAbR]		-> [^(self isAddressRelativeToVarBase: (operands at: 0)) ifTrue: [false] ifFalse: [true]].
		[MoveRAb]		-> [^(self isAddressRelativeToVarBase: (operands at: 1)) ifTrue: [false] ifFalse: [true]].
	

		[MoveRM32r]	-> [^ false]. "#TODO"

		[MoveRMwr]	-> [^ false]. "#TODO"

		[MoveRsM32r]	-> [^self is12BitValue: (operands at: 1) ifTrue: [:s :v| false] ifFalse: [true]]. 												
		[MoveRdM64r]	-> [^self is12BitValue: (operands at: 1) ifTrue: [:s :v| false] ifFalse: [true]]. 
		[MoveMbrR]	-> [^self is9BitValue: (operands at: 0) ifTrue: [:v| false] ifFalse: [true]].
		[MoveRMbr]	-> [^self is12BitValue: (operands at: 1) ifTrue: [:s :v| false] ifFalse: [true]].
		[MoveRM8r]	-> [^self is12BitValue: (operands at: 1) ifTrue: [:s :v| false] ifFalse: [true]].
		[MoveM16rR]	-> [^self rotateable8bitImmediate: (operands at: 0) ifTrue: [:r :i| false] ifFalse: [true]].
		[MoveRM16r]	-> [^self is12BitValue: (operands at: 1) ifTrue: [:s :v| false] ifFalse: [true]].
		[MoveM32rRs]	-> [^self is12BitValue: (operands at: 0) ifTrue: [:s :v| false] ifFalse: [true]].
		[MoveM64rRd]	-> [^self is12BitValue: (operands at: 0) ifTrue: [:s :v| false] ifFalse: [true]].
			
		[MoveM32rR] -> [^ false]. "#TODO"

		[MoveMwrR]	-> [
			offset := (operands at: 0).
			(offset >= 0 and: [ (offset bitAnd: 16rFFF) = offset ]) 
				ifTrue: [ ^ false ]
				ifFalse: [ 	self
									is9BitValue: offset
										ifTrue: [ :v | ^ false ] 
										ifFalse: [^ true ] ]].
								
		[PushCw]		-> [^(self inCurrentCompilation: (operands at: 0)) not].
		[PushCq]		-> [^ ((operands at: 0) bitAnd: 16rfff) ~= (operands at: 0)].
		[PrefetchAw] 	-> [^(self isAddressRelativeToVarBase: (operands at: 0)) ifTrue: [false] ifFalse: [true]].

		"Patcheable instruction. Moves a literal. Uses out of line literal."
		[MovePatcheableC32R] -> [ ^ true ]
		}
		otherwise: [self error: 'We should not be here!!!'].
	^false "to keep C compiler quiet"

]
