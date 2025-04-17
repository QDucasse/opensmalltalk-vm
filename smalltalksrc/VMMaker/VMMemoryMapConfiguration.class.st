Class {
	#name : 'VMMemoryMapConfiguration',
	#superclass : 'VMClass',
	#classVars : [
		'CodeZoneInitialAddress',
		'ConfWordSize',
		'NewSpaceInitialAddress',
		'OldSpaceInitialAddress',
		'PermSpaceInitialAddress',
		'StackPagesInitialAddress'
	],
	#category : 'VMMaker-Memory',
	#package : 'VMMaker',
	#tag : 'Memory'
}

{ #category : 'translation' }
VMMemoryMapConfiguration class >> declareCVarsIn: aCCodeGenerator [

	aCCodeGenerator addHeaderFile: '"memoryMap.h"'.

	#( ConfWordSize CodeZoneInitialAddress NewSpaceInitialAddress
	   OldSpaceInitialAddress PermSpaceInitialAddress
	   StackPagesInitialAddress ) do: [ :e |
		aCCodeGenerator removeConstant: e ]
]

{ #category : 'instance-creation' }
VMMemoryMapConfiguration class >> for32Bits [

	^ self new
		codeZoneInitialAddress: 16r10000000 "(256 MB)";
		confWordSize: 4;
		newSpaceInitialAddress: 16r20000000 "(512 MB)";
		oldSpaceInitialAddress: 16r40000000 "(1024 MB)";
		permSpaceInitialAddress: 16r80000000 "(2048 MB)";
		stackPagesInitialAddress: 16r0F000000 "(240 MB)";
		yourself
]

{ #category : 'instance-creation' }
VMMemoryMapConfiguration class >> for64Bits [

	^ self new
		codeZoneInitialAddress: 16r320000000  "12.5GB";
		confWordSize: 8;
		newSpaceInitialAddress: 16r360000000 "13.5GB";
		oldSpaceInitialAddress: 16r10000000000 "1024GB";
		permSpaceInitialAddress: 16r20000000000 "2048GB";
		stackPagesInitialAddress: 16r300000000 "12GB";
		yourself
]

{ #category : 'instance-creation' }
VMMemoryMapConfiguration class >> forWordsize: anInteger [

	anInteger = 8 ifTrue: [ ^ self for64Bits ].

	^ self for32Bits
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> codeZoneInitialAddress [

	^ CodeZoneInitialAddress
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> codeZoneInitialAddress: anObject [

	CodeZoneInitialAddress := anObject
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> confWordSize [

	^ ConfWordSize
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> confWordSize: anObject [

	ConfWordSize := anObject
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> newSpaceInitialAddress [

	^ NewSpaceInitialAddress
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> newSpaceInitialAddress: anObject [

	NewSpaceInitialAddress := anObject
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> oldSpaceInitialAddress [

	^ OldSpaceInitialAddress
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> oldSpaceInitialAddress: anObject [

	OldSpaceInitialAddress := anObject
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> permSpaceInitialAddress [

	^ PermSpaceInitialAddress
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> permSpaceInitialAddress: anObject [

	PermSpaceInitialAddress := anObject
]

{ #category : 'initial addresses' }
VMMemoryMapConfiguration >> stackPagesInitialAddress [

	^ StackPagesInitialAddress
]

{ #category : 'accessing' }
VMMemoryMapConfiguration >> stackPagesInitialAddress: anObject [

	StackPagesInitialAddress := anObject
]
