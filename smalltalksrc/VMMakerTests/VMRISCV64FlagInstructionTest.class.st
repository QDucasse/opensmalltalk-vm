Class {
	#name : #VMRISCV64FlagInstructionTest,
	#superclass : #VMSimpleStackBasedCogitAbstractTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #tests }
VMRISCV64FlagInstructionTest class >> testParameters [

	^ ParametrizedTestMatrix new
		addCase: { #ISA -> #'riscv64' . #wordSize -> 8 }
		yourself
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRImmediateNoFlagSet [

	self compile: [		 
		cogit AddCq: 12 R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 12.
	
	self runGeneratedCode.	
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 24.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRImmediateSetCarryFlag [

	self compile: [		 
		cogit AddCq: 2 R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRImmediateSetOverflowFlag [

	self compile: [		 
		cogit AddCq: 16r7FF R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	self runGeneratedCode.
	
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRImmediateSetSignFlag [

	self compile: [		 
		cogit AddCq: 1 R: TempReg 
	].

	machineSimulator temporaryRegisterValue: (-3 twoComplementOfBitSize: 64).
	self runGeneratedCode.
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: (-2 twoComplementOfBitSize: 64).
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRImmediateSetZeroFlag [

	self compile: [		 
		cogit AddCq: 0 R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 0.
	self runGeneratedCode.
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRLargeImmediateNoFlagSet [

	self compile: [		 
		cogit AddCq: 16r1FFF R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 1.
	
	self runGeneratedCode.
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r2000.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRLargeImmediateSetCarryFlag [

	self compile: [		 
		cogit AddCq: 16r1FFF R: TempReg 
	].

	machineSimulator temporaryRegisterValue: (-1 twoComplementOfBitSize: 64).
	
	self runGeneratedCode.
	
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRLargeImmediateSetOverflowFlag [

	self compile: [		 
		cogit AddCq: 16r1FFF R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	self runGeneratedCode.

	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRLargeImmediateSetSignFlag [

	self compile: [		 
		cogit AddCq:  16r1FFF R: TempReg 
	].

	machineSimulator temporaryRegisterValue: (-16r2000 twoComplementOfBitSize: 64).
	self runGeneratedCode.
	
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.
	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddCqRLargeImmediateSetZeroFlag [

	self compile: [		 
		cogit AddCq:  (-16r1FFF twoComplementOfBitSize: 64) R: TempReg 
	].

	machineSimulator temporaryRegisterValue: 16r1FFF.
	self runGeneratedCode.
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRNoFlagSet [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 7F | 127  |  127  ||  0  |  0   |   0   ||  7F | 127  |  127  ||  0  |  0  |  0  |  0  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 0.
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r7FFFFFFFFFFFFFFF.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetCarryFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  7F  | 127  | 127  ||  7E | 126  |  126  ||  0  |  0  |  0  |  1  |
	"


	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF. "-1"
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r7FFFFFFFFFFFFFFE.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetCarryOverflowFlags [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF |  255 |  -1   || 80  | 128  |  -128 ||  7F |  127  | 127  ||  1  |  0  |  0  |  1  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16r8000000000000000.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r7FFFFFFFFFFFFFFF.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetCarryOverflowZeroFlags [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 80 | 128  | -128  || 80  | 128  | -128  ||  0  |  0    |  0   ||  1  |  0  |  1  |  1  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16r8000000000000000.
	machineSimulator temporaryRegisterValue: 16r8000000000000000.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetCarrySignFlags [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF |  255 |  -1   || FF  | 255  |  -1   ||  FE |  254  | -2   ||  0  |  1  |  0  |  1  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16rFFFFFFFFFFFFFFFE.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetCarryZeroFlags [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF |  255 |  -1   ||  1  |  1   |   1   ||  0  |  0   |  0    ||  0  |  0  |  1  |  1  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 1.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetOverflowSignFlags [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 7F | 127  |  127  || 7F  | 127  |  127  || FE  |  254  | -2   ||  1  |  1  |  0  |  0  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16r7FFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16rFFFFFFFFFFFFFFFE.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetSignFlag [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF |  255 |  -1   ||  0  |  0   |   0   ||  FF |  255 |  255  ||  0  |  1  |  0  |  0  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 0.
	
	self runGeneratedCode.
	
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16rFFFFFFFFFFFFFFFF.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testAddRRSetZeroFlag [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 0  |  0   |   0   ||  0  |  0   |   0   ||  0  |  0   |  0    ||  0  |  0  |  1  |  0  |
	"

	self compile: [		 
		cogit AddR: ReceiverResultReg R: TempReg 
	].
	
	machineSimulator receiverRegisterValue: 0.
	machineSimulator temporaryRegisterValue: 0.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRNoFlagSet [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  FE | 254  |  -2   ||  1  |   1  |   1   ||  0  |  0  |  0  |  0  |
	"
	"SubR: r1 R: r2 -> r2-r1"
	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFE.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRSetCarryFlag [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 7E | 126  |  126  ||  FF | 255  |  -1   ||  7F | 127  | 127   ||  0  |  0  |  0  |  1  |
	"

	"SubR: r1 R: r2 -> r2-r1"
	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFE.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRSetCarrySignFlags [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FE | 254  |  -2   ||  FF | 255  |  -1   ||  FF |  255 |  -1   ||  0  |  1  |  0  |  1  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFE.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRSetCarrySignOverflowFlags [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 7F | 127  |  127  ||  FF | 255  |   -1  ||  80 |  128 |  -128 ||  1  |  1  |  0  |  1  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRSetOverflowFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FE | 254  |  -2   ||  7F | 127  |  127  ||  7F |  127 |  127  ||  1  |  0  |  0  |  0  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16r7FFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFE.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRSetSignFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  7F | 127  |  127  ||  80 |  128 |  -128 ||  0  |  1  |  0  |  0  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16r7FFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testCmpRRSetZeroFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  FF | 255  |  -1   ||  0  |  0   |   0   ||  0  |  0  |  1  |  0  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit CmpR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testMulRRSetOverflowSignFlags [

	self compile: [		 
		cogit MulR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16r7FFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 2.
	
	self runGeneratedCode.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testMulRRSetSignFlag [

	self compile: [		 
		cogit MulR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 2.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16rFFFFFFFFFFFFFFFE.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testMulRRSetZeroFlag [

	self compile: [		 
		cogit MulR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 0.
	machineSimulator temporaryRegisterValue: 0.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRNoFlagSet [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  FE | 254  |  -2   ||  1  |   1  |   1   ||  0  |  0  |  0  |  0  |
	"
	"SubR: r1 R: r2 -> r2-r1"
	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFE.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 1.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRSetCarryFlag [
	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 7E | 126  |  126  ||  FF | 255  |  -1   ||  7F | 127  | 127   ||  0  |  0  |  0  |  1  |
	"

	"SubR: r1 R: r2 -> r2-r1"
	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFE.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r7FFFFFFFFFFFFFFF.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRSetCarrySignFlags [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A + B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FE | 254  |  -2   ||  FF | 255  |  -1   ||  FF |  255 |  -1   ||  0  |  1  |  0  |  1  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFE.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16rFFFFFFFFFFFFFFFF.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRSetCarrySignOverflowFlags [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| 7F | 127  |  127  ||  FF | 255  |   -1  ||  80 |  128 |  -128 ||  1  |  1  |  0  |  1  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16r7FFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r8000000000000000.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 1.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRSetOverflowFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FE | 254  |  -2   ||  7F | 127  |  127  ||  7F |  127 |  127  ||  1  |  0  |  0  |  0  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16r7FFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFE.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r7FFFFFFFFFFFFFFF.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 1.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRSetSignFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  7F | 127  |  127  ||  80 |  128 |  -128 ||  0  |  1  |  0  |  0  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16r7FFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 16r8000000000000000.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 0.
	self assert: machineSimulator flagSignRegisterValue equals: 1.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]

{ #category : #tests }
VMRISCV64FlagInstructionTest >> testSubRRSetZeroFlag [

	"(equivalent with 2 bytes)
	        A           ||        B           ||      A - B         ||         Flags
	  h     ud      d   ||  h     ud      d   ||  h     ud      d   ||  OF    SF    ZF    CF
	| FF | 255  |  -1   ||  FF | 255  |  -1   ||  0  |  0   |   0   ||  0  |  0  |  1  |  0  |
	"

	"SubR: r1 R: r2 -> r2-r1"

	self compile: [		 
		cogit SubR: ReceiverResultReg R: TempReg 
	].

	machineSimulator receiverRegisterValue: 16rFFFFFFFFFFFFFFFF.
	machineSimulator temporaryRegisterValue: 16rFFFFFFFFFFFFFFFF.
	
	self runGeneratedCode.
	"Check result"
	self assert: machineSimulator temporaryRegisterValue equals: 0.
	"Check flags"
	self assert: machineSimulator flagZeroRegisterValue equals: 1.
	self assert: machineSimulator flagSignRegisterValue equals: 0.	
	self assert: machineSimulator flagCarryRegisterValue equals: 0.
	self assert: machineSimulator flagOverflowRegisterValue equals: 0.	
	
]
