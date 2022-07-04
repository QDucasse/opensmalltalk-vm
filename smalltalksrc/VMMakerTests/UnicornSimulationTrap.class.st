Class {
	#name : #UnicornSimulationTrap,
	#superclass : #Object,
	#instVars : [
		'simulator',
		'runtimeError'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #'instance creation' }
UnicornSimulationTrap class >> simulator: simulator error: aRuntimeError [

	^ self new
		simulator: simulator;
		runtimeError: aRuntimeError;
		yourself
]

{ #category : #accessing }
UnicornSimulationTrap >> address [
	
	^ runtimeError address
]

{ #category : #accessing }
UnicornSimulationTrap >> nextpc [
	
	| instruction |
	instruction := self simulator disassembleCurrentInstruction.
	^ self simulator instructionPointerRegisterValue + instruction size
]

{ #category : #accessing }
UnicornSimulationTrap >> registerAccessor [
	
	"Assume this is a read of a value into a register"
	| failingInstruction registerName |
	self assert: self type = #read.
	
	"Get the register were we wanted to read the value into"
	failingInstruction := self simulator disassembleCurrentInstruction.
	registerName := self simulator extractDestinationRegisterFromAssembly: failingInstruction.
	^ (registerName , ':') asSymbol
]

{ #category : #accessing }
UnicornSimulationTrap >> runtimeError: aRuntimeError [ 
	runtimeError := aRuntimeError
]

{ #category : #accessing }
UnicornSimulationTrap >> simulator [
	
	^ simulator
]

{ #category : #accessing }
UnicornSimulationTrap >> simulator: anObject [
	simulator := anObject
]

{ #category : #accessing }
UnicornSimulationTrap >> type [
	
	runtimeError type = UcMemoryAccessType UC_MEM_WRITE_UNMAPPED
		ifTrue: [ ^ #write ].
	runtimeError type = UcMemoryAccessType UC_MEM_READ_UNMAPPED
		ifTrue: [ ^ #read ].
	runtimeError type = UcMemoryAccessType UC_MEM_FETCH_UNMAPPED
		ifTrue: [ ^ #jump ].	
	
	self halt
]

{ #category : #accessing }
UnicornSimulationTrap >> writtenValue [
	"This is the value that was tried to be written but failed (if this is a failed write)"
	^ runtimeError value
]
