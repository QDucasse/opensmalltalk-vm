Class {
	#name : #VMRISCV64CustomInstructionTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #tests }
VMRISCV64CustomInstructionTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'riscv64' . #wordSize -> 8};
		yourself
]

{ #category : #tests }
VMRISCV64CustomInstructionTest >> testCustomRotateRight [

	self compile: [		 
		cogit RotateRightCq: 5 R: TempReg 
	].
	machineSimulator temporaryRegisterValue: 16rF0.
	machineSimulator instructionPointerRegisterValue: 16r1000000.
	self openMachineDebugger. 1halt.
	machineSimulator step.
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r8000000000000007.
]
