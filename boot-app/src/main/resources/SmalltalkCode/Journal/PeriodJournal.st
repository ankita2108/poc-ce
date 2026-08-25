
Journal subclass: #PeriodJournal
    classInstanceVariableNames: ''
    instanceVariableNames: 'datePeriodClass '
    classVariableNames: ''
    poolDictionaries: ''!

!PeriodJournal class publicMethods !

periodClass
	^self!

sortByKeyOnly: aCollection
	|newColl sortColl resultColl count|
	newColl := OrderedCollection new.
	resultColl := OrderedCollection new.
	count := 1.
	aCollection do:[:each |newColl add: each deepCopy]. 
	newColl do:[:each| each value: count.  count := count + 1].
	sortColl := newColl asSortedCollection. 
	sortColl do:[:each| resultColl add: each].
	resultColl do:[:each | each value: (aCollection at: each value) value].
	^resultColl
	
	! !

!PeriodJournal publicMethods !

+ aJournal
	^(self isIntersecting: aJournal)
		ifTrue: [(self combine: aJournal) resolveOverlaps]
		ifFalse: [self copyNamedWithoutStorage addJournal: aJournal]!

- aJournal
	^self + (aJournal copyNamedWithoutStorage negated)!

= aJournal
	^aJournal equalToPeriodJournal: self!

abtXmlPrintOn: aStream
	aStream nextPutAll: '<PeriodJournal>'.
	self entrys do:[:each| each abtXmlPrintOn:aStream ].
	aStream nextPutAll: 'PeriodJournal' abtAsXmlEndTag.!

abtXmlPrintOn: anAbtXmlStream context: anAbtXmlSerializationContext
"This is not the way to write this method and the best way would be to create a mapping spec. Please consider refactoring later"
	anAbtXmlStream nextPutAll: '<value><PeriodJournal>'.
	self entrys do:[:each| each abtXmlPrintOn: anAbtXmlStream ].
	anAbtXmlStream nextPutAll: '</PeriodJournal></value>'.!

add: aNumber
from: fromDate 
to: toDate
| result key|
	(key := self datePeriodClass from: fromDate to: toDate) isEmpty ifTrue: [^self].
	result := self copyNamedWithoutStorage.
	result add: (self entryClass
						key: key
						value: aNumber).
	result resolveOverlaps.
	^result!

addAllValid: aCollection
	self addAll: (aCollection select:
		[:each | each key fromDate isDate and: [each key toDate isDate]])!

addOfOverlappingEntries:aColl 
|aTempColl valColl tempEntry|
valColl := OrderedCollection new.
aColl do:[:each| 
		aTempColl := SortedCollection new.
		self entrys do:[:each2|(each isIntersecting: each2 key) 
			ifTrue:[
				tempEntry := (each2 entryOverUnique:each).
				aTempColl add:(tempEntry value)
				].
			].
			tempEntry value:(aTempColl inject:0 into: [:a :b| a + b]).
			valColl add:tempEntry.
		].
	^valColl!

addOverlappingEntries
	^self copyWithoutStorage entrys:(self addOfOverlappingEntries:(self resolvedOverlapPeriods)).!

aggregateFromEndForEntries: aNumber	
	| resultEntries currentEntry | 
	(self isEmpty or: [aNumber < 2])
		ifTrue: [^self].
	resultEntries := OrderedCollection new.
	self size to: 1 by: (aNumber * -1) do: [:each |
		each < self size
			ifTrue: [resultEntries add: currentEntry].
		currentEntry := (self entrys at: each) copy. 
		each - 1 to: (each - aNumber + 1) by: -1 do: [:each2 |
			each2 < 1
				ifFalse: [currentEntry := currentEntry combine: (self entrys at: (each2))]]].
	resultEntries add: currentEntry.
	^self copyWithEntrys: resultEntries
	!

aggregateFromStartForEntries: aNumber	
	| resultEntries currentEntry | 
	(self isEmpty or: [aNumber < 2])
		ifTrue: [^self].
	resultEntries := OrderedCollection new.
	1 to: self size by: aNumber do: [:each |
		each > 1
			ifTrue: [resultEntries add: currentEntry].
		currentEntry := (self entrys at: each) copy. 
		each + 1 to: (each + aNumber - 1) do: [:each2 |
			each2 > self size
				ifFalse: [currentEntry := currentEntry combine: (self entrys at: (each2))]]].
	resultEntries add: currentEntry.
	^self copyWithEntrys: resultEntries
	!

alignedAddJrnl: aJournal
	^self copyNamedWithoutStorage
		with: aJournal 
		do: [:each1 :each2 | each1 value: each1 value + each2 value]!

alignedDivJrnl: aJournal
	^self copyNamedWithoutStorage
		with: aJournal 
		do: self divisionBlock!

alignedMaxJrnl: aJournal 
	^self copyNamedWithoutStorage
		with: aJournal 
		do: self maxBlock!

alignedMinJrnl: aJournal 
	^self copyNamedWithoutStorage
		with: aJournal 
		do: self minBlock!

alignedMultiplyJrnl: aJournal
	^self copyNamedWithoutStorage
		with: aJournal 
		do: self multiplicationBlock!

alignedSubJrnl: aJournal
	^self copyNamedWithoutStorage
		with: aJournal 
		do: [:each1 :each2 | each1 value: each1 value - each2 value]!

asAnnual: aMonthDay
	^self copyWithEntrys:
		(self
			resolve: (self entrysAsAnniversaryYears: aMonthDay)
			asAnniversaryYears: aMonthDay)!

asBiWeeklyFor: aCalendar in: aContext

	| resultEntries |
	
	self isEmpty ifTrue:[^self].
	resultEntries := self entrysAsBiWeeklyFor: aCalendar in: aContext.
	
	"This resultEntries should not contain a periodJournalEntry that's out of the 
	ranges of the specific Journal being passed in."
	resultEntries := self checkForOutOfRangePeriodJournalEntries: resultEntries.
	
	resultEntries do: [:each | each value: (self biWeeklyValueOver: each key)].
	^self copyWithEntrys: resultEntries!

asCalendarYears
	^self copyWithEntrys: self entrysAsCalendarYears!

asCompleteMonths 
	^self completeMonths 
		inject: (self emptyCopy entryClass: self entryClass)
		into: [:inj :each | inj at: each put: (self valueOver: each). inj]

!

asCompleteYears: aMonthDay  
	^(self completeYears: aMonthDay) 
		inject: (self emptyCopy entryClass: self entryClass)
		into: [:inj :each | inj at: each put: (self valueOver: each). inj]

!

asDateJournal
	^self asDateJournalSelector: #fromDate!

asDateJournalSelector: aSelector
| journal |
	journal := self dateClass new.
	self journalEntrysDo:
		[:each |
			journal addValue: each value at: (each key perform: aSelector)].
	^journal    !

asDatePeriod: aClass
|result|
	self datePeriodClass = aClass ifTrue: [^self].
	result := self copyWithEntrys: (self entrysAsDatePeriod: aClass).
	result datePeriodClass: aClass.
	^result!

asFullAnnual: aMonthDay
	^self copyWithEntrys:
		(self
			resolve: (self entrysAsFullAnnual: aMonthDay)
			asAnniversaryYears: aMonthDay)!

asFullAnnualNew: aMonthDay
	^self copyWithEntrys:
		(self
			resolve: (self entrysAsFullAnnual: aMonthDay)
			asAnniversaryYearsNew: aMonthDay)!

asFullMonthly 
	^self copyWithEntrys:
		(self resolveAsMonths: self entrysAsFullCalendarMonths)!

asFullQuarter: aMonthDay
	^self copyWithEntrys:
		(self
			resolve: (self entrysAsFullQuarter: aMonthDay)
			asQuarters: aMonthDay)!

asFullQuarterNew: aMonthDay
	^self copyWithEntrys:
		(self
			resolve: (self entrysAsFullQuarter: aMonthDay)
			asQuartersNew: aMonthDay)!

asIncompleteMonths 
	^self incompleteMonths 
		inject: (self emptyCopy entryClass: self entryClass)
		into: [:inj :each | inj at: each put: (self valueOver: each). inj]

!

asIncompleteYears 
	^self incompleteYears 
		inject: (self emptyCopy entryClass: self entryClass)
		into: [:inj :each | inj at: each put: (self valueOver: each). inj]

