
AtFunctionCalculator subclass: #JournalAbstractCalculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!JournalAbstractCalculator class publicMethods !

category
	^#('Journals')!

userName
	^self hiddenName! !

!JournalAbstractCalculator publicMethods !

exceptionalResultClass
	^ExceptionalJournalResult!

highDateError
	^OrderedCollection with:
			(ArgumentRelationshipError 
				argumentName: 'Last date in journal' 
				argument: ''
				relatedArgumentName: '12/31/2299'
				relatedArgument: ''
				relationship: 'before')!

highDateError: aCollection in: aContext
	| journal |
	(journal := (self journal: aCollection in: aContext)) isEmpty	
		ifTrue: [^nil].
	^journal latestDate < Date tbaHighDate
		ifTrue: [nil]
		ifFalse: [self highDateError]!

journal: aCollection
	^aCollection at: 1!

journal: aCollection in: aContext
	| result |
	result := aCollection at: 1.
	(result needsProrationPolicy and: [aContext journalProrationPolicy notNil])
		ifTrue: [result setProrationPolicyIn: aContext].
	^result
!

lowDateError
	^OrderedCollection with:
			(ArgumentRelationshipError 
				argumentName: 'First date in journal' 
				argument: ''
				relatedArgumentName: '01/01/1800'
				relatedArgument: ''
				relationship: 'after')!

lowDateError: aCollection in: aContext
	| journal |
	(journal := (self journal: aCollection in: aContext)) isEmpty	
		ifTrue: [^nil].
	^journal earliestDate > Date tbaLowDate
		ifTrue: [nil]
		ifFalse: [self lowDateError]!

lowHighDateErrors: aCollection in: aContext
	| errors |
	^(errors := self highDateError: aCollection in: aContext) isNil
		ifTrue: [self lowDateError: aCollection in: aContext]
		ifFalse: [errors]! !

JournalAbstractCalculator initialize!

JournalAbstractCalculator initializeAfterLoad!