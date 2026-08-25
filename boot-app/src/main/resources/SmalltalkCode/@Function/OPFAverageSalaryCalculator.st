
AbstractLoopingCalculator subclass: #OPFAverageSalaryCalculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!OPFAverageSalaryCalculator class publicMethods !

computeArgumentDescriptions
	| result |
	result := OrderedCollection new.
	result add: (ArgumentDescription
			name: 'Journal'
			dataTypeBlock: self journalBlock
			defaultValue: nil
			validValues: nil
			explanation: 'Journal to be used.'
			repeating: false
			required: true).		
	result add: (ArgumentDescription
		name: 'Years Of Earning'
		dataTypeBlock: self numberBlock
		defaultValue: nil
		validValues:  nil
		explanation: 'Years of earning (3 or 5) based on which highest average annual salary will be determined.'
		repeating: false
		required: true).
	^result!

explanation
	^'Find the highest possible average annual salary based on a member’s earnings history by examining all possible combinations of three or five 12-month non-overlapping periods of earnings to determine the largest sum.'!

returnType
	^self journalType!

userName
	^'AverageAnnualSalary'! !

!OPFAverageSalaryCalculator publicMethods !

calculateAnnualSum: aCollection
| total collSize journalColl annulaPay annulaPaySize k startDt endDt topKAnnulaPay top5NonOverlappingAnnualPay months isContinous temp |

collSize := ( ( aCollection at:1) size ).
months := ( ( aCollection at:2) * 12 ) + 40.
topKAnnulaPay := OrderedCollection new.
journalColl := ( self journal: aCollection ) entrys.
annulaPay := AmountPeriodJournal clean.

( 1 to: ( collSize - 11 ) )
  do: [ :index | 	total := 0. temp := 1.
	startDt :=  ( journalColl at: index ) fromDate.
	k := index.
	isContinous := true.
  	 ( index to: ( k + 11 ) )
		do: [ :index2 | total := ( total + ( journalColl at: index2 ) value ).
			endDt := ( journalColl at: index2 ) toDate.
			( ( index2 > 1) and: [ temp > 1 ] )
			ifTrue:[ ( ( ( journalColl at: index2 ) fromDate ) =  ( ( (  journalColl at: ( index2 -1 ) ) toDate ) addDays: 1 ) ) 
						ifFalse:[  ( ( ( journalColl at: index2 ) fromDate ) =  ( (  journalColl at: ( index2 -1 ) ) toDate ) )
									ifFalse:[ isContinous := false ] ]
				].
				temp := temp + 1 ].	
	isContinous ifTrue: [ annulaPay addValue: total at: (startDt to: endDt) ].
	].
	
annulaPaySize := ( annulaPay entrys size ).
( annulaPaySize < months ) ifTrue:[ months := annulaPaySize ].

 topKAnnulaPay := ( ( ( annulaPay entrys asOrderedCollection) sort: [ :a :b | ( a value ) > ( b value ) ] ) first: months ) sort.
 
top5NonOverlappingAnnualPay := self topKNonOverlappingAnnualSum: topKAnnulaPay  years: ( aCollection at:2).

^top5NonOverlappingAnnualPay

		
!

calculateIn: aContext withArguments: aCollection
| annulaSum |
annulaSum := self calculateAnnualSum: aCollection.
^annulaSum
	
!

dummyCollection

|dict jrnl1 jrnl2 |
dict := Dictionary new.
jrnl1 :=  AmountPeriodJournal clean
	 							addValue: 1 at: ('01-01-1995' asDate to: '12-01-1995' asDate);
	 							addValue: 2 at: ('12-01-1995' asDate to: '01-01-1997' asDate);
	 							addValue: 3 at: ('01-01-1997' asDate to: '01-01-2000' asDate);
								yourself.

jrnl2 := AmountPeriodJournal clean
	 							addValue: 5 at: ('01-01-1995' asDate to: '12-01-1995' asDate);
	 							addValue: 5 at: ('12-01-1995' asDate to: '01-01-1997' asDate);
	 							addValue: 5 at: ('01-01-1997' asDate to: '01-01-2000' asDate);
								yourself.
dict 	at: 'EMClientId1' put: jrnl1;
		at: 'EMClientId2' put: jrnl2.
^dict!

journal: aCollection
	^aCollection first  	!

relationalErrors: aCollection	
	|result errors|
	result := OrderedCollection new.
	errors := self editCodeRatePeriodJrnl: (aCollection at:1).
	errors notNil ifTrue:[ errors do:[:each| result add: each]].
	result isEmpty ifTrue:[^nil].
	^result!

returnTypeBlock: aCollection
	^self class amountPeriodJournalBlock!

topKNonOverlappingAnnualSum: intervals years: k

| sorted n p dp take bestSum selected i j topKNonOverlappingAnnualPay |

topKNonOverlappingAnnualPay := AmountPeriodJournal clean.

"Sort intervals by end date"
sorted := intervals asSortedCollection: [:a :b | a toDate < b toDate].
n := sorted size.

"Compute p[i]: index of last interval whose end <= current start (strict non-overlap)"
p := Array new: n.
1 to: n do: [:idx |
	| currentStart pos |
	currentStart := (sorted at: idx) fromDate.
	pos := 0.
	1 to: idx - 1 do: [:jdx |
		((sorted at: jdx) toDate <= currentStart)
			ifTrue: [ pos := jdx ]  "keep the latest compatible"
	].
	p at: idx put: pos
].

"Initialize DP tables (size n x k)"
dp := Array new: n.
take := Array new: n.
1 to: n do: [:idx |
	dp at: idx put: (Array new: k withAll: 0).
	take at: idx put: (Array new: k withAll: false)
].

"Fill DP: dp[idx][kk] = max(dp[idx-1][kk], value[idx] + dp[p[idx]][kk-1])"
1 to: n do: [:idx |
	1 to: k do: [:kk |
		| skip prevBest takeVal |
		skip := (idx > 1) ifTrue: [ (dp at: idx - 1) at: kk ] ifFalse: [ 0 ].

		"Base case when kk = 1: you can only take the current interval"
		prevBest := (kk = 1)
			ifTrue: [ 0 ]
			ifFalse: [ (p at: idx) > 0
						  ifTrue: [ (dp at: (p at: idx)) at: kk - 1 ]
						  ifFalse: [ 0 ] ].

		takeVal := prevBest + (sorted at: idx) value.

		(takeVal > skip)
			ifTrue: [
				((dp at: idx) at: kk put: takeVal).
				((take at: idx) at: kk put: true)
			]
			ifFalse: [
				((dp at: idx) at: kk put: skip).
				((take at: idx) at: kk put: false)
			]
	]
].

"Reconstruct solution by following the 'take' table"
bestSum := ((dp at: n) at: k).
selected := OrderedCollection new.
i := n.
j := k.
[i > 0 and: [j > 0]] whileTrue: [
	((take at: i) at: j)
		ifTrue: [
			selected addFirst: (sorted at: i).
			i := (p at: i).
			j := j - 1
		]
		ifFalse: [ i := i - 1 ]
].

"Add selected entries to AmountPeriodJournal"
	selected do: [:entry |
		topKNonOverlappingAnnualPay addValue: entry value at: (entry fromDate to: entry toDate)].
		
^ topKNonOverlappingAnnualPay
!

valueIn: aContext 
	^self relationalEditValueIn: aContext
	! !

OPFAverageSalaryCalculator initialize!

OPFAverageSalaryCalculator initializeAfterLoad!