!

asIncompleteYears: aMonthDay  
	^(self incompleteYears: aMonthDay) 
		inject: (self emptyCopy entryClass: self entryClass)
		into: [:inj :each | inj at: each put: (self valueOver: each). inj]

!

asJournalWithMissingPeriodsFrom: startDate to: endDate
	^self copyWithEntrys: (self missingPeriodsFrom: startDate to: endDate)
	!

asMergedContiguous
	^self copyWithEntrys: self entrysMergeContiguous!

asMonthly
	^self asMonthly: true!

asMonthly: aBoolean
	^self copyWithEntrys:
		(aBoolean
			ifTrue: [self resolveAsMonths: self entrysAsCalendarMonths]
			ifFalse: [self entrysAsContiguousCalendarMonths])!

asPeriodJournal
	^self!

asQuarter: aMonthDay
	^self copyWithEntrys:
		(self
			resolve: (self entrysAsQuartersOn: aMonthDay)
			asQuarters: aMonthDay)!

asSemiMonthlyOn: anInteger
	^self copyWithEntrys: (self entrysAsSemiMonthsOn: anInteger)!

asSplitAnnualContiguous: aMonthDay
	^self copyWithEntrys: (self entrysContiguous: aMonthDay)!

asSplitMonthly
	^self copyWithEntrys: self entrysAsCalendarMonths!

asSplitMonthlyContiguous
	^self copyWithEntrys: self entrysContiguous!

asSplitYearly: aMonthDay
	| resultEntries |
	self isEmpty ifTrue:[^self].
	resultEntries := (self entrysAsAnniversaryYears: aMonthDay).
	resultEntries := self checkForOutOfRangePeriodJournalEntries: resultEntries.
	^self copyWithEntrys: resultEntries!

asStepBackAnnual
	^self asStepBackAnnualForThreshold: 0!

asStepBackAnnualForThreshold: exactYears
	^(self stepBackPeriodsForThreshold: exactYears)
		inject: self class clean
		into: [:inj :each | inj at: each put: (self valueOver: each).
								inj]!

biWeeklyValueOver: aPeriod
|sum|
	sum := 0.
	self isEmpty
		ifTrue: [^sum].
	(self indexBeginningIn: aPeriod)
		to: (self indexEndingIn: aPeriod)
		do: [:each | sum := sum + ((self journalEntryAtIndex: each) biWeeklyValueOver: aPeriod)].
	^sum!

checkForOutOfRangePeriodJournalEntries: aResultEntries

		| journalStartDate journalEndDate resultEntries |
		journalStartDate := self entrys first key fromDate.
		journalEndDate := self entrys last key toDate.
		
		resultEntries := aResultEntries reject:[ :each |
			each key fromDate < journalStartDate
				and:[each key toDate < journalEndDate]].
		
		^resultEntries 
				
			!

combine: aJournal
	^self copyNamedWithoutStorage addAll: aJournal copyEntrys;
		yourself!

combineEditOverlappingEntries
	^(self mergeOverlappingEntries)!

combineNextFrom: sourceCollection to: aCollection
	aCollection last combine: sourceCollection removeFirst!

completeMonths
	^self contiguousPeriods
		inject: OrderedCollection new
		into: [:inj :each | inj addAll: each completeMonths. inj]
!

completePeriodFromDateAfter: aDate 
	aDate >= self toDate 
		ifTrue: [^self errorInvalidKey: aDate].
	aDate <= self fromDate 
		ifTrue: [^self fromDate]. 
	self entrys do: 
		[:each | 
			(aDate <= each toDate) 
				ifTrue: [(aDate <= each fromDate)
								ifTrue:[^each fromDate].
							^self fromDateAfterEntry: each]].
	^nil


!

completePeriodFromDateAfter: aDate default: defaultDate
	(self  size >= 2) ifTrue:[
		(((self entrys at: self size) key = (self entrys at: (self size-1)) key) 
					and: [(aDate > self lastDate fromDate) and:[aDate < self lastDate toDate]])					
			ifTrue:[ ^self lastDate fromDate]].
	(aDate > self lastDate fromDate)
			ifTrue:[ self hasOverlappingEntries
						ifTrue:[ (self dateIsInPreviousEntry: aDate) not
									ifTrue: [^defaultDate]]
						ifFalse: [^defaultDate]].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self fromDate)].
	self entrys do: [:each | (aDate = each fromDate) ifTrue: [^each fromDate].
										  (aDate <= each throughDate) ifTrue:[
																						(self entryOn: aDate) notNil 
																								ifTrue: [^self fromDateAfterEntry: each]
																								ifFalse: [^each fromDate]]]										
!

completePeriodFromDateBefore: aDate default: defaultDate
	(aDate > (self lastDate throughDate)) 
						ifTrue: [^self lastDate fromDate].		
	(self  size >= 2) ifTrue:[
		(((self entrys at: 1) key = (self entrys at:2) key) and: [(aDate >= self firstDate fromDate) and:[aDate < self firstDate throughDate]])						
			ifTrue:[ ^self firstDate fromDate]].		
	(aDate < self firstDate throughDate)
			ifTrue:[ self hasOverlappingEntries
							ifTrue:[ (self dateIsInLaterEntry: aDate) not
									ifTrue:[^defaultDate]]
							ifFalse: [^defaultDate]].
		self entrys reverseDo: [:each | (aDate = each throughDate) ifTrue: [^each fromDate].
											 (aDate >= each fromDate)
											 ifTrue:[ (aDate < each throughDate)
														ifTrue:[^self fromDateBeforeEntry: each].
														(self entryOn: aDate) isNil 
															ifTrue: [^each fromDate]]]
!

completePeriodThroughDateAfter: aDate 
	aDate >= self throughDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self entrys do: 
		[:each |
			(aDate < each fromDate) 
				ifTrue: [^each throughDate]]
!

completePeriodThroughDateAfter: aDate default: defaultDate
	(self  size >= 2) ifTrue:[
		(((self entrys at: self size) key = (self entrys at: (self size-1)) key) 
				and: [(aDate > self lastDate fromDate) and:[aDate < self lastDate toDate]])					
			ifTrue:[ ^self lastDate throughDate]].
	(aDate > (self lastDate fromDate)) 
			ifTrue:[ self hasOverlappingEntries
						ifTrue:[ (self dateIsInPreviousEntry: aDate) not
									ifTrue: [^defaultDate]]
						ifFalse: [^defaultDate]].	
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self firstThroughDate)].
	self entrys do: [:each | (aDate = each fromDate) ifTrue: [^each throughDate].
										  (aDate <= each throughDate) ifTrue:[
																			(self entryOn: aDate) notNil 
																					ifTrue: [^self throughDateAfterEntry: each]
																					ifFalse: [^each throughDate]]]
																			
!

completePeriodThroughDateBefore: aDate 
	aDate >= self toDate 
		ifTrue: [^self lastDate throughDate].
	aDate <= self fromDate 
		ifTrue: [^self errorInvalidKey: aDate].	
	self entrys do:
		[:each |
			(aDate <= each throughDate) 
				ifTrue: [^self throughDateBeforeEntry: each]].
	^nil
!

completePeriodThroughDateBefore: aDate default: defaultDate
	(aDate > (self lastDate throughDate)) 
						ifTrue: [^self lastDate throughDate].
	(self  size >= 2) ifTrue:[
		(((self entrys at: 1) key = (self entrys at:2) key) and: [(aDate >= self firstDate fromDate) and:[aDate < self firstDate throughDate]])						
			ifTrue:[ ^self firstDate throughDate]].
	(aDate < (self firstDate throughDate)) 
			ifTrue:[ self hasOverlappingEntries
							ifTrue:[ (self dateIsInLaterEntry: aDate) not
									ifTrue:[^defaultDate]]
							ifFalse: [^defaultDate]].
	self entrys reverseDo: [:each | (aDate = each throughDate) ifTrue: [^each throughDate].
											 (aDate >= each fromDate)
											 ifTrue:[ (aDate < each throughDate)
														ifTrue:[^self throughDateBeforeEntry: each].
														(self entryOn: aDate) isNil 
															ifTrue: [^each throughDate]]]
!

