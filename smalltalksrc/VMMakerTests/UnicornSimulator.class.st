Class {
	#name : #UnicornSimulator,
	#superclass : #ProcessorSimulator,
	#instVars : [
		'stopReason',
		'invalidAccessHandler'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #'instance creation' }
UnicornSimulator class >> ARMv5 [
	
	^ UnicornARMv5Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> ARMv8 [
	
	^ UnicornARMv8Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> IA32 [

	^ UnicornI386Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> X64 [
	
	^ UnicornX64Simulator new
]

{ #category : #'instance creation' }
UnicornSimulator class >> aarch64 [
	
	^ UnicornARMv8Simulator new
]

{ #category : #'as yet unclassified' }
UnicornSimulator class >> supportsISA: isa [

	^ #( #ARMv5 #ARMv8 #IA32 #X64 #aarch64 ) includes: isa
]

{ #category : #initialization }
UnicornSimulator >> createUnicorn [

	self subclassResponsibility
]

{ #category : #executing }
UnicornSimulator >> doStartAt: startAddress until: until timeout: timeout count: count [

	| result error startTime currentTime remainingTimeout remainingCount |

	self instructionPointerValue: startAddress.
	startTime := Time millisecondClockValue.
	remainingTimeout := timeout.
	remainingCount := count.

	[ true ]
		whileTrue: [ 
			[result :=  simulator
				startAt: self instructionPointerValue
				until: until
				timeout: remainingTimeout
				count: remainingCount.
					
				stopReason ifNotNil: [ 
						error := stopReason.
						stopReason := nil.
						error signal ].
		
			"If execution did not stop because of a stop reason, verify the error code"
			simulator verifyErrorCode: result] 
				on: UnicornInvalidMemoryAccess do: [ :invalidAccess |
					
					self instructionPointerValue = until ifTrue: [ ^ 0 ].
					
					(self handleInvalidAccess: invalidAccess)
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
			
			self instructionPointerValue = until 
				ifTrue: [ ^ result ]]
]

{ #category : #'handling invalid accesses' }
UnicornSimulator >> handleInvalidAccess: invalidAccess [ 

	| previousInstructionPointer hasToContinue |
	previousInstructionPointer := self instructionPointerValue.
	
	"If the called handler want to resume execution but it has not set a next instruction pointer to execute I will calculate it"
	
	(hasToContinue := invalidAccessHandler value: invalidAccess)
		ifTrue: [ previousInstructionPointer = self instructionPointerValue 
			ifTrue: [  
					self instructionPointerValue: 
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
	
	invalidAccessHandler := [ :invalidAccess | 
		self cogit handleSimulationTrap: (UnicornSimulationTrap simulator: self error: invalidAccess).
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
			false ]
]

{ #category : #'handling invalid accesses' }
UnicornSimulator >> invalidAccessHandler: aFullBlockClosure [ 
	invalidAccessHandler := aFullBlockClosure
]

{ #category : #initialization }
UnicornSimulator >> registerHook: aBlock atAddress: anAddress [

	simulator
		registerInvalidMemoryAccessHook: UcHookType fetchingAccess value 
		doing: [ :type :address :size :value | address = anAddress ifTrue: aBlock ]
]

{ #category : #executing }
UnicornSimulator >> startAt: begin until: until timeout: timeout count: count [ 

	^ self doStartAt: begin until: until timeout: timeout count: count.
	
]

{ #category : #actions }
UnicornSimulator >> step [
	
	self
		startAt: self instructionPointerValue
		until: 0
		timeout: 0
		count: 1
]
