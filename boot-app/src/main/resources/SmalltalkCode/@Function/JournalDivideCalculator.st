
JournalAbstractCalculator subclass: #JournalDivideCalculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!JournalDivideCalculator class publicMethods !

computeArgumentDescriptions
	| result |
	result := OrderedCollection new.
	result add: 
		(ArgumentDescription
			name: 'journal'
			dataTypeBlock: self journalBlock
			defaultValue: nil
			validValues: nil
			explanation: 'Journal to be used.'
			repeating: false
			required: false).
	result add: 
		(ArgumentDescription
			name: 'number'
			dataTypeBlock: nil
			defaultValue: nil
			validValues: nil
			explanation: 'Number used to divide journal.'
			repeating: false
			required: false).
	^result!

explanation
	^'Returns a journal with values equal to the existing journal values divided by the number provided.'!

userName
	^'JrnlDivide'! !

!JournalDivideCalculator publicMethods !

calculateIn: aContext withArguments: aCollection
	^(self journal: aCollection) divideNumber: (self number: aCollection)!

number: aCollection
	^aCollection at: 2!

relationalErrors: aCollection	
	|result errors|
	result := OrderedCollection new.
	errors := self editCodePeriodJrnl: (aCollection at: 1).
	errors notNil ifTrue:[errors do:[:each | result add: each]].
	result isEmpty ifTrue:[^nil].
	^result!

returnTypeBlock: aCollection
	^self class journalBlock!

valueIn: aContext
	^self relationalEditValueIn: aContext! !

JournalDivideCalculator initialize!

JournalDivideCalculator initializeAfterLoad!