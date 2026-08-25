
StoredObject subclass: #Journal
    classInstanceVariableNames: ''
    instanceVariableNames: 'entrys definition entryClass isNamed '
    classVariableNames: ''
    poolDictionaries: ''!

!Journal class publicMethods !

cleanWith: aData storageKey: anObject
	^self manager
		cleanWithData: aData
		storageKey: anObject!

definition: aDefinition
	^aDefinition entryClass createJournal
		definition: aDefinition!

entryClass: aClass
	^self newWithoutStorage entryClass: aClass!

fromCDHRecords: aCollection
	^aCollection first isNumericFieldType
		ifTrue: [AmountPeriodJournal fromCDHRecords: aCollection]
		ifFalse: [CodePeriodJournal fromCDHRecords: aCollection]!

menuName
	^''!

name: aString ownedBy: anObject
	^self dataClass
		name: aString
		ownedBy: anObject
		database: self database!

new: anInteger entryClass: aClass
	^self newWithoutStorage
		new: anInteger
		entryClass: aClass!

newWithoutStorage
	^super newWithoutStorage entrysWithoutStorage!

ownedBy: anObject
	^self dataClass
		ownedBy: anObject
		database: self database!

ownedByOriginalPerson: anObject
	^self dataClass
		ownedByOriginalPerson: anObject
		database: self database!

typeStrings
	^#('AmountPeriodJournal' 'CodePeriodJournal' 'RatePeriodJournal')! !

!Journal publicMethods !

* anObject
	^anObject timesJournal: self!

, aJournal
	^self combine: aJournal!

/ anObject
	^anObject dividesJournal: self!

abrAsString
	^self asString!

add: aJournalEntry
	^self entrys add: aJournalEntry!

addAll: aCollection
	self entrys addAll: aCollection!

addAllValues: aDictionary
	aDictionary keysDo:
		[:each |self
					at: each
					updateValue: (aDictionary at: each)].
	self entrysChanged!

addDuplicateEntries
	|tempJrnl|
	tempJrnl := self class clean.
	self copyEntrys do:[:each | (tempJrnl keys includes:each key)
			 ifTrue:[tempJrnl addValue: ((each value) + (tempJrnl at:each key)) at: each key]
			 ifFalse:[tempJrnl add:each].
				].
^tempJrnl!

addJournal: aJournal
	self addAll: aJournal entrys!

addValue: aValue at: dateKey
	(self isValidKey: dateKey) ifFalse: [^self error: 'InvalidKey type']. 
	self journalChanged.
	self
		at: dateKey
		updateValue: aValue!

addValueString: aString at: dateKey
|newEntry|
	newEntry := self entryClass key: dateKey value: nil.
	newEntry value: (newEntry stringToValue: aString).
	^self add: newEntry!

applyLowerLimit: aNumber
	^self copyWithEntrys: (self entrysCollect: [:each | each max: aNumber])!

applyUpperLimit: aNumber
	^self copyWithEntrys: (self entrysCollect: [:each | each min: aNumber])!

asAmount
	self error: 'Invalid JournalSwitch'!

asAmountJournal
	^self asAmount!

asDateJournal
	^self subclassResponsibility!

asHighestConsecutive: anInteger 
	|answer|
	answer := self emptyCopy.
	answer entrys: (self highestConsecutiveEntrys: anInteger).
	^answer!

asHighestConsecutive: range ofLast: count 
	^(self asLastConsecutive: count) asHighestConsecutive: range!

asHighestNonConsecutive: anInteger 
|answer|
	answer := self emptyCopy.
	answer entrys: (self highestNonConsecutiveEntrys: anInteger) asSortedCollection.
	^answer!

asHighestNonConsecutive: range ofLast: count 
	^(self asLastConsecutive: count) asHighestNonConsecutive: range!

asJournalEntrys: aCollection
	^self entryClass asJournalEntrys: aCollection!

