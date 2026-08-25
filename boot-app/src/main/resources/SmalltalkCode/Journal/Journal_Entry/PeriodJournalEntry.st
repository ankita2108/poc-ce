
JournalEntry subclass: #PeriodJournalEntry
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!PeriodJournalEntry class publicMethods !

configurationClass
	^#PeriodJournalEntry!

empty
	^self new emptyPeriod! !

!PeriodJournalEntry publicMethods !

< aJournalEntry
	^aJournalEntry isGreaterThanPeriodEntry: self!

<= aJournalEntry
	^aJournalEntry isGreaterThanOrEqualPeriodEntry: self!

= aJournalEntry
	^aJournalEntry isEqualPeriodEntry: self!

> aJournalEntry
	^aJournalEntry < self!

>= aJournalEntry
	^aJournalEntry <= self!

abtXmlPrintOn: aStream
	aStream nextPutAll: '<PeriodJournalEntry><entryValue>'; 
	    nextPutAll:(self value) asString;nextPutAll: 'entryValue' abtAsXmlEndTag.
	aStream nextPutAll: (self key abtXmlPrintString).
	aStream nextPutAll: 'PeriodJournalEntry' abtAsXmlEndTag.!

addConsistent: aNumber
	self + aNumber!

addDateEntry: aDateJournalEntry
	^self unsupportedRequest!

addEntry: aJournalEntry
	^aJournalEntry addPeriodEntry: self!

addPeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry "clone" + (self valueOver: aPeriodJournalEntry key)!

allocateOver: aCollection  
	^self defaultAllocationPolicy
		ensureEntries: (self asEntrys: aCollection)
		equal: value!

allocateOverCommon: aCollection  
	^(self commonEntries: aCollection) asSortedCollection 
		addAll: (self uniqueEntries: aCollection); 
		yourself 
	!

asAnniversaryYears 
	^self asAnniversaryYearsStartingOn: (MonthDay month:1 day: 1)!

asAnniversaryYearsStartingOn: aMonthDay 
	^self allocateOver: (self key asAnniversaryYearsStartingOn: aMonthDay)!

asAttaStringEntry
	"return Journal Entry in format fromDate*throughDate*value"

	| valueString |

	valueString := self value asString.
	valueString isEmptyString ifTrue: [valueString := 'empty'].

	^(self fromDate asString, '*', self throughDate asString, '*' , valueString)
!

asBiWeeklyFor: aCalendar in: aContext  
	^self asEntrys: (self key asBiWeeklyFor: aCalendar in: aContext)!

asCalendarMonths 
	^self allocateOver: self key asCalendarMonths!

asCalendarMonthsFrom: startDate to: stopDate 
	^self allocateOver: (self datePeriodClass from: startDate to: stopDate) asCalendarMonths!

asCalendarYears 
	^self asAnniversaryYearsStartingOn: (MonthDay calendarStart)!

asCalendarYearsFrom: startDate to: stopDate 
	^self allocateOver: (self datePeriodClass from: startDate to: stopDate) asCalendarYears!

asDatePeriod: aClass
	^self class
		key: (aClass from: self fromDate to: self toDate)
		value: self value!

asFullAnniversary
	self asFullAnniversaryYearsStartingOn: (MonthDay month:1 day: 1)!

asFullAnniversaryStartingOn: aMonthDay
	self key: (key asFullAnniversaryStartingOn: aMonthDay)!

asFullAnniversaryYears
	^self asFullAnniversaryYearsStartingOn: (MonthDay month:1 day: 1)!

asFullAnniversaryYearsStartingOn: aMonthDay
|result|
	result := self asAnniversaryYearsStartingOn: aMonthDay.
	result isEmpty ifTrue: [^result].
	result first asFullAnniversaryStartingOn: aMonthDay.
	result last asFullAnniversaryStartingOn: aMonthDay.
	^result!

asFullCalendarMonths
|result|
	result := self asCalendarMonths.
	result isEmpty ifTrue: [^result].
	result first asFullMonth.
	result last asFullMonth.
	^result!

asFullCalendarYears
	^self asFullAnniversaryYearsStartingOn: (MonthDay month:1 day: 1)!

asFullMonth
	self key: key asFullMonth!

asFullQuarterOn: aMonthDay
	self key: (key asFullQuarterOn: aMonthDay)!

asFullQuartersOn: aMonthDay
|result|
	result := self asQuartersOn: aMonthDay.
	result isEmpty ifTrue: [^result].
	result first asFullQuarterOn: aMonthDay.
	result last asFullQuarterOn: aMonthDay.
	^result!

asFullYear
	self asFullAnniversaryStartingOn: (MonthDay calendarStart)!

asQuartersOn: aMonthDay 
	^self allocateOver: (self key asQuartersOn: aMonthDay)!

