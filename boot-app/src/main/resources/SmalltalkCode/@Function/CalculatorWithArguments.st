
Calculator subclass: #CalculatorWithArguments
    classInstanceVariableNames: 'argumentDescriptions '
    instanceVariableNames: 'inputArguments '
    classVariableNames: ''
    poolDictionaries: ''!

!CalculatorWithArguments class publicMethods !

argumentDescriptionNameAt: anInteger
	^(self argumentDescriptionsAt: anInteger) name!

argumentDescriptions
	argumentDescriptions isNil
		ifTrue: [argumentDescriptions := self computeArgumentDescriptions].
	^argumentDescriptions!

argumentDescriptionsAt: anInteger
|repArg repPos position|
	(anInteger <= self argumentDescriptions size)
		ifTrue: [^self argumentDescriptions at: anInteger]
		ifFalse: [ repArg := self argumentDescriptions select: [:each | each isRepeating].
			   position := anInteger - self argumentDescriptions size.
			   repPos := position rem: repArg size.
			   (repPos = 0)
			   ifTrue: [repPos := repArg size ].
	^repArg at: repPos ]
 
!

computeArgumentDescriptions
	^OrderedCollection new!

defaultArguments
	| result |
	result := OrderedCollection new.
	self argumentDescriptions
		do: [ :each | result addAll: (each defaultValues)].
	^result!

defaultArgumentsAsSize: anInteger
	| result |
	result := self defaultArguments.
	result size >= anInteger ifTrue: [^result].
	result size + 1 to: anInteger do:
		[:each | result add: (result at: (self indexFor:each))].
	^result!

editArgument: anArgument at: anInteger
	self hasArgumentDescriptions ifFalse: [^anArgument].
	^(self argumentDescriptionsAt: anInteger)
		validate: anArgument
		at: (anInteger - self argumentDescriptions size + 1)!

editArguments: aCollection 
	self hasArgumentDescriptions ifFalse: [^aCollection].
	1 to: aCollection size do:
		[:each |
			aCollection 
				at: each
				put: ((self argumentDescriptionsAt: each)
						validate: (aCollection at: each)
						at: (each - self argumentDescriptions size + 1))].
	^aCollection!

hasArgumentDescriptions
	^self argumentDescriptions notEmpty!

initialize
	self allSubclasses do:
		[:each | each initializeArgumentDescriptions]!

initializeArgumentDescriptions
	argumentDescriptions := nil!

numberOfArguments
	^self argumentDescriptions size! !

!CalculatorWithArguments publicMethods !

argumentErrors: aCollection
	^aCollection select: [:each | each isExceptionOrHAError]!

calculateIn: aContext withArguments: aCollection
	^self subclassResponsibility!

calendarCalculators
	^self inputArguments 
		inject: Set new
		into: [:inj :each | each isCalendarCalculator ifTrue: [inj add: each]. inj]!

complexity
	^inputArguments
		inject: 1
		into: [:inj :each |inj + each complexity]!

dataTypeOfInputArgument: aCalculator
	| index |
	index := self inputArguments indexOf: aCalculator.
	^index > 0
		ifTrue: [self dataTypeOfInputArgumentAt: index]
		ifFalse: [nil]!

dataTypeOfInputArgumentAt: anInteger
	^(self class argumentDescriptionsAt: anInteger) dataTypeBlock!

dateSearchCalculators
	^self inputArguments 
		inject: Set new
		into: [:inj :each | each isDateSearchCalculator ifTrue: [inj add: each]. inj]!

defaultInputArguments
	^OrderedCollection new!

diagnoseErrorsFor: aResult withArguments: aCollection in: aContext
	| relationalErrors errors editedArguments |
	editedArguments := self class editArguments: aCollection.
	aResult isExceptionOrHAError 
		ifFalse: [^self invalidResultException: aResult withArguments: editedArguments].
	(self hasValidIndividualArguments: editedArguments)
		ifFalse: [^aResult copy errors: (self argumentErrors: editedArguments) calculator: self].
	(relationalErrors := (self relationalErrors: editedArguments in: aContext)) isNil
		ifFalse: [^aResult copy errors: relationalErrors calculator: self].
	^aResult!

exceptionalResultClass
	self subclassResponsibility!

hasCalcModuleReference: anEnvironment 
	self inputArguments do: [:each | (each hasCalcModuleReference: anEnvironment) ifTrue: [^true]].
	^false!

hasDateSearchReference: anEnvironment with: aWorksheet
	self inputArguments do: [:each | (each hasDateSearchReference: anEnvironment with: aWorksheet) ifTrue: [^true]].
	^false!

hasValidIndividualArguments: aCollection
	aCollection detect: [:each | each isExceptionOrHAError and: [each isFatal]] ifNone: [^true].
	^false!

indexOfArgumentNamed: aString
	self argumentDescriptors 
		inject: 1
		into: [:inj :each | 
					each name asUppercase = aString asUppercase 
						ifTrue: [^inj]. 
					inj + 1].
	^0 !

initializeWithArguments: anOrderedCollection
	self inputArguments: anOrderedCollection!

