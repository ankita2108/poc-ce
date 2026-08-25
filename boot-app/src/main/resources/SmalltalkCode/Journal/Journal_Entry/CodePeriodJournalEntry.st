
PeriodJournalEntry subclass: #CodePeriodJournalEntry
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!CodePeriodJournalEntry class publicMethods !

journal
	^CodePeriodJournal! !

!CodePeriodJournalEntry publicMethods !

+ aString
	aString isString
		ifFalse: [^self error: 'Adding non string to a code journal'].
	(aString isEmpty or: [aString = value])
		ifTrue: [^self].
	value isEmpty
		ifTrue: [self value: aString]
		ifFalse: [self error: 'Can not add overlapping code journals']!

biWeeklyValueOver: aPeriod 
	^value!

combine: aPeriodJournalEntry
	self key combine: aPeriodJournalEntry key.
	self value = aPeriodJournalEntry value
		ifFalse: ["Probably want to avoid this"
					self value: self value, aPeriodJournalEntry value]!

combine: aPeriodJournalEntry with: aPolicy
	self value: (self combineValue: self value and: aPeriodJournalEntry value in: aPolicy).
	self key combine: aPeriodJournalEntry key!

combineValue: firstValue and: lastValue in: aPolicy
	aPolicy asUppercase = 'C'
		ifTrue:[^self concatenateValues: firstValue and: lastValue]. 
	aPolicy asUppercase = 'F' 
		ifTrue:[^firstValue]. 
	aPolicy asUppercase = 'L'
		ifTrue:[^lastValue]. !

concatenateValues: firstValue and: lastValue
	^firstValue,lastValue!

isMergableContiguousWith: aPeriodJournalEntry
	^self value = aPeriodJournalEntry value
		and: [super isMergableContiguousWith: aPeriodJournalEntry]!

stringToValue: aString
	^aString!

tbaTypeCode
	^'A'!

valueOver: aPeriod
	^(aPeriod isIntersecting: key)
		ifTrue: [self value]
		ifFalse: ['']!

valueOver: aPeriod prorationPolicy: aPolicy
	^(aPeriod isIntersecting: key)
		ifTrue: [self value]
		ifFalse: ['']!

valueOverUnique: aPeriod
	^self valueOver: aPeriod! !

CodePeriodJournalEntry initializeAfterLoad!