completePeriodToDateAfter: aDate 
	aDate >= self toDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self entrys do: 
		[:each |
			(aDate < each fromDate) 
				ifTrue: [^each toDate]]
!

completePeriodToDateAfter: aDate default: defaultDate
	(self  size >= 2) ifTrue:[
		(((self entrys at: self size) key = (self entrys at: (self size-1)) key) 
				and: [(aDate > self lastDate fromDate) and:[aDate < self lastDate toDate]])					
			ifTrue:[ ^self lastDate toDate]].
	(aDate > (self lastDate fromDate)) 
			ifTrue:[ self hasOverlappingEntries
						ifTrue:[ (self dateIsInPreviousEntry: aDate) not
									ifTrue: [^defaultDate]]
						ifFalse: [^defaultDate]].	
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self firstToDate)].
	self entrys do: [:each | (aDate = each fromDate) ifTrue: [^each toDate].
										  (aDate <= each throughDate) ifTrue:[
																							(self entryOn: aDate) notNil 
																									ifTrue: [^self toDateAfterEntry: each]
																									ifFalse: [^each toDate]]]
!

completePeriodToDateBefore: aDate 
	aDate >= self toDate 
		ifTrue: [^self toDate].
	aDate <= self fromDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self entrys do:
		[:each |
			(aDate <= each toDate) 
				ifTrue: [^self toDateBeforeEntry: each]].
	^nil
!

completePeriodToDateBefore: aDate default: defaultDate
	(aDate > (self lastDate throughDate)) 
						ifTrue: [^self lastDate toDate].
	(self  size >= 2) ifTrue:[
	(((self entrys at: 1) key = (self entrys at:2) key) and: [(aDate >= self firstDate fromDate) and:[aDate < self firstDate throughDate]])						
		ifTrue:[ ^self firstDate toDate]].
	(aDate < (self firstDate throughDate)) 
			ifTrue:[ self hasOverlappingEntries
							ifTrue:[ (self dateIsInLaterEntry: aDate) not
									ifTrue:[^defaultDate]]
							ifFalse: [^defaultDate]].
	self entrys reverseDo: [:each | (aDate = each throughDate) ifTrue: [^each toDate].
											 (aDate >= each fromDate)
											 ifTrue:[ (aDate < each throughDate)
														ifTrue:[^self toDateBeforeEntry: each].
														(self entryOn: aDate) isNil 
															ifTrue: [^each toDate]]]
!

completePeriodValueAfter: aDate 
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^self errorInvalidKey: aDate].
	(aDate <= (self firstDate fromDate)) 
						ifTrue: [^(self firstValue)].
	self
		inject: aDate
		into: [:inj :each |
						(aDate <= (each throughDate) or: [ aDate <= (each toDate)]) 
							ifTrue: [
								(aDate <= each fromDate)
									ifTrue:[^each value].
								^(self valueAfterEntry: each)]].
	^nil
!

completePeriodValueAfter: aDate default: defaultVal
	(self  size >= 2) ifTrue:[
		(((self entrys at: self size) key = (self entrys at: (self size-1)) key) 
				and: [(aDate > self lastDate fromDate) and:[aDate < self lastDate toDate]])					
			ifTrue:[ ^self lastValue ]].
	(aDate > (self lastDate fromDate)) 
				ifTrue:[ self hasOverlappingEntries
						ifTrue:[ (self dateIsInPreviousEntry: aDate) not
									ifTrue: [^defaultVal]]
						ifFalse: [^defaultVal]].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self firstValue)].
	self entrys do: [:each | (aDate = each fromDate) ifTrue: [^each value].
										  (aDate <= each throughDate) ifTrue:[
																							(self entryOn: aDate) notNil 
																									ifTrue: [^self valueAfterEntry: each]
																									ifFalse: [^each value]]]



!

completePeriodValueBefore: aDate 
		(aDate >= (self lastDate toDate)) 
						ifTrue: [^(self lastValue)].
		(aDate <= (self firstDate fromDate)) 
						ifTrue: [^self errorInvalidKey: aDate].
		self
		inject: aDate
		into: [:inj :each |
						(aDate <= (each throughDate) or: [ aDate <= (each toDate)]) 
							ifTrue: [^(self valueBeforeEntry: each)]].
	^nil
!

completePeriodValueBefore: aDate default: defaultVal
	(aDate > (self lastDate throughDate)) 
						ifTrue: [^self lastValue].
	(self  size >= 2) ifTrue:[
		(((self entrys at: 1) key = (self entrys at:2) key) and: [(aDate >= self firstDate fromDate) and:[aDate < self firstDate throughDate]])						
			ifTrue:[ ^self firstValue]].	
	(aDate < self firstDate throughDate) 
		ifTrue:[self hasOverlappingEntries
					ifTrue:[(self dateIsInLaterEntry: aDate) not
							ifTrue:[^defaultVal]]
					ifFalse: [^defaultVal]].				
		self entrys reverseDo: [:each | (aDate = each throughDate) ifTrue: [^each value].
											 (aDate >= each fromDate)
											 ifTrue:[ (aDate < each throughDate)
														ifTrue:[^self valueBeforeEntry: each].
														(self entryOn: aDate) isNil 
															ifTrue: [^each value]]]
!

completeYears: aMonthDay
	^self contiguousPeriods
		inject: OrderedCollection new
		into: [:inj :each | inj addAll: (each completeYears: aMonthDay). inj]
!

contains: aDate
	^self datePeriod contains: aDate!

contiguousPeriods
	^self contiguousPeriodsForThreshold: 0!

contiguousPeriodsForThreshold: anInteger
|periods result |
	result := OrderedCollection new.
	(periods := self keysAsArray) isEmpty ifTrue: [^result].
	result add: periods first.
	2 to: periods size do:
		[:each | (result last isContiguousWith: (periods at: each) forThreshold: anInteger)
						ifTrue: [result add: (result removeLast createTo: (periods at: each))]
						ifFalse: [result add: (periods at: each)]].
	^result!

creditMonthly: aNumber
roundingRule: aString
	^self copyWithEntrys: 
		(self contiguousPeriods
				collect: [:each | self entryClass
								key: each
								value: (each monthRoundingRule: aString) * aNumber])!

creditYearly: aNumber
roundingRule: aString
monthDay: aMonthDay
	^self copyWithEntrys: 
		(self contiguousPeriods
			collect: [:each | self entryClass
									key: each
									value: (each
												yearRoundingRule: aString
												monthDay: aMonthDay ) * aNumber])!

dataTypeBlock
	^AtFunctionCalculator periodJournalBlock!

dateIsInLaterEntry: aDate
	|firstEntry|
	firstEntry := self entrys first. 
	self entrys do:[:each | (each contains: aDate)
										ifTrue:[(each ~= firstEntry)
													ifTrue:[^true]]].
	^false!

dateIsInPreviousEntry: aDate
	|lastEntry|
	lastEntry := self entrys last. 
	self entrys do:[:each | (each contains: aDate)
										ifTrue:[(each ~= lastEntry)
													ifTrue:[^true]]].
	^false!

datePeriod
	^self fromDate to: self toDate!

datePeriodClass
	datePeriodClass isNil
		ifTrue: [self datePeriodClass: self defaultDatePeriodClass].
	^datePeriodClass!

datePeriodClass: aClass
	datePeriodClass := aClass.
	self entrys do: [:each | each datePeriodClass: aClass]!

defaultDatePeriodClass
	^self isEmpty
		ifTrue: [DatePeriod]
		ifFalse: [self firstEntry datePeriodClass]!

divideJrnl: aJournal
	^self
		intersectWith: aJournal 
		do: self divisionBlock!

divisionBlock
	^[:each1 :each2 | each1 value: each1 value / each2 value]!

earliestDate
	^self firstDate fromDate!

endOfBreakIndex: anIndex greaterThan: aMinimum
	anIndex = self size ifTrue: [^0].
	(anIndex + 1) to: self size do: [:each |	
		((entrys at: each) value haEqualTo: 0) 
			ifFalse: [^((entrys at: each) fromDate subtractYears: aMinimum) > (entrys at: anIndex) toDate
								ifTrue: [each]
								ifFalse: [0]]]!

entryOn: aDate
	^self
		detect: [:each | each contains: aDate]
		ifNone: [^nil]!

