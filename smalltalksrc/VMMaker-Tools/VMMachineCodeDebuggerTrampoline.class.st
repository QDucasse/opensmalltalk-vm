Class {
	#name : #VMMachineCodeDebuggerTrampoline,
	#superclass : #Object,
	#instVars : [
		'machineSimulator',
		'debugger',
		'address',
		'name'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #'as yet unclassified' }
VMMachineCodeDebuggerTrampoline class >> address: anAddressString name: aName on: machineSimulator [ 
	
	^ self new
		address: anAddressString;
		name: aName;
		machineSimulator: machineSimulator;
		yourself
]

{ #category : #accessing }
VMMachineCodeDebuggerTrampoline >> address [
	^ address
]

{ #category : #accessing }
VMMachineCodeDebuggerTrampoline >> address: anAddress [

	address := anAddress
]

{ #category : #accessing }
VMMachineCodeDebuggerTrampoline >> addressString [
	^ self address hex
]

{ #category : #accessing }
VMMachineCodeDebuggerTrampoline >> machineSimulator: aSimulator [

	machineSimulator := aSimulator
]

{ #category : #accessing }
VMMachineCodeDebuggerTrampoline >> name [ 
	^name
]

{ #category : #accessing }
VMMachineCodeDebuggerTrampoline >> name: aName [ 
	name := aName
]
