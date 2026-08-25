
CalculatorWithArguments subclass: #AtFunctionCalculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!AtFunctionCalculator class publicMethods !

booleanType
	^'Boolean'!

calculatorUserNamesByCategory
	| dictionary array |
	dictionary := Dictionary new.
	self realSubclasses do:
			[:each |
				each category do:
					[:each2 |
						array := dictionary at: each2 ifAbsent: [OrderedCollection new].
						array add: each userName.
						dictionary at: each2 put: array]].
	^dictionary!

categories 
	| result |
	result := (self allSubclasses
		inject: Set new
		into: [:inj :calculator |
					inj addAll: calculator category.
					inj]) asSortedCollection.
	^result reject: [:each | each asUppercase = 'HIDDEN']!

category
	"Must return an arrary"
	^#( 'Uncategorized')!

dateType
	^'Date'!

dictionaryType
	^'Dictionary'!

editArgumentDataAndValues: aCollection
	| result |
	result := aCollection.
	1 to: aCollection size
		do: [:each |
				result
					at: each
					put: ((self argumentDescriptionsAt: each)
							validate: (aCollection at: each)
							at: (each - self argumentDescriptions size + 1))].
	^result!

editNumberOfArguments: aCollection
	aCollection size <= self argumentDescriptions size
		ifTrue: [^aCollection].
	self argumentDescriptions last isNotRepeating
		ifTrue: [^self mergeNumberOfArgumentsError: aCollection].
	self argumentDescriptions last isRepeatingArgumentDescriptionGroup
		ifTrue: [^self editNumberOfRepeatingArguments: aCollection].
	^aCollection
!

editNumberOfRepeatingArguments: aCollection
	^((aCollection size - self argumentDescriptions size + 1) rem: (self argumentDescriptions last size)) = 0
		ifTrue: [aCollection]
		ifFalse: [self mergeNumberOfRepeatingArgumentsError: aCollection]




!

editRequiredArgument: anArgument at: anInteger
	^(anArgument isNil and:
		[(self argumentDescriptionsAt: anInteger) isRequiredArgumentAt: anInteger])
			ifTrue: [ArgumentMissingError argumentName:
							((self argumentDescriptionsAt: anInteger) argumentNameAt: anInteger)]
			ifFalse: [anArgument]!

editRequiredArguments: aCollection
| i |
	i := 0.
	^aCollection
		collect: [:each | self editRequiredArgument: each at: (i := i + 1)]!

explanation
	^'No Explanation Available'!

hiddenName
	^'Hidden'!

indexFor: anInteger
	| index |
	(anInteger <= self argumentDescriptions size)
		ifTrue: [^anInteger].
	(self argumentDescriptions last isNotRepeatingArgumentDescriptionGroup)
		ifTrue: [^self argumentDescriptions size].
	index := anInteger.
	[index > (self argumentDescriptions last size + self argumentDescriptions size - 1)]
		whileTrue: [index := (index - self argumentDescriptions last size)].
	^index!

initialize
	self allSubclasses do:
		[:each | each initializeArgumentDescriptions]!

journalType
	^'Journal'!

mergeInputArgumentsWithDefaults: aCollection
|return|
	return := self defaultArgumentsAsSize: aCollection size.
	1 to: aCollection size do:
		 [:each | (aCollection at: each) notNil
						ifTrue: [return at: each put: (aCollection at: each)]].
	^return!

mergeNumberOfArgumentsError: aCollection
	| maxArguments result |
	maxArguments := self argumentDescriptions size.
	result := aCollection.
	(maxArguments + 1) to: aCollection size
		do: [:each | 
				result 
					at: each 
					put: (ArgumentInvalidNumberOfError argument: (aCollection at: each) maxArguments: maxArguments)].
	^result!

mergeNumberOfRepeatingArgumentsError: aCollection
	| result |
	result := aCollection.
	^result 
		at: aCollection size 
		put: (ArgumentInvalidNumberOfError argumentName: (self argumentDescriptions last name) argument: aCollection last);
		yourself




!

numberOrDateOrStringType
	^'NumberOrDateOrString'!

numberOrStringType
	^'NumberOrString'!

numberType
	^'Number'!

postMergeValidation: aCollection 
	^self editRequiredArguments: aCollection!

preMergeValidation: aCollection
	| mergedCollection |
	mergedCollection := self editNumberOfArguments: aCollection.
	^self editArgumentDataAndValues: mergedCollection!

realSubclasses
	| result |
	result := self allSubclasses 
					reject: [:each | each userName = self userName or: 
								[each category first = self hiddenName]].
	result addAll: CalculatorBuilder userDefinedFunctions values.
	^result
!

returnType
#obsolete.
	^nil!

stringType
	^'String'!

template
	^self templatePerform: #template!

