
StoredObject subclass: #JournalEntry
    classInstanceVariableNames: ''
    instanceVariableNames: 'value key '
    classVariableNames: ''
    poolDictionaries: ''!

!JournalEntry class publicMethods !

asJournalEntrys: aCollection
	"Returns a collection of JournalEntrys with keys from aCollection (which can be
	dates or datePeriods)" 
	^aCollection collect:
		[:each | self
					key: each
		        	value: self defaultValue]!

asJournalEntrys: aCollection value: aValue
	"Returns a collection of JournalEntrys with keys from aCollection (which can be
	dates or datePeriods)" 
	^aCollection collect:
		[:each | self
					key: each
		        	value: aValue]!

createJournal
	^self journal entryClass: self!

defaultValue
	^nil!

isAnnually
	^false!

isHourly
	^false!

isMonthly
	^false!

key: aDateKey value: anObject
	^self newWithoutStorage
		key: aDateKey
		value: anObject!

key: aDateKey value: anObject prorationPolicy: aPolicy
	^self newWithoutStorage
		key: aDateKey
		value: anObject!

register: anObject 
	"don't cache JournalEntry"!

unregister: anObject
	"Journal Entry's aren't registered"! !

!JournalEntry publicMethods !

* aNumber
	self value: value * aNumber!

+ aNumber
	self value: value + aNumber!

- aNumber
	self value: value - aNumber!

/ aNumber
	self value: value / aNumber!

addValue: aJournalEntry
	self + aJournalEntry value!

asEntryResultFor: aResult
	^CalculationJournalEntryResult new
		name: aResult name;
		result: self;
		yourself!

asEntrys: aCollection
	^self class asJournalEntrys: aCollection!

asEntrys: aCollection value: aValue
	^self class asJournalEntrys: aCollection value: aValue!

copy
	^self class
		key: self key copy
		value: self value !

copyValue: anObject
	^self copy value: anObject!

datePeriod
	^self subclassResponsibility!

deepCopy
	^self class
		key: self key shallowCopy
		value: self value shallowCopy!

displayAt: anInteger
	^(anInteger = 1
		ifTrue: [self key]
		ifFalse: [self value]) asStringForEditor: self editor!

earliestFromDate: aJournalEntry
	^self fromDate min: aJournalEntry fromDate!

earliestThroughDate: aJournalEntry
	^self throughDate min: aJournalEntry throughDate!

earliestToDate: aJournalEntry
	^self toDate min: aJournalEntry toDate!

endsAfterDate: aDate
	^self toDate > aDate!

endsBeforeDate: aDate
	^self toDate <= aDate!

endsEarlier: aJournalEntry
	^self toDate = (self earliestToDate: aJournalEntry)!

endsLater: aJournalEntry
	^self toDate = (self latestToDate: aJournalEntry)!

hash
	^key hash!

initializeNew
	self
		makeNew;
		initializeStoredData!

isAfter: aPeriodJournalEntry
	^self subclassResponsibility!

isAnnually
	^false!

isBefore: aPeriodJournalEntry
	^self subclassResponsibility!

isEmpty
	^value isNil!

isHourly
	^false!

isJournalEntry
	^true!

isKey: anObject
	^key = anObject!

isMonthly
	^false!

isValid
	^key notNil and: [value notNil]!

isValue: anObject
	^value haEqualTo: anObject!

journalID
	^self storageKey!

journalID: anObject
	self setStorageKey: anObject!

key
	^key!

key: anObject
	key := anObject.
	self register!

key: anObject value: aValue
	value := aValue.
	key := anObject!

key: anObject value: aValue prorationPolicy: aPolicy
	value := aValue.
	key := anObject!

keyAndValueDo: aBlock
	aBlock
		value: key
		value: value!

latestFromDate: aJournalEntry
	^self fromDate max: aJournalEntry fromDate!

latestThroughDate: aJournalEntry
	^self throughDate max: aJournalEntry throughDate!

latestToDate: aJournalEntry
	^self toDate max: aJournalEntry toDate!

max: aNumber
	^self value: (self maximum: aNumber)!

maximum: aNumber
	^value max: aNumber!

maxValue: aJournalEntry
	^self maximum: aJournalEntry value!

min: aNumber
	^self value: (self minimum: aNumber)!

minimum: aNumber
	^value min: aNumber!

minValue: aJournalEntry
	^self minimum: aJournalEntry value!

months
	^self key months!

monthsPolicy: anInteger
	^self key monthsPolicy: anInteger!

needsProrationPolicy
	^false!

negated
	self value: self value negated !

newResult
	^CalculationJournalEntryResult clean!

periodClass
	^self class periodClass!

prepareForStorage
	data notNil ifTrue: [^nil].
	self initializeNew!

printOn: aStream
	key printOn: aStream.
	aStream nextPutAll: '   '.
	value printOn: aStream!

roundToDecimals: anInteger
	self value: (value roundedToDecimals: anInteger)!

startsAfterDate: aDate
	^self fromDate >= aDate!

startsBeforeDate: aDate
	^self fromDate < aDate!

startsEarlier: aJournalEntry
	^self fromDate = (aJournalEntry earliestFromDate: self)!

startsLater: aJournalEntry
	^self fromDate = (aJournalEntry latestFromDate: self)!

stringToValue: aString
	^(aString = '' or: [aString isValidNumber not]) 
		ifTrue: [nil]
		ifFalse: [aString asFloat]!

subtractValue: aJournalEntry
	self - aJournalEntry value!

tbaTypeCode
	^'N'!

time
	^self months!

translate: aTable
	^self copy value: (aTable at: value
						 ifAbsent: [value])!

value
	^value!

value: anObject
	self makeDirty.
	value := anObject!

valueSortWith: aJournalEntry
	^(value haGreaterThan: aJournalEntry value)
		or: [(value haEqualTo: aJournalEntry value)
				and: [aJournalEntry < self]]!

with: aData
	self
		setData: self createDataObject;
		setDatabase: self class manager database.
	data loadObject: aData.
	self register.
	^self!

writeLocal: aContext forKey: anObject
	"Later, protect this so it stays dirty if the write fails. TSH: This needs to reviewed"

	self prepareForStorage.
	data write: aContext forKey: anObject.
	self makeClean! !

JournalEntry initializeAfterLoad!