asJournalEntrys: aCollection value: aValue
	^self entryClass asJournalEntrys: aCollection value: aValue!

asLastConsecutive: anInteger
	^self
		protectedCopyFrom: self size - anInteger + 1
		to: self size!

asSecondHighestConsecutive: anInteger 
	|answer|
	answer := self emptyCopy.
	answer entrys: (self secondHighestConsecutiveEntrys: anInteger).
	^answer!

asString
	"| result |
	result := ReadWriteStream on: ' '.
	self printEntrysOn: result.
	^result contents copyFrom: 3 to: result contents size"
	^WfDrawnObject draw: self!

asStringForDocumentation
	| result |
	result := ReadWriteStream on: ' '.
	self printEntrysOn: result.
	^result contents copyFrom: 3 to: result contents size!

asStringForEditor: anEditor
	^anEditor expandJournals
		ifTrue: [self asString]
		ifFalse: [self class asString]!

asTableItems
	^self entrys!

at: keyValue
	^self
		at: keyValue
		ifAbsent: [self errorInvalidKey: keyValue]!

at: keyValue ifAbsent: aBlock
	^(self
		detect: [:each | each isKey: keyValue]
		ifNone: [^aBlock value]) value    !

at: dateKey put: aValue
	^self add: (self entryClass
						key: dateKey
						value: aValue)!

at: dateKey updateValue: aValue 
	(self
		journalEntryAt: dateKey
		ifAbsent: [self at: dateKey put: aValue.
						^self]) value: aValue
!

atAll: aJournal put: anObject
	aJournal keysDo: [ :each |
		self addValue: anObject at: each]!

atAllPut: anObject
	^self journalEntrysDo: [:each | each value: anObject]!

average
	^self isEmpty
		ifTrue: [nil]
		ifFalse: [self sum / self size]!

averageHighestConsecutive: range ofLast: count 
	^(self
		asHighestConsecutive: range
		ofLast: count) average!

averageHighestNonConsecutive: range ofLast: count 
	^(self
		asHighestNonConsecutive: range
		ofLast: count) average!

clone
"For journals, may want to use copyWithoutStorage instead"
| answer |
	answer := super clone entrys: nil.
	answer addAll: (entrys collect: [:each | each clone]).
	^answer!

collect: aBlock
	^self copyWithEntrys: (self entrysCollect: aBlock)!

collectAll: aBlock
	^self copyWithEntrys: (self entrysCollectAllAsOrderedCollection: aBlock)!

containsValue: aValue
	^self includes: aValue!

containsValue: aValue at: dateKey
	^(self
		at: dateKey
		ifAbsent: [^false]) haEqualTo: aValue
			!

contiguousPeriods
	^self subclassResponsibility!

copyCollect: aBlock
	^self copyWithEntrys: (self entrysCopyCollect: aBlock)!

copyEntrys
	^self entrys asOrderedCollection
		collect: 
			[:each | each copy]!

copyFrom: beginning to: end
	^self copyWithEntrys: (self entrysFrom: beginning to: end)!

copyNamedWithoutStorage
	self isNamed
		ifTrue: [^self copyWithoutStorage].
	^self!

copyWithEntrys: aCollection
	^self copyWithSortedEntrys: aCollection asSortedCollection!

copyWithoutStorage
	self system yield.
	^self emptyCopy entrys: self copyEntrys asSortedCollection!

copyWithSortedEntrys: aSortedCollection
	^self emptyCopy entrys: aSortedCollection deepCopy!

dataTypeBlock
	^AtFunctionCalculator journalBlock!

datesDo: aBlock
	self keysDo: aBlock!

datesOf: aValue
| collection|
	collection := OrderedCollection new.
	self journalEntrysDo:
		[:each |
			(each isValue: aValue)
				ifTrue: [collection add: each key]].
	^collection   !

datesOf: aValue do: aBlock
	self journalEntrysDo:
		 [:each |
			(each isValue: aValue)
				ifTrue: [aBlock value: each key]]!

