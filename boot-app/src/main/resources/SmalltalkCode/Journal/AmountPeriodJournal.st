
PeriodJournal subclass: #AmountPeriodJournal
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!AmountPeriodJournal class publicMethods !

fromCDHRecords: aCollection
	^(aCollection asSortedCollection: [:each1 :each2 | each1 beginDate < each2 beginDate])
		inject: AmountPeriodJournal clean
		into: [:inj :each | inj add: (self journalEntryClass fromCDHRecord: each).
									inj]	!

journalEntryClass
	^AmountPeriodJournalEntry!

menuName
	^'Amount Period'! !

!AmountPeriodJournal publicMethods !

accumulateOver: aMonthDay
| aJournal year jrnl2|
	jrnl2 :=  AmountPeriodJournal new.
	self entrys do:[:each | jrnl2 entrys add: (AmountPeriodJournalEntry key: each key deepCopy value: each value deepCopy prorationPolicy: each prorationPolicy deepCopy)].
	jrnl2 entrys
		inject: 0
		into: [:inj :each ||ann newValue|
				ann := aMonthDay anniversaryYear: each fromDate.
				newValue := each value + ((year isNil or: [ann > year])
															ifTrue: [year := ann.0]
															ifFalse: [inj]).
				each value: newValue.
				newValue].
	^jrnl2
!

add: aNumber
from: fromDate 
to: toDate
| result key|
	(key := self datePeriodClass from: fromDate to: toDate) isEmpty ifTrue: [^self].
	result := self copyNamedWithoutStorage.
	result add: (self entryClass
						key: key
						value: aNumber
						prorationPolicy: self prorationPolicy).
	result resolveOverlaps.
	^result!

addOverlappingEntries
| count |
(self prorationPolicy isNil) ifFalse:[^super addOverlappingEntries].
count := 1.
[count + 1 > self size]
	whileFalse: [count := count + (self resolvedOverlapsAt: count)].
self entrys:(self resolveDuplicates:'ADD')entrys.
(self hasOverlappingEntries) ifFalse:[^self]
ifTrue:[self addOverlappingEntries].!

applyBaseRate: aValue
withGrowth: aFactor
roundedTo: aNumber
	self
		inject: aValue
		into: [:inj :each |
				each value: inj.
				(each value * aFactor) roundedToDecimals: aNumber]!

applyForfeitMinimum: forfeitMinimum serviceMinimum: serviceMinimum
	| totalService index |
	totalService := 0.   
	1 to: (self size - 1) do: [:each | 
		totalService := totalService + (entrys at: each) value.
		(totalService haGreaterThanOrEqualTo: serviceMinimum) ifTrue: [^self copyNamedWithoutStorage].
		(index := self endOfBreakIndex: each greaterThan: forfeitMinimum) > 0	
			ifTrue: [^self copyFrom: index to: self size]].
	^self copyNamedWithoutStorage!

asAmount
	^self!

asDaily
	^self copyWithEntrys: self entrysAsDays
			!

asDateJournal
	^self asDateJournalSelector: #toDate!

asPayCap
	^self asPayCap: 150000!

asPayCap: anInteger
	^(self asMonthly: true) payCap: anInteger!

asPayCapJournal
	| monthlyJournal current newEntrys |
	current := OrderedCollection new.
	newEntrys := OrderedCollection new.
	monthlyJournal := self asMonthly: true.
	monthlyJournal entrys asOrderedCollection reverseDo:
		[:each | current add: each.
					current size = 12
						ifTrue: 	[newEntrys add:
										 (self entryClass
												key: (self datePeriodClass
															from: (current at: current size) fromDate
														    to: (current at: 1) toDate)
												value: (current inject: 0
															into: [:inj :each2 | inj + each2 value] )
												prorationPolicy: each prorationPolicy).
									current := OrderedCollection new]].
	current size > 0
		ifTrue: [	newEntrys  add:
					 (self entryClass
							key: (self datePeriodClass
										from: (current at: current size) fromDate
										to: (current at: 1) toDate)
							value: (current inject: 0
										into: [:inj :each2 | inj + each2 value] )
							prorationPolicy: self prorationPolicy)].
	^self copyWithEntrys: newEntrys

!

asPayCappedJournalWith: aTable 
| aJournal |
	(aJournal := self copyNamedWithoutStorage) entrys
		do: [:each | each value: (each value min: ((aTable at: each fromDate year) value))].
	^aJournal
!

asPayCumCappedJournalWith: aTable 
| aJournal limit priorEntryYear|
	priorEntryYear := 0.
	(aJournal := self copyNamedWithoutStorage) entrys
		do: [:each ||newValue|
						 (priorEntryYear < each fromDate year)
							ifTrue: [limit := aTable at: each fromDate year].
						newValue := (each value min: limit).
						limit := (limit - each value max: 0.0).
						each value: newValue.
						priorEntryYear := each fromDate year].
	^aJournal