entrysAsAnniversaryYears: aMonthDay
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asAnniversaryYearsStartingOn: aMonthDay]!

entrysAsBiWeeklyFor: aCalendar in: aContext
	^self asMergedContiguous entrysCollectAllAsOrderedCollection:  
		[:each | each asBiWeeklyFor: aCalendar in: aContext]!

entrysAsCalendarMonths
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asCalendarMonths]!

entrysAsCalendarYears
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asCalendarYears]!

entrysAsContiguousAnniversaryYears: aMonthDay
	^self
		resolve: (self entrysAsAnniversaryYears: aMonthDay)
		asContiguousAnniversaryYears: aMonthDay!

entrysAsContiguousCalendarMonths
	^self resolveAsContiguousMonths: self entrysAsCalendarMonths!

entrysAsDatePeriod: aClass
	^self entrys asOrderedCollection
		collect: [:each | each asDatePeriod: aClass]!

entrysAsFullAnnual: aMonthDay
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asFullAnniversaryYearsStartingOn: aMonthDay]!

entrysAsFullCalendarMonths
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asFullCalendarMonths]!

entrysAsFullQuarter: aMonthDay
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asFullQuartersOn: aMonthDay]!

entrysAsQuartersOn: aMonthDay
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asQuartersOn: aMonthDay]!

entrysAsSemiMonthsOn: anInteger
	^self entrysCollectAllAsOrderedCollection:
		[:each | each asSemiMonthsOn: anInteger]!

entrysBetween: startDate toDate: endDate
	^self journalEntrysSelect: 
		[:each |
			(each endsAfterDate: startDate) and: (each startsBeforeDate: endDate)]!

entrysContiguous
	^self
		resolve: self entrysAsCalendarMonths
		samePeriodBlock: [:each :each2 | (each isSameMonth: each2)
														and: [each isMergableContiguousWith: each2]]!

entrysContiguous: aMonthDay
	^self
		resolve: (self entrysAsAnniversaryYears: aMonthDay)
		samePeriodBlock: [:each :each2 | (each isSameAnniversary: each2 
																startingOn: aMonthDay)
														and: [each isMergableContiguousWith: each2]]!

entrysFrom: aDate
|answer|
	answer := OrderedCollection new.
	self journalEntrysDo:
		[:each |
			(each endsAfterDate: aDate)
				ifTrue: [answer add: (each from: aDate)]].
	^answer!

entrysMergeContiguous
	^self
		resolve: self copyEntrys
		samePeriodBlock: [:each :each2 | each isMergableContiguousWith: each2]!

entrysNotFrom: startDate toDate: endDate
	^self journalEntrysSelect: 
		[:each |
			((each startsBeforeDate:startDate) and:[each  endsAfterDate: endDate]) or:[
			((each endsAfterDate: endDate) or: [(each startsBeforeDate: startDate)]) 
				and: ((each endsBeforeDate: endDate) or: [(each startsAfterDate: startDate)])]]!

entrysTo: aDate
|answer|
	answer := OrderedCollection new.
	self journalEntrysDo:
		[:each |
			(each startsBeforeDate: aDate)
				ifTrue: [answer add: (each to: aDate)]].
	^answer!

equalToPeriodJournal: aJournal
	^self size = aJournal size
		and: [(self class = aJournal class)
		and: [self with: aJournal do:
				[:myEntry :anEntry | myEntry = anEntry
					ifFalse: [^false]].
				true]]!

exclusive: aJournal
	"do not overlap"
	^self earliestDate >= aJournal latestDate
		or: [aJournal earliestDate >= self latestDate]!

firstIndexBeginningIn: aPeriod
	((self includesPeriod: aPeriod) not) ifTrue:[^1].
	^self entrys 
		findFirst: [:each | each key intersects: aPeriod]
		!

firstOfOverlappingEntries
^self copyWithoutStorage entrys:(self firstOfOverlappingEntries:(self resolvedOverlapPeriods))!

firstOfOverlappingEntries:aColl	
|aTempColl valColl tempEntry|
valColl := OrderedCollection new.
aColl do:[:each| 
		aTempColl := OrderedCollection new.
		self entrys copy do:[:each2|(each isIntersecting: each2 key) 
			ifTrue:[
				tempEntry := (each2 entryOverUnique:each).
				aTempColl add:(tempEntry value)
				].
			].
			tempEntry value:(aTempColl first).
			valColl add:tempEntry.
		].
	^valColl!

firstThroughDate
	^self firstDate throughDate!

firstToDate
	^self firstDate toDate!

fragmentedEntrys
|answer|
	answer := OrderedCollection new.
	self entrys doWithNext:
		[:each1 :each2 |
			(each1 isContiguousWith: each2)
				ifFalse: [answer add: (each1 fragmentedEntryWith: each2)]].
	^answer!

from: aDate
	^self copyWithEntrys: (self entrysFrom: aDate)
	!

fromDate
	^self firstEntry fromDate!

fromDate: fromDate
toDate: toDate
|result|
	result := fromDate = self fromDate
					ifTrue: [self]
					ifFalse: [self from: fromDate].
	^toDate = result toDate
					ifTrue: [result]
					ifFalse: [result to: toDate]!

fromDateAfter: aDate 
	aDate >= self toDate 
		ifTrue: [^self errorInvalidKey: aDate].
	aDate <= self firstDate fromDate 
		ifTrue: [^self firstDate fromDate].
	self entrys do:  
		[:each |
			(aDate <= each toDate) 
				ifTrue: [^each fromDate]].
	^nil	

!

fromDateAfter: aDate default: defaultDate
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^defaultDate].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self fromDate)].
	self entrys do:[:each| (aDate <= each throughDate)
										ifTrue:[( (aDate >= each fromDate) or:[(self entryOn: aDate) isNil ])
													ifTrue:[^each fromDate]]].	

	
		
!

fromDateBefore: aDate default: defaultDate
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^self lastDate fromDate].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^defaultDate].
	self entrys reverseDo: [:each | (aDate >= each fromDate)
													 ifTrue:[( (aDate <= each throughDate) or:[(self entryOn: aDate) isNil ])
																ifTrue:[^each fromDate]]].
!

hasOverlappingEntriesIn:aColl
	1 to: aColl size - 1 do: [:each | (((aColl at: each) ~= (aColl at: each + 1)) 
		and:[((aColl at: each) isIntersecting: (aColl at: each + 1))])
		ifTrue: [^true]].
		^false!

highestOfOverlappingEntries
^self copyWithoutStorage entrys:(self highestOfOverlappingEntries:(self resolvedOverlapPeriods)).!

highestOfOverlappingEntries:aColl	
|aTempColl valColl tempEntry|
valColl := OrderedCollection new.
aColl do:[:each| 
		aTempColl := OrderedCollection new.
		self entrys copy do:[:each2|(each isIntersecting: each2 key) 
			ifTrue:[
				tempEntry := (each2 entryOverUnique:each).
				aTempColl add:(tempEntry value)
				].
			].
			tempEntry value:(aTempColl asSortedCollection last).
			valColl add:tempEntry.
		].
	^valColl!

hourService: anInteger anniversary: aMonthDay
	^(self asFullAnnual: aMonthDay) entrys
		inject: 0
		into: [:inj :each | each value >= anInteger
									ifTrue: [inj + 1]
									ifFalse: [inj]]!

hourService: anInteger
minimum: minInteger
multiple: aFloat
rounding: aSymbol
	^entrys
		inject: 0
		into: [:inj :each | inj + (each
										hourService: anInteger
										minimum: minInteger
										multiple: aFloat
										rounding: aSymbol)]!

ifFragmented: aBoolean
	self isEmpty 
		ifTrue: [^false].
	(self size = 1)
		ifTrue: [^aBoolean not].
	self entrys doWithNext:
		[:each1 :each2 |
			(each1 isContiguousWith: each2)
				ifFalse: [^aBoolean]].
	^aBoolean not!

includesDate: aDate
	^(self entryOn: aDate) notNil!

includesFrom: fromDate to: toDate
	^(self entryOn: fromDate) notNil and: [(self entryOn: (toDate subtractDays: 1)) notNil]!