asSemiMonthsOn: anInteger 
	^self semiMonthlyAllocationOver: (self key asSemiMonthsOn: anInteger)!

biWeeklyValueOver: aPeriod 
	^(self key intersect: aPeriod) days / self days * value!

calculateFirstMonth
	^self key calculateFirstMonth!

calculateLastMonth
	^self key calculateLastMonth!

combine: aPeriodJournalEntry
	self key combine: aPeriodJournalEntry key.
	self value: self value + aPeriodJournalEntry value !

combineIfContiguous: aPeriodJournalEntry
	(self isContiguousWith: aPeriodJournalEntry) ifFalse: [^nil].
	^self combine: aPeriodJournalEntry!

commonEntries: aCollection  
	^self allocateOver: (aCollection select: [:each | each intersects: self key])!

completedDays
	^self key completedDays!

completedMonths
	^self key completedMonths!

completedYears
	^self key completedYears!

completeMonths
	^key completeMonths!

completeYears: aMonthDay
	^key completeYears: aMonthDay!

contains: aDate
	^self key contains: aDate!

datePeriod
	^self key!

datePeriodClass
	^self key class!

datePeriodClass: aClass
	key := aClass 
				from: self key fromDate
				to: self key toDate!

days
	^self key days!

daysInFirstMonth
	^self key daysInFirstMonth!

daysInLastMonth
	^self key daysInLastMonth!

defaultAllocationPolicy
	^AllocationPolicy new!

defaultProrationPolicy
	^ProrationPolicy new!

elapsedMonths
	^self key elapsedMonths!

emptyPeriod
	key := DatePeriod new!

endDate
	^self key endDate!

entryOver: aPeriod
	^self class
		key: aPeriod
		value: (self valueOver: aPeriod)!

entryOverUnique: aPeriod
	^self class
		key: aPeriod
		value: (self valueOverUnique: aPeriod)!

first: aValue after: aDate
	^key toDate > aDate and: [value haEqualTo: aValue]!

fragmentedEntryWith: aJournalEntry
	   ^self class
			key: (self fragmentedPeriodWith: aJournalEntry)
			value: nil!

fragmentedPeriodWith: aJournalEntry
	   ^self key fragmentedPeriodWith: aJournalEntry key!

from: aDate
	^(self startsAfterDate: aDate)
		ifTrue: [self]
		ifFalse: [self entryOver: (self datePeriodClass from: aDate to: self toDate)]!

fromDate
	^self key fromDate!

fromDate: aDate
	self key fromDate: aDate!

hourService: anInteger
minimum: minInteger
multiple: aFloat
rounding: aSymbol
	^(value haGreaterThanOrEqualTo: anInteger)
		ifTrue: [1]
		ifFalse: [(value haLessThan: minInteger)
						ifTrue: [0]
						ifFalse: [value / anInteger
										perform: aSymbol
										with: aFloat]]!

incompleteMonths
	^key incompleteMonths!

incompleteYears
	^key incompleteYears!

incompleteYears: aMonthDay
	^key incompleteYears: aMonthDay!

intersect: aJournalEntry
	^self entryOver: (key intersectPeriod: aJournalEntry key)!

intersects: aJournalEntry
	^self isIntersecting: aJournalEntry!

intersectsPeriod: aDatePeriod
	^self key isIntersecting: aDatePeriod!

isAfter: aJournalEntry
	^aJournalEntry isNotAfterPeriodEntry: self!

isBefore: aJournalEntry
	^aJournalEntry isNotBeforePeriodEntry: self!

isContiguousWith: aPeriodJournalEntry
	^self datePeriod isContiguousWith: aPeriodJournalEntry datePeriod!

isContiguousWith: aPeriodJournalEntry forThreshold: anInteger
	^self datePeriod isContiguousWith: aPeriodJournalEntry datePeriod forThreshold: anInteger!

isEqualPeriodEntry: aPeriodJournalEntry
	^key = aPeriodJournalEntry key
		and: [(value haEqualTo: aPeriodJournalEntry value)
			and: [super = aPeriodJournalEntry]]!

isFullAnniversary: aMonthDay
	^self key isFullAnniversary: aMonthDay!

isFullBiWeeklyFor: aCalendar in: aContext
	^self key isFullBiWeeklyFor: aCalendar in: aContext!

isFullMonth
	^self key isFullMonth!

isFullSemiMonthlyOn: anInteger
	^self key isFullSemiMonthlyOn: anInteger!

isFullYear
	^self key isFullYear!

isFullYear: aMonthDay
	^self key isFullYear: aMonthDay!

isGreaterThanDateEntry: aDateJournalEntry
	^self unsupportedRequest!

isGreaterThanOrEqualDateEntry: aDateJournalEntry
	^self unsupportedRequest!

