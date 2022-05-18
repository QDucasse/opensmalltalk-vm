Extension { #name : #Integer }

{ #category : #'*VMMaker-Tools' }
Integer >> armv7Disassembled [
	
	^ self disassembleWith: LLVMARMDisassembler armv7
]