includesPeriod: aPeriod
| entry |
	(entry := self entryOn: aPeriod fromDate) isNil
		ifTrue: [^false].
	^entry toDate >= aPeriod toDate
		ifTrue: [true]
		ifFalse: [self includesPeriod: (self datePeriodClass from: entry toDate to: aPeriod toDate)]!

incompleteMonths
	^self contiguousPeriods
		inject: OrderedCollection new
		into: [:inj :each | inj addAll: each incompleteMonths. inj]
!

incompleteYears
	^self contiguousPeriods
		inject: OrderedCollection new
		into: [:inj :each | inj addAll: each incompleteYears. inj]
!

incompleteYears: aMonthDay
	^self contiguousPeriods
		inject: OrderedCollection new
		into: [:inj :each | inj addAll: (each incompleteYears: aMonthDay). inj]
!

indexBeginningIn: aPeriod
	^self entrys 
		binaryIndexSearchFind: [:value | value contains: aPeriod fromDate]
		stepBefore: [:value | value key isBefore: aPeriod]!

indexEndingIn: aPeriod
	^self entrys 
		binaryIndexSearchFind: [:value | value contains: aPeriod toDate]
		stepBefore: [:value | value key endsEarlier: aPeriod]!

intersect: aPeriodJournal
	(self isIntersecting: aPeriodJournal) ifFalse: [^self emptyCopy].
	^self copyWithEntrys: (self intersectEntrys: aPeriodJournal)
	!

intersectEntrys: aPeriodJournal
|answer|
	answer := OrderedCollection new.
	aPeriodJournal journalEntrysDo:
		[:each1 |
			self system yield.
			self journalEntrysDo:
				[:each2 |
					(each1 isIntersecting: each2)
						ifTrue: [answer add: (each2 intersect: each1)]]].
	^answer!

intersectFrom: startDate to: stopDate
	^self intersect: (self emptyCopy
							addValue: '' at: (self datePeriodClass from: startDate to: stopDate);
							yourself)
!

intersects: aJournal
	^self isIntersecting: aJournal!

intersectWith: aJournal
do: aBlock
	^(self intersect: aJournal)
		with: (aJournal intersect: self)
		do: aBlock!

isBefore: aPeriodJournal
	^self datePeriod isBefore: aPeriodJournal datePeriod!

isContiguous
	^self ifFragmented: false !

isContiguousFrom: fromDate to: toDate
	| journal |
	journal := self intersectFrom: fromDate to: toDate.
	(journal includesFrom: fromDate to: toDate)
		ifFalse: [^false].
	^journal isContiguous

!

isFragmented
	^self ifFragmented: true!

isIntersecting: aJournal
	^(self isEmpty or: [aJournal isEmpty])
		ifTrue: [false]
		ifFalse: [(self exclusive: aJournal) not]!

isIntersectingWithEntry: anEntry
	self entrys do: [:each | (each isIntersecting: anEntry) ifTrue: [^true]].
	^false!

isNotIntersecting: aJournal
	^(self isIntersecting: aJournal) not!

isNotIntersectingWithEntry: anEntry
	^(self isIntersectingWithEntry: anEntry) not!

isPeriodBased
	^true!

isPeriodJournal
	^true!

isTypeConsistentWith: anObject
	^anObject isPeriodJournal!

isValidKey: anObject
	^anObject isDatePeriod!

jrnlResolveOverlapsForFunc: func
	^self resolveOverlaps: (func class funcPolicyForOverlaps at:(self class name asString))!

lastEntry: aValue before: aDate
| match |
	self journalEntrysDo:
		 [:each | each value = aValue
						ifTrue: [each key fromDate >= aDate ifTrue: [^match].
									match := each]].
	^match!

lastIndexEndingIn: aPeriod
	^self entrys 
		findLast: [:each | each key intersects: aPeriod]
		!

lastOfOverlappingEntries
^self copyWithoutStorage entrys:(self lastOfOverlappingEntries:(self resolvedOverlapPeriods))!

lastOfOverlappingEntries:aColl	
|aTempColl valColl tempEntry|
valColl := OrderedCollection new.
aColl do:[:each| 
		aTempColl := OrderedCollection new.
		self entrys copy do:[:each2|(each isIntersecting: each2 key) 
			ifTrue:[
				tempEntry := (each2 entryOverUnique:each).
				aTempColl add:(tempEntry value)
				].
			].
			tempEntry value:(aTempColl last).
			valColl add:tempEntry.
		].
	^valColl!

latestDate
	^self lastDate toDate!

latestFromDate
	^self lastDate fromDate!

longestUsedValue
	^JournalLongestVisitor visit: self!

lowestOfOverlappingEntries
^self copyWithoutStorage entrys:(self lowestOfOverlappingEntries:(self resolvedOverlapPeriods)).!

lowestOfOverlappingEntries:aColl
|aTempColl valColl tempEntry|
valColl := OrderedCollection new.
aColl do:[:each| 
		aTempColl := SortedCollection new.
		self entrys copy do:[:each2|(each isIntersecting: each2 key) 
			ifTrue:[
				tempEntry := (each2 entryOverUnique:each).
				aTempColl add:(tempEntry value)
				].
			].
			tempEntry value:(aTempColl first).
			valColl add:tempEntry.
		].
	^valColl!

maxBlock
	^[:each1 :each2 | each1 value: (each1 value > each2 value
		ifTrue:[each1 value]	
		ifFalse:[each2 value])]!

mergeOfOverlappingEntries:aColl	
|aTempColl valColl tempEntry|
valColl := OrderedCollection new.
aColl do:[:each| 
		aTempColl := OrderedCollection new.
		self entrys do:[:each2|(each isIntersecting: each2 key) 
			ifTrue:[
				tempEntry := (each2 entryOverUnique:each).
				aTempColl add:(tempEntry value)
				].
			].
			aTempColl := aTempColl copy abrAsUniqueCollection.
			tempEntry value:(aTempColl inject:0 into: [:a :b|a + b]).
			valColl add:tempEntry.
		].
	^valColl!

mergeOverlappingEntries
^self copyWithoutStorage entrys:(self mergeOfOverlappingEntries:(self resolvedOverlapPeriods)).!

minBlock
	^[:each1 :each2 | each1 value: (each1 value < each2 value
		ifTrue:[each1 value]
		ifFalse:[each2 value])]!

minJrnl: aJournal
	^self
		intersectWith: aJournal 
		do: self multiplicationBlock!

missingPeriodEntrys
| answer|
	answer := OrderedCollection new.  
	1 to: self size - 1 do: [:each | 
		((self entrys at: each) toDate < (self entrys at: each + 1) fromDate)
			ifTrue:[answer add: ((self entrys at: each) missingPeriod:  (self entrys at: each + 1))]].
	^answer !

missingPeriodEntrysWith: aCollection
|answer| 
	answer := OrderedCollection new. 
	aCollection do:
		[:each1 |
			(self isNotIntersectingWithEntry: each1)
				ifTrue: [answer add: each1]].
	^answer!

missingPeriodsFrom: startDate to: endDate
| entries |
	self isContiguous 
		ifTrue: [^OrderedCollection new].
	^(self copyWithEntrys: 
		(self entrysBetween: startDate 
		toDate: endDate)) missingPeriodEntrys


!

multiplicationBlock
	^[:each1 :each2 | each1 value: each1 value * each2 value]!

multiplyJrnl: aJournal
	^self
		intersectWith: aJournal 
		do: self multiplicationBlock!

nonIntersect: aPeriodJournal
	(aPeriodJournal isEmpty or: [self isNotIntersecting: aPeriodJournal])
		 ifTrue: [^self copy].
	^self copyWithEntrys: (self nonIntersectEntrys: aPeriodJournal)
	!

nonIntersectEntrys: aPeriodJournal
	| answer | 
	answer := OrderedCollection new.
	self journalEntrysDo: 
		[:each1 | 
			self system yield.
			(aPeriodJournal isNotIntersectingWithEntry: each1)
				ifTrue: [answer add: each1]
				ifFalse: [aPeriodJournal journalEntrysDo:	[:each2 | 
								(each1 isIntersecting: each2)
									ifTrue: [self system yield.
												answer addAll: (aPeriodJournal nonIntersectEntrysWith: (each1 nonIntersect: each2))]]]].
		^(aPeriodJournal nonIntersectEntrysWith: (answer abrAsUniqueCollection)) abrAsUniqueCollection!