templateDescOn: aStream perform: aSymbol
| first |
	first := true.
	self argumentDescriptions do:
		[:each | first
						ifTrue: [first := false ]
						 ifFalse: [aStream nextPutAll: ', '].
					aStream nextPutAll: (each perform: aSymbol)]!

templateNameOn: aStream
	aStream
		nextPutAll: '@';
		nextPutAll: self userName;
		nextPutAll: '('!

templatePerform: aSymbol
|stream |
	stream := WriteStream on: String new.
	self templateNameOn: stream.
	self templateDescOn: stream perform: aSymbol.
	stream nextPutAll: ')'.
	^stream contents
	!

templateWithNames
	^self templatePerform: #templateWithName!

userName
	^self hiddenName!

validateInputArgumentsAtCompile: aCollection
	"This method controls the validation of the input arguments and the overlay of the default values."

	| mergedArguments | 
	self hasArgumentDescriptions ifFalse: [^aCollection].
	mergedArguments := self preMergeValidation: aCollection.
	mergedArguments := self mergeInputArgumentsWithDefaults: mergedArguments.
	mergedArguments := self postMergeValidation: mergedArguments.
	^mergedArguments!

validateInputArgumentsAtRuntime: aCollection
! !

!AtFunctionCalculator publicMethods !

argumentDescriptors
	^self class argumentDescriptions!

calculateIn: aContext
	^self calculateIn: aContext withArguments: nil!

editAmountCodePeriodJrnl: aJournal
	^((aJournal isAmountPeriodJournal) or: [aJournal isCodePeriodJournal])
		ifTrue:[OrderedCollection with: (ArgumentInvalidTypeError
							argumentName: 'Input journal'
							type: ''
							expectedType: 'Rate period journal')]
		ifFalse:[nil]!

editAmountRatePeriodJrnl: aJournal
	^((aJournal isAmountPeriodJournal) or: [aJournal isRatePeriodJournal])
		ifTrue:[OrderedCollection with: (ArgumentInvalidTypeError
							argumentName: 'Input journal'
							type: ''
							expectedType: 'Code period journal')]
		ifFalse:[nil]!

editCodePeriodJrnl: aJournal
	^(aJournal isCodePeriodJournal)
		ifTrue:[OrderedCollection with: (ArgumentInvalidTypeError
							argumentName: 'Input journal'
							type: ''
							expectedType: 'Rate or Amount period journal')]
		ifFalse:[nil]!

editCodeRatePeriodJrnl: aJournal
	^((aJournal isCodePeriodJournal) or: [aJournal isRatePeriodJournal])
		ifTrue:[OrderedCollection with: (ArgumentInvalidTypeError
							argumentName: 'Input journal'
							type: ''
							expectedType: 'Amount period journal')]
		ifFalse:[nil]!

editConflictingDupsOverlaps: aJournal
	^(aJournal hasConflictingOverlaps)
		ifTrue:[OrderedCollection with:(ArgumentHasInvalidError
			argumentName: 'Input journal'
			scenario: 'no duplicate or overlapping entries having different values')]
		ifFalse:[nil].!

editDifferentJrnl: aJournal1 Jrnl: aJournal2
	^(aJournal1 class = aJournal2 class)
		ifFalse:[OrderedCollection with: (ArgumentInvalidTypeError
							argumentName: 'Input journals'
							type:''
							expectedType: 'of same type')]
		ifTrue:[nil]!

editDuplicates: aJournal
	^(aJournal hasDuplicateEntries)
		ifTrue:[OrderedCollection with: (ArgumentHasInvalidError
							argumentName: 'Input journal'
							scenario: 'no duplicate entries')]
		ifFalse:[nil]!

editFromDateToDate: aCollection
	^(self fromDate: aCollection) > (self toDate: aCollection)
		ifTrue: [OrderedCollection with: 
					(ArgumentRelationshipError
						argumentName: self fromDateName
						argument: (self fromDate: aCollection)
						relatedArgumentName: self toDateName
						relatedArgument: (self toDate: aCollection)
						relationship: 'before')]
		ifFalse: [nil]!

editName
	^'@', self class userName!

editOverlaps: aJournal
	^(aJournal hasOverlappingEntries)
		ifTrue:[OrderedCollection with: (ArgumentHasInvalidError
							argumentName: 'Input journal'
							scenario: 'no overlapping entries')]
		ifFalse:[nil]!

editRatePeriodJrnl: aJournal
	^(aJournal isRatePeriodJournal)
		ifTrue:[OrderedCollection with: (ArgumentInvalidTypeError
							argumentName: 'Input journal'
							type: ''
							expectedType: 'Code or Amount period journal')]
		ifFalse:[nil]!

isRepeating
	^self argumentDescriptors size > 1
		and: [self argumentDescriptors last isRepeating]!

operator
	^self class userName!

precedence
	^0!

userName
	^self class userName!

visitFor: aVisitor
	^aVisitor visitAtFunction: self! !

AtFunctionCalculator initialize!

AtFunctionCalculator initializeAfterLoad!