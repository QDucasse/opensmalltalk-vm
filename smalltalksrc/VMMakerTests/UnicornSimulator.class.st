Class {
	#name : #UnicornSimulator,
	#superclass : #ProcessorSimulator,
	#instVars : [
		'stopReason',
		'runtimeErrorHandler'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #'instance creation' }
UnicornSimulator class >> supportsISA: isa [

	^ #( #ARMv5 #ARMv8 #IA32 #X64 #aarch64 #riscv64 ) includes: isa
]

{ #category : #initialization }
UnicornSimulator >> createUnicorn [

	self subclassResponsibility
]

{ #category : #executing }
UnicornSimulator >> doStartAt: startAddress until: until timeout: timeout count: count [

	| result error startTime currentTime remainingTimeout remainingCount |

	self instructionPointerRegisterValue: startAddress.
	startTime := Time millisecondClockValue.
	remainingTimeout := timeout.
	remainingCount := count.
	[ true ]
		whileTrue: [
			[result :=  simulator
				startAt: self instructionPointerRegisterValue
				until: until
				timeout: remainingTimeout
				count: remainingCount.

				stopReason ifNotNil: [
						error := stopReason.
						stopReason := nil.
						error signal ].

			"If execution did not stop because of a stop reason, verify the error code"
			simulator verifyErrorCode: result]
				on: UnicornRuntimeError do: [ :runtimeError |

					self instructionPointerRegisterValue = until ifTrue: [ ^ 0 ].

					(self handleRuntimeError: runtimeError)
						ifFalse: [ ^ result ]].

			stopReason ifNotNil: [ ^ result ].

			count ~= 0 ifTrue: [ | lastCount |
				lastCount := simulator lastInstructionCount.
				remainingCount := remainingCount - lastCount.
				remainingCount <= 0 ifTrue: [ ^ result ]].

			timeout ~= 0 ifTrue: [
				currentTime := Time millisecondClockValue.
				remainingTimeout := remainingTimeout - (currentTime - startTime).

				remainingTimeout <= 0
					ifTrue: [
						UnicornTimeout new
								target: until;
								signal ]].
			self instructionPointerRegisterValue = until
				ifTrue: [ ^ result ]]
]

{ #category : #'stack-access' }
UnicornSimulator >> finishMappingMemory [

	"Do nothing in the case of Unicorn, is useful if the simulator used has to map memory by hand"
]

{ #category : #'handling invalid accesses' }
UnicornSimulator >> handleRuntimeError: runtimeError [

	| previousInstructionPointer hasToContinue |
	previousInstructionPointer := self instructionPointerRegisterValue.

	"If the called handler want to resume execution but it has not set a next instruction pointer to execute I will calculate it"

	(hasToContinue := runtimeErrorHandler value: runtimeError)
		ifTrue: [ previousInstructionPointer = self instructionPointerRegisterValue
			ifTrue: [
					self instructionPointerRegisterValue:
						self lastExecutedInstructionAddress + self lastExecutedInstructionSize
				] ].

	^ hasToContinue
]

{ #category : #initialization }
UnicornSimulator >> initialize [

	super initialize.
	simulator := self createUnicorn.
	self initializeUnicorn.

	registerAliases := Dictionary new.
	self initializeRegisterAliases.

	runtimeErrorHandler := [ :runtimeError |
		self cogit handleSimulationTrap: (UnicornSimulationTrap simulator: self error: runtimeError).
		true]
]

{ #category : #initialization }
UnicornSimulator >> initializeUnicorn [

	simulator
		registerInvalidMemoryAccessHook: UcHookType invalidMemoryAccess value
		doing: [ :type :address :size :value |
			simulator stop.
			stopReason := UnicornInvalidMemoryAccess new
				type: type;
				address: address;
				size: size;
				value: value;
				yourself.
			false ].
	
	simulator
		registerInvalidInstructionHook: UcHookType invalidInstruction value
		doing: [ 
			simulator stop.
			stopReason := UnicornInvalidInstruction new;
				yourself.
			false ].
]

{ #category : #initialization }
UnicornSimulator >> postCallArgumentsNumArgs: numArgs "<Integer>" in: aMemory [ "<ByteArray|Bitmap>"

	self subclassResponsibility
]

{ #category : #initialization }
UnicornSimulator >> registerHook: aBlock atAddress: anAddress [

	simulator
		registerInvalidMemoryAccessHook: UcHookType fetchingAccess value
		doing: [ :type :address :size :value | address = anAddress ifTrue: aBlock ]
]

{ #category : #executing }
UnicornSimulator >> retpcIn: aMemory [

	self subclassResponsibility

]

{ #category : #'handling invalid accesses' }
UnicornSimulator >> runtimeErrorHandler: aFullBlockClosure [
	runtimeErrorHandler := aFullBlockClosure
]

{ #category : #initialization }
UnicornSimulator >> simulateJumpCallOf: anInteger memory: aSpurSimulatedMemory [

	^ self subclassResponsibility
]

{ #category : #initialization }
UnicornSimulator >> simulateReturnIn: aMemory [

	self subclassResponsibility
]

{ #category : #initialization }
UnicornSimulator >> smashCallerSavedRegistersWithValuesFrom: base by: step in: aMemory [

	self subclassResponsibility
]

{ #category : #executing }
UnicornSimulator >> startAt: begin until: until timeout: timeout count: count [

	^ self doStartAt: begin until: until timeout: timeout count: count.

]