nonIntersectEntrysNew: aMaskingJournal
|result jrnl entries continue intrimResult|
result := OrderedCollection new.
entries := OrderedCollection new.
self journalEntrysDo:
[:periodEntry | 																	
	jrnl := self emptyCopy.
	jrnl isNamed:true.
	jrnl at:periodEntry key put: periodEntry value.   
	jrnl entrys do:[ :each |  (periodEntry prorationPolicy) isNil
											ifFalse:[each prorationPolicy: periodEntry prorationPolicy]].
	continue := true.
	intrimResult := OrderedCollection new.
	"entry is before/after masking jrnl first/last entry, don't go in - put in result"
	((periodEntry throughDate < aMaskingJournal entrys first fromDate) or:[(periodEntry fromDate > aMaskingJournal entrys last throughDate)])
	ifTrue:[result add:periodEntry]
	ifFalse:[
	    aMaskingJournal entrys do:[:maskingEntry | 
	        continue ifTrue:[
	            entries := (jrnl periodsNotBetween: maskingEntry fromDate and: maskingEntry toDate) entrys.
		        (entries size = 0) ifTrue:[intrimResult := OrderedCollection new. continue := false]
		        ifFalse:[(entries size = 2) 
			        ifTrue:[intrimResult add:entries removeFirst]
			        ifFalse:[ (entries first throughDate <= maskingEntry throughDate) 
					    ifTrue:[intrimResult add:entries removeFirst. continue := false]
			        ]. 
			        (entries size = 1) 
			        ifTrue:[ jrnl := self emptyCopy.jrnl isNamed:true. jrnl at:entries first key put: entries first value.]
		        ]
	        ]
	    ].
	    intrimResult do:[:each | result add:each].
	    ((entries size = 1) and:[continue]) ifTrue:[result add:entries removeFirst].
	]
].							
^result!

nonIntersectEntrysNew: aMaskingJournal prorationPolicy: aPolicy
|result jrnl entries continue intrimResult|
result := OrderedCollection new.
entries := OrderedCollection new.
self journalEntrysDo:
[:periodEntry | 																	
	jrnl := self emptyCopy.
	jrnl isNamed:true.
	jrnl at:periodEntry key put: periodEntry value.   
	jrnl entrys do:[ :each |  (periodEntry prorationPolicy) isNil
											ifFalse:[each prorationPolicy: periodEntry prorationPolicy]].
	continue := true.
	intrimResult := OrderedCollection new.
	"entry is before/after masking jrnl first/last entry, don't go in - put in result"
	((periodEntry throughDate < aMaskingJournal entrys first fromDate) or:[(periodEntry fromDate > aMaskingJournal entrys last throughDate)])
	ifTrue:[result add:periodEntry]
	ifFalse:[
	    aMaskingJournal entrys do:[:maskingEntry | 
	        continue ifTrue:[
	            entries := (jrnl periodsNotBetween: maskingEntry fromDate and: maskingEntry toDate prorationPolicy: aPolicy) entrys.
		        (entries size = 0) ifTrue:[intrimResult := OrderedCollection new. continue := false]
		        ifFalse:[(entries size = 2) 
			        ifTrue:[intrimResult add:entries removeFirst]
			        ifFalse:[ (entries first throughDate <= maskingEntry throughDate) 
					    ifTrue:[intrimResult add:entries removeFirst. continue := false]
			        ]. 
			        (entries size = 1) 
			        ifTrue:[ jrnl := self emptyCopy.jrnl isNamed:true. jrnl at:entries first key put: entries first value.]
		        ]
	        ]
	    ].
	    intrimResult do:[:each | result add:each].
	    ((entries size = 1) and:[continue]) ifTrue:[result add:entries removeFirst].
	]
].							
^result!

nonIntersectEntrysWith: aCollection
|answer| 
	answer := OrderedCollection new. 
	aCollection do:
		[:each1 | self system yield.
			(self isNotIntersectingWithEntry: each1)
				ifTrue: [answer add: each1]
				ifFalse: [self journalEntrysDo: [:each2 |
								(each1 isIntersecting: each2)
									ifTrue: [answer addAll: (each1 nonIntersect: each2)]]]].
	^answer!

nonIntersectEntrysWithNew: aCollection
|answer| 
	answer := OrderedCollection new. 
	aCollection do:
		[:each1 | self system yield.
			(self isNotIntersectingWithEntry: each1)
				ifTrue: [answer add: each1]
				ifFalse: [self journalEntrysDo: [:each2 |
								(each1 isIntersecting: each2)
									ifTrue: [answer addAll: (each1 nonIntersect: each2)]]]].
	^answer!

nonIntersectNew: aPeriodJournal
	(aPeriodJournal isEmpty or: [self isNotIntersecting: aPeriodJournal])
		 ifTrue: [^self copy].
	^self copyWithEntrys: (self nonIntersectEntrysNew: aPeriodJournal)
	!

nonIntersectNew: aPeriodJournal prorationPolicy: aPolicy
	(aPeriodJournal isEmpty or: [self isNotIntersecting: aPeriodJournal])
		 ifTrue: [^self copy].
	^self copyWithEntrys: (self nonIntersectEntrysNew: aPeriodJournal prorationPolicy: aPolicy)
	!

nonIntersects: aPeriodJournal
	(aPeriodJournal isEmpty or: [self isNotIntersecting: aPeriodJournal])
		 ifTrue: [^self copy].
	^self copyWithEntrys: (self nonIntersectEntrys: aPeriodJournal)
	!

occurrencesOf: aValue from: startDate to: stopDate
	^(self entrys asOrderedCollection select:
		[:each |
			each value = aValue
			and: [each intersectsPeriod: (self datePeriodClass from: startDate to: stopDate)]]) size!

periodsBetween: fromDate and: toDate
| aDatePeriod temp results |
	aDatePeriod := ((DatePeriod new) setFrom: fromDate to: nil isToDate: true). 
	temp := ((DatePeriod new) setFrom: nil to: toDate isToDate: true). 
	results := self copyNamedWithoutStorage.
	^results copyWithEntrys:
		((results copyWithoutStorage entrysBetween: fromDate toDate: toDate)
			do:[: each | 
				each fromDate < fromDate 
					ifTrue:[each value: (each valueOver: (aDatePeriod toDate: each toDate)). each fromDate: fromDate].
				each toDate > toDate
					ifTrue:[each value: (each valueOver: (temp fromDate: each fromDate)). each toDate: toDate]])!

periodsNotBetween: fromDate and: toDate
| aDatePeriod temp results e2 selEntrys|
	aDatePeriod := ((DatePeriod new) setFrom: nil to: fromDate isToDate: true). 
	temp := ((DatePeriod new) setFrom: toDate to: nil isToDate: true).
	results := self copyNamedWithoutStorage.
	selEntrys:=(results entrysNotFrom: fromDate toDate: toDate).
		selEntrys copy do:[: each | 
		e2 := each deepCopy.
			(each fromDate < fromDate and:[each  toDate > toDate])
				ifTrue:[each value:(each valueOver:(aDatePeriod fromDate:(each fromDate)) ). 
					each toDate: fromDate.
					e2 value:(e2 valueOver:(temp toDate: (e2 toDate))).
					e2 fromDate: toDate.
					selEntrys add:e2].
			(each fromDate >= fromDate and: [each fromDate < toDate])
				ifTrue:[each value: (each valueOver: (temp toDate: each toDate)). 
					each fromDate: toDate].
			(each toDate <= toDate and: [each toDate > fromDate])
				ifTrue:[each value: (each valueOver: (aDatePeriod fromDate: each fromDate)). 
					each toDate: fromDate]].
	^results copyWithEntrys: selEntrys
!