!

asSocialSecurityDateJournal
	| aJournal |
	aJournal := self asDateJournalSelector: #fromDate.
	aJournal entrys do: [:each | each asSocialSecurityValue].
	^aJournal
!

asSocialSecurityPayCollectionTo: aLawYear
"Returns a fixed string of pays for Social Security pass area, taking into consideration the possiblity of missing pays and pay past law year."
	^(self asFullAnnual: MonthDay calendarStart)
		 asSocialSecurityDateJournal payCollectionTo: aLawYear!

asSplitAnnualContiguous: aMonthDay
	^self copyWithEntrys: ((self resolveOverlaps:'ADD') entrysContiguous: aMonthDay).!

asSplitMonthlyContiguous
	^self copyWithEntrys: (self resolveOverlaps:'ADD') entrysContiguous!

capEntrys: aCollection to: anInteger
| cap |
	cap := (aCollection 
				inject: 0
				into: [:inj :each | inj + each value]) - anInteger.
	cap > 0 ifFalse: [^aCollection].
	aCollection reverseDo:
		[:each | each value >= cap
						ifTrue: [each value: each value - cap.
									^aCollection]
						ifFalse: [cap := cap - each value.
									each value: 0]].
	^aCollection!

combineEditOverlappingEntries
	^(self addOverlappingEntries)!

combineOverlappingEntries:aColl with:aString
|tempColl tempJrnl aDic index|
tempColl := OrderedCollection new.
aDic := Dictionary new. index := 0.
self entrys do:[:entry| 
	index := index + 1.
	aDic at: index put: OrderedCollection new.
	aColl do:[:each|
		(entry key isIntersecting:each) 
		ifTrue:[ (aDic at: index) add: each ]
	]
].
index :=0.
self entrys do:[:entry| index := index + 1.
	tempColl addAll: (entry allocateOverCommon: (aDic at: index)).
]. 
tempJrnl := self class clean.
tempJrnl entrys:tempColl.
^(tempJrnl resolveDuplicates:aString)!

creditMonthly: aNumber
roundingRule: aString
	^self copyWithEntrys: 
		(self contiguousPeriods
				collect: [:each | self entryClass
								key: each
								value: (each monthRoundingRule: aString) * aNumber
								prorationPolicy: self prorationPolicy])!

creditYearly: aNumber
roundingRule: aString
monthDay: aMonthDay
	^self copyWithEntrys: 
		(self contiguousPeriods
			collect: [:each | self entryClass
									key: each
									value: (each
												yearRoundingRule: aString
												monthDay: aMonthDay ) * aNumber
									prorationPolicy: self prorationPolicy])!

dataTypeBlock
	^AtFunctionCalculator amountPeriodJournalBlock!

dateClass
	^AmountDateJournal!

defaultValue
	^0!

entrysAsDays
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asDays]!

entrysPayCap: anInteger
| current newEntrys |
	current := OrderedCollection new.
	newEntrys := OrderedCollection new.
	entrys asOrderedCollection reverseDo:
		[:each | current add: each.
					current size = 12
						ifTrue: 	[newEntrys addAll: (self capEntrys: current to: anInteger).
									current := OrderedCollection new]].
	current size = 0 ifTrue: [^newEntrys].
	newEntrys addAll: (self capEntrys: current to: anInteger).
	^newEntrys!

findValueFromEnd: aValue  
	self  
		reverseInject: aValue
		into: [:inj :each | |date|
					date := each findValueFromEnd: inj.
					date >= each fromDate ifTrue: [^date].
					inj - each value].
	^nil!

findValueFromStart: aValue  
	self  
		inject: aValue
		into: [:inj :each | |date num|
					date := each findValueFromStart: inj.
					date <= each throughDate ifTrue: [^date].
					((inj - each value) asFloat isNegative or:[inj - each value = 0]) ifTrue:[^date].
					inj - each value
					].
	^nil!

firstMonth
	self isEmpty ifTrue: [^0].
	^self valueOver: (self firstEntry firstMonth)!

firstOfOverlappingEntries
(self prorationPolicy isNil) ifFalse:[^super firstOfOverlappingEntries].
^self combineOverlappingEntries:(self resolvedOverlapPeriods) with:'FIRST'!

firstYear: aMonthDay
	self isEmpty ifTrue: [^0].
	^self valueOver: (self firstEntry firstYear: aMonthDay)!

