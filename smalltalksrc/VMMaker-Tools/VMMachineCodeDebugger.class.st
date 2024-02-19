Class {
	#name : #VMMachineCodeDebugger,
	#superclass : #SpPresenter,
	#instVars : [
		'cogit',
		'machineSimulator',
		'instructions',
		'irinstructions',
		'trampolines',
		'stepButton',
		'disassembleAtPCButton',
		'machineState',
		'initialInstructionToDisassemble',
		'stack',
		'jumpToButton',
		'abstractInstructions',
		'disassembleAtSPButton',
		'setSPToButton',
		'pcInput',
		'spInput',
		'trampolineDictionary',
		'trampolineButton'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #layout }
VMMachineCodeDebugger class >> defaultLayout [

	^  SpBoxLayout newVertical
		add:(SpBoxLayout newHorizontal
			add: #trampolines expand: true fill: true padding: 5;
			add: #irinstructions expand: true fill: true padding: 5;
			add: #instructions expand: true fill: true padding: 5;
			add: #machineState expand: true fill: true padding: 5;
			add: #stack expand: true fill: true padding: 5;
			yourself) expand: true fill: true padding: 5;
		add: (SpBoxLayout newHorizontal
			add: #trampolineButton expand: true fill: true padding: 5;
			add: #stepButton expand: true fill: true padding: 5;
			add: (SpBoxLayout newVertical
				add: #pcInput;
				add: #jumpToButton) expand: true fill: true padding: 5;
			add: #disassembleAtPCButton expand: true fill: true padding: 5;
			add: (SpBoxLayout newVertical
				add: #spInput;
				add: #setSPToButton) expand: true fill: true padding: 5;
			add: #disassembleAtSPButton expand: true fill: true padding: 5) width: 200;
		yourself
]

{ #category : #'as yet unclassified' }
VMMachineCodeDebugger class >> openOnCogit: aCogit [

	self openOnCogit: aCogit ip: aCogit processor machineSimulator pc
]

{ #category : #'as yet unclassified' }
VMMachineCodeDebugger class >> openOnCogit: aCogit ip: anInstructionPointer [

	self new
		cogit: aCogit;
		machineSimulator: aCogit processor machineSimulator;
		trampolineDictionary: aCogit trampolineDictionary;
		initialInstructionToDisassemble: anInstructionPointer;
		openWithSpec.
]

{ #category : #accessing }
VMMachineCodeDebugger >> abstractInstructions [

	^ abstractInstructions
]

{ #category : #accessing }
VMMachineCodeDebugger >> abstractInstructions: aCollection [

	^ abstractInstructions := aCollection
]

{ #category : #accessing }
VMMachineCodeDebugger >> cogit [
	^ cogit
]

{ #category : #accessing }
VMMachineCodeDebugger >> cogit: anObject [
	cogit := anObject.
	self abstractInstructions: ((0 to: cogit getOpcodeIndex - 1)
			collect: [ :i | cogit abstractOpcodes at: i ])
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectButtons [

	trampolineButton action: [ self disassembleTrampoline ].
	stepButton action: [ self step ].
	disassembleAtPCButton action: [ self disassembleAtPC ].
	jumpToButton action: [ self jump ].
	disassembleAtSPButton action: [ self disassembleAtSP ].
	setSPToButton action: [ self setSPTo ].
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectIRInstructionsPresenter [

	|  irinstructionsContextMenu |
	irinstructionsContextMenu := SpMenuPresenter new.
	irinstructionsContextMenu
		addItem: [ :item |
		item
			name: 'Inspect Operands';
			action: [ self selectedIRInstruction operands inspect ] ];
		"Inspect the IR Instruction debugger object"
		addItem: [ :item |
		item
			name: 'Inspect';
			action: [ self inspectSelectedIRInstruction ] ].
	irinstructions contextMenu: irinstructionsContextMenu
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectInstructionsPresenter [

	| instructionsContextMenu |
	instructionsContextMenu := SpMenuPresenter new.
	instructionsContextMenu
		"Set PC to the instruction"
		addItem: [ :item |
		item
			name: 'Set Intruction Pointer Here';
			action: [
				self setInstructionPointerToSelectedInstruction.
				self refreshAll ] ];
		"Run from current PC to instruction"
		addItem: [ :item |
		item
			name: 'Run to Here';
			action: [
				self runToSelectedInstruction.
				self refreshAll ] ];
		"Inspect machine code debugger instruction"
		addItem: [ :item |
		item
			name: 'Inspect';
			action: [ self inspectSelectedInstruction ] ].
	instructions contextMenu: instructionsContextMenu
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectMachineStatePresenter [

	| contextMenu |

	contextMenu := SpMenuPresenter new.
	contextMenu
		"Inspect the value of the register"
		addItem: [ :item |
		item
			name: 'Inspect Value';
			action: [ machineState selection selectedItem inspectValue ] ];
		"Copy the value to the clipboard"
		addItem: [ :item |
		item
			name: 'Copy Value to Clipboard';
			action: [ machineState selection selectedItem copyValueToClipboard ] ];
		"Print the value of the register"
		addItem: [ :item |
		item
			name: 'Print Value';
			action: [ machineState selection selectedItem printValue ] ].

	machineState contextMenu: contextMenu.



]

{ #category : #initialization }
VMMachineCodeDebugger >> connectPresenters [

	self connectButtons.
	self connectTrampolinesPresenter.
	self connectIRInstructionsPresenter.
	self connectInstructionsPresenter.
	self connectMachineStatePresenter.
]

{ #category : #initialization }
VMMachineCodeDebugger >> connectTrampolinesPresenter [

	| trampolinesContextMenu |
	trampolinesContextMenu := SpMenuPresenter new.
	trampolinesContextMenu
		"Inspect the Trampoline debugger object"
		addItem: [ :item |
		item
			name: 'Inspect';
			action: [ self inspectSelectedTrampoline ] ].
	irinstructions contextMenu: trampolinesContextMenu
]

{ #category : #actions }
VMMachineCodeDebugger >> disassembleAtPC [

	self initialInstructionToDisassemble:  machineSimulator instructionPointerRegisterValue.
	self refreshInstructions.
]

{ #category : #actions }
VMMachineCodeDebugger >> disassembleAtSP [

	self refreshStack.
]

{ #category : #showing }
VMMachineCodeDebugger >> disassembleInstructionsAt: anAddress [

	^ machineSimulator disassembler
		printImmediatesInHexa;
		useAlternatePrinterVariant;
		disassembleNext: 300
		instructionsIn: (cogit objectMemory memoryManager
			copyFrom: self initialInstructionToDisassemble
			to: self initialInstructionToDisassemble + 1200)
		startAddress: anAddress
		pc: machineSimulator smalltalkStackPointerRegisterValue
]

{ #category : #showing }
VMMachineCodeDebugger >> disassembleTrampoline [

	| trampolineAddress |
	trampolineAddress := self selectedTrampoline address asNumber.
	instructions items:
		((self disassembleInstructionsAt: trampolineAddress) collect: [ :anInstruction |
			VMMachineCodeDebuggerInstruction new
				instruction: anInstruction;
				bytes: (anInstruction codeBytes: cogit objectMemory memoryManager);
				debugger: self;
				machineSimulator: machineSimulator;
				yourself ]).
	self initialDisassembly 
]

{ #category : #actions }
VMMachineCodeDebugger >> highlightMCInstructions: aVMDebuggerIRInstruction [

	"Extract the machine code instructions from the IR instruction"

	| indexes instructionAddresses |
	instructionAddresses := aVMDebuggerIRInstruction machineCodeInstructionsAddresses.
	indexes := instructionAddresses collect: [ :addr | (self initialDisassembly collect: [ :e | e address ]) indexOf: addr ].
	indexes size = 1
		ifTrue: [ instructions beSingleSelection ]
		ifFalse: [ instructions beMultipleSelection ].
	instructions selection selectIndexes: indexes.


]

{ #category : #actions }
VMMachineCodeDebugger >> highlightPCInstruction [

	| index |
	index :=	(self initialDisassembly collect: [ :e | e address ]) indexOf: machineSimulator instructionPointerRegisterValue.
	instructions selection selectIndex: index

]

{ #category : #actions }
VMMachineCodeDebugger >> highlightRegisters: aVMDebuggerInstruction [

	"Extract registers name from instruction assembly and highlight the corresponding lines"
	| usedRegisters indexes |
	usedRegisters := aVMDebuggerInstruction usedRegisters.
	indexes := usedRegisters collect: [ :reg | machineSimulator registerList indexOf: reg ].
	indexes size = 1
		ifTrue: [ machineState beSingleSelection ]
		ifFalse: [ machineState beMultipleSelection ].
	machineState selection selectIndexes: indexes.


]

{ #category : #actions }
VMMachineCodeDebugger >> highlightSelectedIRInstructionMCInstructions [

	self selectedIRInstruction
		ifNotNil: [ self highlightMCInstructions: self selectedIRInstruction ]


]

{ #category : #actions }
VMMachineCodeDebugger >> highlightSelectedInstructionRegisters [

	self selectedInstruction
		ifNotNil: [ self highlightRegisters: self selectedInstruction ]

]

{ #category : #showing }
VMMachineCodeDebugger >> initialDisassembly [

	^ (self disassembleInstructionsAt: self initialInstructionToDisassemble) collect: [ :anInstruction |
			VMMachineCodeDebuggerInstruction new
				instruction: anInstruction;
				bytes: (anInstruction codeBytes: cogit objectMemory memoryManager);
				debugger: self;
				machineSimulator: machineSimulator;
				yourself ]
]

{ #category : #showing }
VMMachineCodeDebugger >> initialExtent [

	^ 1000@600
]

{ #category : #showing }
VMMachineCodeDebugger >> initialIRDisassembly [

	^ self abstractInstructions collect: [ :anInstruction | VMMachineCodeDebuggerIRInstruction new
				irinstruction: anInstruction;
				debugger: self;
				machineSimulator: machineSimulator;
				processOperands;
				yourself ]
]

{ #category : #showing }
VMMachineCodeDebugger >> initialInstructionToDisassemble [

	^ initialInstructionToDisassemble
		ifNil: [ machineSimulator instructionPointerRegisterValue ]
]

{ #category : #showing }
VMMachineCodeDebugger >> initialInstructionToDisassemble: anInstructionAddress [

	initialInstructionToDisassemble := anInstructionAddress
]

{ #category : #showing }
VMMachineCodeDebugger >> initialTrampolineDisassembly [

	"Add the method zone base to the trampoline"
	self trampolineDictionary at: cogit methodZoneBase hex put: 'methodZoneBase'.
	^ (self trampolineDictionary keys sorted) collect: [ :key | VMMachineCodeDebuggerTrampoline
				address: key
				name: (trampolineDictionary at: key)
				on: machineSimulator ]
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeButtons [

	trampolineButton := self newButton.
	trampolineButton label: 'Disassemble Trampoline'.
	stepButton := self newButton.
	stepButton label: 'Step'.
	disassembleAtPCButton := self newButton.
	disassembleAtPCButton label: 'Disassemble at PC'.
	pcInput := self newTextInput.
	jumpToButton := self newButton.
	jumpToButton label: 'Jump to'.
	disassembleAtSPButton := self newButton.
	disassembleAtSPButton label: 'Refresh Stack'.
	spInput := self newTextInput.
	setSPToButton := self newButton.
	setSPToButton label: 'Set SP to'.

]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeIRInstructionsPresenter [

	irinstructions := self newTable.
	irinstructions
		isResizable: true;
		addColumn:
			((SpStringTableColumn
			title: 'Name'
			evaluated: #opCodeName)
				 isSortable: false;
				 yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Op1'
			evaluated: #operand1)
				isSortable: false;
				yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Op2'
			evaluated: #operand2)
				isSortable: false;
				yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Op3'
			evaluated: #operand3)
				isSortable: false;
				yourself);
		showColumnHeaders;
		whenSelectionChangedDo: [ self highlightSelectedIRInstructionMCInstructions ]
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeInstructionsPresenter [

	instructions := self newTable.
	instructions
		isResizable: true;
		addColumn:
			((SpStringTableColumn title: 'Address' evaluated: #addressString)
				 isSortable: false;
				 yourself);
		addColumn: ((SpImageTableColumn title: '' evaluated: #icon)
				 width: 50;
				 beNotExpandable;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'ASM' evaluated: #assemblyCodeString)
				 isSortable: false;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'Bytes' evaluated: #bytesString)
				 isSortable: false;
				 yourself);
		showColumnHeaders;
		whenSelectionChangedDo: [ self highlightSelectedInstructionRegisters ]
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeMachineStatePresenter [


	machineState := self newTable.
	machineState
		isResizable: true;
		addColumn:
			((SpStringTableColumn title: 'Name' evaluated: #name)
				isSortable: false;
				width: 40;
				yourself);
		addColumn:
			((SpStringTableColumn title: 'Machine Alias' evaluated: #alias)
				isSortable: false;
				width: 80;
				yourself);
		addColumn:
			((SpStringTableColumn title: 'Smalltalk Alias' evaluated: #smalltalkAlias)
				isSortable: false;
				width: 100;
				yourself);
		addColumn:
			((SpStringTableColumn title: 'Value' evaluated:  [ :register | register printString ])
				isSortable: false;
				width: 300;
				yourself)
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializePresenters [

	self initializeTrampolinesPresenter.
	self initializeIRInstructionsPresenter.
	self initializeInstructionsPresenter.
	self initializeMachineStatePresenter.
	self initializeStackPresenter.
	self initializeButtons
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeStackPresenter [

	stack := self newTable.
	stack
		isResizable: true;
		addColumn:
			((SpStringTableColumn title: 'Pointer' evaluated: [ :aPosition | aPosition specialRegister ])
				isSortable: false;
				width: 50;
				yourself);
		addColumn: ((SpStringTableColumn title: 'Address' evaluated: [ :aPosition | aPosition address hex ])
				isSortable: false;
				width: 100;
				yourself);
		addColumn:
			((SpStringTableColumn title: 'Value' evaluated: [ :aPosition | [ aPosition value hex ] on: Error do: [ 'Error' ] ])
				isSortable: false;
				yourself)
]

{ #category : #initialization }
VMMachineCodeDebugger >> initializeTrampolinesPresenter [

	trampolines := self newTable.
	trampolines
		isResizable: true;
		addColumn:
			((SpStringTableColumn
			title: 'Address'
			evaluated: #address)
				 isSortable: false;
				 yourself);
		addColumn:
			((SpStringTableColumn
			title: 'Name'
			evaluated: #name)
				isSortable: false;
				yourself);
		showColumnHeaders
		"whenSelectionChangedDo: [ self highlightSelectedIRInstructionMCInstructions ]"
]

{ #category : #actions }
VMMachineCodeDebugger >> inspectSelectedIRInstruction [

	irinstructions selection selectedItem inspect
]

{ #category : #actions }
VMMachineCodeDebugger >> inspectSelectedInstruction [

	instructions selection selectedItem inspect
]

{ #category : #actions }
VMMachineCodeDebugger >> inspectSelectedTrampoline [

	trampolines selection selectedItem inspect
]

{ #category : #accessing }
VMMachineCodeDebugger >> irinstructions: aCollection [

	irinstructions := aCollection
]

{ #category : #actions }
VMMachineCodeDebugger >> jump [

	machineSimulator instructionPointerRegisterValue: (NumberParser parse: pcInput text).
	self refreshInstructions.
	self refreshRegisters.
]

{ #category : #accessing }
VMMachineCodeDebugger >> machineSimulator [
	^ machineSimulator
]

{ #category : #accessing }
VMMachineCodeDebugger >> machineSimulator: anObject [
	machineSimulator := anObject
]

{ #category : #showing }
VMMachineCodeDebugger >> openWithSpec [

	self refreshAll.
	super open
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshAll [

	self refreshIRInstructions.
	self refreshInstructions.
	self refreshStack.
	self refreshRegisters.
	self refreshTrampolines.
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshIRInstructions [

	irinstructions items: self initialIRDisassembly
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshInstructions [

	instructions items: self initialDisassembly
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshRegisters [

	machineState items: machineSimulator registerDescriptors
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshStack [

	| stackCollection |
	stackCollection :=
		(1 to: 30) collect: [ :anIndex |
		VMMachineCodeDebuggerStackItem
			address: self machineSimulator smalltalkStackPointerRegisterValue - 32 + (machineSimulator memory wordSize * (anIndex - 1))
			on: self machineSimulator.
	].
	stack items: stackCollection.
]

{ #category : #showing }
VMMachineCodeDebugger >> refreshTrampolines [

	trampolines items: self initialTrampolineDisassembly
]

{ #category : #'as yet unclassified' }
VMMachineCodeDebugger >> runToSelectedInstruction [

	| selectedInstruction |

	selectedInstruction := self selectedInstruction.

	machineSimulator
		startAt: machineSimulator instructionPointerRegisterValue
		until: selectedInstruction address
		timeout: 100000 "microseconds = 100ms"
		count: 0.
	self refreshStack.
]

{ #category : #accessing }
VMMachineCodeDebugger >> selectedIRInstruction [

	^ irinstructions selection selectedItem
]

{ #category : #accessing }
VMMachineCodeDebugger >> selectedInstruction [

	^ instructions selection selectedItem
]

{ #category : #accessing }
VMMachineCodeDebugger >> selectedTrampoline [

	^ trampolines selection selectedItem
]

{ #category : #actions }
VMMachineCodeDebugger >> setInstructionPointerToSelectedInstruction [

	machineSimulator instructionPointerRegisterValue: instructions selection selectedItem address
]

{ #category : #actions }
VMMachineCodeDebugger >> setSPTo [

	machineSimulator smalltalkStackPointerRegisterValue: (NumberParser parse: spInput text).
	self refreshStack.
	self refreshRegisters.
]

{ #category : #actions }
VMMachineCodeDebugger >> step [

	machineSimulator step.
	self refreshAll.
	self highlightPCInstruction
]

{ #category : #accessing }
VMMachineCodeDebugger >> title [

	^ 'VM Debugger'
]

{ #category : #initialization }
VMMachineCodeDebugger >> trampolineDictionary [
	^ trampolineDictionary
]

{ #category : #initialization }
VMMachineCodeDebugger >> trampolineDictionary: aDictionary [
	trampolineDictionary := aDictionary
]

{ #category : #accessing }
VMMachineCodeDebugger >> trampolines [
	^ trampolines
]

{ #category : #accessing }
VMMachineCodeDebugger >> trampolines: aCollection [
	trampolines := aCollection
]