periodsNotBetween: fromDate and: toDate prorationPolicy: aPolicy
| aDatePeriod temp results e2 selEntrys|
	aDatePeriod := ((DatePeriod new) setFrom: nil to: fromDate isToDate: true). 
	temp := ((DatePeriod new) setFrom: toDate to: nil isToDate: true).
	results := self copyNamedWithoutStorage.
	selEntrys:=(results entrysNotFrom: fromDate toDate: toDate).
		selEntrys copy do:[: each | 
		e2 := each deepCopy.
			(each fromDate < fromDate and:[each  toDate > toDate])
				ifTrue:[each value: (each valueOver: (aDatePeriod fromDate:(each fromDate)) prorationPolicy: aPolicy). 
					each toDate: fromDate.
					e2 value: (e2 valueOver: (temp toDate: (e2 toDate)) prorationPolicy: aPolicy).
					e2 fromDate: toDate.
					selEntrys add:e2].
			(each fromDate >= fromDate and: [each fromDate < toDate])
				ifTrue:[each value: (each valueOver: (temp toDate: each toDate) prorationPolicy: aPolicy). 
					each fromDate: toDate].
			(each toDate <= toDate and: [each toDate > fromDate])
				ifTrue:[each value: (each valueOver: (aDatePeriod fromDate: each fromDate) prorationPolicy: aPolicy). 
					each toDate: fromDate]].
	^results copyWithEntrys: selEntrys
!

remove: aCollection ifFullAnniversary: aMonthDay
	^aCollection reject:
			[:each | each isFullAnniversary: aMonthDay]  !

remove: aCollection ifNotFullAnniversary: aMonthDay
	^aCollection select:
			[:each | each isFullAnniversary: aMonthDay] !

removeIfFullMonth: aCollection
	^aCollection reject: [:each | each isFullMonth] !

removeIfNotFullMonth: aCollection
	^aCollection select: [:each | each isFullMonth]!

replace: anObject
from: fromDate
to: toDate
	| key jrnl |
	(key := self datePeriodClass from: fromDate to: toDate) isEmpty ifTrue: [^self].
	jrnl := self copyNamedWithoutStorage.
	^ self emptyCopy  
		addValue: anObject at: key;
		addAll: (jrnl entrysTo: fromDate);
		addAll: (jrnl entrysFrom: toDate);
		yourself!

replaceAlignedValueBlock

	^[:each1 :each2 | each1 value: ((each1 fromDate = each2 fromDate and: each1 throughDate = each2 throughDate)
		ifTrue:[each2 value]	
		ifFalse:[each1 value])]!

replaceAlignedValueJrnl: aJournal 
	^self copyNamedWithoutStorage
		withJournal: aJournal 
		do: self replaceAlignedValueBlock!

replaceValue: anObject from: startDate to: stopDate
	|anIntersectJournal|
	anIntersectJournal := self intersectFrom: startDate to: stopDate.
	^(anIntersectJournal collect: [:each | each copyValue: anObject])
		addAll: (self entrysTo: startDate);
		addAll: (self entrysFrom: stopDate);
		yourself!

resolve: aCollection asAnniversaryYears: aMonthDay
	^self
		resolve: aCollection asSortedCollection
		samePeriodBlock:	[:each :each2 | each 
									isSameAnniversary: each2 
									startingOn: aMonthDay]!

resolve: aCollection asAnniversaryYearsNew: aMonthDay
	^self
		resolve: aCollection "asSortedCollection"
		samePeriodBlock:	[:each :each2 | each 
									isSameAnniversary: each2 
									startingOn: aMonthDay]!

resolve: aCollection asContiguousAnniversaryYears: aMonthDay
	^self
		resolve: aCollection asSortedCollection
		samePeriodBlock: [:each :each2 | each 
												isSameContiguousAnniversary: each2 
												startingOn: aMonthDay]!

resolve: aCollection asQuarters: aMonthDay
	^self
		resolve: ( PeriodJournal sortByKeyOnly: aCollection )
		samePeriodBlock:	[:each :each2 | each 
									isSameQuarter: each2 
									on: aMonthDay]!

resolve: aCollection asQuartersNew: aMonthDay
	^self
		resolve: ( PeriodJournal sortByKeyOnly: aCollection )
		samePeriodBlock:	[:each :each2 | each 
									isSameQuarter: each2 
									on: aMonthDay]!

resolve: aCollection samePeriodBlock: aBlock
| result | 
	aCollection isEmpty ifTrue: [^aCollection].
	result := OrderedCollection new: aCollection size.
	result add: aCollection removeFirst.
	[aCollection isEmpty]
		whileFalse:
		[(aBlock value: aCollection first value: result last)
			ifTrue: [self combineNextFrom: aCollection to: result]
			ifFalse: [result add: aCollection removeFirst]].
	^result!

resolveAsContiguousMonths: aCollection
	^self
		resolve: aCollection asSortedCollection
		samePeriodBlock: [:each :each2 | each isSameContiguousMonth: each2]!

resolveAsMonths: aCollection 
	^self
		resolve: aCollection "asSortedCollection"
		samePeriodBlock: [:each :each2 | each isSameMonthAndYear: each2]!

resolveConsistentOverlaps
| count | 
	count := 1.
	[count + 1 > self size]
		whileFalse: [count := count + (self resolvedConsistentOverlapsAt: count)]!

resolvedConsistentOverlapsAt: anInteger
	|entryCollection|         
 	entryCollection := (self journalEntryAtIndex: anInteger) uniqueConsistentEntrysWith: (self journalEntryAtIndex: anInteger + 1).
	1 to: 2 do: [:each | self entrys removeAtIndex: anInteger].
	self entrys addAll: entryCollection.
	^entryCollection size - 1!

resolvedOverlapPeriods
| count aColl aTempColl |
aColl := self keys asSortedCollection.
[self hasOverlappingEntriesIn:aColl] whileTrue:[
	count := 1.
	[count + 1 > aColl size]
	whileFalse:[ 
	    ((aColl at: count) isIntersecting:(aColl at: (count + 1))) 
	    ifTrue:[
 		    aTempColl:= ((aColl at: count) uniquePeriodsWith: (aColl at: (count + 1))) asOrderedCollection .
		    1 to: 2 do: [:each | aColl removeAtIndex: count].
		    aColl addAll: aTempColl.
		    count := count + (aTempColl size - 1)]
	    ifFalse:[count := count + 1]
	]	
].
^aColl asSet asSortedCollection!

resolvedOverlapsAt: anInteger
	|entryCollection|        
 	entryCollection := (self journalEntryAtIndex: anInteger) uniqueEntrysWith: (self journalEntryAtIndex: anInteger + 1).
	1 to: 2 do: [:each | self entrys removeAtIndex: anInteger].
	self entrys addAll: entryCollection.
	^entryCollection size - 1!

resolveOverlaps
| count |
	count := 1.
	[count + 1 > self size]
		whileFalse: [count := count + (self resolvedOverlapsAt: count)]!

resolveOverlapsWith:aString
self entrys:(self resolveDuplicates:aString)entrys.
(self hasOverlappingEntries) ifFalse:[^self].
	('ADD' = aString) ifTrue:[^(self addOverlappingEntries)].
	('MERGE' = aString) ifTrue:[^(self mergeOverlappingEntries)].
	('HIGHEST' = aString) ifTrue:[^(self highestOfOverlappingEntries)].
	('LOWEST' = aString) ifTrue:[^(self lowestOfOverlappingEntries)].
	('FIRST' = aString) ifTrue:[^(self firstOfOverlappingEntries)].
	('LAST' = aString) ifTrue:[^(self lastOfOverlappingEntries)].
	('COMBINE_EDIT' = aString) ifTrue:[^(self combineEditOverlappingEntries)].
	('SINGLE_ENTRY' = aString) ifTrue:[^(self singleEntryOverlappingEntries)].

!

roundingFromDatePerform: aSelector ifValues: aCollection
	^aCollection isEmpty
		ifTrue: [self copyCollect:
		 			[:each | each roundFromDatePerform: aSelector]]
		ifFalse: [self copyCollect:
		 			[:each | each
						roundFromDatePerform: aSelector
						ifValues: aCollection]]!

roundingFromDatePerform: aSelector startingOn: aMonthDay ifValues: aCollection
	^aCollection isEmpty
		ifTrue: [self copyCollect:
		 			[:each | each
							roundFromDatePerform: aSelector
							with: aMonthDay]]
		ifFalse: [self copyCollect:
		 			[:each | each
						roundFromDatePerform: aSelector
						with: aMonthDay
						ifValues: aCollection]]!

roundingThroughDatePerform: aSelector ifValues: aCollection
	^aCollection isEmpty
		ifTrue: [self copyCollect:
		 			[:each | each roundThroughDatePerform: aSelector]]
		ifFalse: [self copyCollect:
		 			[:each | each
						roundThroughDatePerform: aSelector
						ifValues: aCollection]]!

