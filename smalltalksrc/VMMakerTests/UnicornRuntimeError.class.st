Class {
	#name : #UnicornRuntimeError,
	#superclass : #Error,
	#instVars : [
		'address',
		'size',
		'value'
	],
	#category : #'VMMakerTests-Unicorn'
}

{ #category : #accessing }
UnicornRuntimeError >> address [
	^ address
]

{ #category : #accessing }
UnicornRuntimeError >> address: anObject [
	address := anObject
]

{ #category : #accessing }
UnicornRuntimeError >> size [
	^ size
]

{ #category : #accessing }
UnicornRuntimeError >> size: anObject [
	size := anObject
]

{ #category : #accessing }
UnicornRuntimeError >> value [
	^ value
]

{ #category : #accessing }
UnicornRuntimeError >> value: anObject [
	value := anObject
]