highestConsecutiveGroupOfTwelveEntrys: aGroupSize with: aPayCapTable
	| max maxValue entries |
	entries := aGroupSize *12.
	self size < entries ifTrue:[^self].
	maxValue := 0.
	(self size  to: 1 by: -1)
		do: [:each | |current curValue count temp cap |
				(each - (entries-1)) <=0 ifTrue:[^max].
				(current := self copyFrom: each - (entries -1) to: each).
				count := 1.
				curValue := 0.
				[count < entries] whileTrue:[
					temp :=  (current copyFrom: count to: count + 11) sum.
				    cap := aPayCapTable lookupDown: (current entrys at: count) fromDate year.
				 	temp > cap
						ifTrue:[curValue := curValue  + cap]
						ifFalse:[curValue := curValue  + temp].
					count := count + 12].
				curValue > maxValue
					ifTrue: [max := current.
								maxValue := curValue]].
			^max!

highestOfOverlappingEntries
(self prorationPolicy isNil) ifFalse:[^super highestOfOverlappingEntries].
^self combineOverlappingEntries:(self resolvedOverlapPeriods) with:'HIGHEST'!

intersectFrom: startDate to: stopDate
	^self intersect: (self emptyCopy
							addValue: 0 at: (self datePeriodClass from: startDate to: stopDate);
							yourself)
!

isAmountJournal
	^true!

isAmountPeriodJournal
	^true!

lastMonth
	self isEmpty ifTrue: [^0].
	^self valueOver: (self lastEntry lastMonth)!

lastMonthTotal
	self isEmpty ifTrue: [^0].
	^self valueOverAll: (self lastEntry lastMonth)!

lastOfOverlappingEntries
(self prorationPolicy isNil) ifFalse:[^super lastOfOverlappingEntries].
^self combineOverlappingEntries:(self resolvedOverlapPeriods) with:'LAST'!

lastYear: aMonthDay
	self isEmpty ifTrue: [^0].
	^self valueOver: (self lastEntry lastYear: aMonthDay)!

lastYearTotal: aMonthDay
	self isEmpty ifTrue: [^0].
	^self valueOverAll: (self lastEntry lastYear: aMonthDay)!

lowestOfOverlappingEntries
(self prorationPolicy isNil) ifFalse:[^super lowestOfOverlappingEntries].
^self combineOverlappingEntries:(self resolvedOverlapPeriods) with:'LOWEST'!

mergeOverlappingEntries
(self prorationPolicy isNil) ifFalse:[^super mergeOverlappingEntries].
^self combineOverlappingEntries:(self resolvedOverlapPeriods) with:'MERGE'!

needsProrationPolicy
	self entrys detect: [:each | each needsProrationPolicy] ifNone: [^false].
	^true!

payCap: anInteger
	^self entrys: (self entrysPayCap: anInteger) asSortedCollection!

prorateBiWeeklyRoundedTo: aNumber for: aCalendar in: aContext
	self isEmpty ifTrue: [^self].
	self firstEntry valueOverBiWeeklyRoundedToDecimals: aNumber for: aCalendar in: aContext.
	self size > 1
		ifTrue: [self lastEntry valueOverBiWeeklyRoundedToDecimals: aNumber for: aCalendar in: aContext]!

prorateRoundedTo: aNumber
	self isEmpty ifTrue: [^self].
	self firstEntry valueOverAnnualRoundedToDecimals: aNumber.
	self size > 1
		ifTrue: [self lastEntry valueOverAnnualRoundedToDecimals: aNumber]!

prorateSemiMonthlyRoundedTo: aNumber on: aDayIndex
	self isEmpty ifTrue: [^self].
	self firstEntry valueOverSemiMonthlyRoundedToDecimals: aNumber on: aDayIndex.
	self size > 1
		ifTrue: [self lastEntry valueOverSemiMonthlyRoundedToDecimals: aNumber on: aDayIndex]!

prorationPolicy
	^self isEmpty
		ifTrue: [nil]
		ifFalse: [self entrys first prorationPolicy]!

prorationPolicy: aPolicy
	self entrys do: [:each | each prorationPolicy: aPolicy]!

resolveDuplicates: aString
(('COMBINE_EDIT' = aString) or:['SINGLE_ENTRY' = aString])
	ifTrue:[^super resolveDuplicates: 'ADD']
	ifFalse:[^super resolveDuplicates: aString].!

setProrationPolicyIn: aContext
	self entrys do: [:each | each prorationPolicy: aContext journalProrationPolicy]!

squeezeMonthsEntrys: aCollection
orphan: orphanString
consecutiveOrphan: consOrphanString
	^(JournalSqueezeMonths
		entrys: aCollection
		orphanRule: (OrphanRule ruleFrom: orphanString)
		consecutiveOrphanRule: (OrphanRule ruleFrom: consOrphanString)) squeezeMonths!

squeezeMonthsOrphan: orphanString consecutiveOrphan: consOrphanString
	^self copyWithEntrys:
		(self 
			squeezeMonthsEntrys: self copyEntrys
			orphan: orphanString
			consecutiveOrphan: consOrphanString)! !

AmountPeriodJournal initializeAfterLoad!