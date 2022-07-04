Class {
	#name : #UnicornInvalidMemoryAccess,
	#superclass : #UnicornRuntimeError,
	#instVars : [
		'type'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #testing }
UnicornInvalidMemoryAccess >> isFetch [
	
	^ self type value anyMask: UcMemoryAccessType UC_MEM_FETCH value
]

{ #category : #accessing }
UnicornInvalidMemoryAccess >> messageText [

	^ type item asString, ' at ', address hex
]

{ #category : #accessing }
UnicornInvalidMemoryAccess >> type [
	^ type
]

{ #category : #accessing }
UnicornInvalidMemoryAccess >> type: anObject [
	type := anObject
]
