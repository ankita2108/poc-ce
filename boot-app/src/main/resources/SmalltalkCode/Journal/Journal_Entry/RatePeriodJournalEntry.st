
PeriodJournalEntry subclass: #RatePeriodJournalEntry
    classInstanceVariableNames: ''
    instanceVariableNames: 'rateFactor '
    classVariableNames: ''
    poolDictionaries: ''!

!RatePeriodJournalEntry class publicMethods !

journal
	^RatePeriodJournal! !

!RatePeriodJournalEntry publicMethods !

addConsistent: aNumber
	((aNumber haEqualTo: value) or: [aNumber haEqualTo: 0])
		ifTrue: [^self].
	^(value haEqualTo: 0)
		ifTrue: [self value: aNumber]
		ifFalse: [ExceptionalNumberResult 
						addError: (ArgumentRelationshipError 
											argumentName: 'journal value'
											argument: ''
											relatedArgumentName: 'overlapping journal value'
											relatedArgument: ''
											relationship: 'equal to'  )]!

asAmount
	^AmountPeriodJournalEntry
		key: key
		value: key years * (self rateFactor) * value!

asAmount: anInteger
	^AmountPeriodJournalEntry
		key: key
		value: (key years / (anInteger) * value roundTo: 0.01)!

biWeeklyValueOver: aPeriod 
	^value!

combine: aPeriodJournalEntry
	self key combine: aPeriodJournalEntry key!

rateFactor
	^self subclassResponsibility! !

RatePeriodJournalEntry initializeAfterLoad!