roundingThroughDatePerform: aSelector startingOn: aMonthDay ifValues: aCollection
	^aCollection isEmpty
		ifTrue: [self copyCollect:
		 			[:each | each
							roundThroughDatePerform: aSelector
							with: aMonthDay]]
		ifFalse: [self copyCollect:
		 			[:each | each
						roundThroughDatePerform: aSelector
						with: aMonthDay
						ifValues: aCollection]]!

roundingToDatePerform: aSelector ifValues: aCollection
	^aCollection isEmpty
		ifTrue: [self copyCollect:
		 			[:each | each roundToDatePerform: aSelector]]
		ifFalse: [self copyCollect:
		 			[:each | each
						roundToDatePerform: aSelector
						ifValues: aCollection]]!

roundingToDatePerform: aSelector startingOn: aMonthDay ifValues: aCollection
	^aCollection isEmpty
		ifTrue: [self copyCollect:
		 			[:each | each
							roundToDatePerform: aSelector
							with: aMonthDay]]
		ifFalse: [self copyCollect:
		 			[:each | each
						roundToDatePerform: aSelector
						with: aMonthDay
						ifValues: aCollection]]!

serviceRounded: aRoundingRule
| result|
	result := AmountPeriodJournal newWithoutStorage.
	result entrys: (self entrysCollect:
							[:each | each serviceRounded: aRoundingRule]).
	^result!

shouldEditFor:aString
^false!

singleEntryOverlappingEntries
^(self copyWithEntrys: (self resolve: self copyEntrys
		samePeriodBlock: [:current :next | (current isIntersecting: next)]))!

stepBackPeriods
	^self stepBackPeriodsForThreshold: 0!

stepBackPeriodsForThreshold: exactYears
	^(self contiguousPeriodsForThreshold: exactYears) 
		inject: OrderedCollection new
		into: [:inj :each | inj addAll: each asYearsSteppingBackFromEnd. 
								inj]!

through: aDate
	^self to: (aDate addDays: 1)
	!

throughDate
	^self lastEntry throughDate
!

throughDateAfter: aDate 
	aDate > self throughDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self entrys do: 
		[:each |
			(aDate < each throughDate) 
				ifTrue: [^each throughDate]]!

throughDateAfter: aDate default: defaultDate
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^defaultDate].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self firstThroughDate)].
	self entrys do:[:each| (aDate <= each throughDate)
										ifTrue:[( (aDate >= each fromDate) or:[(self entryOn: aDate) isNil ])
													ifTrue:[^each throughDate]]].
!

throughDateBefore: aDate 
	self isEmpty
		ifTrue: [^self errorInvalidKey: aDate].
	aDate >= self throughDate 
		ifTrue: [^self throughDate].	
	aDate < self fromDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self reverseDo:  
		[:each |
			(aDate >= each fromDate) 
				ifTrue: [^each throughDate]]!

throughDateBefore: aDate default: defaultDate
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^self lastDate throughDate].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^defaultDate].
	self entrys reverseDo: [:each | (aDate >= each fromDate)
													 ifTrue:[( (aDate <= each throughDate) or:[(self entryOn: aDate) isNil ])
																ifTrue:[^each throughDate]]].

!

to: aDate
	^self copyWithEntrys: (self entrysTo: aDate)
	!

toDate
	^self lastEntry toDate!

toDateAfter: aDate 
	aDate > self toDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self entrys do: 
		[:each |
			(aDate < each toDate) 
				ifTrue: [^each toDate]]!

toDateAfter: aDate default: defaultDate
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^defaultDate].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self firstToDate)].
	self entrys do:[:each| (aDate <= each throughDate)
										ifTrue:[( (aDate >= each fromDate) or:[(self entryOn: aDate) isNil ])
													ifTrue:[^each toDate]]].

!

toDateBefore: aDate 
	self isEmpty
		ifTrue: [^self errorInvalidKey: aDate].
	aDate >= self toDate 
		ifTrue: [^self toDate].	
	aDate < self fromDate 
		ifTrue: [^self errorInvalidKey: aDate].
	self reverseDo: [:each |
		(aDate >= each fromDate) 
			ifTrue: [^each toDate]]!

toDateBefore: aDate default: defaultDate
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^self lastDate toDate].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^defaultDate].
	self entrys reverseDo: [:each | (aDate >= each fromDate)
													 ifTrue:[( (aDate <= each throughDate) or:[(self entryOn: aDate) isNil ])
																ifTrue:[^each toDate]]].!

translate: aTable from: startDate to: stopDate
	|anIntersectJournal|
	anIntersectJournal := self intersectFrom: startDate to: stopDate.
	^(anIntersectJournal translate: aTable)
		addAll: (self entrysTo: startDate);
		addAll: (self entrysFrom: stopDate);
		yourself!

uniqueContiguousPeriods
	^self uniqueContiguousPeriodsForThreshold: 0!

uniqueContiguousPeriodsForThreshold: anInteger
|periods result |
	result := OrderedCollection new.
	(periods := self entrys asArray) isEmpty ifTrue: [^result].
	result add: entrys first.
	2 to: entrys size do:
		[:each | ((result last key isContiguousWith: (periods at: each) key forThreshold: anInteger) and: 
						[result last value = (periods at: each) value])
							ifTrue: [result add: (result removeLast copy combine: (periods at: each))]
							ifFalse: [result add: (periods at: each)]].
	^result collect: [:each | each key]!

validEntry: aValue at: dateKey
	^((self entrys)
			select: [:each |
						each key isIntersecting: dateKey]) isEmpty

!

valueAfter: aDate 
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^self errorInvalidKey: aDate].
	(aDate <= (self firstDate fromDate)) 
						ifTrue: [^(self firstValue)].
	self  
	inject: aDate
	into: [:inj :each |
				(aDate <= (each throughDate) or: [ aDate <= (each toDate)]) 
						ifTrue: [^(each value)]].
	^nil	

!

valueAfter: aDate default: defaultVal
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^defaultVal].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^(self firstValue)].
	self entrys do:[:each| (aDate <= each throughDate)
										ifTrue:[( (aDate >= each fromDate) or:[(self entryOn: aDate) isNil ])
													ifTrue:[^each value]]].

!

valueAtFromDate: aDate ifAbsent: aBlock
		^(self asDateJournalSelector: #fromDate) at: aDate ifAbsent: aBlock
!

valueAtToDate: aDate ifAbsent: aBlock
		^(self asDateJournalSelector: #toDate) at: aDate ifAbsent: aBlock
!

valueBefore: aDate 
	self isEmpty
		ifTrue: [^self errorInvalidKey: aDate].
	(aDate >= self toDate) 
		ifTrue: [^self lastValue].
	(aDate < self fromDate) 
		ifTrue: [^self errorInvalidKey: aDate].
	self reverseDo: [:each |
		aDate >= each fromDate 
			ifTrue: [^each value]]!

valueBefore: aDate default: defaultVal
	(aDate >= (self lastDate toDate)) 
						ifTrue: [^self lastValue].
	(aDate < (self firstDate fromDate)) 
						ifTrue: [^defaultVal].
	self entrys reverseDo: [:each | (aDate >= each fromDate)
													 ifTrue:[( (aDate <= each throughDate) or:[(self entryOn: aDate) isNil ])
																ifTrue:[^each value]]].
!

valueFrom: fromDate to: toDate
	^self valueOver: (self datePeriodClass from: fromDate to: toDate)!

valueOver: aPeriod
|sum|
	sum := 0.
	self isEmpty
		ifTrue: [^sum].
	(self indexBeginningIn: aPeriod)
		to: (self indexEndingIn: aPeriod)
		do: [:each | sum := sum + ((self journalEntryAtIndex: each) valueOver: aPeriod)].
	^sum!

valueOverAll: aPeriod
|sum |
	sum := 0.	
	self isEmpty 
		ifTrue: [^sum].
	(self firstIndexBeginningIn: aPeriod)
		to: (self lastIndexEndingIn: aPeriod)
		do: [:each | sum := sum + ((self journalEntryAtIndex: each) valueOver: aPeriod)].
	^sum! !

PeriodJournal initializeAfterLoad!