isGreaterThanOrEqualPeriodEntry: aPeriodJournalEntry
	aPeriodJournalEntry key = key
		ifTrue:[((aPeriodJournalEntry value) wfIsBoolean or:[value wfIsBoolean]) 
					ifTrue:[^(aPeriodJournalEntry value) asString <= value asString]
					ifFalse:[^aPeriodJournalEntry value <= value]
					].
	^aPeriodJournalEntry key < key!

isGreaterThanPeriodEntry: aPeriodJournalEntry
	 key = aPeriodJournalEntry key
		ifTrue:[((aPeriodJournalEntry value) wfIsBoolean or:[value wfIsBoolean]) 
					ifTrue:[^(value asString > (aPeriodJournalEntry value) asString)]
					ifFalse:[^ value > aPeriodJournalEntry value]
					].
	^key > aPeriodJournalEntry key

!

isIntersecting: aJournalEntry
	^self intersectsPeriod: aJournalEntry key!

isMergableContiguousWith: aPeriodJournalEntry
	^(self isIntersecting: aPeriodJournalEntry) or:[self isContiguousWith: aPeriodJournalEntry].!

isNotAfterDateEntry: aPeriodJournalEntry
	^self unsupportedRequest!

isNotAfterPeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry datePeriod isAfter: self datePeriod!

isNotBeforeDateEntry: aPeriodJournalEntry
	^self unsupportedRequest!

isNotBeforePeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry datePeriod isBefore: self datePeriod!

isNotIntersecting: aJournalEntry
	^(self intersectsPeriod: aJournalEntry key) not!

isPeriodBased
	^true!

isPeriodJournalEntry
	^true!

isSameAnniversary: aJournalEntry startingOn: aMonthDay
	^aJournalEntry isSameAnniversaryPeriodEntry: self startingOn: aMonthDay!

isSameAnniversaryPeriodEntry: aPeriodJournalEntry startingOn: aMonthDay
	^aPeriodJournalEntry key isSameAnniversary: key startingOn: aMonthDay!

isSameContiguousAnniversary: aJournalEntry startingOn: aMonthDay
	^key isSameContiguousAnniversary: aJournalEntry key startingOn: aMonthDay!

isSameContiguousMonth: aJournalEntry
	^key isSameContiguousMonth: aJournalEntry key!

isSameMonth: aJournalEntry
	^aJournalEntry isSameMonthPeriodEntry: self!

isSameMonthAndYear: aJournalEntry
	^aJournalEntry isSameMonthAndYearPeriodEntry: self!

isSameMonthAndYearDateEntry: aDateJournalEntry
	^aDateJournalEntry key isSameMonthAndYear: key fromDate !

isSameMonthAndYearPeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry key isSameMonthAndYear: key !

isSameMonthDateEntry: aDateJournalEntry
	^aDateJournalEntry key isSameMonth: key fromDate !

isSameMonthPeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry key isSameMonth: key !

isSameQuarter: aJournalEntry on: aMonthDay
	^aJournalEntry isSameQuarterPeriodEntry: self on: aMonthDay!

isSameQuarterPeriodEntry: aPeriodJournalEntry on: aMonthDay
	^aPeriodJournalEntry key isSameQuarter: key on: aMonthDay!

isSameYear: aJournalEntry
	^aJournalEntry isSameYearPeriodEntry: self!

isSameYearDateEntry: aDateJournalEntry
	^aDateJournalEntry key isSameYear: key fromDate !

isSameYearPeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry key isSameYear: key !

last: aValue before: aDate
	^(value haEqualTo: aValue) and: [key fromDate >= aDate]!

missingPeriod: aJournalEntry  
	^self entryOver: (aJournalEntry key missingPeriod: key) !

monthsInFirstYear
	^self key monthsInFirstYear!

monthsInLastYear
	^self key monthsInLastYear!

monthsInYear
	^self key monthsInYear!

monthsInYear: aDate
	^self key monthsInYear: aDate!

nearestMonths
	^self key nearestMonths!

nearestYears
	^self key nearestYears!

nextMonths
	^self key nextMonths!

nonIntersect: aJournalEntry  
	^(aJournalEntry key nonIntersectPeriod: key) 
		inject: OrderedCollection new 
		into: [:inj :each |
					inj add: (self entryOver: each); yourself]


	
!

prorationPolicy
	^nil!

reportToStream: aStream delimiter: aString
	aStream nextPutAll: ' ', aString, self fromDate asString, aString, self toDate asString, aString, self value asString!

roundFromDatePerform: aSelector
	^self fromDate: (self fromDate perform: aSelector);
		yourself!

roundFromDatePerform: aSelector ifValues: aCollection
	^(aCollection haIncludes: self value)
		ifTrue: [self roundFromDatePerform: aSelector]
		ifFalse: [self]!

roundFromDatePerform: aSelector with: aMonthDay
	^self fromDate: (aMonthDay perform: aSelector with: self fromDate);
		yourself!

