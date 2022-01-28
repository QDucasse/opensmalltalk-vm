Class {
	#name : #VMRISCV64CallJumpOffsetTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testCallBigPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: 16r1000BE8 ].
	
	self machineSimulator
			startAt: initialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator linkRegisterValue equals: initialAddress + cogit backend callInstructionByteSize.
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r1000BE8.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testCallNegativeOffset [

	| callInstruction |
	self compile: [		 
		cogit Nop. cogit Nop. cogit Nop.
		callInstruction := cogit Call: 16r1000000 ].

	self machineSimulator
			startAt: 16r1000004
			until: 16r1000000
			timeout: 0
			count: 0.
	
	self assert: machineSimulator linkRegisterValue equals: initialAddress + cogit backend callInstructionByteSize + 12 "3 nops".
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r1000000.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testCallNegativeOffsetRewriting [

	| callInstruction |
	self compile: [	
		cogit Nop. cogit Nop. cogit Nop. cogit Nop. cogit Nop.
		callInstruction := cogit Call: 16r10000E8 ].
	"Rewrite the long jump and checks the extraction"
	cogit backend rewriteCallAt: initialAddress + cogit backend jumpLongByteSize + 20 target: 16r1000000.
	self assert: (cogit backend callTargetFromReturnAddress: initialAddress + cogit backend callInstructionByteSize + 20) equals: 16r1000000.
	"Check the instructions have changed by launchig the simulation"
	self machineSimulator startAt: initialAddress + 20 until: 0 timeout: 0 count: 2.
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r1000000
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: 16r10000E8 ].
	
	self machineSimulator
			startAt: initialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator linkRegisterValue equals: initialAddress + cogit backend callInstructionByteSize.
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r10000E8.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffsetExtraction [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: 16r10000E8 ].
		
	self assert: (cogit backend callTargetFromReturnAddress: initialAddress + cogit backend callInstructionByteSize) equals: 16r10000E8.
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testCallPositiveOffsetRewriting [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit Call: 16r10000E8 ].
	"Rewrite the long jump and checks the extraction"
	cogit backend rewriteCallAt: initialAddress + cogit backend jumpLongByteSize target: 16r100AAAA.
	self assert: (cogit backend callTargetFromReturnAddress: initialAddress + cogit backend callInstructionByteSize) equals: 16r100AAAA.
	"Check the instructions have changed by launchig the simulation"
	self machineSimulator startAt: initialAddress until: 0 timeout: 0 count: 2.
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r100AAAA
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testJumpLongBigPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: 16r1000BE8 ].
	self machineSimulator
			startAt: initialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r1000BE8.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testJumpLongBigPositiveOffsetExtraction [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: 16r1000BE8 ].
	
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: initialAddress + cogit backend jumpLongByteSize) equals: 16r1000BE8.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffset [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: 16r10000E8 ].
	
	self machineSimulator
			startAt: initialAddress
			until: 0
			timeout: 0
			count: 2.
	
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r10000E8.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffsetExtraction [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: 16r10000E8 ].
	
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: initialAddress + cogit backend jumpLongByteSize) equals: 16r10000E8.
	
]

{ #category : #running }
VMRISCV64CallJumpOffsetTest >> testJumpLongPositiveOffsetRewriting [

	| callInstruction |
	self compile: [		 
		callInstruction := cogit JumpLong: 16r10000E8 ].
	"Rewrite the long jump and checks the extraction"
	cogit backend rewriteJumpLongAt: initialAddress + cogit backend jumpLongByteSize target: 16r100AAAA.
	self assert: (cogit backend jumpLongTargetBeforeFollowingAddress: initialAddress + cogit backend jumpLongByteSize) equals: 16r100AAAA.
	"Check the instructions have changed by launchig the simulation"
	self machineSimulator startAt: initialAddress until: 0 timeout: 0 count: 2.
	self assert: machineSimulator instructionPointerRegisterValue equals: 16r100AAAA


]
