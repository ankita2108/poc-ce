
JournalAbstractCalculator subclass: #JournalIntersectCalculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!JournalIntersectCalculator class publicMethods !

computeArgumentDescriptions
	| result |
	result := OrderedCollection new.
	result add: (ArgumentDescription
		name: 'target_journal'
		dataTypeBlock: self periodJournalBlock
		defaultValue: nil
		validValues:  nil
		explanation: 'The period journal containing the entries to be returned if they are reflected in both the target and masking Journals.'
		required: true).
	result add: (ArgumentDescription
		name: 'masking_journal'
		dataTypeBlock: self periodJournalBlock
		defaultValue: nil
		validValues:  nil
		explanation: 'The period journal containing the entries that will be compared to the target journal to determine any intersection.'
		required: true).
	result add: (ArgumentDescription
		name: 'proration_policy'
		dataTypeBlock: self stringBlock
		defaultValue: nil
		validValues:  HAProrationPolicyConstants keys asOrderedCollection
		explanation: 'The policy used to compute prorated amounts.'
		required: false).
	result add: (ArgumentDescription
		name: 'multiplier_decimals'
		dataTypeBlock: self numberBlock
		defaultValue: nil
		validValues:  #(1 2 3 4 5 6 7 8)
		explanation: 'The number of decimal places maintained in the proration multiplier (i.e., time in prorated result / time in entire entry).'
		required: false).
	result add: (ArgumentDescription
		name: 'result_decimals'
		dataTypeBlock: self numberBlock
		defaultValue: nil
		validValues:  #(1 2 3 4 5 6 7 8)
		explanation: 'The number of decimal places maintained in the prorated amount (i.e., original entry value * proration multiplier).'
		required: false).
	^result    !

explanation
	^'Returns a version of target_journal containing only those periods reflected in both target_journal and masking_journal. Note that both journals must be period based journals. If an entry must be split, proration is preformed based on proration_policy, multiplier_decimals and result_decimals.'
	!

userName
	^'JrnlIntersect'
	! !

!JournalIntersectCalculator publicMethods !

calculateIn: aContext withArguments: aCollection
	^(self targetJournal: aCollection in: aContext) intersect: (self maskingJournal: aCollection in: aContext)
		!

maskingJournal: aCollection in: aContext
	|maskJrnl|
	maskJrnl := (aCollection at: 2) copyNamedWithoutStorage prorationPolicy: (self maskingProrationPolicy: aCollection in: aContext).
	^(maskJrnl copyWithEntrys: (maskJrnl resolve: maskJrnl copyEntrys
		samePeriodBlock:[:current :next | (current isIntersecting: next)]))!

maskingProrationPolicy: aCollection in: aContext
	(aCollection at: 3) notNil
		ifTrue: [^self prorationPolicy: aCollection].
	^(aCollection at: 2) prorationPolicy isNil
		ifTrue: [aContext journalProrationPolicy]	
		ifFalse: [(aCollection at: 2) prorationPolicy]
	!

multiplierDecimals: aCollection
	^aCollection at: 4!

prorationPolicy: aCollection
	^(HAProrationPolicyConstants at: (aCollection at: 3))
		multiplierDecimals: (self multiplierDecimals: aCollection)
		resultDecimals: (self resultDecimals: aCollection) !

resultDecimals: aCollection
	^aCollection at: 5!

returnTypeBlock: aCollection
	^self class journalBlock!

targetJournal: aCollection in: aContext
	^(aCollection at: 1) copyNamedWithoutStorage prorationPolicy: (self targetProrationPolicy: aCollection in: aContext)!

targetProrationPolicy: aCollection in: aContext
	(aCollection at: 3) notNil
		ifTrue: [^self prorationPolicy: aCollection].
	^(aCollection at: 1) prorationPolicy isNil
		ifTrue: [aContext journalProrationPolicy]	
		ifFalse: [(aCollection at: 1) prorationPolicy]! !

JournalIntersectCalculator initialize!

JournalIntersectCalculator initializeAfterLoad!