roundFromDatePerform: aSelector with: aMonthDay ifValues: aCollection
	^(aCollection haIncludes: self value)
		ifTrue: [self roundFromDatePerform: aSelector with: aMonthDay]
		ifFalse: [self]!

roundThroughDatePerform: aSelector
	^self throughDate: (self throughDate perform: aSelector);
		yourself!

roundThroughDatePerform: aSelector ifValues: aCollection
	^(aCollection haIncludes: self value)
		ifTrue: [self roundThroughDatePerform: aSelector]
		ifFalse: [self]!

roundThroughDatePerform: aSelector with: aMonthDay
	^self throughDate: (aMonthDay perform: aSelector with: self throughDate);
		yourself!

roundThroughDatePerform: aSelector with: aMonthDay ifValues: aCollection
	^(aCollection haIncludes: self value)
		ifTrue: [self roundThroughDatePerform: aSelector with: aMonthDay]
		ifFalse: [self]!

roundToDatePerform: aSelector
	^self toDate: (self toDate perform: aSelector);
		yourself!

roundToDatePerform: aSelector ifValues: aCollection
	^(aCollection haIncludes: self value)
		ifTrue: [self roundToDatePerform: aSelector]
		ifFalse: [self]!

roundToDatePerform: aSelector with: aMonthDay
	^self toDate: (aMonthDay perform: aSelector with: self toDate);
		yourself!

roundToDatePerform: aSelector with: aMonthDay ifValues: aCollection
	^(aCollection haIncludes: self value)
		ifTrue: [self roundToDatePerform: aSelector with: aMonthDay]
		ifFalse: [self]!

semiMonthlyAllocationOver: aCollection  
	self isFullMonth
		ifFalse: [^self allocateOver: aCollection].
	^self defaultAllocationPolicy
		ensureSemiMonthlyEntries: (self asEntrys: aCollection)
		equal: value
	
	!

serviceRounded: aRoundingRule
	^AmountPeriodJournalEntry
		key: self key
		value: (self key perform: aRoundingRule)!

setFromDate: aDate
	key setFromDate: aDate!

setToDate: aDate
	key setToDate: aDate!

storeOn: aStream
	key storeOn: aStream.
	aStream nextPutAll: ' ==> '.
	value storeOn: aStream!

subtractDateEntry: aDateJournalEntry
	^self unsupportedRequest!

subtractEntry: aJournalEntry
	^aJournalEntry subtractPeriodEntry: self!

subtractPeriodEntry: aPeriodJournalEntry
	^aPeriodJournalEntry "clone" - (self valueOver: aPeriodJournalEntry key)!

through: aDate
	^self to: (aDate addDays: 1)!

throughDate
	^self key throughDate!

throughDate: aDate
	self key throughDate: aDate!

to: aDate
	^(self endsBeforeDate: aDate)
		ifTrue: [self]
		ifFalse: [self entryOver: (self datePeriodClass from: self fromDate to: aDate)]!

toDate
	^self key toDate!

toDate: aDate
	self key toDate: aDate!

uniqueConsistentEntrysWith: aPeriodJournalEntry
	^(key uniquePeriodsWith: aPeriodJournalEntry key)
		collect: [:each | 
			(self entryOverUnique: each) addConsistent: (aPeriodJournalEntry valueOverUnique: each)]!

uniqueEntries: aCollection
	^self asEntrys: (aCollection reject: [:each | each intersects: self key]) value: 0
	!

uniqueEntrysWith: aPeriodJournalEntry
	^(key uniquePeriodsWith: aPeriodJournalEntry key)
		collect: [:each | 
			(self entryOverUnique: each) + (aPeriodJournalEntry valueOverUnique: each)]!

unloadToDictionary: aString dictKey: dKey stream: aStream
	aStream nextPutAll: 'DPE| ', aString, '| ', dKey, '| ', self fromDate asString,
								'| ', self toDate asString, '| ', self value asString!

unloadToStream: aStream
	aStream nextPutAll: 'JPE| ', self fromDate asString,
								'| ', self toDate asString, '| ', self value asString!

valueOver: aPeriod
	^self defaultProrationPolicy
		valueOf: self value
		for: aPeriod
		for: self key!

valueOver: aPeriod prorationPolicy: aPolicy
	^aPolicy
		valueOf: self value
		for: aPeriod
		for: self key!

valueOverUnique: aPeriod
	^self defaultProrationPolicy
		valueOf: self value
		overUnique: aPeriod
		for: self key!

yearMonthDay 
	^self datePeriodClass yearMonthDay 
		from: self fromDate 
		to: self toDate
!

years
	^self key years!

yearsAndCompletedMonths
	^self key yearsAndCompletedMonths! !

PeriodJournalEntry initializeAfterLoad!