inputArgumentNamed: aString
	^self inputArguments at: (self indexOfArgumentNamed: aString)!

inputArguments
	inputArguments isNil
		ifTrue: [inputArguments := self defaultInputArguments].
	^inputArguments	!

inputArguments: aCollection
	inputArguments := aCollection!

invalidResultError: aResult withArguments: arguments
	^ResultInvalidTypeError 
		calculator: self 
		result: aResult 
		expectedType: (self returnType: arguments)
!

invalidResultException: aResult withArguments: arguments
	^self exceptionalResultClass 
		value: aResult 
		error: (self invalidResultError: aResult withArguments: arguments)	
		calculator: self
!

isReturnTypeCorrect: anObject withArguments: arguments	  
	^(self returnTypeBlock: arguments) value: anObject !

loopCalculators
	^self inputArguments 
		inject: Set new
		into: [:inj :each | each isLoopCalculator ifTrue: [inj add: each]. inj]!

lowestCachingLevel: levels
	(levels includes: '???')
		ifTrue: [^'???'].
	(levels includes: 'BCCR')
		ifTrue: [^'BCCR'].
	(levels includes: 'PCR')
		ifTrue: [^'PCR'].
	(levels includes: 'TCR')
		ifTrue: [^'TCR']!

optimalCachingLevel: completionBlock
	| arguments |
	arguments := self inputArguments select: [:each | each isCalculator].
	^self findOptimalLevelFor: arguments completionBlock: completionBlock!

pessimisticValueArguments: aContext
	^self class editArguments: (self pessimisticValueInputArgumentsIn: aContext)!

pessimisticValueIn: aContext   
	| valueArguments relationalErrors result |  
	valueArguments := self pessimisticValueArguments: aContext.
	(self hasValidIndividualArguments: valueArguments) 
		ifFalse: [^self exceptionalResultClass errors: (self argumentErrors: valueArguments) calculator: self].
	(relationalErrors := self relationalErrors: valueArguments in: aContext) isNil
		ifFalse: [^self exceptionalResultClass errors: relationalErrors calculator: self].
	result := self calculateIn: aContext withArguments: valueArguments.
	^self verifyResult: result withArguments: valueArguments 


	!

pessimisticValueInputArgumentsIn: aContext
	^self inputArguments collect: [:each | each pessimisticValueIn: aContext]!

relationalEditValueIn: aContext  
	| valueArguments relationalErrors result |
	valueArguments := self valueArguments: aContext.
	[(relationalErrors := self relationalErrors: valueArguments in: aContext) isNil
		ifFalse: [^self exceptionalResultClass errors: relationalErrors calculator: self].
	result := self calculateIn: aContext withArguments: valueArguments]
		whenExceptionDo: [^self verifyResult: self exceptionalResultClass new withArguments: valueArguments in: aContext].
	^self verifyResult: result withArguments: valueArguments in: aContext


	!

relationalErrors: aCollection
	^nil  !

relationalErrors: aCollection in: aContext
	^self relationalErrors: aCollection  !

removeWarnings
	inputArguments := self inputArguments
									reject: [:each |each removeWarnings.
														each isExceptionOrHAError]!

returnType: aCollection
	^(self returnTypeBlock: aCollection) dataType!

section415Calculators
	^self inputArguments 
		inject: Set new
		into: [:inj :each | each isSection415Calculator ifTrue: [inj add: each]. inj]!

socialSecurityCalculators
	^self inputArguments 
		inject: Set new
		into: [:inj :each | each isSocialSecurityProvisionCalculator ifTrue: [inj add: each]. inj]!

valueArguments: aContext 
	^self valueInputArgumentsIn: aContext!

valueIn: aContext  
	| valueArguments result |    
	valueArguments := self valueArguments: aContext.   
	[result := self calculateIn: aContext withArguments: valueArguments]
			whenExceptionDo: [^self verifyResult: self exceptionalResultClass new withArguments: valueArguments in: aContext].
	^self verifyResult: result withArguments: valueArguments in: aContext


	!

valueInputArgumentsIn: aContext
	^self inputArguments asArray collect: [:each | each valueIn: aContext]!

verifyResult: aResult
	^aResult isHAError	
		ifTrue: [self exceptionalResultClass error: aResult calculator: self]
		ifFalse: [aResult]
!

verifyResult: aResult withArguments: arguments	
	^((self isReturnTypeCorrect: aResult withArguments: arguments) or: [aResult isException])
		ifTrue: [aResult]
		ifFalse: [	self invalidResultException: aResult withArguments: arguments]
	!

verifyResult: aResult withArguments: arguments in: aContext	
	^(aResult isException not and: [self isReturnTypeCorrect: aResult withArguments: arguments])
		ifTrue: [aResult ]
		ifFalse: [self diagnoseErrorsFor: aResult withArguments: arguments in: aContext]




	!

worksheetCalculators
	^self inputArguments 
		inject: Set new
		into: [:inj :each | each isWorksheetCalculator ifTrue: [inj add: each]. inj]! !

CalculatorWithArguments initialize!

CalculatorWithArguments initializeAfterLoad!