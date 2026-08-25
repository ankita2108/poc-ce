
PeriodJournal subclass: #RatePeriodJournal
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: 'TypeConversion '
    poolDictionaries: ''!

!RatePeriodJournal class publicMethods !

annualRate
	^HARateFrequencyConstants at: 'AnnualRate'!

hourlyRate
	^HARateFrequencyConstants at: 'HourlyRate'!

initializeTypeConversion
	|dictionary|
	dictionary := Dictionary new.
	dictionary at: self monthlyRate put: MonthlyRatePeriodJournalEntry.
	dictionary at: self hourlyRate put: HourlyRatePeriodJournalEntry.
	dictionary at: self annualRate put: AnnualRatePeriodJournalEntry.
	^dictionary!

journalEntryClass
	^AnnualRatePeriodJournalEntry!

menuName
	^'Rate Period'!

monthlyRate
	^HARateFrequencyConstants at: 'MonthlyRate'!

rateFrequency: aString
	^(self validFrequency: aString)
		ifTrue: [self entryClass: (self type: aString)]
		ifFalse: [self error: aString, ' is an invalid rate frequency.']!

type: aString
	^self typeConversion
		at: aString
		ifAbsent: [^AnnualRatePeriodJournalEntry]!

typeConversion
	(TypeConversion isNil or: [self typeIsInvalid])
		ifTrue: [TypeConversion := self initializeTypeConversion].
	^TypeConversion!

typeIsInvalid
	^((TypeConversion
		at: 'A'
		ifAbsent: [^true]) = AnnualRatePeriodJournalEntry) not!

validFrequency: aString
	^HARateFrequencyConstants includes: aString! !

!RatePeriodJournal publicMethods !

applyBaseRate: aValue
withGrowth: aFactor
roundedTo: aNumber
	self
		inject: aValue
		into: [:inj :each |
				each value: inj.
				(each value * aFactor) roundedToDecimals: aNumber]!

asAmount
	^AmountPeriodJournal newWithoutStorage
		addAll: (self entrys collect:
						[:each | each asAmount])!

asFullMonthlyUsing: aPolicy  
	^self copyWithEntrys:
		(self resolveAsMonths: self entrysAsFullCalendarMonths policy: aPolicy)!

asFullMonthlyUsingBeginningRate 
	^self copyWithEntrys:
		(self resolveAsMonths: self entrysAsFullCalendarMonths policy: 'B')!

asMonthly: aBoolean policy: aPolicy
	^self copyWithEntrys:
		(aBoolean
			ifTrue: [self resolveAsMonths: self entrysAsCalendarMonths policy: aPolicy]
			ifFalse: [self entrysAsContiguousCalendarMonths: aPolicy])!

asSplitAnnualContiguous: aMonthDay
	^self copyWithEntrys: ((self resolveOverlaps:'FIRST') entrysContiguous: aMonthDay).!

asSplitMonthlyContiguous
	^self copyWithEntrys: (self resolveOverlaps:'FIRST') entrysContiguous!

biWeeklyValueOver: aPeriod
|aNumber|
	aNumber := 0.
	self isEmpty
		ifTrue: [^aNumber].
	^(self journalEntryAtIndex: (self indexBeginningIn: aPeriod)) biWeeklyValueOver: aPeriod.!

combineNextFrom: sourceCollection to: aCollection policy: aPolicy
	aPolicy
		combine: aCollection last 	
		with: sourceCollection removeFirst 
		for: self!

dataTypeBlock
	^AtFunctionCalculator ratePeriodJournalBlock!

dateClass
	^RateDateJournal!

defaultValue
	^0!

entrysAsContiguousCalendarMonths: aPolicy
	^self resolveAsContiguousMonths: self entrysAsCalendarMonths policy: aPolicy!

hasConflictingOverlaps
	1 to: self entrys size - 1 do: [:each | ((self entrys at: each) key intersects: (self entrys at: each + 1) key)	
																	ifTrue: [((self entrys at: each) value ~= (self entrys at: each + 1) value)
																						ifTrue: [^true]]].
	^false
!

isAnnually
	^self entryClass isAnnually!

isHourly
	^self entryClass isHourly!

isMonthly
	^self entryClass isMonthly!

isRateJournal
	^true!

isRatePeriodJournal
	^true!

nonIntersects: aPeriodJournal
	(aPeriodJournal isEmpty or: [self isNotIntersecting: aPeriodJournal])
		 ifTrue: [^self copy].
	^self copyWithEntrys: (self nonIntersectEntrys: aPeriodJournal)!

resolve: aCollection asAnniversaryYearsNew: aMonthDay
	^self
		resolve: aCollection "asSortedCollection"
		samePeriodBlockNew:	[:each :each2 | each 
									isSameAnniversary: each2 
									startingOn: aMonthDay]!

resolve: aCollection asQuartersNew: aMonthDay
	^self
		resolve: ( PeriodJournal sortByKeyOnly: aCollection )
		samePeriodBlockNew:	[:each :each2 | each 
									isSameQuarter: each2 
									on: aMonthDay]!

resolve: aCollection samePeriodBlock: aBlock policy: aPolicy
| result | 
	aCollection isEmpty ifTrue: [^aCollection].
	result := OrderedCollection new: aCollection size.
	result add: aCollection removeFirst.
	[aCollection isEmpty]
		whileFalse:
		[(aBlock value: aCollection first value: result last)
			ifTrue: [self combineNextFrom: aCollection to: result policy: aPolicy]
			ifFalse: [result add: aCollection removeFirst]].
	^result!

resolve: aCollection samePeriodBlockNew: aBlock
| result periods newCollection| 
	aCollection isEmpty ifTrue: [^aCollection].
	periods := OrderedCollection new.
	newCollection := OrderedCollection new.
	aCollection do:[:each| periods add: each key].
	aCollection do:[:each| (each key isDuplicateDatePeriodIn: periods) 
											ifTrue:[newCollection add: (aCollection at: (aCollection findLast:[:each2| each2 key = each key]))]
											ifFalse:[newCollection add: each ].
							].
	result := OrderedCollection new: newCollection size.
	result add: newCollection removeFirst.
	[newCollection isEmpty]
		whileFalse:
		[(aBlock value: newCollection first value: result last)
			ifTrue: [self combineNextFrom: newCollection to: result]
			ifFalse: [result add: newCollection removeFirst]].
	^result!

resolveAsContiguousMonths: aCollection policy: aPolicy
	^self
		resolve: aCollection
		samePeriodBlock: [:each :each2 | each isSameContiguousMonth: each2]
		policy: aPolicy!

resolveAsMonths: aCollection policy: aString
	^self 
		resolve: aCollection 
		samePeriodBlock: [:each :each2 | each isSameMonthAndYear: each2]
		policy: aString!

resolveDuplicates: aString
('COMBINE_EDIT' = aString) 
	ifTrue:[^super resolveDuplicates: 'MERGE'].
('SINGLE_ENTRY' = aString)
	ifTrue:[^super resolveDuplicates: 'FIRST'].

	^super resolveDuplicates: aString.!

shouldEditFor:aString
^(aString = 'COMBINE_EDIT')! !

RatePeriodJournal initializeAfterLoad!