defaultJournalEntrys
	^SortedCollection new
	"^StorageSortedCollection new"!

defaultJournalEntrys: aCollection
	^aCollection asSortedCollection
"^aCollection asStorageSortedCollection"!

defaultJournalEntrysSize: anInteger
	^SortedCollection new: anInteger!

defaultProrationPolicy
	^nil!

definition
	^definition !

definition: aJournalDefinition
	definition := aJournalDefinition.
	self distributeDefinition!

detect: aBlock
	^self entrys detect: aBlock!

detect: aBlock ifNone: exceptionBlock
	^self entrys
			detect: aBlock
			ifNone: exceptionBlock!

distributeDefinition
	self entryClass: definition entryClass!

divideNumber: aNumber
	^self copyWithEntrys: (self entrysCollect: [:each | each / aNumber])!

dividesJournal: aJournal
	^aJournal divideJrnl: self!

do: aBlock
	self valuesDo: aBlock!

do: aBlock andBetweenDo: seperatorBlock
	^self entrys
			do: aBlock
			andBetweenDo: seperatorBlock!

earliestDate
	^self firstDate !

elementsEqual: aJournal
	^self entrys elementsEqual: aJournal entrys!

emptyCopy
	^self class newWithoutStorage!

emptyCopyWithEntry: anEntry
|result|
	result := self emptyCopy.
	anEntry isNil
		ifFalse: [result add: anEntry].
	^result	!

emptyDefault
	^0!

entryClass
	entryClass isNil
		ifTrue: [entryClass := self journalEntryClass].
	^entryClass !

entryClass: aClass
	entryClass := aClass!

entrys
	entrys isNil ifTrue: [self entrys: self defaultJournalEntrys].
	^entrys!

entrys: aCollection
	entrys := aCollection!

entrysChanged
	self journalChanged!

entrysCollect: aBlock
	^self entrys asOrderedCollection
		collect:
			[:each | (aBlock value: each copy)]!

entrysCollectAllAsOrderedCollection: aBlock
| answer | 
	answer := OrderedCollection new.
	self entrys do:
		[:each | answer addAll: (aBlock value: each)].
	^answer!

entrysCopyCollect: aBlock
	^self entrys asOrderedCollection
		collect:
			[:each | (aBlock value: each deepCopy)]!

entrysFrom: beginning to: end
	^(self entrys asOrderedCollection copyFrom: beginning to: end)
			collect: [:each | each copy]!

entrysReject: aBlock
	^(self entrys asOrderedCollection
		reject: [:each | aBlock value: each])
			collect: [:each | each copy]!

entrysRemoveKey: aKey ifAbsent: aBlock
	^self
		removeJournalEntry: (self journalEntryAt: aKey ifAbsent: [nil])
		ifAbsent: aBlock!

entrysSelect: aBlock
	^(self entrys asOrderedCollection
		select: [:each | aBlock value: each])
			collect: [:each | each copy]!

entrysSelectIntersection: aJournalEntry
	^self entrysSelect: [:each | each intersects: aJournalEntry]!

entrysSetJournalID
	self journalEntrysDo:
		[:each | self own: each]!

entrysWithoutStorage
	entrys := SortedCollection new!

equalTo: anObject forDecimals: anInteger
	^anObject equalToJournal: self forDecimals: anInteger!

equalToJournal: aJournal forDecimals: anInteger
	(self size = aJournal size and: [(self class = aJournal class)])
		ifFalse: [^false].
	self entrys
		with: aJournal entrys
		do: [:e1 :e2 | (e1 key = e2 key and: [e1 value equalTo: e2 value forDecimals: anInteger])
						ifFalse: [^false]].
	^true!

errorAbsentEntry
	self error: 'Journal Entry is missing'!

errorAbsentKey
	self error: 'Key is missing'!

errorAbsentObject
	self error: 'Object is missing'!

