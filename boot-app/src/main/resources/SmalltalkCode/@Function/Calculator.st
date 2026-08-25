
Object subclass: #Calculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!Calculator class publicMethods !

amountDateJournalBlock
	^AmountDateJournalType new!

amountJournalBlock
	^AmountJournalType new!

amountOrRatePeriodJournalBlock
	^AmountOrRatePeriodJournalType new!

amountPeriodJournalBlock
	^AmountPeriodJournalType new!

arguments: anOrderedCollection
	^self new initializeWithArguments: anOrderedCollection!

arguments: anOrderedCollection builder: aCalculationBuilder
	^self arguments: anOrderedCollection!

benefitPaymentBlock
	^BenefitPaymentDataType new!

booleanBlock	
	^BooleanType new!

buildFunctionToClassTranslationTable
| dictionary |
	dictionary := Dictionary new.
	AtFunctionCalculator allSubclasses do:
			[:each | 	dictionary at: each userName asUppercase put: each].
	^dictionary!

cashBalanceAccountBlock
	^CashBalanceAccountType new!

cashBalanceResultBlock
	^CashBalanceResultDataType new
	!

codeDateJournalBlock
	^CodeDateJournalType new!

codeJournalBlock
	^CodeJournalType new!

codePeriodJournalBlock
	^CodePeriodJournalType new!

dateBlock
	^DateType new!

dateJournalBlock
	^DateJournalType new!

dateOrNilBlock
	^DateOrNilType new!

dateOrStringBlock
	^DateOrStringType new!

dictionaryBlock
	^DictionaryType new!

eligDtResultBlock
	^EligDtResultDataType new!

endDateJournalBlock
	^EndDateJournalType new!

explanation
	^'No Explanation Available'!

frequencyJournalResultBlock
	^FrequencyJournalResultDataType new!

isCalculator
	^true!

jointSurvivorAnnuityBlock
	^JointSurvivorAnnuityDataType new!

journalBlock
	^JournalType new!

levelIncomeAnnuityBlock
	^LevelIncomeAnnuityDataType new!

lumpSumDistributionBlock
	^LumpSumDistributionDataType new!

nilBlock
	^NilType new!

noDataTypeBlock
	^NoDataType new!

numberBlock
	^NumberType new!

numberOrBooleanBlock
	^NumberOrBooleanType new!

numberOrDateBlock
	^NumberOrDateType new
!

numberOrDateOrStringBlock
	^NumberOrDateOrStringType new!

numberOrDateOrStringOrBooleanBlock
	^NumberOrDateOrStringOrBooleanType new!

numberOrJournalBlock
	^NumberOrJournalType new!

numberOrNilBlock
	^NumberOrNilType new!

numberOrPeriodJournalBlock
	^NumberOrPeriodJournalType new!

numberOrStringBlock
	^NumberOrStringType new!

numberOrStringOrNilBlock
	^NumberOrStringOrNilType new!

numberOrStringOrPeriodJournalBlock
	^NumberOrStringOrPeriodJournalType new!

periodBlock
	^PeriodType new!

periodJournalBlock
	^PeriodJournalType new!

planAttributeResultBlock
	^PlanAttributeResultDataType new!

rateDateJournalBlock	
	^RateDateJournalType new!

rateJournalBlock
	^RateJournalType new!

ratePeriodJournalBlock
	^RatePeriodJournalType new!

section415LimitResultBlock
	^Section415LimitType new!

serviceResultBlock
	^ServiceResultDataType new!

singleLifeAnnuityBlock
	^SingleLifeAnnuityDataType new!

socialSecurityResultBlock
	^SocialSecurityType new!

startDateJournalBlock
	^StartDateJournalType new!

stringBlock
	^StringType new!

symbolBlock
	^SymbolType new!

table1DBlock
	^Table1DType new!

table2DBlock
	^Table2DType new!

validBlock
	^self noDataTypeBlock! !

!Calculator publicMethods !

actuarialOptionFactorCalculators
	^#()!

asCodeString
	^self code!

calculateIn: aContext	
	self subclassResponsibility!

calculator
	^self!

calendarCalculators
	^#()!

calendarReferencedIn: aContext
	^aContext environment provisionAt:
		((self calendar: self inputArguments) valueIn: 
			aContext)!

code
	^PrintingCalculatorVisitor new
		visit: self;
		code!

complexity
	^1!

dateSearchCalculators
	^#()!

editName
	^self class name!

formattedCode
	^FormattedPrintingCalculatorVisitor new
		visit: self;
		code!

formattedCodeWorksheetName: aString
	^FormattedPrintingCalculatorVisitor new
		worksheetName: aString;
		visit: self;
		code!

hasDataAccessorArgument
	self inputArguments do: [:each | each isDataAccessor ifTrue: [^true]].
	^false!

inputArguments
	^OrderedCollection new!

isAlwaysCacheable
	^false!

isAndOr
	^false!

isCalculator
	^true!

isCalculatorWithArguments
	^false!

isConstant
	^false!

isOptimized
	^false!

isSpecialFormat
	^false!

loopCalculators
	^#()!

namedCalculators
	^(NamedCalculatorVisitor visit: self) calculators!

operator
	^self printString!

optimalCachingLevel: completionBlock
	^'TCR'!

pessimisticValueArguments: aContext
	^self valueArguments: aContext!

provisionReferencedIn: aContext
	^nil!

returnExHalt: anException
	"^(anException exception description 
			copyFrom: 2 to: 19) = 'ExCPMStackOverflow'
		ifTrue: [^'Error: Check for circular references']
		ifFalse: [anException handlesByDefault]"
	^anException exception!

roundedToDecimals: aNumber
	^self!

section415Calculators
	^#()!

socialSecurityCalculators
	^#()!

tableReferencedIn: aContext
	^aContext environment tableAt:
		((self table: self inputArguments) valueIn: 
			aContext)!

valueIn: aCalculationContext
	^self calculateIn: aCalculationContext!

valueIn: aContext when: anException return: anObject
	^[self valueIn: aContext]
		when: anException
		do: [:exception | ^anObject]!

visitFor: aVisitor
	"subclass responsibility"!

worksheetCalculators
	^#()!

wrapForEditing
	^WrappingCalculatorVisitor visit: self! !

Calculator initializeAfterLoad!