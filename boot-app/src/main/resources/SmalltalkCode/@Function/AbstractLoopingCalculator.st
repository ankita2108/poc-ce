
AtFunctionCalculator subclass: #AbstractLoopingCalculator
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''!

!AbstractLoopingCalculator class publicMethods !

category
	^#('Looping Functions')! !

!AbstractLoopingCalculator publicMethods !

exceptionalResultClass
	^ExceptionalLoopingCalculatorResult!

isLoopCalculator
	^true!

loopCalculators
	^Set new add: self; yourself! !

AbstractLoopingCalculator initialize!

AbstractLoopingCalculator initializeAfterLoad!