errorInvalidKey: keyValue
	^ExceptionalJournalResult value: self error: (JournalKeyError key: keyValue)!

excluding: anObject
	^self reject: [:each | anObject haEqualTo: each value]!

excludingAll: aCollection
	^self reject: [:each | aCollection haIncludes: each value]!

findFirst: aBlock
	^self
		findFirst: aBlock
		ifAbsent: [self errorAbsentObject]!

findFirst: aBlock ifAbsent: errorBlock
	^self
		detect: [:each | aBlock value: each]
		ifNone: [errorBlock value]!

findLast: aBlock
	self
		findLast: aBlock
		ifAbsent: [self errorAbsentObject]!

findLast: aBlock ifAbsent: notFoundBlock
|answer|
	self valuesDo: [:each |
			(aBlock value: each)
				ifTrue: [answer := self keyAtValue: each]].
	^answer isNil
		ifTrue: [ notFoundBlock value ]
		ifFalse: [ answer ]!

first: aValue
	^self
		first: aValue
		after: (HATimeConstants at: 'HABeginningOfTime')!

first: aValue after: aDate
	^self emptyCopyWithEntry: (self firstEntry: aValue after: aDate)!

firstDate
	^self notEmpty
		ifTrue: [self firstEntry key]
		ifFalse: [nil]!

firstEntry
	^self entrys first!

firstEntry: aValue after: aDate
	^(self
		detect: [:each | each first: aValue after: aDate]
		ifNone: [^nil])!

firstOfDuplicateEntries
	|tempJrnl|
	tempJrnl := self class clean.
	self copyEntrys do:[:each | (tempJrnl keys includes:each key)
			 ifFalse:[tempJrnl add:each].
				].
^tempJrnl!

firstValue
	^self notEmpty
		ifTrue: [self firstEntry value]
		ifFalse: [nil]!

fragmentedPeriods
	^self subclassResponsibility!

fromDateAfterEntry: anEntry
	^self
		reverseInject: Date highDate
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each fromDate]!

fromDateBeforeEntry: anEntry
	^self
		inject: Date lowDate
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each fromDate]!

fromDateIndex: anInteger
errValue: anObject
	^(self 
		journalEntryAtIndex: anInteger
		ifAbsent: [^anObject]) fromDate!

haIncludes: anObject
	^self includes: anObject!

hasConflictingOverlaps
	^false!

hasDuplicateEntries
	|sc|
	sc:=self entrys collect:[:each|each key].
	^(sc size = sc asSet size) not!

hasOverlappingEntries
	self isDateJournal ifTrue:[^false].
	1 to: self entrys size - 1 do: [:each | (((self entrys at: each) key ~= (self entrys at: each + 1) key) and:[
																((self entrys at: each) key intersects: (self entrys at: each + 1) key)	])
																	ifTrue: [^true]
													].
	^false
!

hasProrationPolicy
	^self entrys first hasProrationPolicy!

highestConsecutiveEntrys: anInteger
| max maxValue |
	self size <= anInteger ifTrue: [^self copyNamedWithoutStorage entrys].
	maxValue := 0. "is there a negative max?"
	(self size  to: anInteger by: -1)
		do: [:each | |current curValue|
				curValue := (current := self copyFrom: each - anInteger + 1 to: each) sum.
				curValue > maxValue
					ifTrue: [max := current.
								maxValue := curValue]].
	^max isNil
		ifTrue: [(self copyFrom: (self size - anInteger + 1)  to: self size) entrys] "all entries have the same value"
		ifFalse: [max entrys]!

highestConsEntrys: anInteger
	| max maxValue |
	self size <= anInteger ifTrue: [^self copyNamedWithoutStorage ].
	maxValue := 0. "is there a negative max?"
	(self size  to: anInteger by: -1)
		do: [:each | |current curValue|
				curValue := (current := self copyFrom: each - anInteger + 1 to: each) sum.
				curValue > maxValue
					ifTrue: [max := current.
								maxValue := curValue]].
	^max isNil
		ifTrue: [(self copyFrom: (self size - anInteger + 1)  to: self size) ] "all entries have the same value"
		ifFalse: [max ]!

