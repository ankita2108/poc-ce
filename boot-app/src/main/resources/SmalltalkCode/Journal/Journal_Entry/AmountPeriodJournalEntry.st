
PeriodJournalEntry subclass: #AmountPeriodJournalEntry
    classInstanceVariableNames: ''
    instanceVariableNames: 'prorationPolicy '
    classVariableNames: ''
    poolDictionaries: ''!

!AmountPeriodJournalEntry class publicMethods !

journal
	^AmountPeriodJournal!

key: aDateKey value: anObject prorationPolicy: aPolicy
	^self newWithoutStorage
		key: aDateKey
		value: anObject
		prorationPolicy: aPolicy! !

!AmountPeriodJournalEntry publicMethods !

allocateOver: aCollection with: aPeriodJournalEntry
	^self 
		combineEntrys: (self allocateOverCommon: aCollection)
		with: (aPeriodJournalEntry allocateOverCommon: aCollection)
	
!

asDays 
	^self allocateOver: (self key asDayPeriods)!

asEntrys: aCollection
	^(self class asJournalEntrys: aCollection) do: [:each | each prorationPolicy: self prorationPolicy]!

asEntrys: aCollection value: aValue
	^(self class asJournalEntrys: aCollection value: aValue) 
		do: [:each | each prorationPolicy: self prorationPolicy]!

combineEntrys: entries with: withEntries
	| result |    
	result := OrderedCollection new.
	1 to: entries size do: [:each | result add: ((entries at: each) combine: (withEntries at: each))].
	^result

!

copy
	^self class
		key: self key copy
		value: self value 
		prorationPolicy: self prorationPolicy!

deepCopy
	^self class
		key: self key shallowCopy
		value: self value shallowCopy
		prorationPolicy: self prorationPolicy shallowCopy!

defaultAllocationPolicy
	^prorationPolicy isNil
		ifTrue: [AmountAllocationPolicy new]
		ifFalse: [prorationPolicy defaultAllocationPolicy]!

defaultProrationPolicy
	^self prorationPolicy isNil
		ifTrue: [self datePeriod defaultProrationPolicy]
		ifFalse: [prorationPolicy]!

defaultProrationPolicyIn: aContext
	^aContext prorationPolicy isNil
		ifTrue: [self datePeriod defaultProrationPolicy]
		ifFalse: [aContext prorationPolicy]!

entryOver: aPeriod
	^self class
		key: aPeriod
		value: (self valueOver: aPeriod)
		prorationPolicy: self prorationPolicy!

entryOverUnique: aPeriod
	^self class
		key: aPeriod
		value: (self valueOverUnique: aPeriod)
		prorationPolicy: self prorationPolicy!

findValueFromEnd: aValue
	^(aValue haGreaterThan: self value)
		ifTrue: [self fromDate subtractDays: 1]
		ifFalse: [self defaultProrationPolicy
						prorateDateFromEnd: self key
						for: aValue
						for: self value]!

findValueFromEnd: aValue in: aContext
	^(aValue haGreaterThan: self value)
		ifTrue: [self fromDate subtractDays: 1]
		ifFalse: [(self defaultProrationPolicyIn: aContext)
						prorateDateFromEnd: self key
						for: aValue
						for: self value]!

findValueFromStart: aValue
	^(aValue haGreaterThan: self value)
		ifTrue: [self toDate]
		ifFalse: [self defaultProrationPolicy
						prorateDate: self key
						for: aValue
						for: self value]!

findValueFromStart: aValue in: aContext
	^(aValue haGreaterThan: self value)
		ifTrue: [self toDate]
		ifFalse: [(self defaultProrationPolicyIn: aContext)
						prorateDate: self key
						for: aValue
						for: self value]!

firstMonth
	^self key firstMonth!

firstYear: aMonthDay
	^self key firstYear: aMonthDay!

fragmentedEntryWith: aJournalEntry
	   ^self class
			key: (self fragmentedPeriodWith: aJournalEntry)
			value: nil
			prorationPolicy: self prorationPolicy!

key: anObject value: aValue prorationPolicy: aPolicy
	value := aValue.
	key := anObject.
	prorationPolicy := aPolicy!

lastMonth
	^self key lastMonth!

lastYear: aMonthDay
	^self key lastYear: aMonthDay!

needsProrationPolicy	
	^self prorationPolicy isNil!

prorationPolicy
	^prorationPolicy!

prorationPolicy: aPolicy	
	prorationPolicy := aPolicy!

semiMonthOn: anInteger
	^self key semiMonthOn: anInteger!

serviceRounded: aRoundingRule
	^AmountPeriodJournalEntry
		key: self key
		value: (self key perform: aRoundingRule)
		prorationPolicy: self prorationPolicy!

time
	^self defaultProrationPolicy timeIn: self key!

uniqueConsistentEntrysWith: aPeriodJournalEntry
	^self uniqueEntrysWith: aPeriodJournalEntry!

uniqueEntrysWith: aPeriodJournalEntry
	^self 
		allocateOver: (key uniquePeriodsWith: aPeriodJournalEntry key) 
		with: aPeriodJournalEntry!

valueOverAnnual
	self value: self value * self key months / 12!

valueOverAnnualRoundedToDecimals: aNumber
	self isFullYear ifTrue: [^self].
	self valueOverAnnual.
	self value: (self value roundedToDecimals: aNumber)!

valueOverBiWeeklyFor: aCalendar in: aContext
	self value: self value * (self days / (self fromDate biWeeklyFor: aCalendar in: aContext) days)!

valueOverBiWeeklyRoundedToDecimals: aNumber for: aCalendar in: aContext
	(self isFullBiWeeklyFor: aCalendar in: aContext) ifTrue: [^self].
	self valueOverBiWeeklyFor: aCalendar in: aContext.
	self value: (self value roundedToDecimals: aNumber)!

valueOverSemiMonthlyOn: anInteger
	self value: self value * (self days / (self fromDate semiMonthOn: anInteger) days)!

valueOverSemiMonthlyRoundedToDecimals: aNumber on: aDayIndex
	(self isFullSemiMonthlyOn: aDayIndex) ifTrue: [^self].
	self valueOverSemiMonthlyOn: aDayIndex.
	self value: (self value roundedToDecimals: aNumber)! !

AmountPeriodJournalEntry initializeAfterLoad!