highestNonConsecutiveEntrys: anInteger
	self size <= anInteger ifTrue: [^self copyNamedWithoutStorage entrys].
	^(self entrys asSortedCollection:
			[:each1 :each2 | each1 valueSortWith: each2]) asOrderedCollection 
		copyFrom: 1
		to: anInteger!

highestOfDuplicateEntries
	|tempJrnl|
	tempJrnl := self class clean.
	self copyEntrys do:[:each | (tempJrnl keys includes:each key)
			ifTrue:[(each value > (tempJrnl at:(each key))) ifTrue:[tempJrnl at:(each key) updateValue:(each value)]]
			ifFalse:[tempJrnl add:each].
				].
^tempJrnl!

includes: anObject
	self journalEntrysDo:
		[:each |
			(each isValue: anObject)
				ifTrue: [^true]].
	^false!

includesAll: aCollection
	self journalEntrysDo:
		[:each |
			(aCollection haIncludes: each value)
				ifTrue: [^true]].
	^false
!

includesJournalEntry: aJournalEntry
	^self entrys includes: aJournalEntry!

including: anObject
	^self select: [:each | anObject haEqualTo: each value]!

includingAll: aCollection
	^self select: [:each | aCollection haIncludes: each value]!

includingGreaterThan: anObject
	^self select: [:each | each value haGreaterThan: anObject]!

includingLessThan: anObject
	^self select: [:each | each value haLessThan: anObject]!

indexOfEntry: anEntry
	^self entrys indexOf: anEntry!

inject: initialValue into: aBinaryBlock
	^self entrys
		inject: initialValue
		into: aBinaryBlock!

isAnnually
	^false!

isContiguous
	^self subclassResponsibility!

isContiguousFrom: startDate to: endDate
	^self subclassResponsibility!

isEmpty
	^self entrys isEmpty!

isFragmented
	^self subclassResponsibility!

isFragmentedFrom: startDate to: endDate
	^self subclassResponsibility!

isHourly
	^false!

isJournal
	^true!

isJournalResult
	^true!

isLastInContext: aContext
	^aContext isLastEntry: self lastEntry!

isMonthly
	^false!

isNamed
	isNamed isNil
		ifTrue: [^false].
	^isNamed!

isNamed: aBoolean
	isNamed := aBoolean!

isValidResultListStoredResult
	^true!

isValidStoredTBAResult
	^true	!

IsValue: anObject on: aDate
	^anObject haEqualTo: (self valueOn: aDate)!

journalChanged
	self makeDirty!

journalEntryAt: aKey
	^self
		journalEntryAt: aKey
		ifAbsent: [self errorAbsentKey]!

journalEntryAt: aKey ifAbsent: aBlock
	self journalEntrysDo:
		[:each |
			each key = aKey
				ifTrue: [^each]].
	^aBlock value!

journalEntryAtIndex: anInteger
	^self entrys at: anInteger!

journalEntryAtIndex: anInteger
ifAbsent: aBlock
	^self entrys
		at: anInteger
		ifAbsent: aBlock!

journalEntryClass
	^self entrys size = 0
		ifTrue: [self class journalEntryClass]
		ifFalse: [entrys first class]!

journalEntrysDo: aBlock
	^self entrys do: aBlock!

journalEntrysSelect: aBlock
	^self entrys select: aBlock!

keyAtValue: anObject
	^self
		keyAtValue: anObject
		ifAbsent: [nil]!

keyAtValue: anObject ifAbsent: aBlock
	^(self
		detect: [ :each | each isValue: anObject]
		ifNone: [^aBlock value]) key!

keys
	| answer |
	answer := Bag new.
	self journalEntrysDo: [ :each |
		answer add: each key].
	^answer!

keysAndValuesDo: aBlock
	self journalEntrysDo:
		[:each |
	   		each keyAndValueDo: aBlock]!

keysAsArray
	| answer |
	answer := OrderedCollection new: self size.
	self journalEntrysDo:
		[:each |
			answer add: each key].
	^answer!

keysDo: aBlock
	self journalEntrysDo:
		[:each | aBlock value: each key]!

keysSorted
   ^self keysAsArray asSortedCollection!

last: aValue
	^self
		last: aValue
		before: (HATimeConstants at: 'HAEndOfTime')
!

last: aValue before: aDate
	^self emptyCopyWithEntry: (self lastEntry: aValue before: aDate)!

lastDate
	^self notEmpty
		ifTrue: [self lastEntry key]
		ifFalse: [nil]!

lastEntry
	^self entrys last!

lastOfDuplicateEntries
	|tempJrnl|
	tempJrnl := self class clean.
	self copyEntrys do:[:each | (tempJrnl keys includes:each key)
			ifTrue:[tempJrnl at:(each key) updateValue:(each value)]
			ifFalse:[tempJrnl add:each].
				].
^tempJrnl!

lastValue
	^self notEmpty
		ifTrue: [self lastEntry value]
		ifFalse: [nil]!

latestDate
	^self lastDate !

lowestOfDuplicateEntries
	|tempJrnl|
	tempJrnl := self class clean.
	self copyEntrys do:[:each | (tempJrnl keys includes:each key)
			ifTrue:[(each value < (tempJrnl at:(each key))) ifTrue:[tempJrnl at:(each key) updateValue:(each value)]]
			ifFalse:[tempJrnl add:each].
				].
^tempJrnl!

max
	^self 
		inject: self firstValue
		into: [ :max :each | each maximum: max]
		!

menuName
	^self class menuName!

mergeDuplicateEntries
	|tempJrnl lastDupEntry|
	tempJrnl := self class clean.
	self copyEntrys do:[:each |
		(tempJrnl keys includes:each key)
		ifTrue:[(each value) ~= (lastDupEntry value)
			ifTrue:[tempJrnl addValue: ((each value) + (tempJrnl at:each key)) at: each key.
			lastDupEntry := each copy]  ]
		ifFalse:[tempJrnl add:each. lastDupEntry := each copy].
	].
^tempJrnl!

min
	^self 
		inject: self firstValue
		into: [ :min :each | each minimum: min]!

mostOccurrences
	^JournalMostVisitor visit: self!

multiplyNumber: aNumber
	^self copyWithEntrys: (self entrysCollect: [:each | each * aNumber])!

needsProrationPolicy
	^false!

negated
	self journalEntrysDo:
			[:each | each negated]!

new: anInteger entryClass: aClass
	entrys := self defaultJournalEntrysSize: anInteger.
	entryClass := aClass!

newEntrys: aCollection
	entrys := nil.
	self addAll: aCollection!

notEmpty
	^self entrys notEmpty!

numberOfDisplayColumns
	^2!

occurrencesGreaterThan: anObject
	^self occurrencesOf: anObject selector: #haGreaterThan:!

occurrencesGreaterThanOrEqual: anObject
	^self occurrencesOf: anObject selector: #haGreaterThanOrEqualTo:!

occurrencesLessThan: anObject
	^self occurrencesOf: anObject selector: #haLessThan:!

occurrencesLessThanOrEqual: anObject
	^self occurrencesOf: anObject selector: #haLessThanOrEqualTo:!

occurrencesNotEqual: aValue
	^self size - (self occurrencesOf: aValue)!

occurrencesOf: aValue
	^self occurrencesOf: aValue selector: #haEqualTo:!

occurrencesOf: anObject selector: aSymbol
	^self
		inject: 0
		into: [ :inj :each |
		inj + ((each value perform: aSymbol with: anObject)
				ifTrue: [1]
				ifFalse: [0])]!

occursLast: aCollection
	self reverseDo: [:each | (aCollection haIncludes: each value) ifTrue: [^each value]]!

own: aJournalEntry
	aJournalEntry journalID: self storageKey!

prepareForStorage
	storageKey isNil ifTrue: [self initializeNew].
	self entrysSetJournalID!

printEntrysOn: aStream
	self entrys do:
		[:each | aStream cr.
					each printOn: aStream]!

printOn: aStream
	super printOn: aStream.
	self printEntrysOn: aStream!

prorationPolicy
	^nil!

prorationPolicy: aPolicy!

protectedCopyFrom: beginning to: end
	   beginning < 1
		ifTrue: [^self copyFrom: 1 to: end].
	^self copyFrom: beginning to: end!

reject: aBlock
	^self copyWithEntrys: (self entrysReject: aBlock)!

remove: anObject
	^self
		removeJournalEntry: anObject
		ifAbsent: [self errorAbsentObject]!

remove: anObject ifAbsent: aBlock
	^self removeJournalEntry: anObject ifAbsent: aBlock!

removeAll
	(self size to: 1 by: -1)
		do: [:each |self
						removeJournalEntry: (self journalEntryAtIndex: each)
						ifAbsent: [nil]]!

removeAll: aJournal
		"Answer aJournal.  Remove all the elements
		 contained in aJournal from the receiver."
	aJournal journalEntrysDo:
		[ :each | self
						removeJournalEntry: each
						ifAbsent: [nil]].
	^aJournal!

removeAllEntrys: aDictionary
   aDictionary keysDo: [:each | self removeEntryAt: each]!

removeEntryAt: aDate
	^self
		removeKey: aDate
		ifAbsent: [^nil]
		!

removeFirst
	self entrys removeFirst!

removeJournalEntry: anEntry
	^self
		removeJournalEntry: anEntry
		ifAbsent: [self errorAbsentEntry]!

removeJournalEntry: anEntry ifAbsent: aBlock
	^self entrys
		remove: anEntry
		ifAbsent: aBlock!

removeKey: aKey
	^self
		entrysRemoveKey: aKey
		ifAbsent: [self errorAbsentKey]!

removeKey: aKey ifAbsent: aBlock
	^self
		entrysRemoveKey: aKey
		ifAbsent: aBlock!

removeLast
	self entrys removeLast!

removeValue: aValue at: aDate
	(self 
		containsValue: aValue
		at: aDate)
			ifFalse: [^nil].
	^self
		removeKey: aDate
		ifAbsent: [nil]        !

resolveDuplicates: aString
	(self isEmpty) ifTrue:[^self].
	(self hasDuplicateEntries) ifFalse:[^self].
	('ADD' = aString) ifTrue:[^(self addDuplicateEntries)].
	('MERGE' = aString) ifTrue:[^(self mergeDuplicateEntries)].
	('HIGHEST' = aString) ifTrue:[^(self highestOfDuplicateEntries)].
	('LOWEST' = aString) ifTrue:[^(self lowestOfDuplicateEntries)].
	('FIRST' = aString) ifTrue:[^(self firstOfDuplicateEntries)].
	('LAST' = aString) ifTrue:[^(self lastOfDuplicateEntries)].!

resolveOverlaps: aString
(self isEmpty) ifTrue:[^self].
	^self resolveOverlapsWith:aString.!

reverseDo: aBlock
	self entrys reverseDo: aBlock!

reverseInject: initialValue into: aBinaryBlock
	^self entrys
		reverseInject: initialValue
		into: aBinaryBlock!

secondHighestConsecutiveEntrys: anInteger		
| max sumValue highestJrnl flag|
	
	self size <= anInteger ifTrue: [^self copyNamedWithoutStorage entrys].
	highestJrnl := self highestConsecutiveEntrys: anInteger.
	sumValue := 0. 
	flag := false.
	(self size  to: anInteger by: -1)
		do: [:each | |current curValue|
				curValue := (current := self copyFrom: each - anInteger + 1 to: each) sum.
				((current entrys =  highestJrnl) and:[flag not]) ifTrue:[flag := true]
				ifFalse:[(curValue > sumValue)
				ifTrue: [max := current. sumValue := curValue]]].
	^max isNil
		ifTrue: [(self copyFrom: (self size - anInteger + 1)  to: self size) entrys] "all entries have the same value"
		ifFalse: [max entrys]!

select: aBlock
	^self copyWithEntrys: (self entrysSelect: aBlock)!

setProrationPolicyIn: aContext!

shallowCopy
	^super shallowCopy entrys: entrys shallowCopy!

size
	^self entrys size!

subtractFromCodeJournal: aJournal
	self error: 'Both journals must be CodePeriodJournals'!

sum
	^self
		inject: 0
		into: [:inj :each | inj + each value] !

tableColumnsFor: aView
	aView columnsForJournal: self!

tbaResultType
	^self class!

throughDateAfterEntry: anEntry
	^self
		reverseInject: Date highDate
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each throughDate]!

throughDateBeforeEntry: anEntry
	^self
		inject: Date lowDate
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each throughDate]!

throughDateIndex: anInteger
errValue: anObject
	^(self 
		journalEntryAtIndex: anInteger
		ifAbsent: [^anObject]) throughDate!

timesJournal: aJournal
	^aJournal multiplyJrnl: self!

toDateAfterEntry: anEntry
	^self
		reverseInject: Date highDate
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each toDate]!

toDateBeforeEntry: anEntry
	^self
		inject: Date lowDate
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each toDate]!

toDateIndex: anInteger
errValue: anObject
	^(self 
		journalEntryAtIndex: anInteger
		ifAbsent: [^anObject]) toDate!

translate: aTable
	^self collect: [:each | each translate: aTable]!

validateConstantOrNonconstant: anArgumentDescription
	^anArgumentDescription validateConstant: self!

valueAfterEntry: anEntry
	self
		reverseInject: self emptyDefault
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each value]!

valueBeforeEntry: anEntry
	self
		inject: self emptyDefault
		into: [:inj :each | each = anEntry ifTrue: [^inj].
								each value]!

valueIndex: anInteger
errValue: anObject
	^(self 
		journalEntryAtIndex: anInteger
		ifAbsent: [^anObject]) value!

valueOn: aDate
| value |
	value := (self entryOn: aDate) value.
	value notNil ifTrue: [^value].
	^self emptyDefault!

valueOn: aDate defaultValue: aValue
| value |
	value := (self entryOn: aDate) value.
	value notNil ifTrue: [^value].
	^aValue!

values
	| answer |
	answer := Bag new.
	self journalEntrysDo:
		[ :each | answer add: each value].
	^answer!

valuesCollect: aBlock
	^self collect: [:each | each value: (aBlock value: each)]!

valuesDo: aBlock
	self journalEntrysDo:
		[:each | aBlock value: each value]!

with: aJournal do: aBlock
	| aStream1 aStream2 |
	self size = aJournal size
		ifFalse: [^self error: 'Journals are of differing length'].
	aStream1 := ReadStream on: self entrys asOrderedCollection.
	aStream2 := ReadStream on: aJournal entrys asOrderedCollection.
	[aStream1 atEnd]
		whileFalse: [
			aBlock
				value: aStream1 next
				value: aStream2 next]!

write: aContext forKey: anObject
	self
		writeLocal: aContext
		forKey: anObject.
	self entrys write: aContext.
	self unregister!

write: aContext forKey: aKey ownedBy: anObject
	self
		writeLocal: aContext
		forKey: anObject.
	self entrys write: aContext.
	self unregister!

writeDataFor: aData
	aData writeJournalData: self!

writeLocal: aContext forKey: anObject
	self prepareForStorage.
	super writeLocal: aContext forKey: anObject! !

Journal initializeAfterLoad!