
nil subclass: #Object
    classInstanceVariableNames: ''
    instanceVariableNames: ''
    classVariableNames: 'Dependents '
    poolDictionaries: 'SystemPrimitiveErrors SystemExceptions '!

!Object class publicMethods !

abtCanBeBoolean
	"Answer true if the receiver can become an object which
	responds to the protocol of Boolean

	See: #abtAsBoolean"

	^false!

abtCanBeCharacter
	"Answer true if the receiver can become an object which
	responds to the protocol of Character.

	See: #abtAsCharacter"

	^false!

abtCanBeDate
	"Answer true if the receiver can become an object which
	responds to the protocol of Date.

	See: #abtAsDate"

	^false!

abtCanBeDateAndTime
	"Answer true if the receiver can become an object which
	responds to the protocol of DateAndTime.

	See: #abtAsDateAndTime"

	^false!

abtCanBeDBString
	"Answer true if the receiver can become an object which
	responds to the protocol of a double-byte string.

	See: #abtAsDBString"

	^false!

abtCanBeEsString
	"Answer true if the receiver can become an object which
	responds to the protocol of EsString.

	See: #abtAsEsString"

	^false!

abtCanBeMonetaryAmount
	"Answer true if the receiver can become an object which
	responds to the protocol of AbtMonetaryAmount

	See: #abtAsMonetaryAmount"

	^false!

abtCanBeNumber
	"Answer true if the receiver can become an object which
	responds to the protocol of Numbers

	See: #abtAsNumber"

	^false!

abtCanBeSBString
	"Answer true if the receiver can become an object which
	responds to the protocol of a single-byte string.

	See: #abtAsSBString"

	^false!

abtCanBeTime
	"Answer true if the receiver can become an object which
	responds to the protocol of Time.

	See: #abtAsTime"

	^false!

abtCanBeTimestamp
	"Answer true if the receiver can become an object which
	responds to the protocol of AbtTimestamp.

	See: #abtAsTimestamp"

	^false!

abtMergedInterfaceBuilderFor: aPartBuilder

	^self abtMergedInterfaceBuilder.!

isCalculator
	^false!

newPart

	^(self abtIsObservableObjectClass
		ifTrue: [AbtObservableObjectPartWrapper new]
		ifFalse: [AbtPartWrapper new]) contents: self new!

remoteObjectFrom: aStream
	"Convert the contents of @aStream into an instance of the current class."

	| remoteObjectID remoteObject |
	remoteObjectID := aStream nextFourAsInteger.
	"Check if the object as not already been imported. If yes, answer the old object
	 otherwise, store it in the table and answer the new object."
	[
		remoteObject := 
			aStream importedObjectTable
				at: remoteObjectID
				ifAbsentPut: [
					self remoteObjectClass new
						remoteObjectID: remoteObjectID;
						yourself]
	] critical. "Critical in case another process is importing the same object at the same time."

	^remoteObject!

system
	^GlobalConfiguration default! !

!Object class privateMethods !

_PRAGMA_IS_Object
	"%%PRAGMA DECLARE
	(name: IS_Object isPool: true isConstant: false)
	(pool: IS_Object declarations: (
		(name: CIS_allInstVarNames isConstant: false)
		(name: CIS_displayName isConstant: false)
		(name: CIS_instanceInterfaceSpec isConstant: false)
	))"!

abePrimaryPartClass

	^self!

abeReferencesClass: aClass
	"Trying to find whether we have circular app builder references"

	^self = aClass!

abeReinitializeDependents

	Dependents := IdentityDictionary new.
!

abtAddDefaultViewForAttributeNamed: attributeName
	builderSet: aLoadedBuilderSet
	connectionOperations: aSetOfConnectionOperations
	at: aPoint

	^nil!

abtAddDefaultViewForAttributeNamed: attributeName
	label: aString
	builderSet: aLoadedBuilderSet
	connectionOperations: aSetOfConnectionOperations
	at: aPoint

	^nil!

abtAddPromptedTextViewForAttributeNamed: attributeName
	builderSet: aLoadedBuilderSet
	connectionOperations: aSetOfConnectionOperations
	at: aPoint
	
	^self abtAddPromptedTextViewForAttributeNamed: attributeName
		label: attributeName
		builderSet: aLoadedBuilderSet
		connectionOperations: aSetOfConnectionOperations
		at: aPoint
!

abtAddPromptedTextViewForAttributeNamed: attributeName
	label: aString
	builderSet: aLoadedBuilderSet
	connectionOperations: aSetOfConnectionOperations
	at: aPoint

	| labelPartBuilder labelSize textPartBuilder textSize |

	labelPartBuilder := AbtLabelView newSubpartBuilder
		attributeSettingNamed: #object put: aString;
		attributeSettingNamed: #alignment put: AbtLabelView defaultQuickFormLabelAlignment.
	labelSize := AbtLabelView defaultQuickFormLabelSize.

	textPartBuilder := AbtTextView newSubpartBuilder
		attributeSettingNamed: #converter 
			put: (self untitledConverterClass newTopLevelPartBuilder).
	textSize := AbtTextView defaultEditSize.

	aLoadedBuilderSet
		builderNamed: (attributeName, 'Label')
			put: labelPartBuilder
			boundingBox: (aPoint extent: labelSize)
			useExtent: true;
		builderNamed: (attributeName, 'Field')
			put: textPartBuilder
			boundingBox: ((aPoint + ((labelSize x + 5) @ 0)) extent: textSize).

	aSetOfConnectionOperations
		add: ((AbtAddConnectionOperation 
				new: AbtAttributeToAttributeConnectionBuilder)
			sourceConnectionItemName: attributeName;
			targetBuilder: textPartBuilder;
			targetConnectionItemName: #object).

	^((labelSize x + textSize x + 5) @ (labelSize y max: textSize y))

!

abtAddPromptedTextViewForAttributeNamed: attributeName
	label: aString
	builderSet: aLoadedBuilderSet
	connectionOperations: aSetOfConnectionOperations
	at: aPoint
	forBuilder: aBuilder

	| labelPartBuilder labelSize textPartBuilder textSize |

	labelPartBuilder := AbtLabelView newSubpartBuilder
		attributeSettingNamed: #object put: aString;
		attributeSettingNamed: #alignment put: AbtLabelView defaultQuickFormLabelAlignment.
	labelSize := AbtLabelView defaultQuickFormLabelSize.

	textPartBuilder := AbtTextView newSubpartBuilder
		attributeSettingNamed: #converter 
			put: (self untitledConverterClass newTopLevelPartBuilder).
	textSize := AbtTextView defaultEditSize.

	aLoadedBuilderSet
		builderNamed: (attributeName, 'Label')
			put: labelPartBuilder
			boundingBox: (aPoint extent: labelSize)
			useExtent: true;
		builderNamed: (attributeName, 'Field')
			put: textPartBuilder
			boundingBox: ((aPoint + ((labelSize x + 5) @ 0)) extent: textSize).

	aSetOfConnectionOperations
		add: ((AbtAddConnectionOperation 
				new: AbtAttributeToAttributeConnectionBuilder)
			sourceBuilder: aBuilder;
			sourceConnectionItemName: attributeName;
			targetBuilder: textPartBuilder;
			targetConnectionItemName: #object).

	^((labelSize x + textSize x + 5) @ (labelSize y max: textSize y))

!

abtArchiveApplication

	^(self
		abtGetObject: self abtArchiveApplicationKey
		ifAbsent: [^nil]) asSymbol asClass!

abtArchiveApplication: anApp

	^self abtStoreObject: anApp name
		inApplication: self controller
		as: self abtArchiveApplicationKey
		mustBeOpenEdition: false!

abtArchiveApplicationKey

	^'AbtArchiveApplication'!

abtBasicRelocalize
	"This implementation handles relocalization of a RUNTIME IC-Based image."

	AbtNlsKernelApp abtNlsLog: 'Object class>>#abtBasicRelocalize'.
	AbtNLSCoordinator abtIcRuntimeRelocalize!

abtBrowse
		"Edit the part defined by the class."

	"Note: This method should return the view so it can be resurfaced by the Organizer."

	^self abtBrowseIn: nil!

abtBrowseIn: anApplication
		"Edit the part defined by the class."

	"Note: This method should return the view so it can be resurfaced by the Organizer."

	| op |

	op := self abtPartUpdateOperation
			classIsNew: false;
			yourself.
	anApplication == nil
		ifFalse: [op contextApplication: anApplication].

	^System showBusyCursorWhile:
		[self abtBrowseOperation: op]!

abtBrowseOperation: aClassUpdateOperation
		"Edit the part defined by the class."

	| rect |

	AbtNonVisualEditorSwitcher registeredViews size = 0
		ifTrue: [^aClassUpdateOperation target browse].

	rect := self abtDesiredWindowRect.
	^((AbtNonVisualEditorSwitcher new)
		x: (rect left); y: (rect top);
		width: (rect right - (rect left));
		height: (rect bottom - (rect top));
		classUpdate: aClassUpdateOperation;
		openWidget)
!

abtDefaultDatabaseErrorBlock
	"
		Answer a block that is to be used for error conditions in headless database applications (server apps).

		Database error block requirements:
			1. It must accept a single argument, which will be an instance of AbtError.
			2. There may be NO returns from the block.
			3. The final result of evaluating the block *MUST* be an instance of AbtError.
				The simplest possible legal error block, [ : error | error ], would simply
				answer back the error argument presented to it.  More useful error blocks,
				however, will do some additional work before answering back the 
				error instance.

		"

	^[	:error | 
		AbtPrimitiveLoggingSupport logError: error errorText. 
		error
		].!

abtDesiredMonitorArea

	^DPIScaler activeDisplayArea!

abtDesiredMonitorCenter: extent

	^DPIScaler activeDisplayPositionToCenter: extent
!

abtDesiredMonitorPos: extent

	(self respondsTo: #osDesiredMonitorPos:) ifTrue: [
		^self osDesiredMonitorPos: extent ].

	^((CgScreen default autoScaleExtent - extent) // 2)
!

abtDesiredWindowRect
	^DPIScaler 
		scaleRectangle: DPIScaler activeDisplayArea extent
		extentTransformer: [:extent | extent * 8 // 10]
		originTransformer: [:point | DPIScaler activeDisplayArea extent // 10]!

abtInImageRestore

	^AbtCwBaseAdditionsApp abtInImageRestore!

abtInstanceBackgroundGraphicsDescriptor
		"Answer a new graphicsDescriptor with its moduleName and id
		filled in to be used as the receiver's background graphic"
		"tdt (09-11-92) new"

	^(AbtBitmapDescriptor new
		moduleName: self abtGraphicsModuleName;
		id: 409)!

abtInstanceGraphicsDescriptor
		"Return the descriptor for the icon representing the class"

	^(AbtIconDescriptor new
			moduleName: self abtGraphicsModuleName;
			id: 207)!

abtIsomorphicClasses

	^nil!

abtIsSuitableViewPrimaryPartClass

	^false!

abtIsTestable

	^false!

abtMainWindowWidgetClass
	" Answer the common widget class to be used for the frame view.   "

	^CwMainWindow!

abtMorphMapAt: aClassRef

	^(Dictionary new
		at: aClassRef 
			put: ((AbtIsomorphicClassMap new)
				classMappingsAt: self symbol put: aClassRef;
				featureMapAt: self symbol
					put: (AbtIsomorphicFeatureMap new);
				yourself);
		yourself) at: aClassRef ifAbsent: []
!

abtSettingsViewHelpFile
		"Return the help file name which contains the help text for
		the settings view of this class of part."
	
	^nil!

abtSettingsViewHelpTopicId
		"Return the help topic id which refers to the help text for
		the settings view of this class of part."
	
	^nil!

abtTranslateString: aString fromCodePage: aSourceCodePage toCodePage: aTargetCodePage
	" Answer nil.  This method is overridden by class AbtCharacterTranslator.  Usage of the VA code page 
	  translation routine is only possible when application AbtNlsCfsSupportApp is loaded.  
	  This method is invoked after an attempt to use the OS code page conversion routine fails.  "

	^nil!

calculateClassInterfaceSpec
	" Object class reinitializeInterfaceSpecFromMethod "

	^AbtInterfaceSpec new!

calculateInterfaceSpec

	^self abtDefaultInterfaceSpec!

CIS_allInstVarNames
	"Private - ** Warning ** This method is generated by VisualAge and should not
	be modified or deleted. This method is responsible for returning a featureSpec
	that describes the implementation of a particular feature of the receiver"

	^IS_Object::CIS_allInstVarNames notNil
		ifTrue: [IS_Object::CIS_allInstVarNames]
		ifFalse: [
		IS_Object::CIS_allInstVarNames := (AbtAttributeSpec new
			getSelector: #allInstVarNames;
			attributeType: Array)]!

CIS_displayName
	"Private - ** Warning ** This method is generated by VisualAge and should not
	be modified or deleted. This method is responsible for returning a featureSpec
	that describes the implementation of a particular feature of the receiver"

	^IS_Object::CIS_displayName notNil
		ifTrue: [IS_Object::CIS_displayName]
		ifFalse: [
		IS_Object::CIS_displayName := (AbtAttributeSpec new
			getSelector: #displayName;
			attributeType: Array)]!

CIS_instanceInterfaceSpec
	"Private - ** Warning ** This method is generated by VisualAge and should not
	be modified or deleted. This method is responsible for returning a featureSpec
	that describes the implementation of a particular feature of the receiver"

	^IS_Object::CIS_instanceInterfaceSpec notNil
		ifTrue: [IS_Object::CIS_instanceInterfaceSpec]
		ifFalse: [
		IS_Object::CIS_instanceInterfaceSpec := AbtInterfaceSpec new
		featureNamed: #displayName put: self CIS_displayName;
		featureNamed: #allInstVarNames put: self CIS_allInstVarNames]!

createClass: aClassSymbol forSuperclass: aSuperclassSymbol

	| theSuperclass theClass aClass subclassType oldDefault selValidator |

	((aSuperclassSymbol == nil) or: [aSuperclassSymbol isEmpty])
		ifTrue: [^AbtError new errorText: (self getMRI: AbtMsgAbe::MsgAbeUBInvalidSuperclassName group: #AbtMsgAbe)].
	theSuperclass := Smalltalk classAt: aSuperclassSymbol asSymbol.
	(theSuperclass == nil) 
		ifTrue:
			[^AbtError new
				errorText: (self getMRI: AbtMsgAbe::MsgAbeUBClassDoesNotExist group: #AbtMsgAbe);
				errorTextReplace: (Array with: aSuperclassSymbol asSymbol)].

	((aClassSymbol == nil) or: [aClassSymbol isEmpty])
		ifTrue: [^AbtError new errorText: (self getMRI: AbtMsgAbe::MsgAbeUBInvalidClassName group: #AbtMsgAbe)].
	aClass := aClassSymbol trimBlanks.
	((selValidator := AbtSelectorValidator new) isIdentifier: (ReadStream on: aClass))
		ifFalse:
			[^AbtError new
				errorText: (self getMRI: AbtMsgAbe::MsgAbeUBInvalidClassNameIdentifier group: #AbtMsgAbe);
				errorTextReplace: (Array with: aClass printString
					with: selValidator errorText
					with: selValidator errorPosition printString)].

	aClass := aClass abtAsProperName.
	theClass := Smalltalk classAt: aClass.
	(theClass == nil) 
		ifFalse: 
			[^AbtError new
				errorText: (self getMRI: AbtMsgAbe::MsgAbeUBClassAlreadyExists group: #AbtMsgAbe);
				errorTextReplace: (Array with: aClass printString)].

	subclassType := theSuperclass isFixed
		ifTrue: [#pointer]
		ifFalse: [theSuperclass isPointers
			ifTrue: [#indexed]
			ifFalse: [#byte]].

	(subclassType == nil) 
		ifTrue: [^AbtError new errorText: (self getMRI: AbtMsgAbe::MsgAbeUBInvalidClassType group: #AbtMsgAbe)].

	System showBusyCursorWhile:
		[(subclassType == #pointer) 
			ifTrue: 
				[theClass := theSuperclass subclass: aClass
					instanceVariableNames: ''
					classVariableNames: ''
					poolDictionaries: ''].
		(subclassType == #indexed) 
			ifTrue: 
				[theClass := theSuperclass variableSubclass: aClass
					instanceVariableNames: ''
					classVariableNames: ''
					poolDictionaries: ''].
		(subclassType == #byte) 
			ifTrue: 
				[theClass := theSuperclass variableByteSubclass: aClass
					classVariableNames: ''
					poolDictionaries: '']].

	(theClass == nil) 
		ifTrue: [^AbtError new errorText: (self getMRI: AbtMsgAbe::MsgAbeUBClassNotCreated group: #AbtMsgAbe)].

	^theClass!

customSettingsOperation

	^AbtDeferredUpdateOperation new!

customSettingsOperationInParentPartClass: parentClass

	^self customSettingsOperation!

debugConnectionSpecFromStackFrame: aStackFrame directedMessage: aDirectedMessage
	"aStackFrame is a stack frame for a method of the receiver's class
	(abrSend or abrSendWithArguments). This method will return
	a debugConnectionSpec with the sourcePartName, sourcePartClass
	and sourcePrimitiveFeatureName filled out"

	^nil!

defaultEditSize

	^200@100!

deferredUpdateOperationClass

	^AbtDeferredUpdateOperation!

execLongDatabaseOperation: aBlock
	"Execute the specified block aBlock as a single unit for this process, blocking
		any other process until completion.  Show the busy cursor while processing.
		IMPORTANT - Ensure that there are no returns from the supplied block aBlock."

	^aBlock value
!

execShortDatabaseOperation: aBlock
	"Execute the specified block aBlock.  This method will only be invoked in headless images
	  where it is not necessary to serialize database calls "

	^aBlock value
!

initializeAfterLoad
	"Initialize the dependents dictionary."
		
	Dependents isNil ifTrue: [
		Dependents := IdentityDictionary new]!

isAppBldrView

	^false!

newSubpartBuilder
		"Return a new partBuilder object for including the part as a subpart."

	^self subpartBuilderClass new partClass: self!

newTopLevelPartBuilder
		"Return a new partBuilder object for including the part as a subpart."

	^self topLevelPartBuilderClass new partClass: self!

newUnattachedPart

	^self newPart!

newVariableBuilder
		"Return a new partBuilder object for including the part as a variable."

	^AbtVariableBuilder new partClass: self!

noSuchAction: actionName

	^self error: ((self getMRIString: AbtVaMsgBase::MsgBaseNoSuchAction group: #AbtVaMsgBase)
			replace: actionName printString)
!

noSuchAttribute: attributeName

	^self error: ((self getMRIString: AbtVaMsgBase::MsgBaseNoSuchAttribute group: #AbtVaMsgBase)
			replace: attributeName printString)
!

noSuchEvent: eventName

	^self error: ((self getMRIString: AbtVaMsgBase::MsgBaseNoSuchEvent group: #AbtVaMsgBase)
			replace: eventName printString)
!

noSuchFeature: featureName

	^self error: ((self getMRIString: AbtVaMsgBase::MsgBaseNoSuchFeature group: #AbtVaMsgBase)
			replace: featureName printString)
!

numberOfPtrs
	"Do not use K8ObjectHeader instSize here since it the class
	 does not currently get packaged."

	^(System is64BitVM ifTrue: [2] ifFalse:[3]) + self instSize!

preferredConnectionFeatures

	^#()!

recursiveDeferredUpdateOperationClass
	" The default update operation class for instances of this class"

	^AbtDeferredUpdateOperation!

remoteObjectClass

	^EsRemoteObject!

subpartBuilderClass
		"Return the default class used as the part builder for the receiver."

	^AbtExternalSubpartBuilder!

topLevelPartBuilderClass

	^AbtTopLevelPartBuilder! !

!Object publicMethods !

-> anObject

	"Answer an Association with the receiver as its key
	 and @anObject as its value."

	^Association key: self value: anObject!

= anObject

	"Answer a Boolean which is true when the receiver and
	 the argument anObject are equivalent, and false
	 otherwise. Subclasses may redefine = to alter the
	 meaning of equivalence. Equivalence implies that two
	 objects are similar in form and content. Objects that
	 are equivalent must answer the same value for the
	 message #hash."

	<primitive: VMprObjectEqualEqual>
	^self primitiveFailed!

== anObject

	"Answer a Boolean which is true when the receiver and
	 the argument anObject represent the identical object,
	 and false otherwise.

	 Do not redefine the message == in any other class!!"

	<primitive: VMprObjectEqualEqual>
	^self primitiveFailed!

@ anObject
	"Answer an OrderedPair with the receiver as the x element and anObject as the y element."

	^OrderedPair x: self y: anObject!

~= anObject

	"Answer a Boolean which is false when the receiver and anObject
	 are equivalent, and true otherwise."

	^(self = anObject) not!

~~ anObject

	"Answer a Boolean which is false when the receiver and anObject
	 represent the identical object, and true otherwise."

	^(self == anObject) not!

abrConverter
	"Public - answer a converter suitable for the receiver."
 
	^self class untitledConverter!

abrIsCommunicationsError
	"Answer if this is a CommunicationsError object
	  or one of its subclasses."
	^false!

abrRemoveAllInterest
	"Remove all dependencies on the receiver for all events
	and for all objects. Return the receiver.

	Example:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: nil)).
	collection abrRemoveAllInterest.
	collection abrAdd: 'hello world'

	Executing this code will not cause anything to be displayed
	in the Transcript because of the call to abrRemoveAllInterest.
	If this line is ommitted, 'hello world' will be displayed in the Transcript

"

	AbtCLDTAdditions removeEventDependentsFor: self!

abrRemoveInterestFrom: aDependentObject
	"Remove all dependencies on the receiver regardless of the
	event they are dependent upon, if the object that would be sent
	messages as a result of the dependency is aDependentObject.
	Retrun the receiver.

	Example:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: nil)).
	collection abrRemoveInterestFrom: Transcript.
	collection abrAdd: 'hello world'

	Executing this code will not cause anything to be displayed
	in the Transcript because of the call to abrRemoveInterestFrom:.
	If this line is ommitted, 'hello world' will be displayed in the Transcript

	NOTE: This method will not correctly remove interest in events that were added
 	using abtWhen:perform:.   Instead please use abrRemoveInterestIn:from: to get the correct behavior.
	This method will correctly remove interest from events added with abtWhenPrimitive:perform:
 	"

	^self abrRemoveInterestSelect: [: message | message receiver == aDependentObject]!

abrRemoveInterestIn: aFeatureName from: obj
	"Remove all the messages dependent on the feature named 
	aFeatureName where the receiver of the message is obj.
	aFeatureName may be the name of an event or an attribute
	of the receiver. Retrun the receiver. Fail if the receiver does
	not have an event or attribute by the name aFeatureName

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abrRemoveInterestIn: #clicked from: Transcript.
	button abtPerformActionNamed: #click

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrRemoveInterestIn: #first from: Transcript.
	collection abrAdd: 'hello world'

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.

	NOTE: This method will correctly remove interest in events that were added
 	using abtWhen:perform:
 
"

	^self abrRemoveInterestIn: aFeatureName ifAbsent: [self class noSuchFeature: aFeatureName] from: obj!

abrRemoveInterestIn: aFeatureName ifAbsent: aBlock from: obj
	"Remove all the messages dependent on the feature named 
	aFeatureName where the receiver of the message is obj.
	aFeatureName may be the name of an event or an attribute
	of the receiver. Retrun the receiver. Fail if the receiver does
	not have an event or attribute by the name aFeatureName

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abrRemoveInterestIn: #clicked ifAbsent: [] from: Transcript.
	button abtPerformActionNamed: #click

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrRemoveInterestIn: #first ifAbsent: [] from: Transcript.
	collection abrAdd: 'hello world'

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.

	NOTE: This method will correctly remove interest in events that were added
 	using abtWhen:perform:
 
"


	 (self abtFeatureNamed: aFeatureName ifAbsent: [^aBlock value]) removeInterestIn: self from: obj!

abrRemoveInterestInPrimitive: anEvent from: aDependentObject
	"Remove all dependencies on the receiver for the event anEvent
	 if the object that would be sent messages as a result of the 
	dependency is aDependentObject. Return the receiver.

	Example:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: nil)).
	collection abrRemoveInterestInPrimitive: #first from: Transcript.
	collection abrAdd: 'hello world'

	Executing this code will not cause anything to be displayed
	in the Transcript because of the call to abrRemoveInterestInPrimitive:from:.
	If this line is ommitted, 'hello world' will be displayed in the Transcript

"


	^self
		abrRemoveInterestInPrimitive: anEvent
		select: [:message | message receiver == aDependentObject]!

abrRemoveInterestInPrimitive: anEvent select: aBlock
	"Remove those dependencies on the receiver for the event anEvent
	 for which the block aBlock returns true when evaluated with the dependency
	as an argument. Return the receiver.

	Example:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: nil)).
	collection abrRemoveInterestInPrimitive: #first select:
		[: aDirectedMessage | aDirectedMessage receiver = Transcript].
	collection abrAdd: 'hello world'

	Executing this code will not cause anything to be displayed
	in the Transcript because of the call to abrRemoveInterestInPrimitive:select:.
	If this line is ommitted, 'hello world' will be displayed in the Transcript

"

	| eventDependents |

	(eventDependents := self abtEventDependents) == nil ifTrue: [^self].
	((eventDependents at: anEvent ifAbsent: [^self]) removeSelectedDependencies: aBlock) isNil
		ifTrue: [ "all the dependencies for this event were removed"
			eventDependents size = 1
				ifTrue: [self abtBasicRemoveAllInterest]
				ifFalse: [eventDependents removeKey: anEvent]]!

abrRemoveInterestSelect: aBlock
	"Remove those dependencies on the receiver
	 for which the block aBlock returns true when evaluated with the dependency
	as an argument, regardless of the event the dependency is associated with.
	Return the receiver.

	Example:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: nil)).
	collection abrRemoveInterestSelect:
		[: aDirectedMessage | aDirectedMessage receiver = Transcript].
	collection abrAdd: 'hello world'

	Executing this code will not cause anything to be displayed
	in the Transcript because of the call to abrRemoveInterestInPrimitive:select:.
	If this line is ommitted, 'hello world' will be displayed in the Transcript

"

	| eventDependents removeKeyList |

	(eventDependents := self abtEventDependents) == nil ifTrue: [^self].

	eventDependents keysAndValuesDo: [:event :dependents |
		(dependents removeSelectedDependencies: aBlock) isNil
			ifTrue: [
				removeKeyList isNil ifTrue: [removeKeyList := OrderedCollection new].
				removeKeyList add: event]].
	removeKeyList notNil
		ifTrue: [
			eventDependents size = removeKeyList size
				ifTrue: [self abtBasicRemoveAllInterest]
				ifFalse: [eventDependents removeAllKeys: removeKeyList]]!

abtAtAttribute: aName
	"Return the current vaue of the attribute named attributeName.
	Fail if attributeName is not the value of an attribute of the receiver.

		Examples:

		OrderedCollection new
			abtAtAttribute: #size.

		1@1
			abtAtAttribute: #x
"

	^self valueOfAttributeNamed: aName!

abtAtAttribute: aName ifAbsent: aBlock
	"Return the current vaue of the attribute named attributeName.
	If attributeName is not the name of an
	attribute supported by the receiver, return the result of evaluating
	the block aBlock. 

		Examples:

		OrderedCollection new
			abtAtAttribute: #sze
			ifAbsent: ['missing'].

		1@1
			abtAtAttribute: #z
			ifAbsent: ['no such attribute']
"

	^self valueOfAttributeNamed: aName ifAbsent: aBlock!

abtAtAttribute: aName ifAbsent: aBlock  put: aValue
	"Set the vaue of the attribute named attributeName to the value 
	aValue. If the attribute is not settable, do nothing. If attributeName 
	is not the name of an attribute supported by the receiver, return the 
	result of evaluating the block aBlock. 

		Examples:

		1@1
			abtAtAttribute: #z
			ifAbsent: ['no such attribute']
			put: 2
"

	^self valueOfAttributeNamed: aName ifAbsent: aBlock  put: aValue!

abtAtAttribute: aName  put: aValue
	"Set the vaue of the attribute named attributeName to the value 
	aValue. If the attribute is not settable, do nothing. Fail if 
	attributeName is not the name of an attribute supported by the receiver. 

		Examples:

		1@1
			abtAtAttribute: #x
			put: 2
"

	^self valueOfAttributeNamed: aName  put: aValue!

abtCanBeBoolean
	"Answer true if the receiver can become an object which
	responds to the protocol of Boolean

	See: #abtAsBoolean"

	^self class abtCanBeBoolean!

abtCanBeCharacter
	"Answer true if the receiver can become an object which
	responds to the protocol of Character.

	See: #abtAsCharacter"

	^self class abtCanBeCharacter!

abtCanBeDate
	"Answer true if the receiver can become an object which
	responds to the protocol of Date.

	See: #abtAsDate"

	^self class abtCanBeDate!

abtCanBeDateAndTime
	"Answer true if the receiver can become an object which
	responds to the protocol of DateAndTime.

	See: #abtAsDateAndTime"

	^self class abtCanBeDateAndTime!

abtCanBeDBString
	"Answer true if the receiver can become an object which
	responds to the protocol of a double-byte string.

	See: #abtAsDBString"

	^self class abtCanBeDBString!

abtCanBeEsString
	"Answer true if the receiver can become an object which
	responds to the protocol of EsString.

	See: #abtAsEsString"

	^self class abtCanBeEsString!

abtCanBeMonetaryAmount
	"Answer true if the receiver can become an object which
	responds to the protocol of AbtMonetaryAmount

	See: #abtAsMonetaryAmount"

	^self class abtCanBeMonetaryAmount!

abtCanBeNumber
	"Answer true if the receiver can become an object which
	responds to the protocol of Numbers

	See: #abtAsNumber"

	^self class abtCanBeNumber!

abtCanBeSBString
	"Answer true if the receiver can become an object which
	responds to the protocol of a single-byte string.

	See: #abtAsSBString"

	^self class abtCanBeSBString!

abtCanBeTime
	"Answer true if the receiver can become an object which
	responds to the protocol of Time.

	See: #abtAsTime"

	^self class abtCanBeTime!

abtCanBeTimestamp
	"Answer true if the receiver can become an object which
	responds to the protocol of AbtTimestamp.

	See: #abtAsTime"

	^self class abtCanBeTimestamp!

abtClone
	"Make a copy of the receiver and recursively make an abtClone
	of any of the objects that the receiver's instance variables point to.
	This results in copying the complete tree of objects of which the
	receiver is the root, right down to the leaves"

	^self abtCloneWithRecursionSet: IdentityDictionary new!

abtDrawUsersAttentionToInputArea
	"Select all of our text and then get the input focus such
		that the user's attention can be drawn to the erroneous
		input contained in our view."

	"The default is to do nothing."!

abtHash32

	"Answer a positive SmallInteger that represents the
	 receiver. Objects that are equivalent (=) must answer
	 the same value for the message #abtHash32."

	^self abtHash32: 453812435
!

abtHash32: aSeedSmallInt
	"Answer a positive SmallInteger that represents the receiver.
	 Objects that are equivalent (=) must answer the same value for the
	 message #hash32:."

	^self abtPrimHashInt: (self hash & 16r3FFFFFFF) seed: aSeedSmallInt!

abtIsGraphicsDescriptor

	^false!

abtMapping
	"Answer the string that the receiver is mapped to.  If no
	mapping exists for the receiver, then answer self."

	^self!

abtMappingIfNone: aBlock
	"Answer the string that the receiver is mapped to.  If no
	mapping exists for the receiver, then answer aBlock value."

	^aBlock value
!

abtPerformAction: actionName
	"Perform the action named actionName and return the result
	of performing the action. Do not provide any parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the receiver requires any parameters for this action.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to nil.

	Examples:

	OrderedCollection new
		abtPerformAction: #size.

	1@1
		abtPerformAction: #x
"

	^self abtPerformActionNamed: actionName!

abtPerformAction: actionName ifAbsent: aBlock
	"Perform the action named actionName and return the result
	of performing the action. Do not provide any parameters to this
	action. Return the result of evaluating the block aBlock if the receiver 
	does not support an action by the name actionName. Fail if the receiver 
	requires any parameters for this action.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to nil.

	Examples: 

	OrderedCollection new 
		abtPerformAction: #sz
		ifAbsent: ['Not There']

"

	^self abtPerformActionNamed: actionName ifAbsent: aBlock!

abtPerformAction: actionName with: arg
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the size of args does not match the number of 
	parameters for this action required by the receiver.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformAction: #add:
		with: 'string'.

	2@2
		abtPerformActionNamed: #x
		with: 1 
"

	^self abtPerformActionNamed: actionName withArguments: (Array with: arg)!

abtPerformAction: actionName withArguments: args
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the size of args does not match the number of 
	parameters for this action required by the receiver.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformAction: #add:
		withArguments: #('string').

	2@2
		abtPerformActionNamed: #x
		withArguments: #(1) 
"

	^self abtPerformActionNamed: actionName withArguments: args!

abtRelease

	"Remove references from the receiver to any of its dependents.
	 Answer self."

	Dependents removeKey: self ifAbsent: [].
	AbtCLDTAdditions removeEventDependentsFor: self!

abtReplaceableBasicDisplay: aString
	"Display aString in a headless environment.  This
	 method can be overridden in a subclass to achieve
	 different display behavior."

	AbtPrimitiveLoggingSupport logError: aString!

abtReplaceableDisplay: anMRI
	"Display the MRI object in a headless environment.  This
	 method can be overridden in a subclass to achieve
	 different display behavior."

	^anMRI display!

abtWhen: eventName ifAbsent: aBlock perform: aMessage

	"Add aMessage to the list of messages to be sent when
	the primitive event corresponding to the event named
	eventName is signalled. If eventName is not the name of an
	event supported by the receiver, return the result of evaluating
	the block aBlock. In most implementations
	of this selector, eventName will be used to locate the
	event defintion for the receiver corresponding to eventName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	eventName may also be the name of any valid attribute of
	the receiver. In this case, aMessage will be sent whenever
	the primitive change event of the attribute is signalled 
	(indicating that the value of the attribute has changed)
	Returns the receiver. 
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. eventName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abtPerformActionNamed: #click
	
	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
			"

	^(self abtFeatureNamed: eventName ifAbsent: [^aBlock value])
		abtWhenIn: self perform: aMessage!

abtWhen: eventName perform: aMessage

	"Add aMessage to the list of messages to be sent when
	the primitive event corresponding to the event named
	eventName is signalled. Fail if eventName is not the name of an
	event supported by the receiver. In most implementations
	of this selector, eventName will be used to locate the
	event defintion for the receiver corresponding to eventName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	eventName may also be the name of any valid attribute of
	the receiver. In this case, aMessage will be sent whenever
	the primitive change event of the attribute is signalled 
	(indicating that the value of the attribute has changed)
	Returns the receiver. 
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. eventName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abtPerformActionNamed: #click
	
	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.

	NOTE: When using abtWhen:perform: be sure to use abrRemoveInterestIn:from:  if you are removing
 	interest in the event.   Using other methods (such as abrRemoveInterestFrom: ) will not
 	behave as expected.
	"

	^self abtWhen: eventName ifAbsent: [self class noSuchEvent: eventName] perform: aMessage			!

abtWhenChanged: attributeName ifAbsent: aBlock perform: message

	"Add aMessage to the list of messages to be sent when
	the primitive event indicating the modification of the attribute 
	named attributeName is signalled. If attributeName is not the name of an
	attribute supported by the receiver, return the result of evaluating
	the block aBlock. In most implementations
	of this selector, attributeName will be used to locate the
	attribute defintion for the receiver corresponding to attributeName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	Returns the receiver.
	Note that 'abtWhen: attributeName ifAbsent: aBlock 
	perform: message' is actually equivalent if attributeName
	is a valid name of an attribute (see abtWhen:ifAbsent:perform:).
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. attributeName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenChanged: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
			"

	^(self abtFeatureNamed: attributeName ifAbsent: [^aBlock value]) 
		abtWhenChangedIn: self perform: message!

abtWhenChanged: attributeName perform: message

	"Add aMessage to the list of messages to be sent when
	the primitive event indicating the modification of the attribute 
	named attributeName is signalled. Fail if eventName is not 
	the name of an attribute supported by the receiver. 
	In most implementations
	of this selector, attributeName will be used to locate the
	attribute defintion for the receiver corresponding to attributeName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	Returns the receiver.
	Note that 'abtWhen: attributeName perform: message' is 
	actually equivalent if attributeName
	is a valid name of an attribute (see abtWhen:perform:).
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. attributeName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenChanged: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
"			

	^self abtWhenChanged: attributeName ifAbsent: [self class noSuchAttribute: attributeName] perform: message!

abtWhenPrimitive: aPrimitiveEvent perform: aMessage

	"Add aMessage to the list of messages to be sent when 
	aPrimitiveEvent is signalled. Return the receiver. aMessage 
	must have the receiver, selector and argument list specified, 
	and the size of the argument list must match the number of 
	arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. aPrimitiveEvent can be any object. Although 
	symbols have historically been used by VisualAge, we 
	recommend that atoms be used instead for constant event names.

	Examples:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: nil)).
	collection abrAdd: 'hello world'
	
	Executing the above code will cause 'hello world' to appear in
	the Transcript. This is because 'hello world' was the parameter
	to the event #first signalled in the processing of abrAdd:, and this
	value was used to replace the nil parameter in the DirectedMessage

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenPrimitive: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript. This is because we did not provide a nil parameter
	slot in the DirectedMessage, so the value we provided was used

	NOTE: When using abtWhenPrimitive:perform: be sure to use abrRemoveInterestFrom:  if you are removing
 	interest in the event.
	"

	| eventDependents interestedParties |

	interestedParties :=
		(AbtCLDTAdditions eventDependentsCollectionOf: self)
			at: aPrimitiveEvent
			ifAbsentPut: [AbtDependentsCollection forEvent: aPrimitiveEvent].

	interestedParties add: aMessage!

addDependent: anObject

	"Add the argument anObject as one of the receiver's dependents.
	 Answer anObject.  Dependents consist of objects that should be notified
	 when the receiver changes in some way."

	| dependents | 
	dependents := Dependents
		at: self
		ifAbsentPut: [OrderedCollection new].

	^dependents add: anObject!

addToBeFinalized
	"Add the receiver to the list of system objects which must be 
	notified when they are about to become garbage. When an object 
	is about to become garbage, there are NO references to that object
	in the system."

	self onFinalizeDo: nil  !

adjustForPrecision: anInteger
	^self!

adjustForPrecision: anInteger formula: aFormula
	^self adjustForPrecision: anInteger!

allChildren
	^self children!

allPreloadAccessorsIn: aContext
	^self allReferencedAccessorsIn: aContext!

allReferencedAccessorsIn: aContext
	^AccessorReferences new!

allReferencedAccessorsIn: aContext at: aKey
	^AccessorReferences new!

application

	^nil!

asAbtConverter
	"Public - answer the receiver as a converter.

	Notes: 
		1. This implementation is most useful for those
			objects which have individual converter types on a
			per-instance (vs. per-class) basis.  In such cases those
			objects can be use as 'converter specifications'. 
		2. Objects which have no need of this facility on the
			instance side should override this to answer nil."
 
	^self abrConverter!

asDatePeriod: aClass
	^self!

asDB2ValueString
	^'"', self asString, '"'!

asHAError
	^IBMExceptionEncounteredError exception: self!

asOpenSSLCipherDataFor: aCipher
	"Answer a new cipher data that wraps this object, which will
	 be the input to the cipher routines (i.e. plainText/cipherText).
	 
	 Answers:
		<OpenSSLCipherData or subclass>"
	
	^aCipher cipherDataFor: self!

asPostgreSQLString
	"Answer the string representation of the receiver in the proper PostgreSQL format.  Subclasses
	 should override default behavior when needed"
	
	^ self asString!

asProvisionFormulaReference
	^ProvisionFormulaReference worksheetName: self name!

assert: aMonadicBlock
	"Signal an assertion exception with a canned description if @aMonadicBlock evaluates to false."
	
	self assert: aMonadicBlock description: 'Assertion failed'	"$NON-NLS$"!

assert: aMonadicBlock description: aString
	"Signal an assertion exception with @aString as the description if @aMonadicBlock
	 evaluates to false."
	
	aMonadicBlock value ifFalse: [ AssertionFailure signal: aString ]!

assert: aMonadicBlock descriptionBlock: aMonadicDescriptionBlock
	"Signal an assertion exception with @aMonadicDescriptionBlock's value as the 
	 description if @aMonadicBlock evaluates to false."
	
	self assert: aMonadicBlock description: aMonadicDescriptionBlock value asString!

asString
	"Answer the string representation of the receiver."

	^self printString!

asStringIfEmpty: aBlock
	^self isEmptyString
		ifTrue: [aBlock value]
		ifFalse: [self]!

asStringIfEmptyReport: aString
	^self asStringIfEmpty: [EmptyString reporting: aString]!

asUnicodeString
	"Subclasses must override to define how to convert to a UnicodeString
	 representation.
	 
	 Answers:
		<UnicodeString>"
	
	self shouldNotImplement!

at: index

	"Answer the object at the position of the Integer index variable in the receiver.

	 Fail if index is not an kind of Integer Fail if index is < 1 Fail if the receiver does not
	 have indexed variables Fail if index is greater than the number of indexed variables in the
	 receiver."

	<primitive: VMprObjectBasicAt>
	^self primitiveFailed!

at: index put: value

	"Store the Object argument value in the variable
	 position of the receiver represented by the Integer
	 argument index. Answer the Object argument value that
	 was stored.

	 Fail if index is not a kind of Integer Fail if index
	 is < 1 Fail if the receiver does not have indexed
	 variables Fail if index is greater than the number of
	 indexed variables in the receiver Fail if the class
	 of value is not appropriate for the index variable
	 type of the receiver."

	<primitive: VMprObjectBasicAtPut>
	self primitiveErrorCode = PrimErrReadOnly ifTrue: [
		^self basicAt: index put: value
	]. 
	^self primitiveFailed!

basicAt: index

	"Answer the object at the position of the Integer index variable in the receiver.

	 Fail if index is not an kind of Integer Fail if index is < 1 Fail if the receiver does not
	 have indexed variables Fail if index is greater than the number of indexed variables in the
	 receiver.

	 Do not override #basicAt: in any subclass!!"

	<primitive: VMprObjectBasicAt>
	^self primitiveFailed
!

basicAt: index put: value

	"Store the Object argument value in the variable position of the receiver represented by the
	 Integer argument index. Answer the Object argument value that was stored.

	 Fail if index is not a kind of Integer Fail if index is < 1 Fail if the receiver does not
	 have indexed variables Fail if index is greater than the number of indexed variables in the
	 receiver Fail if the class of value is not appropriate for the index variable type of the
	 receiver.

	 Do not override #basicAt:Put: in any subclass!!"

	<primitive: VMprObjectBasicAtPut>
	self primitiveErrorCode = PrimErrReadOnly ifTrue: [
		[self attemptedROMStore: value intoSlot: index + self class instSize] critical == true ifTrue: [
			self basicAt: index put: value
		].
		^value
	]. 
	^self primitiveFailed!

basicInspect
	"Open a default inspector on the receiver. The flat inspector should always be used for 
	 basicInspect since it shows the internal state of the object."

	(EtInspector on: self)
		owningImage: System image;
		open!

basicSize

	"Answer an Integer which represents the number of indexable fields in the receiver. This is
	 the same as the largest legal subscript.

	 Do not override #basicSize in any subclass!!"

	<primitive: VMprObjectBasicSize>
	^ self primitiveFailed !

become: otherObject
	"Change all objects that refer to the receiver (via
	 instance variables) to now refer to @otherObject.
	 This is termed 'one way' become. 

	 Fail if the receiver is a immediate object:
	 (anSmallInteger, a Character, true, false, nil)
	 
	 Arguments:
		otherObject - <Object>
	 Answers:
		<Object> self"

	<primitive: VMprObjectBecome>
	^self primitiveFailed!

bigEndian
	"Public - Answer true if this is a bigEndian system "
 
	^System bigEndian!

broadcast: aSymbol

	"Send the argument aSymbol as a unary message to all of the receiver's
	 dependents.  Answer self.

	 Fail if aSymbol does not represent a unary message."

	self dependents do: [ :dependent |
		(dependent respondsTo: aSymbol) ifTrue:
			[dependent perform: aSymbol]]!

broadcast: aSymbol with: anObject

	"Send the argument aSymbol as a keyword message with argument anObject
	 to all of the receiver's dependents.  Answer self.

	 Fail if aSymbol is not a Symbol.
	 Fail if the number of arguments expected by aSymbol is not 1"

	self dependents do: [ :dependent |
		(dependent respondsTo: aSymbol) ifTrue:
			[dependent perform: aSymbol with: anObject]]!

browse
	"Create and schedule a system class browser on the class of the object."

	((EtTools browser: #class) on: self class) 
		owningImage: System image;
		open!

buttonImageInset

	^5!

buttonSpacing

	^0!

caAsConfigValue

	^self!

caIsContentAssistConfigUpdate

	^false!

caIsErrorType

	^false!

caIsUnresolvedST80Type

	^false!

calcModuleResults
	^LookupTable new!

calculator
	^self !

canEdit
	^false!

caProvideContentAssistTextWidgetFor: aContentAssistant
	"Text Widgets that can be used with content assist should override this"

	^nil!

caProvideContextFor: aTextWidget

	^VAContentAssistUndefinedContext basicNew!

catBrndCd
	^''!

changed

	"Inform all dependents that the receiver has changed in a general
	 way.  Answer self."

	self changed: self!

changed: anObject

	"Inform all dependents that the receiver has changed in an aspect
	 represented by the argument anObject.  Answer self."

	self dependents do: [ :dependent |
		dependent update: anObject]!

class

	"Answer a Class which is the receiver's class"

	<primitive: VMprObjectClass>
	^self primitiveFailed!

className
	"Return the name of the in image class of the receiver"

	^ self class name!

cmpoAccessors: aProvision
	^#()!

codePage
	"Public - Answer the default code page."
 
	^AbtCodePageConverter currentCodePage!

completeFutureThen: aBlock
	"Answer true if this object has an EsFuture interface, false otherwise
	 @see methods in the @EsFuture category in <EsFuture> for required methods
	 
	 Answers:
		<EsFuture> future"

	^self hasEsFutureInterface
		ifTrue: [self then: [:o | aBlock value: o]]
		ifFalse: [EsFuture sync: [aBlock value: self]]!

complexity
	^1!

componentInstanceResults
	^LookupTable new!

convertToDisplay
	"Public - answer the receiver as a displayable string"
	
	^self abrConverter objectToDisplay: self.!

convertToPrint
	"Public - answer the receiver as a printable string.
		(This string may not be suitable for editing.)"
	
	^self abrConverter objectToPrint: self.!

copy
	"Return a copy of the receiver.

	 Definition: <Object>
		Return a new object that must be as similar as possible to the receiver in its initial state and
		behavior. Any operation that changes the state of the new object should not as a side-effect
		change the state or behavior of the receiver. Similarly, any change to the receiver should not as a
		side-effect change the new object.

		If the receiver is an identity object, return the receiver.  This behavior is delegated to
		'shallowCopy'.

		Subclasses normally override the 'postCopy' method to add class-specific copying behavior.  However,
		some classes that should not be copied in the standard manner override 'copy' or 'shallowCopy'.

	 Return Value
		<RECEIVER> unspecified

	 Errors
		none"
	
	^self shallowCopy postCopy!

copyToMemorySegment: anEsMemorySegment forDumper: anObjectDumper
	"Copy the receiver into @anEsMemorySegment and return the copy. @anObjectDumper is the 
	 requestor. Queries can be done to decide what to do before/after copying."

	| result size extraSegment |

	(result := anEsMemorySegment copyObject: self) notNil
		ifTrue: [
			(anObjectDumper classBasedReplacer definesLoadingReplacement: result eswBasicClass)
					ifTrue: [result markForReplacement].
			^result].

	"Not enough space. Get extra segment, of proper size."
	extraSegment :=
		anObjectDumper
			allocateNextSegmentOfAtLeast: (size := self sizeInBytesWithHeader)
			forObject: self.
	"Retry the operation."
	(result := extraSegment copyObject: self) notNil
		ifTrue: [
			(anObjectDumper classBasedReplacer definesLoadingReplacement: result eswBasicClass)
					ifTrue: [result markForReplacement].
			^result].

	^anObjectDumper
		generateError: SwapperConstants::FailedCopyToSegment
		forObject: size	   "Failed to copy object to intermediate buffer." !

createError
	^ExceptionalEvent basicNew
		resumable: true;
		parent: ExAll;
		yourself!

currentClassAndMethod

	^Association
		key: self class name asString
		value: (Processor activeProcess methodAtFrame: 1) selector asString!

currentMethod

	^(Processor activeProcess methodAtFrame: 1) selector!

dataType	
	^self dataTypeBlock dataType!

dataTypeBlock	
	^UnknownDataType object: self!

defaultMRIGroupName
	"Answer our default message group/pool."
	
	^AbtNLSCoordinator current nlsGroupManager defaultMRIGroupName.!

delete
	"To avoid checking if nil or proxy"!

deleteObject
	"Do nothing - implemented to bypass a base image bug"

	"Note: this method is optionally loaded by the WindowBuilder Pro
	 runtime *only* in the case that it is otherwise not defined by
	 another application"!

dependents

	"Answer an OrderedCollection of Objects that are dependents
	 of the receiver."

	^Dependents at: self ifAbsent: [OrderedCollection new]!

deprecated: explanationString
	"Process a deprecation warning associated with the sender.  @explanationString identifies why the
	 sender was deprecated."

	Deprecation
		method: (Processor activeProcess methodAtFrame: 1)
		explanation: explanationString
		in: ''!

deprecated: explanationString in: versionString
	"Process a deprecation warning associated with the sender.  @explanationString identifies why the
	 sender was deprecated and @versionString identifies the product version when the sender was
	 deprecated."

	Deprecation
		method: (Processor activeProcess methodAtFrame: 1)
		explanation: explanationString
		in: versionString
		!

displayString
	^''!

dividesJournal: aJournal
	^aJournal divideNumber: self!

doesNotUnderstand: aMessage
	"Report to the user that the receiver class or superclasses do not
	 implement any methods for the message selector contained within the
	 argument @aMessage."

	^MessageNotUnderstood signalWith: (Array with: self with: aMessage)!

dsInLocalSpace
   "Answer the receiver in the objectspace of the sender if
	that is possible. A copy is made only if necessary"

   ^self      !

dsPerformWithLocalResult: aSelector
"Send the receiver the unary message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message. Answer the result of the method invocation, if
	 possible in the same objectspace as the sender, a copy of the 
	 result may be returned if necessary.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 0"
   ^(self perform: aSelector) dsInLocalSpace        !

dsPerformWithLocalResult: aSelector with: arg1

   ^(self perform: aSelector with: arg1) dsInLocalSpace     !

dsPerformWithLocalResult: aSelector with: arg1 with: arg2
	"Send the receiver the keyword message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message, and the arguments firstObject and
	 secondObject are arguments of the message to be sent.
	 Answer the result of the method invocation in the objectSpace
	 of the sender if possible. This may make a copy of the result
	 value if necessary.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 2"
   ^(self perform: aSelector with: arg1 with: arg2) dsInLocalSpace           !

dsPerformWithLocalResult: aSelector with: arg1 with: arg2 with: arg3

	"Send the receiver the keyword message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message, and the arguments firstObject, secondObject
	 and thirdObject are arguments of the message to be sent.
	 Answer the result of the method invocation in the objectspace
	 of the sender. A copy of the result may be returned if necessary.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 3"
   ^(self perform: aSelector with: arg1 with: arg2 with: arg3) dsInLocalSpace              !

dsPerformWithLocalResult: aSelector withArguments: argArray

	"Send the receiver the message indicated by the argument
	 aSymbol. The argument aSymbol is the selector of the
	 message, and the argument anArray is an Array containing
	 the arguments of the message to be sent. Answer the result
	 of the method invocation in the objectspace of the sender.
	 A copy of the result may be made if necessary.

	 Fail if aSymbol is not a Symbol. Fail if anArray is not an
	 Array. Fail if the number of arguments expected by aSymbol
	 is not = anArray size."
   ^(self perform: aSelector withArguments: argArray) dsInLocalSpace           !

dsSpace

   "Answer the objectSpace in which the receiver actually lives"
	^DsDistributedSystem distributionEnabled
	ifTrue: [Processor activeProcess dsParentProcess dsLocalSpace]
	ifFalse: [DsDistributedSystem localSpace]                              !

dumpingReplacementForClassField
	"Return a possibly new object that will replace the receiver's class field when dumping. This is 
	 useful when one wants to replace this specific 'field' of a given object by another object. By 
	 default, same as #class. That is, no replacement, but subclasses can override it. This method 
	 is related to #dumpingReplacementForInstVar:. However, since the class field is not an inst 
	 var, the method has to be different."


	<primitive: VMprObjectClass>
	^self primitiveFailed!

dumpingReplacementForInstVar: anInteger forReplacer: anInstVarBasedReplacer
	"Return a possibly new object that will replace the receiver's instance variable number 
	 @anInteger when dumping for replacer @anInstVarBasedReplacer. This is useful when one wants to 
	 replace 'fields' of a given object by another object, of another class. By default, same as 
	 #instVarAt:. That is, no replacement, but subclasses can override it."

	<sysprim: VMsysprObjectInstVarAtFor>
	^self primitiveFailed!

dumpingReplacementForReplacer: aClassBasedReplacer
	"Return a possibly new object that will replace the receiver when dumping. This is useful when 
	 one wants to replace instances of a given class by another object, of another class. The 
	 default is no replacement, but subclasses can override it."

	^self!

dumpingShallowCopy

	"Answer a copy of the the receiver, which shares the receiver's instance variables."

	| copy |

	<primitive: VMprObjectShallowCopy>

	self class isVariable
		ifTrue: [copy := self class basicNew: self basicSize]
		ifFalse: [copy := self class basicNew].

	1 to: self class instSize do: [:instVarIndex |
		copy instVarAt: instVarIndex put: (self instVarAt: instVarIndex)].

	1 to: self basicSize do: [:index | copy basicAt: index put: (self basicAt: index)].

	^copy!

editName 
	^''!

emWriteLiteralOn: decoder
	"Write a linear representation of the receiver on the decoder.
	 If the receiver's class is not a known literal type then write out the store
	 string representation of the literal."

	| type |
	type := decoder writeLiteralTypeFor: self.
	type = 0 ifFalse: [^self].
	decoder writeString: self storeString!

environment

	^self class environment!

epAnnotate: aPackager globalVariableNamed: aName with: anAnnotation reason: aReason inImage: anImage
	"ACTION
		I am an object in a compiled method literal frame. Annotate the
		global variable I reference with anAnnotation and aReason.

	PARAMETERS
		<EpPackager>
		<Symbol>
		<IepPackagingAnnotation>
		<IepAnnotationReason>
		<EmSystemConfiguration>
	"

	aPackager
		annotate: (anImage epDescriptionForGlobalVariableNamed: aName)
		with: anAnnotation
		reason: aReason!

epAnnotateReferencedGlobals: aPackager
	with: anAnnotation
	reason: aReason
	using: aTable
	inImage: anImage
	"ACTION
		I am an object in a compiled method literal frame. Annotate any
		global variables that I reference with anAnnotation and aReason.
		Only associations need to overridde. Pool variables can find their
		descriptions in aTable which maps pool variable associations to
		descriptions.

	PARAMETERS
		<EpPackager>
		<IepPackagingAnnotation>
		<IepAnnotationReason>
		<LookupTable of <Association> -> <IepPoolVariableDescription>>
		<EmSystemConfiguration>
	"
!

epAsArrayedCollection
	"ACTION
		Return myself as aCollection. I represent a collection
		with one element, so return myself in anArray.

	RETURNS
		<Array>
	"

	^Array with: self!

epAtIndex: anInteger
	"ACTION
		Return the object at the specified position.

	PARAMETER
		<Integer>

	RETURNS
		<Object>
	"

	^self!

epbIsInitializeRule
	^false!

epClassNameReferencesInContextOf: aPackager into: aSet
	"ACTION
		Add references of classes by name in myself to aSet.

	PARAMETERS
		aPackager <EpPackager>
		aSet <Set of <Class>>

	RETURNS
		<Set of <Class>>
	"

	^aSet!

epCopyAndGrowWith: anObject
	"ACTION
		Return a copy of myself with an object appended to me.

	PARAMETER
		<Object>

	RETURNS
		<Array>
	"

	^Array with: self with: anObject!

epCopyAndRemoveElementAt: anInteger
	"ACTION
		Return a copy of myself with an object at index anInteger removed from me.
		Return nil sicne I will become the empty collection.

	PARAMETER
		<Integer>

	RETURNS
		<nil>
	"

	^nil!

epCopyAtAllPut: anObject
	"ACTION
		Return a copy of myself with an object in all entries.

	PARAMETER
		<Object>

	RETURNS
		<Object>
	"

	^anObject!

epDirectClassReferencesInContextOf: aPackager into: aSet
	"ACTION
		Add direct (i.e. not by name) class references in/of myself to aSet.

	PARAMETERS
		aPackager <EpPackager>
		aSet <Set of <Class>>

	RETURNS
		<Set of <Class>>
	"

	^self epReferencedClassesInContextOf: aPackager into: aSet!

epHighlightText
	"ACTION
		I represent a literal in a compiled method literal frame. Return	
		a string that can be highlighted by a method browser that
		represents me.

	RETURNS
		<String>
	"

	^self printString!

epIndexOf: anObject
	"ACTION
		Return the index of anObject in me.

	PARAMETER
		<Object>

	RETURNS
		<Integer>
	"

	^anObject = self ifTrue: [1] ifFalse: [0]!

epInstVarsDo: aBlock
		"Evaluate aBlock with every instance variable
		 of the receiver."

	self PackagerClass isPointers ifFalse: [^self].
	1 to: (self PackagerClass instSize + self basicSize) do: [ :i |
		aBlock value: (self instVarAt: i)].!

epIsAnnotationStatus
	"ACTION
		Return false

	RETURNS
		<Boolean>
	"

	^false!

epIsBCT

	"Answer if the receiver is a BlockContextTemplate."

	^false!

epIsComponentDescription
	"ACTION
		Return true if the receiver represents a component description

	RETURNS
		<Boolean>
	"

	^false!

epIsFilter

	^false!

epIsFilterState

	^false!

epIsFixedSpace
	^false!

epIsInstructionsValueEquivalentTo: anObject
	"ACTION
		Return true or false depending on whether I am an
		equivalent object to anObject.  Used for determining if
		the methodSymbolArgumentFilter of packaging instructions
		needs to be saved.

	PARAMETERS
		<Object>
	
	RETURNS
		<Boolean>
"

	^self = anObject!

epIsPackagingAnnotation
	"ACTION
		Return true if the receiver is a packaging annotation

	RETURNS
		<Boolean>
	"

	^false!

epIsPackagingAnnotationReason
	"ACTION
		Return true  if the receiver is a packaging annotation reason

	RETURNS
		<Boolean>
	"

	^false!

epIsPoolAssociation

	"Answer if the reciever is a pool dictionary association."

	^false!

epIsPoolDictionary
	^false!

epIsRAMSpace
	^false!

epIsROMSpace
	^false!

epIsRuleStore
	"ACTION
		Return true if I implement @ IepRuleStore.

	RETURNS
		<Boolean>
	"

	^false!

epIsRuleStoreKey
	"ACTION
		Return true if I implement @ IepRuleStoreKey

	RETURNS
		<Boolean>
	"

	^false!

epIsXDClass

	"Answer true when in XD mode and the receiver is the class
	 of XD classes/metaclasses."

	^false!

epReferencedClassesInContextOf: aPackager into: aSet
	"ACTION
		Add the class references in/of myself (the classes of the objects) to aSet.

	PARAMETERS
		aPackager <EpPackager>
		aSet <Set of <Class>>

	RETURNS
		<Set of <Class>>
	"

	aSet add: (aPackager classFromName: self class name).
	^aSet!

epRepresentativeObject
	"ACTION
		Return the object that I represent in the packaged
		image

	RETURNS
		<Object>
	"

	^self!

epSnapshotCopy
	"ACTION
		Return a copy of myself to be placed in a snapshot.
		By default, this is a simply a copy of myself.

	RETURNS
		<Object>
	"

	^self copy!

epSymbolReferences
	"ACTION
		Return a collection of symbols contained in the receiver

	RETURNS
		<Collection of <Symbol>>
	"

	^#()!

equalTo: anObject 
forDecimals: aPrecisionNumber 
	^self = anObject!

error: aString

	"Stop the currently executing process and display
	 the error message aString."

	^ExError signalWith: aString!

eswBasicClass
	"Answer the actual class field of the receiver."

	<primitive: VMprObjectClass>
	^self primitiveFailed!

eswGetClassOf: anObject
	"Get the class of @anObject without sending it a message."

	<sysprim: VMsysprObjectClassOf>
	^self primitiveFailed!

eswIsBehavior

	^false!

eswIsBlock

	^false!

fileExists: aString
	^CfsDirectoryDescriptor hasFullFile: aString!

fileString
	^self asString!

finalize
	"The receiver no longer has any referencers in the image
	and is being finalized. The default behavior is to do nothing."

	^ self !

fixClassTo: anObject
	"Change the class field of the receiver to be @anObject. This is used to change the class field 
	 of objects by 'lightweight classes' when dumping and by 'real classes' when loading."

	<primitive: VMprObjectClassColon>
	^self primitiveFailed!

fixInstVar: anInteger toBe: anObject
	"Same as #instVarAt:put:, but specific to marshalling framework. This method classes can 
	 override, defining their own behaviour. It's a copy of the method #instvarAt:put: for 
	 performance reasons (save a message send)."

	<primitive: VMprObjectInstVarAtPut>
	^self primitiveFailed!

formattedCode
	^self asString!

forward: aMessage to: aRemoteObject
	"The receiver has been asked to perform @aMessage."

	"For backward compatibility, aMessage could be aSymbol, so perform it."
	aMessage isSymbol ifTrue: [^self perform: aMessage].

	^self 
		perform: aMessage selector
		withArguments: aMessage arguments!

frequencyString
	^''!

fromDate
	^self unsupportedRequest!

getComponentFrom: aContext
	^nil.!

getMRI: id 
	"Answer the Machine Readable Information known
		as <id> in our default message group.  If either the group or the id is
		unknown, then answer an empty string."
	
	^self getMRI: id group: self defaultMRIGroupName.
	!

getMRI: id group: groupId
	"Answer the Machine Readable Information known
	 as <id> in group <groupId>.  If either the group or the id is
	 unknown, then answer an empty string."
	
	^AbtNLSCoordinator current nlsGroupManager getMRI: id group: groupId
	!

getMRIString: id 
	"Answer the Machine Readable Information known
	 as <id> in the receiver's default group.  If either the group or the id is
	 unknown, then answer an empty string."
	
	^(self getMRI: id) string
	!

getMRIString: id group: groupId
	"Answer the Machine Readable Information known
	 as <id> in group <groupId>.  If either the group or the id is
	 unknown, then answer an empty string."
	
	^(self getMRI: id group: groupId) string
	!

getMsg: msgId 
	"Answer the message text using the default group and no replacement parms."

	^self getMsg: msgId
		group: self defaultMRIGroupName
			replace: nil.!

getMsg: msgId group: groupId
	"Answer the message text using the group <groupId> with no
		replacement parameters."

	^self getMsg: msgId
		group: groupId
			replace: nil.!

getMsg: msgId group: groupId replace: replCltn
	"Answer the string specified by the input parameters
			as follows:
				msgId => integer or name of pool constant which maps to an integer.
				groupId => name of the pool used to resolve constants and message
					numbers.
				replCltn => collection of objects used to replace substitution 
					parameters in the original message.  This collection may be
					nil if no substitution is required. "
	
	^self primGetMsg: msgId
		group: groupId
			replace: replCltn	!

getMsg: iMsg group: groupSym with: parm1
	"Answer message iMsg with a single parameter.
		Look for the message in group groupId"
 
	^self getMsg: iMsg group: groupSym replace: parm1.!

getMsg: iMsg group: groupSym with: parm1 with: parm2
	"Answer message iMsg with two parameters.
		Look for the message in group groupId"
 
	^self getMsg: iMsg group: groupSym 
		replace: (Array with: parm1 with: parm2).!

getMsg: iMsg group: groupSym with: parm1 with: parm2 with: parm3
	"Answer message iMsg with three parameters.
		Look for the message in group groupId"
 
	^self getMsg: iMsg group: groupSym 
		replace: (Array with: parm1 with: parm2 with: parm3).!

getMsg: msgId replace: replCltn
	"Answer the message text using the default group
		and replacement parms <replCltn>."

	^self getMsg: msgId
		group: self defaultMRIGroupName
			replace: replCltn.!

getMsg: iMsg with: parm1
	"Answer message iMsg with a single parameter.
		Look for the message in our default group."
 
	^self getMsg: iMsg 
		group: self defaultMRIGroupName 
		with: parm1!

getMsg: iMsg with: parm1 with: parm2
	"Answer message iMsg with two parameters.
		Look for the message in our default group."
 
	^self getMsg: iMsg 
		group: self defaultMRIGroupName 
		with: parm1
		with: parm2!

getMsg: iMsg with: parm1 with: parm2 with: parm3
	"Answer message iMsg with three parameters.
		Look for the message in our default group."
 
	^self getMsg: iMsg 
		group: self defaultMRIGroupName 
		with: parm1
		with: parm2
		with: parm3!

greaterThanOrEqualTo: anObject 
forDecimals: aPrecisionNumber  
	^self >= anObject!

haEqualTo: anObject
	^self = anObject
!

haGreaterThan: anObject
	^self > anObject
!

haGreaterThanOrEqualTo: anObject
	^self >= anObject
!

haLessThan: anObject
	^self < anObject
!

haLessThanOrEqualTo: anObject
	^self <= anObject
!

halt

	"Suspend the currently executing process by signalling the halt exception."

	ExHalt signal.
	^ self !

halt: aMessage

	"Suspend the currently executing process, and display
	 the message aMessage."

	ExHalt signalWith: aMessage.
	^self!

hasCalcModuleReference: anEnvironment
	^false!

hasDateSearchReference: anEnvironment with: aWorksheet
	^false!

hasEsFutureInterface
	"Answer true if this object has an EsFuture interface, false otherwise
	 @see methods in the @EsFuture category in <EsFuture> for required methods
	 
	 Answers:
		<Boolean>"

	^false!

hasExternalFactors
	^false!

hash

	"Answer a positive SmallInteger that represents the
	 receiver. Objects that are equivalent (=) must answer
	 the same value for the message #hash."

	<primitive: VMprObjectBasicHash>
	^self primitiveFailed!

hasPrecedence: anInteger
	^self precedence > anInteger!

identityHash
	"Answer an integer hash code that can be used in conjunction with
	 an #== (identity) comparison.

	 This method has little use in VisualAge Smalltalk since #==
	 (identity) comparisons are normally done in a system primitive."

	^self basicHash!

ifMissing: aBlock
	^self!

ifNil: nilBlock
	"If the receiver is the nil object, then answer the result of evaluating @nilBlock,
	 a <niladicValuable>  or <monadicValuable> block; otherwise answer the receiver.
	
	 If @nilBlock is a <monadicValuable> block, it is evaluated with the receiver as
	 its argument."!

ifNil: nilBlock ifNotNil: notNilBlock 
	"If the receiver is the nil object, then answer the result of evaluating @nilBlock,
	 a <niladicValuable>  or <monadicValuable> block; otherwise answer the result
	 of evaluating @notNilBlock, a <niladicValuable> or <monadicValuable> block.

	 If @nilBlock is a <monadicValuable> block, it is evaluated with the receiver as
	 its argument.  If @notNilBlock is a <monadicValuable> block, it is evaluated
	 with the receiver as its argument."

	^notNilBlock argumentCount == 1
		ifTrue: [notNilBlock value: self]
		ifFalse: [notNilBlock value]!

ifNotNil: notNilBlock 
	"If the receiver is not the nil object, then answer the result of evaluating @notNilBlock,
	 a <niladicValuable>  or <monadicValuable> block; otherwise answer the receiver.

	 If @notNilBlock is a <monadicValuable> block, it is evaluated with the receiver as
	 its argument."

	^notNilBlock argumentCount == 1
		ifTrue: [notNilBlock value: self]
		ifFalse: [notNilBlock value]!

ifNotNil: notNilBlock ifNil: nilBlock
	"If the receiver is the nil object, then answer the result of evaluating @nilBlock,
	 a <niladicValuable>  or <monadicValuable> block; otherwise answer the result
	 of evaluating @notNilBlock, a <niladicValuable> or <monadicValuable> block.

	 If @nilBlock is a <monadicValuable> block, it is evaluated with the receiver as
	 its argument.  If @notNilBlock is a <monadicValuable> block, it is evaluated
	 with the receiver as its argument."

	^notNilBlock argumentCount == 1
		ifTrue: [notNilBlock value: self]
		ifFalse: [notNilBlock value]!

ifSciErrorDo: aBlock
	"Take no action"
	
	^self!

ifSslErrorDo: aBlock
	"Take no action"
	
	^self!

imageVersionName

	^String new!

in: aTable ifAbsent: aBlock	
	^aTable
		at: self
		ifAbsent: aBlock!

initialize
	"Subclasses should override if they need specific instance-creation initialization."!

inspect

	"Open a default inspector on the receiver. The default inspector can be configured as 
	 either the flat or hierarchical inspector. The flat inspector should always be used 
	 for basicInspect."

	((EtBaseTools browser: #inspector) on: self)
		owningImage: System image;
		open!

instVarAt: index

	"Answer an Object contained within the fixed variable
	 position of the receiver, indicated by the Integer
	 argument index. The numbering of the variables
	 corresponds to the enumeration of the receiver's
	 named instance variables.

	 Fail if index is not a kind of Integer Fail if index
	 is < 1 Fail if index is greater than the number of
	 fixed instance variables of the receiver.

	 Use of instVarAt: violates the principle of
	 encapsulation and should be used only in system
	 classes."

	<primitive: VMprObjectInstVarAt>
	^self primitiveFailed!

instVarAt: anInteger put: anObject

	"Store the argument anObject in the fixed variable
	 position of the receiver represented by the argument
	 anInteger. Answer anObject.

	 Fail if index is not a kind of Integer Fail if index
	 is < 1 Fail if index is greater than the number of
	 fixed instance variables of the receiver.

	 Use of instVarAt:put: violates the principle of
	 encapsulation and should be used only in system
	 classes."

	<primitive: VMprObjectInstVarAtPut>
	self primitiveErrorCode = PrimErrReadOnly ifTrue: [
		[self attemptedROMStore: anObject intoSlot: anInteger] critical == true ifTrue: [
			self instVarAt: anInteger put: anObject
		].
		^anObject
	]. 
	^self primitiveFailed!

instVarNamed: instVarName
	"Answer the value of the receiver's instance variable named @instVarName.
	 Raise an error if this instance variable doesn't exist."

	| index |

	index := self class allInstVarNames 
			indexOf: instVarName 
			ifAbsent: [^self error: ((NlsCatKRN indexedMsg: 53) bindWith: instVarName)].  "$NLS$ Instance variable named %1 not found in receiver"
	^self instVarAt: index!

instVarNamed: instVarName put: aValue
	"Store @aValue in the receiver's instance variable named @ instVarName.
	 Raise an error if this instance variable doesn't exist."

	| index |
	
	index := self class allInstVarNames 
			indexOf: instVarName 
			ifAbsent: [^self error: ((NlsCatKRN indexedMsg: 53) bindWith: instVarName)].  "$NLS$ Instance variable named %1 not found in receiver"
	^ self instVarAt: index put: aValue!

isAbtCaPostalCode
	"Answer true if the receiver is a Canadian postal code object."
	
	^false!

isAbtError
	"Public-Return true if the receiver responds to the basic
	  protocol for AbtError objects (defined in class AbtError)."

	^false.!

isAbtMonetaryAmount
	"Public - answer true if the receiver is a monetary amount."
	"02.03.93 gwc"
 
	^false!

isAbtQuantity

	^false!

isAbtZipCode
	"Answer true if the receiver is a zip code object."
	
	^false!

isAccessor
	^false!

isAccessorDefaultsProvision
	^false!

isAccessorTypesProvision
	^false!

isAcoError

	"Answer true if the object is an AcoError"

	^false!

isAcoFuture

	"Answer true if the object is an AcoFuture"

	^false!

isAgeAccessor
	^false!

isAlternationNode

	^false!

isAltKeyDown

	^self isKeyDown: CwConstants::Mod1Mask!

isAmountDateJournal
	^false!

isAmountJournal
	^false!

isAmountPeriodJournal
	^false!

isArray
	"Answer true if the receiver is a kind of Array."

	^ false!

isArrayCalcResult
	^false!

isAscii
	"Performs a ASCII check on the object.
	 If any byte in the object data is not within the ASCII range, false is answered.
	 
	 Example:
		self assert: ['ascii' isAscii].
		self assert: [#[195 169] isAscii not].
		
	 Answers:
		<Boolean> true if valid all bytes are ascii, false otherwise
	 Raises:
		<Exception>"

	^UnicodeSupport isAscii: self!

isAssociation
	"Answer true if the receiver is a kind of Association."

	^ false!

isAtom
	"Answer true if the receiver is an Atom; otherwise answer false."

	^ false!

isBasicView
	"Answer true if this is a basic view part."

	^false!

isBehavior
	"Answer true if the receiver is a kind of Behavior."

	^ false!

isBenefitElections
	^false!

isBenefitPayment
	^false!

isBlock
	"Answer true if the receiver is a kind of Block."

	^ false!

isBNISGenerationMap
	^false!

isBoolean

	^ false!

isByteArray
	"Answer true if the receiver is a kind of ByteArray."

	^ false!

isCalcInputAccessor
	^false!

isCalcModuleAccessor
	^false!

isCalcModuleResultHolder
	^false!

isCalculationModule
	^false!

isCalculator
	^false!

isCalendar
	^false!

isCalendarCalculator
	^false!

isCapsKeyDown

	^self isKeyDown: CwConstants::LockMask!

isCashBalanceResult
	^false!

isCBA
	^false!

isCfsError
		"Answers true if the receiver is a CfsError instance,
		otherwise answers false."

	^false!

isCgPngChunkReadStream

	^false!

isCharacter
	"Answer true if the receiver is a kind of Character."

	^ false!

isClass
	"Answer true if the receiver is a kind of Class."

	^ false!

isCmpAccessor
	^false!

isCmpoInstance
	^false!

isCodeDateJournal
	^false!

isCodePeriodJournal
	^false!

isCollapseRule
	^false!

isCollection
	"Answer true if the receiver is a kind of Collection."

	^ false!

isColor

	^ false!

isCompilerError
	^false!

isComponent
	^false!

isComponentAlignedProvision
	^false!

isComponentInstanceContext
	^false!

isConcatenationNode

	^false!

isControlKeyDown

	^self isKeyDown: CwConstants::ControlMask!

isDataAccessor
	^false!

isDataCatalog
	^false!

isDataLink

	^false!

isDate
	^false!

isDateBased
	^false!

isDateJournal
	^false!

isDatePeriod
	^false!

isDateSearchArgumentAccessor
	^false!

isDateSearchCalculation
	^false!

isDateSearchCalculator
	^false!

isDbgError

	"Answer true if the receiver is a DbgError, false otherwise."

	^false!

isDBPaymentInstructionResult
	^false!

isDBString

	"Answer true if the receiver is a double byte string"

	^false!

isDefaultCalculator
	^false!

isDefinedBenefitPlan
	^false!

isDefinedRule
	^true!

isDictionary
	"Answer true if the receiver is a kind of Dictionary."

	^ false!

isElementBnisResult
	^false!

isElementSingleBnisResult
	^false!

isEligResult
	^false!

isEmptyString
	^self isNil!

isEndDateJournal
	^false!

isEntirelyAfter: anObject
	^anObject isEntirelyBefore: self!

isEntirelyBefore: anObject
	^self toDate <= anObject fromDate!

isEpsilonNode

	^false!

isEqualComplexAccessMessage: aComplexAccessMessage
	^false!

isEqualDateEntry: aDateJournalEntry
	^false!

isEqualPeriodEntry: aPeriodJournalEntry
	^false!

isEqualSimpleAccessMessage: aSimpleAccessMessage
	^false!

isEqualToConstantCalculator: anObject
	^false!

isEqualToProvisionReference: aRef
	^false!

isEqualToWorksheetReference: aWorksheetRef
	^false!

isEsAsyncError
	"Polymorphic test
	 
	 Answers:
		<Boolean>"

	^false!

isEsAsyncRootZone
	"Polymorphic test
	 
	 Answers:
		<Boolean>"

	^false!

isEsAsyncZone
	"Polymorphic test
	 
	 Answers:
		<Boolean>"
	
	^false!

isEsPointer

	"Answer whether the receiver is kind of
	 EsPointer or not."

	^false!

isEsString
	"Used by Unicode support to determine if conversion is required"
	
	^false!

isException
	^false!

isExceptionOrHAError
	^false!

isExcludeRule
	^false!

isFactorTable
	^false!

isFatal
	^false!

isFatalNoDefault
	^self isFatal!

isFixedLoop
	^false!

isFloat

	"Answer true if the receiver is a Float."

	^ false!

isFormula
	^false!

isFraction
	"Answer true if the receiver is a kind of Fraction."

	^ false!

isFrequencyJournal
	^false!

isFrequencyJournalResult
	^false!

isFSAFinalState

	^false!

isGlobalProvision
" A provision (not within a component) can be accessed by formulas from within an encapsulated component. "	
	^false!

isGrammarProduction

	^false!

isGrapheme
	"Answer true if the receiver is a unicode grapheme, false otherwise.
	 
	 Answers:
		<Boolean>"
	
	^false!

isGreaterThanDateEntry: aDateJournalEntry
	^true!

isGreaterThanOrEqualDateEntry: aDateJournalEntry
	^true!

isGreaterThanOrEqualPeriodEntry: aPeriodJournalEntry
	^true!

isGreaterThanPeriodEntry: aPeriodJournalEntry
	^true!

isHAError
	^false!

isHAFactorTable
	^false!

isHALookupTable
	^false!

isIFObject

	"Answer whether the receiver is an image file object or not."

	^false!

isImmediateForDumping
	"Returns a Boolean indicating if the receiver is an immediate. That is, if the receiver is 
	 either true, false, nil, SmallInteger or Character."

	^false!

isIncludeRule
	^false!

isInteger

	"Answer true if the receiver is an Integer."

	^false!

isInternetArrayAgeAccessor
	^false!

isInternetArrayCalculation
	^false!

isInvalidStoredTBAResult
	^self isValidStoredTBAResult not!

isItemSet

	^false!

isJournal
	^false!

isJournalComputeCalculator
	^false!

isJournalLoop
	^false!

isJournalResult
	^false!

isKeyDown: keyMask

	^self getModifierState anyMask: keyMask!

isKindOf: aClass

	"Answer a Boolean which is true if aClass, is the class or
	 a superclass of the receiver, and false otherwise."

	^(self isMemberOf: aClass) or: [self class inheritsFrom: aClass]
!

isLeftButtonDown

	^self isKeyDown: CwConstants::Button1Mask!

isListed
	^true!

isLobFileReference
	"Answer true if the receiver is a LOB locator type"

	^false!

isLobLocator
	"Answer true if the receiver is a LOB locator type"

	^false!

isLoopCalculator 
	^false!

isLR0Item

	^false!

isLR1Item

	^false!

isMaterialized
	^true!

isMemberOf: aClass

	"Answer a Boolean which is true if aClass, is the class of
	 the receiver, and false otherwise."

	^self class == aClass!

isMetaclass
	"Answer true if the receiver is a kind of Metaclass."

	^ false!

isMiddleButtonDown

	^self isKeyDown: CwConstants::Button2Mask!

isMissing
	^false!

isMissingFormula
	^false!

isMRI
	"Answer true if the receiver is a kind of AbtMRI"
 
	^false!

isMZError
	"@see MZError class"

	^false!

isNamedCalculator
	^false!

isNativeProcess
	"Object check
	 
	 Answers:
		<Boolean> false"
	
	^false!

isNil

	"Answer a Boolean which is true if the receiver class inherits from
	 UndefinedObject, and false otherwise."

	"Answer false, since Object does not inherit from UndefinedObject"

	^false!

isNil: aBlock
	"Added by OSI - Replaces the <isNil ifTrue: aBlock> construct.
	  Note - use #ifNil: instead"
	^self ifNil: aBlock!

isNlsPool
	"Answer true if the receiver represents an nls pool otherwise
	answer false."

	^false!

isNoEntry
	^false!

isNonterminal

	^false!

isNotEmptyString
	^self isEmptyString not!

isNumber
	"Answer true if the receiver is a kind of Number."

	^ false!

isOpenSSLByteObject
	"Subclasses that are byte-oriented and know their size
	 are byte objects"
	
	^false!

isOpenSSLCipherAEAD
	
	^false!

isOpenSSLCipherAuthData
	
	^false!

isOpenSSLCipherData
	
	^false!

isOpenSSLDecrypted
	"Objects are always in decrypted form, unless otherwise handled"
	
	^true!

isOpenSSLEncrypted
	"Objects are always in decrypted form, unless otherwise handled"
	
	^false!

isOptionalFormCalculator
	^false!

isOptionalFormGroup
	^false!

isOptionalFormResult
	^false!

isOrderedCollection

	"Answer true if the receiver is an OrderedCollection"

	^false!

isOSObject

	"Answer true if the receiver is an OSObject."

	^false!

isPartitionTransitionMap

	^false!

isPaymentInstructionMap
	^false!

isPCRWorksheet
	^false!

isPensionCalculation
	^false!

isPeriodBased
	^false!

isPeriodJournal
	^false!

isPlanAttributeResult
	^false!

isPlanBnisResult
	^false!

isPlanSingleBnisResult
	^false!

isPoint
	"Answer true if the receiver is a kind of Point."

	^ false!

isPreloadProvision
	^false!

isProcess

	^ false!

isProvisionReference
	^false!

isProxy
	^false!

isRateDateJournal
	^false!

isRateJournal
	^false!

isRatePeriodJournal
	^false!

isRectangle
	"Answer true if the receiver is a kind of Rectangle."

	^ false!

isReferencable
	^false!

isRepeating
	^false!

isReplaceRule
	^false!

isResultFormula
	^false!

isResultHolder
	^false!

isResultList
	^false!

isRightButtonDown

	^self isKeyDown: CwConstants::Button3Mask!

isSameEnd: anObject
	^self toDate = anObject toDate!

isSameStart: anObject
	^self fromDate = anObject fromDate!

isSBString

	"Answer true if the receiver is a single byte string"

	^false!

isScaledDecimal

	^ false!

isScenarioBEResultHolder
	^false!

isSciError
	"Answer true if the receiver is a SciError instance,
	otherwise answer false."

	^false!

isScrolledWindow
	"Answer whether the receiver is a ScrolledWindow"

	^false!

isSection415LimitResult
	^false!

isServiceResult
	^false!

isSetLoopTempVariableCalculator
	^false!

isShiftKeyDown

	^self isKeyDown: CwConstants::ShiftMask!

isSingleBnisEfDtResult
	^false!

isSingleBNISGenerationMap
	^false!

isSingleBnisRtrPrdQtyResult
	^false!

isSocialSecurityResult
	^false!

isSpecialRootForDumpingFor: aDumpingStrategy
	"Returns a Boolean indicating if the receiver is a special root object for dumping. If it is 
	 true, the dumper will use a different, lightweight strategy."

	^false!

isSslError
	"Answer true if the receiver is an instance of SslError, false otherwise.
	 
	 Answers:
		<Boolean>"

	^false!

isSslInitializationError
	"Answer true if the receiver is an SSL Initialization error.
	 
	 Answers:
		<Boolean>"

	^false!

isSstError

	"ACTION
		Answer true if the receiver is an SstError instance, otherwise answer false.

	RETURN VALUE
		<Boolean>"

	^false!

isStackFrameVariable

	"Answer true if the receiver represents a stack frame variable, false otherwise."

	^false!

isStartDateJournal
	^false!

isStorageObject
	^false!

isStoredProvision
	^false!

isString

	"Answer true if the receiver is a logical String. This
	 includes String, DBString, and Symbol."

	^ false!

isSymbol

	"Answer true if the receiver is a Symbol."

	^false!

isTable
	^false!

isTable1D
	^false!

isTable2D
	^false!

isTableCalculator
	^false!

isTableDataStringResult
 ^false!

isTBAArrayCalculationContext
	^false!

isTBACalculation
	^false!

isTBAPreloadInputs
	^false!

isTCRWorksheet
	^false!

isTerminal

	^false!

isTerminalNode

	^false!

isTest
	^false!

isTestingArrayContext
	^false!

isTightlyCoupled
	"Answer whether the receiver is a tightly coupled ScrolledWindow"

	^false!

isTokenClassification

	^false!

isTypeConsistentWith: anObject
	^false!

isUndefinedComponent

	^false!

isUnicodeScalar
	"Answer true if the receiver is a unicode scalar, false otherwise.
	 
	 Answers:
		<Boolean>"
	
	^false!

isUnicodeString
	"Answer true if the receiver is a unicode string, false otherwise.
	 
	 Answers:
		<Boolean>"
	
	^false!

isUnicodeView
	"Answer true if the receiver is a unicode view, false otherwise.
	 
	 Answers:
		<Boolean>"
	
	^false!

isUnicodeViewPosition
	"Answer true if the receiver is a unicode view position, false otherwise.
	 
	 Answers:
		<Boolean>"
	
	^false!

isUnresolved
	^false!

isUserArg
	^false!

isUserDefinedExceptionalValue
	^false!

isUserDefinedFunction
	^false!

isValidBufferForSwapping
	"Return a Boolean indicating if the receiver is a valid buffer to be used with the swapper's API 
	 that dumps into/loads from a 'ByteArray'. Some objects are also compatible, like Strings, etc."

	^false!

isValidResultListStoredResult
	^self isValidStoredTBAResult
!

isValidStoredTBAResult
	^false!

isValidUserId
	^false!

isValidUtf8
	"Performs a UTF-8 validity check on the object.
	 If the bytes of the object data do not form valid UTF-8, false is answered.
	 
	 Example:
		self assert: ['ascii' isValidUtf8].
		self assert: [#[195 169] isValidUtf8].
		self assert: [#[195 169 255] isValidUtf8 not].
	 
	 Answers:
		<Boolean> true if valid UTF-8, false otherwise
	 Raises:
		<Exception>"
	
	^UnicodeSupport isValidUtf8: self!

isVastProcess
	"Object check
	 
	 Answers:
		<Boolean> false"
	
	^false!

isVastSubprocess
	"Object check
	 
	 Answers:
		<Boolean> false"
	
	^false!

isWbLabeledImage

	^false!

isWhileLoop
	^false!

isWindow
	"Answer a Boolean indicating whether the
	 receiver is a CgWindow or not."

	^false!

isWorksheet
	^false!

isWorksheetCalculator
	^false!

isWorksheetGroup
	^false!

isYBRFormula
	^false!

isYBRResult
	^false!

join: aCollection
	"Append the elements of the argument, @aCollection, separating them by the receiver."

	^(Array with: self) join: aCollection!

lessThanOrEqualTo: anObject 
forDecimals: aPrecisionNumber  
	^self <= anObject!

loadingReplacementForReplacer: aLoadingReplacer
	"Return a possibly new object that will replace the receiver when loading. This is useful when 
	 one wants to replace instances of a given class by another object, of another class. The 
	 default is no replacement, but subclasses can override it."

	^self!

markForReplacement
	"Mark the receiver as an object that has a loading replacement. Objects not marked will not be 
	 detected by the default loading replacer provider with an instance of ObjectLoader."

	<sysprim: VMsysprMarkForReplacement>
	^self primitiveFailed!

materialize
	^self!

materializeForKey: aString
	^self
!

memCopyStateFrom: anObject
	"Copy all pointer fields of @anObject into the receiver."

	<sysprim: VMsysprCopyPointerInstVarsFrom>
	^self primitiveFailed!

memCopyStateInto: anObject
	"Copy all pointer fields of the receiver into @anObject."

	^anObject memCopyStateFrom: self!

miniHelpFont

	^CwFontList fontStruct: CgFontStruct default!

mriExists: anInt 
	"Answer true if the MRI object for anInt exists in our default group."

	^AbtNLSCoordinator current nlsGroupManager mriExists: anInt group: self defaultMRIGroupName
	!

mriExists: anInt group: groupId
	"Answer true if the MRI object for anInt exists in groupId."
	
	^AbtNLSCoordinator current nlsGroupManager mriExists: anInt group: groupId
	!

namedCalculator
	^NamedCalculator!

namedCalculators
	^#()!

nameString
	^self asString!

newResult
	^CalculationResult clean!

notMissing
	^true
!

notNil

	"Answer a Boolean which is false if the receiver class inherits from UndefinedObject, and
	 true otherwise."

	"Answer true, since Object does not inherit from UndefinedObject"

	^true!

notNil: aBlock
	"Added by OSI - Replaces the <notNil ifTrue: aBlock> construct"
	^aBlock value!

numberOfPointerFields
	"Return the number of pointer fields of the receiver. That is, the number of named + indexed 
	 instance variable that might contain references to other objects."


	| class |

	<sysprim: VMsysprObjectSizeInPointers>

	^(class := self class) instSize	   "Number of instance variables" + (
		class isPointers
			ifTrue: [self basicSize]	"Has indexed instance variables that are pointers."
			ifFalse: [0])	 "No indexed instance variables that are pointers."!

objectClass

	^System image globalNamespace classAt: self class name ifAbsent: []!

onFinalizeDo: selectorOrNilOrMessage  
	"Add the receiver to the list of system objects which must be 
	notified when they are about to become garbage. An object 
	is about to become garbage, when there are NO references to that object
	in the system. When that occurs, the action specified by
	selectorOrNilOrMessage is performed.
	If selectorOrNilOrMessage == nil, the receiver is sent the #finalize message.
	If selectorOrNilOrMessage is a Symbol, the receiver is sent the selector.
	If selectorOrNilOrMessage is a Message, the receiver is sent the Message."

	EsWeakList addToBeFinalized: self action: selectorOrNilOrMessage   
	!

openSSLDecrypt
	"Objects are always in decrypted form, unless otherwise handled"
	
	^true!

openSSLDiscard
	"Policy: Zero out the memory if not Read-Only"
	
	self openSSLZeroize!

openSSLDoWhileDecrypted: aBlock
	"Provided for compatibility, just run @aBlock as is"

	aBlock value!

openSSLEncrypt
	"Objects are always in decrypted form, unless otherwise handled"
	
	^false!

openSSLZeroize
	"Zero'ing out memory is left for subclass implementations"
	
	^false
	
	!

originalErrors
	^Array with: self!

PackagerBasicAt: index

	"Answer the object at the position of the Integer index variable in the receiver.

	 Fail if index is not an kind of Integer Fail if index is < 1 Fail if the receiver does not
	 have indexed variables Fail if index is greater than the number of indexed variables in the
	 receiver.

	 Do not override #basicAt: in any subclass!!"

	<primitive: VMprObjectBasicAt>
	^self primitiveFailed
!

PackagerBasicHash

	"Answer a SmallInteger that represents the receiver. Objects that are equivalent (=) must
	 answer the same value for the message #basicHash.

	 Do not override #basicHash in any subclass!!"

	<primitive: VMprObjectBasicHash>
	^self primitiveFailed!

PackagerClass

	"Answer a Class which is the receiver's class"

	<primitive: VMprObjectClass>
	^self primitiveFailed!

PackagerIsReadOnly

	"Answer true if the receiver is read-only, false if not."

	<primitive: VMprObjectIsReadOnly>
	^false!

perform: aSymbol

	"Send the receiver the unary message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message. Answer the result of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 0"

	<primitive: VMprObjectPerform>
	^self primitiveFailed
!

perform: aSymbol with: anObject

	"Send the receiver the binary or keyword message indicated
	 by the argument aSymbol. The argument aSymbol is the
	 selector of the message, and the argument anObject is the
	 argument of the message to be sent. Answer the result of
	 the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 1"

	<primitive: VMprObjectPerform>
	^self primitiveFailed!

perform: aSymbol with: firstObject with: secondObject

	"Send the receiver the keyword message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message, and the arguments firstObject and
	 secondObject are arguments of the message to be sent.
	 Answer the result of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 2"

	<primitive: VMprObjectPerform>
	^self primitiveFailed!

perform: aSymbol
	with: firstObject
	with: secondObject
	with: thirdObject

	"Send the receiver the keyword message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message, and the arguments firstObject, secondObject
	 and thirdObject are arguments of the message to be sent.
	 Answer the result of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 3"

	<primitive: VMprObjectPerform>
	^self primitiveFailed!

perform: aSymbol withArguments: anArray

	"Send the receiver the message indicated by the argument
	 aSymbol. The argument aSymbol is the selector of the
	 message, and the argument anArray is an Array containing
	 the arguments of the message to be sent. Answer the result
	 of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if anArray is not an
	 Array. Fail if the number of arguments expected by aSymbol
	 is not = anArray size."

	<primitive: VMprObjectPerformWithArguments>
	^self primitiveFailed!

pessimisticValueIn: aContext
	^self valueIn: aContext!

postCopy
	"Finish doing whatever is required, beyond 'shallowCopy',
	 to implement 'copy'.  This message is only intended to
	 be sent by 'copy' to the newly created instance.

	 Subclasses may add functionality, but they should always
	 invoke 'super postCopy' first."

	^self!

precedence
	^-10!

primitiveFailed

	"Report to the user that a method that is implemented as a system primitive 
	 has failed."

	^self primitiveFailed: self primitiveErrorCode withArgument: self primitiveBadArgumentNumber backUp: 1
!

printOn: aStream

	"Append to the argument aStream, a sequence of characters that
	 describes the receiver.

	 Fail if aStream is not a kind of Stream."

	aStream
		nextPutAll: (self class name first isVowel
						ifTrue: ['an ']  "$NON-NLS$"
						ifFalse: ['a ']).  "$NON-NLS$"
	self class printOn: aStream.!

printString

	"Answer a String whose characters are a description of the receiver."

	| writeStream |
	self printOn: (writeStream := WriteStream on: (Locale current preferredStringClass new: 10)).
	^writeStream contents asReducedString!

printStringLimitedTo: limit
	"Answer a String whose characters are a description of the receiver.  If
	 the string is longer than @limit, truncate it and add a notation of this
	 fact to the end of the truncated string."

	| limitedString |

	limitedString := String streamContents: [ :s | self printOn: s ] limitedTo: limit.
	^limitedString size < limit
		ifTrue: [ limitedString ]
		ifFalse: [ limitedString, ' ...etc...' ]	"$NON-NLS$"!

publish: aSymbol
	"Prevents need to load Publish/Subscribe application"!

putObjectOn: aStream
	"Write into @aStream the byte representation of the receiver."

	| objectID |
	objectID := aStream objectIDFor: self.
	aStream nextPutIntegerAsFourBytes: objectID.
	[
		aStream exportedObjectTable
			at: objectID
			ifAbsentPut: [self]
	] critical "Critical in case another process is exporting the same object at the same time."!

realClassName

	"Return the name of the in image class of the receiver"

	^self class name!

reconstructOn: aStream

	self printOn: aStream!

reconstructOn: aStream using: dummy

	self printOn: aStream!

referencesUsed
	^Set new!

refreshIfNecessary

	^self!

release

	"Remove references from the receiver to any of its dependents.
	 Answer self."

	Dependents removeKey: self ifAbsent: [].
	^ self !

releaseObject
	self isNil ifFalse: [ 	self become: nil ]!

remove
	"To avoid checking if nil or proxy"!

removeDependent: anObject

	"Remove the argument anObject, as one of the receiver's dependents.
	 If there are no more dependents of the receiver, remove it from the
	 dependents map. 
	 Answer anObject."

	| dependents | 
	dependents := Dependents at: self ifAbsent: [^ anObject].
	dependents remove: anObject ifAbsent: [].
	dependents isEmpty ifTrue: [	Dependents removeKey: self].
	^ anObject 
!

removeToBeFinalized
	"Remove the receiver from the list of system objects which must be 
	notified when they are about to become garbage."

	EsWeakList removeToBeFinalized: self	!

removeWarnings!

respondsTo: aSymbol

	"Answer a Boolean which is true if my class or a superclass
	 contains a method implementation for the message selector aSymbol,
	 and false otherwise."

	^aSymbol isSymbol and:
		[self class canUnderstand: aSymbol]!

resultHolder
	^nil!

reversePairWith: x
	"Answer a new OrderedPair whose x value is the argument and whose y value is the receiver."

	^OrderedPair x: x y: self!

sameLiteralAs: aLiteral
	"Answer true if the receiver, which is a literal of a method,
	 can be used to represent the candidate @aLiteral; otherwise
	 answer false."

	^self class == aLiteral class and: [self = aLiteral]  !

selector

	^nil!

setCachingLevel: anEnvironment
	^false!

setDateSearchCachingLevel: anEnvironment
	^false!

setDateSearchCachingLevel: anEnvironment with: aWorksheet
	^false!

setLocalCachingLevel: anEnvironment
	!

shouldNotImplement

	"Report to the user that the receiver's class or superclasses do
	 not have an appropriate implementation for the method from which
	 this message was invoked."

	^self error: self shouldNotImplementError!

size

	"Answer an Integer which represents the number of
	 indexable fields in the receiver. This value is the
	 same as the largest legal subscript."

	<primitive: VMprObjectBasicSize>
	^self primitiveFailed
!

sizeInBytesWithHeader
	"Answer the bytesize of representation. This is the number of bytes captured by the object 
	 itself, not anything it points to. This includes. 1) Header 2) 4/8 bytes per pointer (indexed and 
	 instVars) or, 4 bytes per long, or, 2 bytes per word, or, 1 byte per byte."


	| baseSize namedInstSize indexedSize |

	<sysprim: VMsysprObjectSizeInBytes>

	baseSize := self objectHeaderSize.
	namedInstSize := self class instSize * System vmPointerSize.	 "Named vars are 4 bytes always."
	indexedSize := self basicSize.
	self class isPointers
		ifTrue: [indexedSize := indexedSize * System vmPointerSize].
	self class isLongs
		ifTrue: [indexedSize := indexedSize * 4].
	self class isWords
		ifTrue: [indexedSize := indexedSize * 2].
	indexedSize := indexedSize + (System vmPointerSize) truncateTo: System vmPointerSize.
	^baseSize + namedInstSize + indexedSize!

smallFont

	^CwFontList fontStruct: CgFontStruct default!

split: aSequenceableCollection
	"Split the argument @aSequenceableCollection using the receiver as a separator."
	"optimized version for single delimiters.
	 
	Examples: 
		($/ split: '/foo/bar') >>> #('' 'foo' 'bar') asOrderedCollection
		([:c| c isSeparator] split: 'aa bb cc dd') >>> #('aa' 'bb' 'cc' 'dd') asOrderedCollection"
		
	| result |
	result := OrderedCollection new: (aSequenceableCollection size / 2) asInteger.
	self split: aSequenceableCollection do: [ :item |
		result add: item ].
	^ result
!

split: aSequenceableCollection do: aBlock
	"Split the argument @aSequenceableCollection using the receiver as a separator
	 and perform an action specified as @aBlock for each splitted subcollection.
	Optimized version for single delimiters.
	 
	Example:
		$/ split: '/foo/bar' indicesDo: [ :item :index| ]"

	self
		split: aSequenceableCollection
		indicesDo: [:start :end | aBlock value: (aSequenceableCollection copyFrom: start to: end)]!

split: aSequenceableCollection indicesDo: aBlock
	"Perform an action specified as @aBlock (with a start and end argument)
	 to each of the indices of the receiver element that have been 
	 identified by splitting the receiver using the splitter argument @aSequenceableCollection. 
	 Optimized version for single delimiters."


	| position oldPosition |

	position := 1.
	oldPosition := position.

	position := aSequenceableCollection indexOf: self startingAt: position.
	[position > 0] whileTrue: [
		aBlock value: oldPosition value: position - 1.
		position := position + 1.
		oldPosition := position.
		position := aSequenceableCollection indexOf: self startingAt: position].

	aBlock value: oldPosition value: aSequenceableCollection size!

sstAt: index

	<primitive: VMprObjectBasicAt>
	^self primitiveFailed
!

sstAt: index put: value

	<primitive: VMprObjectBasicAtPut>
	^self primitiveFailed!

sstBasicHash

	"Answer a SmallInteger that represents the receiver. Objects that are equivalent (=) must
	 answer the same value for the message #basicHash.

	 Do not override #basicHash in any subclass!!"

	<primitive: VMprObjectBasicHash>
	^ 0 !

sstBasicSize

	"Answer an Integer which represents the number of indexable fields in the receiver. This is
	 the same as the largest legal subscript.

	 Do not override #basicSize in any subclass!!"

	<primitive: VMprObjectBasicSize>
	^ self primitiveFailed !

sstClassField
	"Answer the actual class field of the receiver."

	<primitive: VMprObjectClass>
	^self primitiveFailed!

sstClassField: class
	"Change the actual class field of the receiver to be class."

	"*****  MEGA DANGEROUS  *****"

	" USE ONLY IF YOU KNOW WHAT YOU ARE DOING "

	<primitive: VMprObjectClassColon>
	^self primitiveFailed!

sstInstrumentContextBindings

	^LookupTable new!

sstInstVarAt: index

	<primitive: VMprObjectInstVarAt>
	^self primitiveFailed!

sstInstVarAt: anInteger put: anObject

	<primitive: VMprObjectInstVarAtPut>
	^self primitiveFailed!

sstIsArray

	"ACTION
		Answer true if the receiver is an array which can hold other non-primitive
		objects (e.g., other arrays).  In general this will only be true for instances
		of Array.  Be careful when redefining this method as it is used in several 
		marshalers and infrastructure code with specific semantics.

	RETURN VALUE
		<Boolean>"

	^false!

sstIsComponentName

	"ACTION
		Return false to indicate that the receiver is not a valid SST 
		component name.

	RETURN VALUE
		<false>"

	^false!

sstIsConfiguration

	"ACTION
		Return false to indicate that the receiver is not an SST configuration.

	RETURN VALUE
		<false>

	NOTES
		The class SstConfiguration and its subclasses implement this method to return true.
		Other classes may do as well."

	^false!

sstIsExportKey

	"ACTION
		Return false to indicate that the receiver is not an export key.

	RETURN VALUE
		<false>"

	^false!

sstIsFuture

	"ACTION
		Return false to indicate that the receiver is not a future.

	RETURN VALUE
		<false>"

	^false!

sstIsHandle
	"Answer false, that the receiver is not a handle.  We use this to get some 
	speed for #= since handles are used as import keys and thus as the
	keys in the import table."

	^false!

sstIsImportKey

	"ACTION
		Return false to indicate that the receiver is not an import key.

	RETURN VALUE
		<false>"

	^false!

sstIsMessage

	"ACTION
		Return false to indicate that the receiver is not an SST communication
		message.

	RETURN VALUE
		<false>"

	^false!

sstIsRemote

	"ACTION
		Return false to indicate that the receiver is not a remote object.

	RETURN VALUE
		<false>"

	^false!

sstIsSpace

	"ACTION
		Return false to indicate that the receiver is not object space.

	RETURN VALUE
		<false>"

	^false!

sstIsSystemObject

	"ACTION
		Return false to indicate that the receiver is not a system object.

	RETURN VALUE
		<false>"

	^false!

sstMemcpyFrom: start to: stop into: anOSOrBitObject startingAt: repStart
	"Copy bytes from byte offset start in the receiver up to and including
	 byte offset stop into anOSOrBitObject starting at byte index repStart.
	 Answer anOSOrBitObject.  All indices are zero-based and can be negative."

	<primitive: VMprOSObjectMemcpy>
	self primitiveErrorCode = PrimErrReadOnly ifTrue: [
		start to: stop do: [:i |
			anOSOrBitObject uint8At: (i - start + repStart) put: (self uint8At: i)
		].
		^anOSOrBitObject
	].
	^self primitiveFailed!

sstPerform: aSymbol

	"Send the receiver the unary message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message. Answer the result of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 0"

	<primitive: VMprObjectPerform>
	^self primitiveFailed
!

sstPerform: aSymbol with: anObject

	"Send the receiver the binary or keyword message indicated
	 by the argument aSymbol. The argument aSymbol is the
	 selector of the message, and the argument anObject is the
	 argument of the message to be sent. Answer the result of
	 the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 1"

	<primitive: VMprObjectPerform>
	^self primitiveFailed!

sstPerform: aSymbol with: firstObject with: secondObject

	"Send the receiver the keyword message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message, and the arguments firstObject and
	 secondObject are arguments of the message to be sent.
	 Answer the result of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 2"

	<primitive: VMprObjectPerform>
	^self primitiveFailed!

sstPerform: aSymbol
	with: firstObject
	with: secondObject
	with: thirdObject

	"Send the receiver the keyword message indicated by the
	 argument aSymbol. The argument aSymbol is the selector of
	 the message, and the arguments firstObject, secondObject
	 and thirdObject are arguments of the message to be sent.
	 Answer the result of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if the number of
	 arguments expected by aSymbol is not 3"

	<primitive: VMprObjectPerform>
	^self primitiveFailed!

sstPerform: aSymbol withArguments: anArray

	"Send the receiver the message indicated by the argument
	 aSymbol. The argument aSymbol is the selector of the
	 message, and the argument anArray is an Array containing
	 the arguments of the message to be sent. Answer the result
	 of the method invocation.

	 Fail if aSymbol is not a Symbol. Fail if anArray is not an
	 Array. Fail if the number of arguments expected by aSymbol
	 is not = anArray size."

	<primitive: VMprObjectPerformWithArguments>
	^self primitiveFailed!

sstPrintString

	| p state |
	p := Processor activeProcess.
	^[
		state := p sstInSystemObject: true.
		self printString]
			ensure: [p sstInSystemObject: state]!

sstSize
	"Be careful to send this to the sstultimateTarget as this directly
	accesses the receiver with no forwarding etc."

	<primitive: VMprObjectBasicSize>
	^ self primitiveFailed !

sstToBeFixed!

storeOn: aStream

	"Append to the argument aStream a sequence of characters that is a
	 Smalltalk expression whose evaluation creates an object similar to
	 the receiver.

	 The general format is
		(class-name basicNew
			instVarAt: index put: variable;
			basicAt: index put: element;
			yourself)
	 or
		((class-name basicNew: size )
			instVarAt: index put: variable;
			basicAt: index put: element;
			yourself)

	Fail if aStream is not a kind of Stream
	Fail if the receiver references itself either directly or indirectly
	via its instance variables."

	"This method avoids the use of printString or storeString messages"

	aStream
		nextPutAll: '((' ;  "$NON-NLS$"
		nextPutAll: self class name;
		nextPutAll: ' basicNew' .  "$NON-NLS$"
	self class isVariable ifTrue:
		[aStream nextPutAll: ': ' .  "$NON-NLS$"
		self basicSize printOn: aStream].
	aStream
		nextPut: $) ;
		cr.

	1 to: self class instSize do: [ :instVarIndex |
		aStream
			tab;
			nextPutAll: 'instVarAt: ' .  "$NON-NLS$"
		instVarIndex printOn: aStream.
		aStream nextPutAll: ' put: ' .  "$NON-NLS$"
		(self instVarAt: instVarIndex) storeOn: aStream.
		aStream
			nextPut: $; ;
			cr].

	1 to: self basicSize do: [ :index |
		aStream
			tab;
			nextPutAll: 'basicAt: ' .  "$NON-NLS$"
		index printOn: aStream.
		aStream nextPutAll: ' put: ' .  "$NON-NLS$"
		(self basicAt: index) storeOn: aStream.
		aStream
			nextPut: $;;
			cr].

	aStream
		tab;
		nextPutAll: 'yourself)'.  "$NON-NLS$"!

storeString

	"Answer a String containing a sequence of characters that is a
	 Smalltalk expression whose evaluation creates an object similar to
	 the receiver.

	 The general format is
		(class-name basicNew
			instVarAt: index put: variable;
			basicAt: index put: element;
			yourself)
	 or
		((class-name basicNew: size )
			instVarAt: index put: variable;
			basicAt: index put: element;
			yourself) "

	| writeStream |
	self storeOn: (writeStream := WriteStream on: (Locale current preferredStringClass new: 10)).
	^writeStream contents asReducedString!

stsImageNamed: imageName

	^StsImageManager iconFromSelector: imageName!

stsIsUnix

	^StsPowerTools graphicsModuleName isNil!

stsRequestCodeAssistOn: aTextWidget contextProvider: aContentAssistContextProvider
	"Request code assistance on the provided @aTextWidget. 
	 @aContentAssistContextProvider is used to provide the surrounding
	 context for the new code assistant.  See implementors of
	 #caProvideContextFor: to see what this object must answer.

	 The <StsCodeAssist> returned must be connected at some later point
	 Call #connect on the <StsCodeAssist> returned from this method to activate
	 code assistance for the text editor"

	"Return nil if StsPowerTools is not enabled"
	StsPowerTools enabled
		ifTrue: [| codeAssistantFactory |
			codeAssistantFactory := StsPowerTools codeAssistant.
			codeAssistantFactory notNil
				ifTrue: [^codeAssistantFactory on: aTextWidget for: aContentAssistContextProvider]].

	^nil!

subclassResponsibility

	"Display a message indicating that a message specified in a
	 superclass of the receiver should be implemented by
	 receiver's class."

	self error: (NlsCatKRN indexedMsg: 29)  "$NLS$ The receiver should have implemented this message."
!

system
	^GlobalConfiguration default!

timesJournal: aJournal
	^aJournal multiplyNumber: self!

toDate
	^self unsupportedRequest!

TranscriptShow
	"Print the receiver to the Transcript. Return false
	 so that any breakpoints will continue"

	| string |
	string := self isString
		ifTrue: [self]
		ifFalse: [self printString].
	Transcript cr; show: string.
	^false!

TranscriptShowWithTime
	"Print the receiver to the Transcript. Also print the current time.
	 Return false so that any breakpoints will continue"

	| string |
	string := self isString
		ifTrue: [self]
		ifFalse: [self printString].
	Transcript cr; show: '<'; show: Time now printString; show: '> '; show: string.
	^false!

triggerAboutToManageWidget
	"Private - Trigger the #aboutToManageWidget event."
	"Do nothing"!

triggerAboutToOpenWidget
	"Private - Trigger the #aboutToOpenWidget event."
	"Do nothing"!

triggerEvent: x

self signalEvent: x
!

triggerOpenedWidget
	"Private - Trigger the #openedWidget event."
	"Do nothing"!

typeID

	"Answer the string which is sent in the stream to indicate the type (class)
	 of the object."

	^self class name!

unloadCharacter
	^self class asString first!

unloadToMFStream: aStream
	self unloadToStream: aStream!

unmarkForReplacement
	"Unmark the receiver as an object that has a loading replacement. Objects not marked will not be 
	 detected by the default loading replacer provider with an instance of ObjectLoader."

	<sysprim: VMsysprUnmarkForReplacement>
	^self primitiveFailed!

unsupportedRequest
	^(self createError description: 'unsupported method') signal!

update: anObject

	"Perform the necessary action pertaining to the fact that an object
	 on which the receiver depends has changed.  The argument anObject
	 helps to identify the kind of action the receiver should take.
	 Answer self."

	"Do nothing by default."!

vaaIsBasicView

	^false!

vaaIsDrawnButton

	^false!

vaaIsLabel

	^false!

vaaIsPushButton

	^false!

vaaStyleMap

	^AbtOrderedDictionary new!

validateConstantOrNonconstant: anArgumentDescription
	^anArgumentDescription validateNonconstant: self!

value
	"Return the result of evaluating the receiver.  The default result is the receiver itself."

	^ self!

valueIn: aContext
	^self!

verifyImage
	"General Information

	How to start image: use the -l<log filename> command line option.

	What is the output: output information to the tty transcript.
   		Success is indicated by the string {VI:} 
  		Failure (i.e. a corrupted image) records information about the segment and pointers    involved.

	How to use verification method:
	   To debug a particular call that you think is corrupting memory use the following    approach. 


	  TranscriptTTY default cr; show: 'Before call'. 
	  self verifylmage. 
	  self do the call . . . 
	  TranscriptTTY default show: 'After call'. 

	   Check the log file for errors after a crash. 

	Specific Information
		This is the most general call. This will walk all of memory, process stacks and internal VM structures. 
		This can take alot of time so this routine should be used to narrow down the area in which to search 
		for the problem. A 100 Mhz Pentium will execute the verifylmage in about 6 seconds. A verifylmage
		 call will include a call to verifyMemorySpaces and verifyVMSlots.

	When to use this call:

		If the problem area is unknown and you are experiencing random crashes, call this routine every 
		1/2 hour or so. Try to keep track of what you were doing since you last called the routine. This will let 
		you zero in on the problem. 

	"

	 <primitive: 'esverifydll':VMprEsVerifyImage>
	 ^ self primitiveFailed !

verifyMemorySpaces
	"General Information

	How to start image: use the -l<log filename> command line option.

	What is the output: output information to the tty transcript.
   		Success is indicated by the string {VI:} 
  		Failure (i.e. a corrupted image) records information about the segment and pointers    involved.

	How to use verification method:
	   To debug a particular call that you think is corrupting memory use the following    approach. 


	  TranscriptTTY default cr; show: 'Before call'. 
	  self verifylmage. 
	  self do the call . . . 
	  TranscriptTTY default show: 'After call'. 

	   Check the log file for errors after a crash. 

	Specific Information
		This call walks all of object memory to determine object memory is valid. This call skips the 
		internal structures. This call can be used to determine if object memory is being written into. 
		This call can run slightly faster but still takes about 5 seconds on a 100 Mhz Pentium.

	When to use this call:

		This call should be used if verifylmage itself crashes. This can be used to determine if the 
		VM structures or memory are corrupt.
	"

	 <primitive: 'esverifydll':VMprEsVerifyMemorySpaces>
	 ^self primitiveFailed!

verifyVMSlots
	"General Information

	How to start image: use the -l<log filename> command line option.

	What is the output: output information to the tty transcript.
   		Success is indicated by the string {VI:} 
  		Failure (i.e. a corrupted image) records information about the segment and pointers    involved.

	How to use verification method:
	   To debug a particular call that you think is corrupting memory use the following    approach. 


	  TranscriptTTY default cr; show: 'Before call'. 
	  self verifylmage. 
	  self do the call . . . 
	  TranscriptTTY default show: 'After call'. 

	   Check the log file for errors after a crash. 

	Specific Information
	
		This call only verifies the process stacks, and internal VM structures so it is faster. 
		This call runs in about 2 ms on 100 Mhz Pentium.

	When to use this call:

		When you suspect then the return value from a primitive is invalid or a primitive call is 
		corrupting memory. This call can be used to verify that the Smalltalk stack contains valid 
		or invalid objects.

	
	"

	 <primitive: 'esverifydll':VMprEsVerifyVMSlots>
	 ^self primitiveFailed!

visitFor: aVisitor
	^aVisitor visitObject: self!

wbIsArray
	"Answer whether the receiver is an Array."

	^false!

wbIsBlock
	"Answer whether the receiver is a Block."

	^false!

wbIsBoolean
	"Answer whether the receiver is either true or false.
	 The method name was picked to avoid conflict with VA"

	^false!

wbIsCgDrawable
	"Answer whether the receiver is a CgDrawable"

	^false!

wbIsCollection
	"Answer whether the receiver is a Collection"

	^false!

wbIsColor
	"Answer whether the receiver is a Color"

	^false!

wbIsCwFormConstraint
	"Answer whether the receiver is a CwFormConstraint"

	^false!

wbIsCwWidget
	"Answer whether the receiver is a CwWidget"

	^false!

wbIsDictionary
	"Answer whether the receiver is a Dictionary.
	 The method name was picked to avoid conflict with VA"

	^false!

wbIsFrame
	"Answer true if the receiver is a Frame."

	^false!

wbIsIcon
	"Answer whether the receiver is a Icon"

	^false!

wbIsMessage
	"Answer whether the receiver is a Message"

	^false!

wbIsPixmap
	"Answer whether the receiver is a Pixmap"

	^false!

wbIsPixmapOrIcon
	"Answer whether the receiver is a Pixmap or Icon"

	^self wbIsPixmap | self wbIsIcon!

wbUnaryCallbackHandler: aWidget selector: selectorAndClientData callData: theCallData

	| selector |
	(selector := selectorAndClientData wbIsArray
		ifTrue: [selectorAndClientData first]
		ifFalse: [selectorAndClientData]) wbIsBlock
		ifTrue: [selector value]
		ifFalse: [
			| argCount |
			(argCount := selector argumentCount) == 0
				ifTrue: [self perform: selector]
				ifFalse: [
					| clientData |
					clientData := selectorAndClientData last.
					argCount == 1
						ifTrue: [
							self 
								perform: selector
								with: (clientData isSymbol
									ifTrue: [aWidget perform: clientData]
									ifFalse: [
										clientData ifNil: [
											theCallData class == WbExtendedCallbackData
												ifTrue: [theCallData first]
												ifFalse: [theCallData ifNil: [aWidget extendedWidgetOrSelf]]]])]
						ifFalse: [
							self 
								perform: selector
								with: (clientData isSymbol
									ifTrue: [aWidget perform: clientData]
									ifFalse: [
										theCallData class == WbExtendedCallbackData
											ifTrue: [theCallData first]
											ifFalse: [theCallData ifNil: [aWidget extendedWidgetOrSelf]]])
								with: (clientData ifNil: [aWidget extendedWidgetOrSelf])]]]!

wfIsBoolean
	^false!

wfIsNil
	^false!

write: aContext
	"To avoid checking if nil or proxy"!

write: aContext forKey: anObject
	"To avoid checking if nil or proxy"!

writeDataFor: aData
	self value isJournal
		ifTrue: [aData writeJournalData: self]
		ifFalse: [aData writeData: self]!

writeLocal: aContext
	"To avoid checking if nil or proxy"!

writeLocal: aContext forKey: anObject
	"To avoid checking if nil or proxy"!

yourself

	"Answer the receiver."

	^self! !

!Object privateMethods !

abeAcceptsParentEditPart: anEditPart

	^self class abeAcceptsParentEditPart:  anEditPart
!

abeAddRuntimePrerequisitesTo: aSet

	aSet add: self class controller rootApplication!

abeInSubpartSpace: anObjectSpace
		"Subpart space is the objectSpace of the part builder"

	^self!

abeIsPartBuilder
		"This is not a part builder"

	^false!

abeLifelessInSubpartSpace: anObjectSpace
	"Subpart space is the objectSpace of the part builder"

	^self abeInSubpartSpace: anObjectSpace!

abeMethod
	"Private - Answer the current compiled method."

	^self abrSender: 2!

abeMethodString
	"Private - Answer the current compiled method as a printString"

	^(self abrSender: 2) printString!

abePrimaryPartClass

	^self class abePrimaryPartClass!

abrAsObservableObject

	^(self abtIsObservableObject or: [self abrIsImmutable])
		ifTrue: [self]
		ifFalse: [AbtObservableWrapper new contents: self]!

abrAsSQLStringForDatabaseMgr: aDatabaseManager
	"Answer the appropriate representation for usage in an SQL statement."

	^aDatabaseManager sQLStringForObject:self.!

abrDereferenced

	^self!

abrInstancesAreImmutable

	^false!

abrIsAccessSet
	"Answer false, the receiver is NOT an access set."

	^false!

abrIsDatabaseConnection
	"Answer true if the receiver is an AbtDatabaseConnection."

	^false!

abrIsImmutable

	^self class abrInstancesAreImmutable!

abrIsIndexableCollection
	"Answer true if the receiver is an indexable collection, 
		else answer false."

	^false.!

abrIsQuerySpec
	"Answer false, the receiver is a stored proc spec."

	^false!

abrMessageToSignalEvent: anEventSymbol

	^AbtMessageToSignalEvent new
		receiver: self;
		event: anEventSymbol!

abrPartiesInterestedIn: anEvent
		"Return all who are interested in knowing when
			anEvent is signalled."

	^AbtCLDTAdditions eventDependentsFor: anEvent of: self!

abrRemoveInterestIn: aFeatureName selector: aFeatureSelector from: obj
	"Remove all the messages dependent on the feature named 
	aFeatureName where the receiver of the message is obj.
	aFeatureName may be the name of an event or an attribute
	of the receiver. Retrun the receiver. Fail if the receiver does
	not have an event or attribute by the name aFeatureName.
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_eventName,
	with colons replaced by _ (e.g. for the event named #clicked, the hint 
	would be #IS_clicked). Most implementations of 
	abrRemoveInterestIn:selector:from: can use this hint to significantly speed 
	up the lookup of the event whose name is eventName.

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abrRemoveInterestIn: #clicked 
		selector: #IS_clicked from: Transcript.
	button abtPerformActionNamed: #click

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrRemoveInterestIn: #first 
		selector: #IS_first from: Transcript.
	collection abrAdd: 'hello world'

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
"

	^self abrRemoveInterestIn: aFeatureName 
		selector: aFeatureSelector 
		ifAbsent: [self class noSuchFeature: aFeatureName] from: obj!

abrRemoveInterestIn: aFeatureName selector: aFeatureSelector ifAbsent: aBlock from: obj
	"Remove all the messages dependent on the feature named 
	aFeatureName where the receiver of the message is obj.
	aFeatureName may be the name of an event or an attribute
	of the receiver. Retrun the receiver. Fail if the receiver does
	not have an event or attribute by the name aFeatureName.
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_eventName,
	with colons replaced by _ (e.g. for the event named #clicked, the hint 
	would be #IS_clicked). Most implementations of 
	abrRemoveInterestIn:selector:ifAbsent:from: can use this hint to significantly speed 
	up the lookup of the event whose name is eventName.

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abrRemoveInterestIn: #clicked 
		selector: #IS_clicked ifAbsent: [] from: Transcript.
	button abtPerformActionNamed: #click

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrRemoveInterestIn: #first 
		selector: #IS_first ifAbsent: [] from: Transcript.
	collection abrAdd: 'hello world'

	Executing the above code will have no effect because the
	dependency has been removed before the event is signalled.
	Commenting the line containing abrRemoveInterestIn:from: and
	then executing the code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
"

	 (self abtFeatureNamed: aFeatureName selector: aFeatureSelector ifAbsent: [^aBlock value])
		 removeInterestIn: self from: obj!

abrSender
	"Private - Answer the compiled method representing the 
		sender of the receiver's current message"

	^self abrSender: 3!

abrSender: stackLevel
	"Private - Answer the compiled method representing 
		the sender at 'stackLevel'."

	| process |
	(stackLevel isInteger not
		or:[ stackLevel < 0 
		or:[ (process := Processor activeProcess) numberOfFrames <= stackLevel ] ] ) ifTrue:[ ^nil ].
	^process methodAtFrame: stackLevel!

abtAddAllItemsToFreeFormPopUpMenu: aPopUpMenu for: aFreeFormEditPart

	self abtAddOwnItemsToFreeFormPopUpMenu: aPopUpMenu for: aFreeFormEditPart.
	self class abtAddItemsAfterOwnItemsToFreeFormPopUpMenu: aPopUpMenu for: aFreeFormEditPart!

abtAddAllItemsToPopUpMenu: aPopUpMenu for: anEditPart

	self abtAddOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart.
	self class abtAddItemsAfterOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart!

abtAddCombinableMenuItemsTo: aDictionary for: anEditPart

	^self class abtAddCombinableMenuItemsTo: aDictionary for: anEditPart.!

abtAddOwnItemsToFreeFormPopUpMenu: aPopUpMenu for: aFreeFormEditPart
	"Add the items for the reciver to the free form popup menu.
	 This method will only be called during the creation of the
	 popup for an object when the object itself is being edited.
	 Hence, the free form popup menu represents the object
	 being edited."

	^self class abtAddOwnItemsToFreeFormPopUpMenu: aPopUpMenu for: aFreeFormEditPart.!

abtAddOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart
	"Add the items for the reciver to the popup menu.
	This method will only be called to during the creation of the
	popup for an object if the object is the only selection."

	^self class abtAddOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart.!

abtAddParentItemsToPopUpMenu: aPopUpMenu for: anArrayOfEditParts of: anEditPart

	^self class abtAddParentItemsToPopUpMenu: aPopUpMenu for: anArrayOfEditParts of: anEditPart!

abtAddParentItemsToPopUpMenu: aPopUpMenu forConnections: anArrayOfEditParts of: aParentEditPart

	self class abtAddParentItemsToPopUpMenu: aPopUpMenu forConnections: anArrayOfEditParts of: aParentEditPart

!

abtAddPartListItemsToPopUpMenu: aPopUpMenu for: anEditPart
	"modify the default popup menu for anEditPart as necessary.  Default is to use
		the default popup menu as is"

	self abtAddPartListOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart.

	(aPopUpMenu children size > 0)
		ifTrue: [(aPopUpMenu createSeparator: 'parent separator' argBlock: nil) manageChild].

	anEditPart parentPart addPartListParentItemsToPopUpMenu: aPopUpMenu for: (Array with: anEditPart)!

abtAddPartListOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart

	^self class abtAddPartListOwnItemsToPopUpMenu: aPopUpMenu for: anEditPart!

abtAddPartListParentItemsToPopUpMenu: aPopUpMenu for: anArrayOfEditParts of: anEditPart

	^self class abtAddPartListParentItemsToPopUpMenu: aPopUpMenu for: anArrayOfEditParts of: anEditPart.!

abtAddTo: aDictionary at: aKey

	aDictionary at: aKey put: self!

abtAddToBeFinalized
	"Add the receiver to the list of system objects which must be 
	notified when they are about to become garbage. When an object 
	is about to become garbage, there are NO references to that object
	in the system."

	self onFinalizeDo: #abtFinalize!

abtAddTopLevelItemsToPopUpMenu: aPopUpMenu for: anEditPart

	^self class abtAddTopLevelItemsToPopUpMenu: aPopUpMenu for: anEditPart.!

abtAllFeatureBuilders

	^self abtMergedFeatureBuilders!

abtAllPreferredConnectionFeatures

	^self class abtAllPreferredConnectionFeatures!

abtAsAddress
	"respond with the normal #asAddress if it exists."

	^self abtAsExternalPassedPointer!

abtAsListItemCollection

	^Array with: self!

abtAsNormalizedTopicID
	"Answer the receiver as an Integer if it really looks like one,
	otherwise answer self."

	^self!

abtAttachPart
	"Do nothing. This selector exists only for historical purposes.
	This implementation is maintained in the image for compatibility
	with older generated code. Return self"

	!

abtAttributes

	^self features select: [: feature | feature isAttribute]!

abtBasicRemoveAllInterest
	""

	AbtCLDTAdditions removeEventDependentsFor: self!

abtCaptureApplicationInfo

	"Default is to do nothing. Look for extensions of EpImage in other apps
		for implementations that do something useful."!

abtCloneWithRecursionSet: objectsAlreadyCloned

	"Answer a copy of the the receiver, with its own copy of each
	 instance variable."

	^objectsAlreadyCloned at: self
		ifAbsent: 
			[self abtPrimitiveCloneWithRecursionSet: objectsAlreadyCloned]
	!

abtConvertValue: aValue forAttribute: anAttribute in: anObject

	^aValue!

abtConvertValue: aValue forParameter: parameterSpec in: actionProvider
		"aValue is gotten from my attribute or executing my action or my script.  
		My subclasses may wish to convert it so that it would be of the right type
		for parameterSpec in an action of actionProvider.  The default is to do nothing."

	^aValue!

abtDefaultPropertyName
	"Answer the name of the default property of the receiver."

	"Note:
		If the receiver does not have a default property, answer nil."

	^nil!

abtDeleteSubparts: aCollection for: anEditPart

	^self class abtDeleteSubparts: aCollection for: anEditPart!

abtDependentsOfProperty: aProperty
	"Answer the properties dependent on the specified property."

	| dependentProperties dependencies |

	dependentProperties := OrderedCollection new.
	self abtProperties do: [:property |
		dependencies := property dependencies.
		(dependencies notNil and: [dependencies includes: aProperty name])
			ifTrue:
				[dependentProperties add: property]].

	^dependentProperties!

abtDereferencedValue
	"Answer the dereferenced value of the receiver."

	^self abrDereferenced!

abtDesignTimeProperties
	"Answer the design time properties of the receiver."

	"Note:
		The value answered is a dictionary where the keys are the property
		names and the values are the properties. A property must conform
		to the property protocol (AbtProperty).

		It is the responsibility of the sender to set the target of each property
		to the appropriate object."

	| featureBuilders designTimeProperties |

	featureBuilders := self abtFeatureBuilders select: [:aFeatureBuilder |
		(aFeatureBuilder isPropertyIn: self) and: [aFeatureBuilder name ~= #self]].

	##PTR = ##PTR10554.
	"Remove #framingSpec property if current part has no framingSpec."
	((featureBuilders includesKey: #framingSpec) and: [self framingSpec isNil])
		ifTrue: [featureBuilders removeKey: #framingSpec].

	designTimeProperties := Dictionary new: featureBuilders size.
	featureBuilders keysAndValuesDo: [:aKey :aValue |
		(aValue isDesignTimePropertyIn: self)
			ifTrue: [designTimeProperties at: aKey put: aValue asProperty]].

	^designTimeProperties!

abtDisplayNameOfProperty: aProperty
	"Answer the display name of the specified property."

	^aProperty displayName!

abtDisplayPolicyOfProperty: aProperty
	"Answer the display policy of the specified property with the current
	 value displayed. A display policy is any object that responds to the
	 #ew...Using: protocol."

	| propertyValue propertyData |

	propertyValue := self abtAtAttribute: aProperty name ifAbsent: [nil].
	propertyData := AbtPartPropertyData new
		property: aProperty;
		valuesSource: self;
		yourself.

	^aProperty displayPolicyIn: self
		with: propertyValue
		propertyData: propertyData!

abtDisplayString
	"Answer the string representation of the receiver when displaying the
	 receiver as a property value."

	^self abrIsImmutable
		ifTrue: [self printString]
		ifFalse: ['(%1)' bindWith: self class name asString]  "$NON-NLS$"!

abtEditPolicyOfProperty: aProperty
	"Answer the edit policy of the specified property with the initial value
	 set to the current value. An edit policy is an instance of any subclass
	 of EwEditPolicy. If nil is answered, the property is considered read-only."

	| propertyValue propertyData |

	propertyValue := self abtAtAttribute: aProperty name ifAbsent: [nil].
	propertyData := AbtPartPropertyData new
		property: aProperty;
		valuesSource: self;
		yourself.

	^aProperty editPolicyIn: self
		with: propertyValue
		propertyData: propertyData!

abtEstimatedFirstIndex
	"Public - answer the estimated first index within the receiver."
	"04.01.93 gwc"

	^self abtEstimatedSize > 0
		ifTrue:[ 1 ]
		ifFalse:[ 0 ].!

abtEstimatedLastIndex
	"Public - answer the estimated last index within the receiver."
	"04.01.93 gwc"

	^self abtEstimatedSize!

abtEstimatedSize
	"Public - answer the estimated size of the receiver."
	"04.01.93 gwc"

	^self size!

abtEventDependents

	^AbtCLDTAdditions eventDependentsOf: self!

abtEvents

	^self features select: [: feature | feature isEvent]!

abtExecutableFeatureNamed: aName

	^self abtFeatureNamed: aName ifAbsent: [nil]!

abtExecutableFeatureNamed: aName selector: aSelector

	^self abtFeatureNamed: aName selector: aSelector ifAbsent: [nil]!

abtFeatureBuilderNamed: aName

	^self abtFeatureBuilderNamed: aName ifAbsent: [self class noSuchFeature: aName]!

abtFeatureBuilderNamed: aName ifAbsent: aBlock

	| ans |
	ans := self abtPrivateFeatureBuilderNamed: aName ifAbsent: [nil].
	^ans == nil	
		ifTrue: [^self class abtMergedFeatureBuilderNamed: aName  ifAbsent: aBlock]
		ifFalse: [ans]	
	!

abtFeatureBuilders

	^self class abtMergedFeatureBuilders, 
		self abtPrivateInterfaceBuilder featureBuilders!

abtFeatureNamed: aName

	^self abtFeatureNamed: aName ifAbsent: [self class noSuchFeature: aName]!

abtFeatureNamed: aName ifAbsent: aBlock

	| ans |
	ans := self abtPrivateInterfaceSpecFeatureNamed: aName ifAbsent: [nil].
	^ans == nil	
		ifTrue: [^self class abtPrimitiveFeatureNamed: aName  ifAbsent: aBlock]
		ifFalse: [ans]	
	!

abtFeatureNamed: aFeatureName selector: aFeatureSelector

	| ans |
	ans := self abtPrivateInterfaceSpecFeatureNamed: aFeatureName ifAbsent: [nil].
	^ans == nil	
		ifTrue: [^self class abtInstanceFeature: aFeatureSelector]
		ifFalse: [ans]	
		!

abtFeatureNamed: aFeatureName selector: aFeatureSelector ifAbsent: aBlock

	| ans |
	ans := self abtPrivateInterfaceSpecFeatureNamed: aFeatureName ifAbsent: [nil].
	^ans == nil	
		ifTrue: [^self class abtInstanceFeature: aFeatureSelector ifAbsent: aBlock]
		ifFalse: [ans]	
			!

abtFinalize
	"The default action is to do nothing."

	^self!

abtFormat
	"Public - answer a converter suitable for the receiver."
 
	^self class abtInstanceFormat!

abtGenerateArchivalCodeOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated
		"Store the object on a stream"

	(self recursiveAccessCheck: alreadyGenerated) ifTrue: [
		^AbtCodeGeneratorContext abtGenerationRecursionMessage: self class name].

	self abtPrimGenerateCodeOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated.

	self recursiveAccessClear: alreadyGenerated.
!

abtGenerateAttribute: attrAssoc on: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated      
		"Append the ASCII representation of the                                       
		 receiver to aStream from which the                                           
		 receiver can be reinstantiated."     

	| attrVal |                                        
																				
	(attrAssoc key == self abtSelfReferenceSymbol or: [attrAssoc value isReadOnlyAttributeIn: self])                     
		ifFalse: [	attrVal := (attrAssoc value getValueIn: self).
			attrVal == nil ifFalse: [
				aStream cr;                                                                
					nextPutAll: aCodeGeneratorContext indentationString;                       
					nextPutAll: 'valueOfAttributeNamed: '.                                     
				attrAssoc key abtGenerateCodeOn: aStream 
					context: aCodeGeneratorContext recursionSet: alreadyGenerated.     
				aStream nextPutAll: ' put: ('.                                              
				attrVal abtGenerateCodeOn: aStream 
					context: aCodeGeneratorContext recursionSet: alreadyGenerated.            
				aStream nextPutAll: ');']]!

abtGenerateCodeFromAttributesOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated          
		"Append the ASCII representation of the                                       
		 receiver to aStream from which the                                           
		 receiver can be reinstantiated."                                             
																				
	self abtPrimGenerateCodeFromAttributesOn: aStream 
		context: aCodeGeneratorContext recursionSet: alreadyGenerated          
!

abtGenerateCodeOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated
		"Store the object on a stream"

	(self recursiveAccessCheck: alreadyGenerated) ifTrue: [
		^AbtCodeGeneratorContext abtGenerationRecursionMessage: self class name].

	self abtPrimGenerateCodeOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated.

	self recursiveAccessClear: alreadyGenerated.
!

abtGetValueOfAttribute: attribute
		"get the value of attribute"

	^attribute == nil
		ifTrue: [nil]
		ifFalse: [attribute getValueIn: self].!

abtGetValueOfAttributeNamed: anAttributeName selector: aSelector
		"get the value of anAttributeName"

	| attribute |
	^(attribute := self abtExecutableFeatureNamed: anAttributeName selector: aSelector) == nil
		ifTrue: [nil]
		ifFalse: [attribute getValueIn: self].!

abtHasCustomPropertiesDialog
	"Answer true if the receiver has a custom properties dialog."

	^self class abtHasCustomPropertiesDialog!

abtIncompatiblePropertyNames
	"Answer the names of any properties of the receiver that are
	 incompatible with the same property of another object."

	^self class abtIncompatiblePropertyNames!

abtInImageRestore

	^AbtCwBaseAdditionsApp abtInImageRestore!

abtInstanceBackgroundGraphicsDescriptor
		"Answer a new graphicsDescriptor with its moduleName and id
		filled in which is used as a background graphic for another graphic.
		Default is to ask the class to do it"
		"tdt (09-03-92) new"

	^self class abtInstanceBackgroundGraphicsDescriptor!

abtInstanceGraphicsDescriptor
		"Return the descriptor for the graphic of the object."
	
	^self class abtInstanceGraphicsDescriptor!

abtInternalError

	self error: 'Internal Error' 	"Does not need NLSed - only internal errors cause this"!

abtIsChildMovable: aPartClass
	"This message is sent to the parent visualPart for a new part during creation of the editPartInputPolicy.
	This method should be overridden by parents that do not allow their children to be moved"

	^aPartClass abtIsChildMovable!

abtIsChildSizable: aChild
	"This message is sent to the parent visualPart for a new part during creation of the editPartInputPolicy.
	This method should be overridden by parents that do not allow their children to be sized"

	^aChild class abtIsChildSizable!

abtIsDate

	^false!

abtIsDateNormalizationRow

	^false!

abtIsDependentsCollection

	^false!

abtIsDirectedMessage

	^false
!

abtIsDisplayPolicy
	"Answer true if the receiver is a display policy."

	^false!

abtIsGraphicalObject

	^false!

abtIsListItemCollection

	^false!

abtIsNlsRequest

	^false!

abtIsObservableObject
	"The assumption is that if an object answers true to this method,
	it is responsible for signalling it's own primitive events when an
	attribute is changed or an action is performed.

	If the object ansers false, an observable wrapper will be created for
	it that will take care of event signalling."

	^self class abtIsObservableObjectClass!

abtIsomorphicClasses
	
	^nil!

abtIsProcess

	self deprecated: 'Use #isProcess instead' in: 'V8.6.1'.
	^ self isProcess!

abtIsPublicInterfaceSameAs: anObject

	^self class = anObject class!

abtIsPureDBString

	^false!

abtIsSequenceableCollection

	^false!

abtIsSupportedOnCurrentPlatform

	^true!

abtIsTypeOf: aType

	^self class abtIsTypeOf: aType!

abtIsUIProcess

	^false!

abtIsValidValue: aValue ofProperty: aProperty
	"Answer true if the specified value is a valid value of the specified
	 property. If the value is not valid, answer either false or an AbtError
	 object. If an AbtError object is answered, its error text may be displayed."

	| propertyData |

	propertyData := AbtPartPropertyData new
		property: aProperty;
		valuesSource: self;
		yourself.

	^aProperty isValidValueIn: self
		with: aValue
		propertyData: propertyData!

abtIsWidget

	^false!

abtMarker: aSymbol
	"Private - use this method to mark code which needs to be reworked, removed, etc.
		You can then find all senders of #marker: to find all marked methods
		or you can look for all senders of the symbol that you sent to #marker: to
		find a category of marked methods."
	
	"Example:
		!!MyCollection publicMethods !!

		add: anObj
			self marker: #obsolete;
			^super add: anObj. !! !!
	"
			!

abtMergedFeatureBuilders

	^AbtOrderedDictionary new!

abtMergedInterfaceSpec

	^self class mergedInterfaceSpec!

abtMqAttemptTableCcsidConversion: aString

	| modifiedCs |

	"Strip of the 'IBM-' if it exists.  If this leaves only a number, go with that,
	otherwise, look up the result in our ccsid conversion table."

	modifiedCs := ((aString indexOfSubCollection: 'IBM-' startingAt: 1) == 1)
		ifTrue: [ aString copyFrom: 5 to: aString size ]
		ifFalse: [ aString ].

	(modifiedCs conform: [ :each | each isDigit ]) ifTrue: [ ^modifiedCs asNumber ].
	^AbtMQConstants::MqccsidConversionTable at: modifiedCs ifAbsent: [ nil ]!

abtMqCcsid

	| cp |

	^(cp := self codePage) isString
		ifTrue: [ self abtMqConvertStringToCcsid: cp ]
		ifFalse: [ cp ]!

abtMqConvertStringToCcsid: aString

	"Attempt to lookup the passed string in our Ccsid conversion table.  If it is not found,
	we default to setting the ccsid to match the ccsid of the queue manager."

	| ccsid |

	^(ccsid := self abtMqAttemptTableCcsidConversion: aString) isNil
		ifTrue: [ AbtMQConstants::MqccsiQMgr ]
		ifFalse: [ ccsid ]!

abtOperationClass
	
	^self class!

abtOwner
	"In general, objects can't tell you who their owner is"

	^nil!

abtOwnerOfProperty: aProperty
	"Answer the owner the specified property."

	^self!

abtPerformActionNamed: actionName
	"Perform the action named actionName and return the result
	of performing the action. Do not provide any parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the receiver requires any parameters for this action.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to nil.

	Examples:

	OrderedCollection new
		abtPerformActionNamed: #size.

	1@1
		abtPerformActionNamed: #x
"

	^(self abtFeatureNamed: actionName) performIn: self!

abtPerformActionNamed: actionName arguments: args
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the size of args does not match the number of 
	parameters for this action required by the receiver.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformActionNamed: #add:
		arguments: #('string').

	2@2
		abtPerformActionNamed: #x
		arguments: #(1) 
"

	^(self abtFeatureNamed: actionName) performIn: self arguments: args!

abtPerformActionNamed: actionName ifAbsent: aBlock
	"Perform the action named actionName and return the result
	of performing the action. Do not provide any parameters to this
	action. Return the result of evaluating the block aBlock if the receiver 
	does not support an action by the name actionName. Fail if the receiver 
	requires any parameters for this action.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to nil.

	Examples: 

	OrderedCollection new 
		abtPerformActionNamed: #sz
		ifAbsent: ['Not There']

"

	^(self abtFeatureNamed: actionName ifAbsent: [^aBlock value]) performIn: self!

abtPerformActionNamed: actionName ifAbsent: aBlock arguments: args
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Return the result of evaluating the block aBlock if the receiver 
	does not support an action by the name actionName. Fail if the size 
	of args does not match the number of parameters for this action required 
	by the receiver.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformActionNamed: #add
		ifAbsent: ['Not There']
		arguments: #('string') 
"

	^(self abtFeatureNamed: actionName ifAbsent: [^aBlock value]) performIn: self arguments: args!

abtPerformActionNamed: actionName selector: aSelector
	"Perform the action named actionName and return the result
	of performing the action. Do not provide any parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the receiver requires any parameters for this action.
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_actionName,
	with colons replaced by _ (e.g. for the action named #click, the hint 
	would be #IS_click). Most implementations of 
	abtPerformActionNamed:selector: can use this hint to significantly speed 
	up the lookup of the action whose name is actionName.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to nil.

	Examples:

	OrderedCollection new 
		abtPerformActionNamed: #size
		selector: #IS_size
	"

	^(self abtFeatureNamed: actionName selector: aSelector) performIn: self!

abtPerformActionNamed: actionName selector: aSelector arguments: args
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the size of args does not match the number of 
	parameters for this action required by the receiver.
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_actionName,
	with colons replaced by _ (e.g. for the action named #click, the hint 
	would be #IS_click). Most implementations of 
	abtPerformActionNamed:selector:arguments: can use this hint to significantly speed 
	up the lookup of the action whose name is actionName.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformActionNamed: #add:
		selector: #IS_add_
		arguments: #('string') 
	"

	^(self abtFeatureNamed: actionName selector: aSelector) performIn: self arguments: args!

abtPerformActionNamed: actionName selector: aSelector ifAbsent: aBlock
	"Perform the action named actionName and return the result
	of performing the action. Do not provide any parameters to this
	action. Return the result of evaluating the block aBlock if the receiver 
	does not support an action by the name actionName. Fail if the receiver 
	requires any parameters for this action.
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_actionName,
	with colons replaced by _ (e.g. for the action named #click, the hint 
	would be #IS_click). Most implementations of 
	abtPerformActionNamed:selector:ifAbsent: can use this hint to significantly speed 
	up the lookup of the action whose name is actionName.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to nil.

	Examples:

	OrderedCollection new 
		abtPerformActionNamed: #sz
		selector: #IS_sz
		ifAbsent: ['Not There']
"

	^(self abtFeatureNamed: actionName selector: aSelector ifAbsent: [^aBlock value]) performIn: self!

abtPerformActionNamed: actionName selector: aSelector ifAbsent: aBlock arguments: args
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Return the result of evaluating the block aBlock if the receiver 
	does not support an action by the name actionName. Fail if the size 
	of args does not match the number of parameters for this action required 
	by the receiver.	aSelector is simply a HINT that is used to optimize the 
	execution speed of this call. aSelector should be a symbol of the form 
	#'IS_<actionName>', with colons replaced by _ (e.g. for the action named 
	#click, the hint would be #IS_click). Most implementations of 
	abtPerformActionNamed:selector:ifAbsent:arguments:
	can use this hint to significantly speed 
	up the lookup of the action whose name is actionName.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples:

	OrderedCollection new 
		abtPerformActionNamed: #add
		selector: #IS_add
		ifAbsent: ['Not There']
		arguments: #('string')

	"

	^(self abtFeatureNamed: actionName selector: aSelector ifAbsent: [^aBlock value]) performIn: self arguments: args!

abtPerformActionNamed: actionName with: arg
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the size of args does not match the number of 
	parameters for this action required by the receiver.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformActionNamed: #add:
		with: 'string'.

	2@2
		abtPerformActionNamed: #x
		with: 1 
"

	^self abtPerformActionNamed: actionName withArguments: (Array with: arg)!

abtPerformActionNamed: actionName withArguments: args
	"Perform the action named actionName and return the result
	of performing the action. Provide args as parameters to this
	action. Fail if the receiver does not support an action by the name 
	actionName. Fail if the size of args does not match the number of 
	parameters for this action required by the receiver.
	actionName may also be the name of any attribute of the receiver.
	In this case, the value of the attribute will be set to the value of the 
	first argument.

	Examples: 

	OrderedCollection new 
		abtPerformActionNamed: #add:
		withArguments: #('string').

	2@2
		abtPerformActionNamed: #x
		withArguments: #(1) 
"

	^self abtPerformActionNamed: actionName arguments: args!

abtPlatformReplacementClass

	^nil!

abtPrecompiledForMVS!

abtPrecompiledForWS!

abtPrimGenerateCodeFromAttributesOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated          
		"Append the ASCII representation of the                                       
		 receiver to aStream from which the                                           
		 receiver can be reinstantiated."                                             
																				
	aStream                                                                        
		nextPut: $(;                                                                  
		nextPutAll: self class name;                                                  
		nextPutAll: ' new'.                                                           
	aCodeGeneratorContext incrementIndentation.                                    
	self abtAttributes associationsDo: [: assoc |                                     
		self abtGenerateAttribute: assoc on: aStream                                   
					context: aCodeGeneratorContext recursionSet: alreadyGenerated].                                           
			aStream cr;                                                                  
				nextPutAll: aCodeGeneratorContext indentationString;                        
				nextPutAll: 'yourself)'.                                                    
																				
	aCodeGeneratorContext decrementIndentation.                                    
!

abtPrimGenerateCodeOn: aStream context: aCodeGeneratorContext recursionSet: alreadyGenerated
		"Store the object on a stream"

	^self storeOn: aStream.!

abtPrimHashBytes: aByteArrayOrString seed: aSeedInt

	<primitive: bytesHash32>

	^self primitiveFailed!

abtPrimHashInt: aSmallInt seed: aSeedSmallInt

	<primitive: intHash32>

	^self primitiveFailed!

abtPrimitiveCloneWithRecursionSet: objectsAlreadyCloned

	"Answer a copy of the the receiver, with its own copy of each
	 instance variable."

	|clone|
	self class isVariable
		ifTrue:  [clone := self class basicNew: self basicSize]
		ifFalse: [clone := self class basicNew].
	objectsAlreadyCloned at: self put: clone.

	1  to: self class instSize do: [ :instVarIndex |
		clone
			instVarAt: instVarIndex
			put: ((self instVarAt: instVarIndex) abtCloneWithRecursionSet: objectsAlreadyCloned)].

	1  to: self basicSize do: [ :index |
		clone basicAt: index put: ((self basicAt: index) abtCloneWithRecursionSet: objectsAlreadyCloned)].

	^clone!

abtPrintString

	^self printString!

abtPrintValueExpressionOn: aStream context: aContext recursionSet: alreadyGenerated

	self abtGenerateCodeOn: aStream context: aContext recursionSet: alreadyGenerated!

abtPrivateFeatureBuilderNamed: aName ifAbsent: aBlock

	^self abtPrivateInterfaceBuilder featureBuilderNamed: aName ifAbsent: aBlock!

abtPrivateInterfaceBuilder

	^self privateInterfaceSpec asInterfaceBuilder!

abtPrivateInterfaceSpecFeatureNamed: aName ifAbsent: aBlock

	^self privateInterfaceSpec interfaceSpecFeatureNamed: aName ifAbsent: aBlock.!

abtPromptOn: aPrompter

	"If we can give up a widget then evoke the prompter with
	our widget,  otherwise just prompt"

	^( self respondsTo: #widget )
		ifFalse: [aPrompter prompt]
		ifTrue: [ aPrompter setupAndPrompt: (CwMessagePrompter for: (self widget))]!

abtProperties
	"Answer the properties of the receiver. The value answered is a dictionary
	 where the dictionary keys are the property names and the dictionary
	 values are the property objects. Property objects are feature builders
	 that are specified, either implicitly or explicitly, as being a property."

	^self abtFeatureBuilders select: [:aFeatureBuilder |
		aFeatureBuilder isPropertyIn: self]!

abtPropertiesSortBlock
	"Answer the block for sorting properties."

	^[:property1 :property2 | property1 displayName < property2 displayName]!

abtPropertiesView
	"Answer the properties view for the object."

	^self class abtPropertiesView!

abtPropertiesViewHelpFileName
	"Answer the help file name to use when displaying help for the properties
	 view of the receiver."

	^self class abtPropertiesViewHelpFileName!

abtPropertiesViewHelpTopicId
	"Answer the help topic id to use when displaying help for the properties
	 view of the receiver."

	^self class abtPropertiesViewHelpTopicId!

abtPropertyNamed: aName ifAbsent: exceptionBlock
	"Answer the property of the object with the specified name. If there is no
	 property with the specified name, answer the value answered by evaluating
	 the specified zero argument exception block."

	^self abtProperties at: aName ifAbsent: [nil]!

abtPropertyValue
	"Answer the receiver as a property value."

	"Note:
		The property value answered can be a deferred update operation.

		To get the dereferenced value, send the message #abtDereferencedValue
		to the receiver."

	^self!

abtPropertyValueClone
	"Answer the clone of the receiver to use when cloning the receiver as
	 a property value."

	| propertyValueClone |

	self abrIsImmutable
		ifTrue:
			[propertyValueClone := self]
		ifFalse:
			[propertyValueClone := self copy.
			self abtDesignTimeProperties do: [:aProperty |
				propertyValueClone abtAtAttribute: aProperty name
					ifAbsent: []
					put: (self abtAtAttribute: aProperty name ifAbsent: [nil]) abtPropertyValueClone]].

	^propertyValueClone!

abtPropertyValueDeferredEditClone
	"Answer the clone of the receiver to use when the receiver is being
	 edited as a property value and updates are being deferred."

	| deferredEditClone |

	self abrIsImmutable
		ifTrue:
			[deferredEditClone := self]
		ifFalse:
			[deferredEditClone := self copy.
			self abtProperties do: [:aProperty |
				deferredEditClone abtAtAttribute: aProperty name
					ifAbsent: []
					put: (self abtAtAttribute: aProperty name ifAbsent: [nil]) abtPropertyValueDeferredEditClone]].

	^deferredEditClone!

abtPropertyValueDisplayString
	"Answer the string representation of the receiver to use when displaying
	 the receiver as a property value."

	^self abrIsImmutable
		ifTrue:
			[self printString]
		ifFalse:
			['(', self class name asString, ')']!

abtReturnReceiver: aValue
	"A temporary kludge for code generation"

	^self!

abtScriptDefinitionClass

	^self class!

abtSelfReferenceSymbol

	^#self!

abtSeparatedConstants: anArrayOfPartStrings

	"Ordinary (non-part) objects do nothing."!

abtSettingsViewHelpFile
		"Return the help file name which contains the help text for
		the settings view of the part."
	
	^self class abtSettingsViewHelpFile!

abtSettingsViewHelpTopicId
		"Return the help topic id which refers to the help text for
		the settings view of the part."
	
	^self class abtSettingsViewHelpTopicId!

abtSignalActionEvents: actionName

	(self featuresAffectedByAction: actionName) do: [: featureName |
		self abtSignalFeature: featureName].
	!

abtSignalAttributeEvents: attributeName

	(self featuresAffectedByAttributeChange: attributeName) do: [: featureName |
		self abtSignalFeature: featureName]!

abtSignalFeature: featureName

	featureName == self abtSelfReferenceSymbol
		ifTrue:
			[self features do: [: feature | feature signalIn: self]]
		ifFalse:
			[(self abtFeatureNamed: featureName) signalIn: self]!

abtSupportsPropertySheet
	"Answer true if the receiver supports being edited in a property sheet."

	^self class abtSupportsPropertySheet!

abtUnWrapped
	"Since #yourself is now optimized away by the compiler, this method
	has been added to ensure that we get the real object even when it
	is being held by a wrapper object."

	^self

	!

abtUpdateDependentsOfProperty: aProperty valueChangedData: aValueChangedData
	"Update the properties dependent on the specified property due to the
	 value of the specified property having changed. The specified value
	 changed data contains the old and new values of the specified property." 

	| dependentProperties |

	dependentProperties := self abtDependentsOfProperty: aProperty.
	(dependentProperties notNil and: [dependentProperties notEmpty])
		ifTrue:
			[| valueUpdateData propertyData |
			valueUpdateData := AbtValueUpdateData new.
			propertyData := AbtPartPropertyData new
				valuesSource: self;
				yourself.

			dependentProperties do: [:aDependentProperty |

				"Perform any update necessary of the dependent property."
				valueUpdateData
					name: aDependentProperty name;
					doit: false;
					currentValue: (self abtAtAttribute: aDependentProperty name
						ifAbsent: [nil]);
					newValue: valueUpdateData currentValue.
				propertyData
					property: aDependentProperty.
				aDependentProperty dependencyChangedIn: self
					valueChangedData: aValueChangedData
					valueUpdateData: valueUpdateData
					propertyData: propertyData.
				(valueUpdateData doit == true)
					ifTrue:
						[self abtAtAttribute: aDependentProperty name ifAbsent: []
							put: valueUpdateData newValue].

				"Signal that a dependency of a property has changed and
				 the displayed value of the property needs to be refreshed."
				self signalEvent: #dependencyChanged
					with: aDependentProperty
					with: aValueChangedData]].!

abtUpdateValueOfProperty: aProperty with: newValue
	"Update the value of the specified property with the specified new value
	 and answer true, if the value is valid. If the new value is not valid, do
	 not update the specified property and answer either false or an AbtError
	 object. If an AbtError object is answered, its error text may be displayed."

	| isValidValue |

	isValidValue := self abtIsValidValue: newValue ofProperty: aProperty.

	isValidValue == true
		ifTrue:
			[| valueChangedData |
			valueChangedData := AbtValueChangedData new
				name: aProperty name;
				oldValue: (self abtAtAttribute: aProperty name ifAbsent: [nil]);
				newValue: newValue;
				yourself.
			self abtAtAttribute: aProperty name ifAbsent: [] put: newValue.
			self abtUpdateDependentsOfProperty: aProperty
				valueChangedData: valueChangedData].

	^isValidValue!

abtWaitInUIUntil: aBlock
	"Wait until aBlock evaluates to true. 
	  Specifically used if waiting UI process"

	| continue |
	continue := true.
	[[ aBlock value not and: [ continue ]] whileTrue: [
		CwAppContext default readAndDispatch ifFalse: [
			System entryCount > 1
				ifFalse: [ CwAppContext default sleep ]]]
	] whenExceptionDo: [ continue := false ].!

abtWaitUntil: aBlock
	"Wait until aBlock evaluates to true"

	(Processor activeProcess == UIProcess currentUI
			or: [ System entryCount > 1])
		ifTrue: [ self abtWaitInUIUntil: aBlock ]
		ifFalse: [
			| sem |
			sem := Semaphore new. 
			[[ aBlock value ] whileFalse: [ 
				(Delay forMilliseconds: 500) wait ].
				sem signal. 
			] forkAt: Processor userBackgroundPriority.
			sem wait ].!

abtWhen: eventName selector: aSelector ifAbsent: aBlock perform: aMessage

	"Add aMessage to the list of messages to be sent when
	the primitive event corresponding to the event named
	eventName is signalled. If eventName is not the name of an
	event supported by the receiver, return the result of evaluating
	the block aBlock. In most implementations
	of this selector, eventName will be used to locate the
	event defintion for the receiver corresponding to eventName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_eventName,
	with colons replaced by _ (e.g. for the event named #clicked, the hint 
	would be #IS_clicked). Most implementations of 
	abtWhen:selector:ifAbsent:perform: can use this hint to significantly speed 
	up the lookup of the event whose name is eventName.
	eventName may also be the name of any valid attribute of
	the receiver. In this case, aMessage will be sent whenever
	the primitive change event of the attribute is signalled 
	(indicating that the value of the attribute has changed)
	Returns the receiver. 
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. eventName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abtPerformActionNamed: #click
	
	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
			"

	^(self abtFeatureNamed: eventName selector: aSelector ifAbsent: [^aBlock value])
		abtWhenIn: self perform: aMessage
		!

abtWhen: eventName selector: aSelector perform: aMessage

	"Add aMessage to the list of messages to be sent when
	the primitive event corresponding to the event named
	eventName is signalled. Fail if eventName is not the name of an
	event supported by the receiver. In most implementations
	of this selector, eventName will be used to locate the
	event defintion for the receiver corresponding to eventName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_eventName,
	with colons replaced by _ (e.g. for the event named #clicked, the hint 
	would be #IS_clicked). Most implementations of 
	abtWhen:selector:ifAbsent:perform: can use this hint to significantly speed 
	up the lookup of the event whose name is eventName.
	eventName may also be the name of any valid attribute of
	the receiver. In this case, aMessage will be sent whenever
	the primitive change event of the attribute is signalled 
	(indicating that the value of the attribute has changed)
	Returns the receiver. 
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. eventName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| button |
	button := AbtPushButtonView new.	
	button 
		abtWhen: #clicked
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	button abtPerformActionNamed: #click
	
	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abtPerformActionNamed: is
	executed (last line)

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhen: #first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
			"

	^(self abtFeatureNamed: eventName selector: aSelector)
		abtWhenIn: self perform: aMessage		!

abtWhenChanged: attributeName selector: aSelector ifAbsent: aBlock perform: message

	"Add aMessage to the list of messages to be sent when
	the primitive event indicating the modification of the attribute 
	named attributeName is signalled. If attributeName is not the name of an
	attribute supported by the receiver, return the result of evaluating
	the block aBlock. In most implementations
	of this selector, attributeName will be used to locate the
	attribute defintion for the receiver corresponding to attributeName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_attributeName,
	with colons replaced by _ (e.g. for the event named #first, the hint 
	would be #IS_first). Most implementations of 
	abtWhenChanged:selector:ifAbsent:perform: can use this hint to significantly 
	speed up the lookup of the event whose name is attributeName.
	Returns the receiver.
	Note that 'abtWhen: attributeName selector: aSelector ifAbsent: aBlock 
	perform: message' is actually equivalent if attributeName
	is a valid name of an attribute (see abtWhen:selector:ifAbsent:perform:).
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. attributeName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenChanged: #first
			selector: #IS_first
			ifAbsent: []
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
			"

	(self abtFeatureNamed: attributeName selector: aSelector ifAbsent: [^aBlock value]) 
		abtWhenChangedIn: self perform: message!

abtWhenChanged: attributeName selector: aSelector perform: message

	"Add aMessage to the list of messages to be sent when
	the primitive event indicating the modification of the attribute 
	named attributeName is signalled. Fail if eventName is not 
	the name of an attribute supported by the receiver. 
	In most implementations
	of this selector, attributeName will be used to locate the
	attribute defintion for the receiver corresponding to attributeName to 
	derive a primitive event of the receiver that will cause aMessage 
	to be sent. (See abtWhenPrimitive:perform:).
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_attributeName,
	with colons replaced by _ (e.g. for the event named #first, the hint 
	would be #IS_first). Most implementations of 
	abtWhenChanged:selector:ifAbsent:perform: can use this hint to significantly 
	speed up the lookup of the event whose name is attributeName.
	Returns the receiver.
	Note that 'abtWhen: attributeName selector: aSelector perform: message' is 
	actually equivalent if attributeName
	is a valid name of an attribute (see abtWhen:selector:perform:).
	aMessage must have the receiver, selector and argument list 
	specified, and the size of the argument list must match the number 
	of arguments expected by the receiver. (For unary selectors
	the argument list may be nil.) Any nil elements in the 
	argument list will be replaced by the parameters provided by 
	the receiver in the order they are provided when the event is 
	signalled. Non-nil entries in the parameter list will be passed 
	on unmodified. attributeName can be any object, although 
	the VisualAge UI always makes them symbols.

	Examples:

	| collection |
	collection := OrderedCollection new.	
	collection 
		abtWhenChanged: #first
			selector: #IS_first
			perform: 
				(DirectedMessage new
					receiver: Transcript;
					selector: #show:;
					arguments: (Array with: 'new first msg')).
	collection abrAdd: 'hello world'

	Executing the above code will cause 'new first msg' to appear in
	the Transcript when the statement abrAdd: is executed (last line).
	This is because the implementation of the statement abrAdd: 
	in OrderedCollection causes the change event corresponding 
	to the attribute #first to be signalled.
"			

	^(self abtFeatureNamed: attributeName selector: aSelector) 
		abtWhenChangedIn: self perform: message!

abtWhenPrimitive: anEvent signal: anEventSymbol of: eventSignaller

	^self abtWhenPrimitive: anEvent perform: 
		(eventSignaller abrMessageToSignalEvent: anEventSymbol)!

acoFix

	"Copy the receiver into fixed space. All references to the receiver will point to the new fixed 
	 object. Answer the new fixed object, nil if unable to make the object fixed"

	<primitive: VMprObjectMakeFixed>
	^nil!

addFirstToOrderedCollection: anOrderedCollection

	"Add the contents of the receiver to the beginning of anOrderedCollection."

	^anOrderedCollection addCollectionFirst: self!

addObjectDependenciesFor: objectRef!

addToOrderedCollection: anOrderedCollection

	"Add the contents of the receiver to anOrderedCollection."

	^anOrderedCollection addCollection: self!

addToOrderedCollection: anOrderedCollection atIndex: anInteger

	"Add the contents of the receiver to anOrderedCollection starting at anInteger."

	^anOrderedCollection addCollection: self atIndex: anInteger!

allocateAllVariableNames: aContext
		"Allocate a variable name for each of the part builders"

	"do nothing."!

allReferences
	"Answer an indexable collection containing all the objects which
	 reference the receiver."

	self basicAllReferences isEmpty  ifTrue: [ ^ #()].
	System globalGarbageCollect.
	^ self basicAllReferences !

asOpenSSLMethodNameFor: anSSLMethodClassFactory
	"Answer an error object since the subclasses could not
	 derive a name
	 
	 Arguments:
		anSSLMethodClassFactory - <OSSslSSLMethod>
	 Answers:
		<SciSslError> error object"

	^anSSLMethodClassFactory dispatcher
		errorObject: self
		hint: 'Illegal Argument: SSLMethod name can not be derived from this object'!

attemptedROMStore: storedObject intoSlot: anInteger

	"This message is sent when an attempt is made to
	 store storedObject into instance slot anInteger of the
	 receiver, which is read-only.  Answer true to retry the
	 store, or anything else to continue without performing
	 the store.  Note that if the receiver is not marked read-
	 write before retrying the store, this message will be sent
	 again.

	 To perform the store here, mark the receiver read-write,
	 use #instVarAt:put: to store the object, then mark the
	 receiver read-only again and answer false."

	^self primitiveError: PrimErrReadOnly!

autoScaleChanged
	"The DPI scaling factor has potentially changed.
	 Subclasses (i.e. Widgets) should take the appropriate
	 actions"

!

autoScaleHash
	"Answer the hash key to use for DPI object tracking
	 
	 Answers:
		<Object>"
	
	^self!

autoScaleObject: aFraction
	"Answer the scaler object for the provided
	 fraction
	 
	 Arguments:
		aFraction - <Fraction>
	 Answers:
		<DPIScalerObject>"
	
	^DPIScalerObject with: self!

badAsyncMessage: selector arguments: arguments

	"The VM has detected an async message which is invalid.
	The message has not been sent yet. 
	Resend the message here and the #perform:withArguments:
	will report the correct message."

	^ self perform: selector withArguments: arguments 
!

basicAllReferences
	"Answer an indexable collection containing all the objects which
	 reference the receiver. In order to not return dead objects, users should call the garbage collector
	 before calling this method."

	<primitive: VMprObjectAllReferences>  
	^self primitiveFailed!

basicClass

	"Answer a Class which is the receiver's class.

	Do not override basicClass in any subclass!!"

	<primitive: VMprObjectClass>
	^self primitiveFailed!

basicHash

	"Answer a SmallInteger that represents the receiver. Objects that are equivalent (=) must
	 answer the same value for the message #basicHash.

	 Do not override #basicHash in any subclass!!"

	<primitive: VMprObjectBasicHash>
	^ 0 !

basicHash: anInteger

	"Set the basicHash of the receiver to anInteger.  Fail if the receiver is immediate or
	 read-only.  Fail if anInteger is not between 0 and 32767.  Answer the receiver."

	<primitive: VMprObjectBasicHashColon>
	^self primitiveFailed!

basicShallowCopy
	"Answer a copy of the the receiver that shares the receiver's
	 instance variables.
	
	 Do not override #basicShallowCopy in any subclass!!"

	| copy class |

	class := self class.
	copy := class isVariable
		ifTrue: [class basicNew: self basicSize]
		ifFalse: [class basicNew].

	1 to: class instSize do: [ :instVarIndex |
		copy instVarAt: instVarIndex put: (self instVarAt: instVarIndex)].

	1 to: self basicSize do: [ :index |
		copy basicAt: index put: (self basicAt: index)].

	^copy!

changeUserTo: newUser for: aBlock
	"Change the current envy user to aUser for the evaluation of aBlock.
	Reset the user after the block executes."

	| oldUser recorded |
	(newUser stsIsUser not or: [(oldUser := newUser class current) = newUser])
		ifTrue: [^aBlock value].
	recorded := StsPowerToolsKernel currentUser: oldUser.
	newUser class stsCurrent: newUser.
	^aBlock ensure: [
			newUser class stsCurrent: oldUser.
			recorded ifTrue: [StsPowerToolsKernel resetCurrentUser]]!

comment

	^String new!

customSettingsOperation

	^self class customSettingsOperation target: self!

customSettingsOperationInParentPartClass: parentClass

	^(self class customSettingsOperationInParentPartClass: parentClass) target: self!

customSettingsView

	^self class customSettingsView!

customSettingsViewInParentPartClass: parentClass

	^self class customSettingsViewInParentPartClass: parentClass!

dbgClassName

	"Answer the name of the class in a format suitable for debugging."

	^self class name!

debugPrintOn: aStream

	"Append to the argument aStream, a sequence of characters that
	 describes the receiver for debugging purposes."

	self printOn: aStream!

debugPrintString

	"Answer a printable representation of the receiver for debugging
	 purposes. If an error occurs, answer the string 'Could not print receiver'."

	^[
		| writeStream |
		writeStream := WriteStream on: (Locale current preferredStringClass new: 10).
		self debugPrintOn: writeStream.
		writeStream contents asReducedString
	]
		when: ExError do: [:sig |
			sig exitWith: 'Could not print receiver']  "$NON-NLS$"
		when: ExCPMStackOverflow do: [:sig |
			sig exitWith: 'Stack overflow printing receiver']  "$NON-NLS$"
		when: ExHalt do: [:sig |
			"resume the halt"]!

deepCopy 

	"Answer a copy of the the receiver, with its own copy of each
	 instance variable."

	| copy |
	self class isVariable
		ifTrue: [copy := self class basicNew: self basicSize]
		ifFalse: [copy := self class basicNew].

	1 to: self class instSize do: [ :instVarIndex |
		copy
			instVarAt: instVarIndex
			put: (self instVarAt: instVarIndex) copy].

	1 to: self basicSize do: [ :index |
		copy basicAt: index put: (self basicAt: index) copy].
	^copy!

deferredUpdateOperation

	^self class deferredUpdateOperationClass new
		target: self;
		yourself!

delegate
	"Return the receiver since only a proxy have a delegate."

	^self!

describesCompoundDataType
	
	^false!

displayName

	^AbtRunCommonStrings::AbtStr_Unnamed_!

do: oneArgBlock appBlock: appBlock userBlock: userBlock

	(self stsSuperUser or: [(appBlock value: self) stsIsSuperGroup])
		ifTrue: [
			self 
				changeUserTo: (userBlock value: self) 
				for: [oneArgBlock value: self]]
		ifFalse: [oneArgBlock value: self]!

do: aBlock forApp: app withSuperUser: user

	^(self stsSuperUser or: [app stsIsSuperGroup])
		ifTrue: [self changeUserTo: user for: aBlock]
		ifFalse: [aBlock value]!

do: oneArgBlock forEachIn: aCollection appBlock: appBlock userBlock: userBlock

	aCollection 
		do: oneArgBlock 
		appBlock: appBlock 
		userBlock: userBlock!

do: aBlock withSuperUser: user

	^self stsSuperUser
		ifTrue: [self changeUserTo: user for: aBlock]
		ifFalse: [aBlock value]!

doesNotUnderstandError: aMessage

	"Report an error that the receiver class or superclasses do not
	 implement any methods for the message selector contained within the
	 argument aMessage.
	 This error is a low level error and should not be NLS converted."

	^(NlsCatKRN residentMsg: 'MxKRN23') bindWith: self class name with: aMessage selector    "$NLS$ %1 does not understand %2"!

epIsOutputDesignation

	"Answer if the receiver indicates an object will be packaged."

	^false!

epIsPlatformFunction

	"Answer if the receiver is a PlatformFunction."

	^false!

equalsLiteral: literal
	"Answer whether the receiver which is a literal of a method
	 equals the literal."

	^self = literal!

ewDrawUsing: anEwRenderContext
	"Draw the receiver using the EwRenderContext given."

	^self printString ewDrawUsing: anEwRenderContext
!

ewHeightUsing: anRC
	"Answer the height of the receiver using the font and GC in the EwRenderContext given."

	^self printString ewHeightUsing: anRC !

ewWidthUsing: anRC
	"Answer the width of the receiver using the font and GC in the EwRenderContext given."

	^self printString ewWidthUsing: anRC!

features

	^self privInstanceFeatures, 
		self privInterfaceSpecFeatures!

featuresAffectedByAction: actionName
	"For objects that do not signal their own change events. Defines the 
	features affected by an action. The default is #(self) implying that the 
	entire object (and so all of its attributes) have changed"

	^#(self)!

featuresAffectedByAttributeChange: attributeName
	"For objects that do not signal their own change events. Defines the 
	features affected by an attributeChange. The default is attributeName, implying that only 
	the change event for the changed attribute should be signalled"

	^Array with: attributeName!

finalizedSlot: slotIndex removedObject: anObject
	"An object has just bee removed from the receiver
	because the receiver is weak. The slot index 
	in the #instVarAt: index at which the removed object
	had previously been referenced.
	anObject must be send the #finalize message."

	anObject finalize. 
	^ self !

garbageCollected: garbageCollectedObjectIDs
	"Default behaviour is to do nothing."

	^self!

generateBuilderSettingValueArchiveCodeIn: aPartBuilder setting: setting on: methodText context: context
	"Generate the code necessary to create the passed part or builder
			a settings value."
	self abtGenerateCodeOn: methodText 
			context: context recursionSet: Set new.
!

getModifierState
	"Return the state of the modifiers and mouse buttons."

	| modifierState |
	CgDisplay default
		queryPointer: CgWindow default
		rootReturn: ReturnParameter null
		childReturn: ReturnParameter null
		rootXReturn: ReturnParameter null
		rootYReturn: ReturnParameter null
		winXReturn: ReturnParameter null
		winYReturn: ReturnParameter null
		maskReturn: (modifierState := ReturnParameter new).
	^modifierState value.!

getMRI: id group: groupId typeIfMissing: type textIfMissing: text
	"Answer the Machine Readable Information known
	 as <id> in group <groupId>.  If the MRI cannot be found (this can happen
	early on in an IC image startUp sequence) then fabricate a MRI object
	using the supplied parameters."
	
	^(AbtNLSCoordinator current nlsGroupManager mriExists: id group: groupId)
			ifTrue:[AbtNLSCoordinator current nlsGroupManager getMRI: id group: groupId]
			ifFalse:[ "Default to the English string."
				AbtMRI
					group: groupId 
					id: id 
					type: type
					string: text].
!

gtAsLocalArray

	^self asArray 

!

gtGlobalAt: aSymbol

	^self gtGlobalNamespace at: aSymbol!

gtGlobalAt: aSymbol ifAbsent: aBlock

	^self gtGlobalNamespace at: aSymbol ifAbsent: aBlock!

gtIsCollection

	^false!

gtIsCompiledMethod

	^false!

gtIsWidget
	^false!

gtIsXDClass

	^false!

gtNoNavigationWithAttributes: nr

	nr instances: (Set new) attributes: (Set new).!

haltErrorIn: anObject
	"Private-This is sent by handleError: if the user selects
	  to debug an error.   An AbtError object can override this
	  method to provide further processing that can give the
	  the user more information to help deal with the error."

	^ anObject halt.			"Just invoke the standard debugger"!

ignoreErrorIn: anObject
	"Private-This is sent by handleError: if the user selects
	  to ignore an error.   An AbtError object can override this
	  method to provide further processing that can allow the
	  user to continue operation."

	(self isError) ifFalse: [
		^ AbtError in: anObject
			locus: self   	"Usually a string"
			rc: nil ].!

initialEditExtent

	^self class defaultEditSize!

initialEditPositionSpec: aRect

	^(AbtViewAttachmentSpec new
		leftEdge: (AbtEdgeConstant new
			offset: aRect left);
		topEdge: (AbtEdgeConstant new
			offset: aRect top))!

initializeStatusFor: aReception
	"initialize with a reception status"!

initializeWith: aReception
	"initialize with a reception"!

inspectorSize

	"Answer an Integer which is the estimated number of variable references that will be created by 
	 the #inspectorVariables method. This can be used to avoid needlessly creating variable 
	 references when determining if children should be shown."

	"If #size fails catch the exception and answer zero."
	^[self basicClass instSize "named" + self basicSize "indexed"]
		when: ExError
		do: [:ex | ex exitWith: 0]!

inspectorVariables

	"Answer a collection containing variable references for all visible children 
	 of the receiver."

	| idx named indexed |

	idx := 0.
	named :=
		self basicClass allInstVarNames collect: [:name |
			idx := idx + 1.
			DbgNamedInstVarReference new
				object: self;
				name: name;
				index: idx;
				yourself].
	indexed :=
		(1 to: self basicSize) collect: [:i |
			DbgIndexedInstVarReference new
				object: self;
				name: i printString;
				index: i;
				yourself].
	^named , indexed!

instVarAtName: instVarName
	"Deprecated -- redirect to new interface."
	
	^ self instVarNamed: instVarName!

instVarAtName: instVarName put: aValue
	"Deprecated -- redirect to new interface."

	^ self instVarNamed: instVarName put: aValue!

isAbtCompoundType
		"Answer false, I can't be a compound type"
	^ false!

isAbtFeature

	^false!

isAbtFileSpec
	"Answer true if the receiver is an AbtFileSpec"
 
	^false!

isAbtRecord
		"Answer false, I can't be a compound type"
	^ false!

isAbtSqlca

	^false!

isAnonymousStructOrUnion
	"Private - Answer true if the receiver is an anonymous struct/union."
	
	^false!

isAppBldrPart

	^false!

isAppBldrView

	^false!

isCommunication

	^false!

isCommunicationsError
	"Answer if this is a CommunicationsError object
	  or one of its subclasses."
	^false!

isContext
	"Answer true if the receiver is a Context or template, false if not."

	^false!

isDeferredUpdateOp

	^false!

isEsFutureImpl

	^false!

isEwError
	"Answer true if the receiver is of type EwError."

	^false!

isExtendedCallback: aCallbackName

	^false!

isIdenticalLiteral: literal
	"Answer whether the receiver which is a literal of a method
	 is 'identical' to the literal (ie. if the receiver was replaced with
	 the literal, could anyone notice?)."

	^self = literal!

isInFixedSpace

	"Answer true if the receiver is in a fixed memory space."

	<primitive: VMprObjectIsFixed>
	^self primitiveFailed!

isOperation
	^false!

isOperationError
	^false!

isReadOnly

	"Answer true if the receiver is read-only, false if not."

	<primitive: VMprObjectIsReadOnly>
	^false!

isRemoteObject
	"Return true since the receiver is not a remote object."

	^ false!

isVersionIn: application

	^true!

isWeak

	"Answer true if the receiver is marked as a weak object.
	A weak object is one which can have any of its pointer slots 
	removed and replaced with the weakObjectPlaceHolder."

	<primitive: VMprObjectIsWeak>
	^self primitiveFailed!

makeFixed
	"Copy the receiver into fixed space. All references to the
	 receiver will point to the new fixed object. Answer the
	 new fixed object."

	<primitive: VMprObjectMakeFixed>
	^self primitiveFailed!

makeWeak

	"Mark the receiver as a weak object. 
	A weak object is processed specially by the garbage collector.
	When the garbage collector encounters a weak object, it may nil out
	any pointer slots in the receiver if the slot is the only reference remaining
	reference to the referenced object.
	When the slot is nil'ed, the weak object, the removed pointer and the #instVarAt: 
	index is placed into the system finalize queue if there is enough room.
	The finalize queue processed from Smalltalk (see Processor>>#finalizeCycle).
	Note, if the finalize queue is empty, the slot is not nil'ed  and the removal
	of the object is deferred until the next cycle.
	 "

	<primitive: VMprObjectMakeWeak>
	^self primitiveFailed!

markReadOnly: aBoolean

	"If aBoolean is true, mark the receiver as read-only. If
	 aBoolean is false, mark the receiver as read-write. Answer
	 the new read-only state of the object (as in isReadOnly)."

	<primitive: VMprObjectMarkReadOnly>
	^self primitiveFailed!

methodClass

	^nil!

mustBeBoolean

	"This message is sent when the receiver of an #ifTrue: ... or #ifFalse: ...
	 message is not a Boolean or when the Block receiver of a #whileTrue:
	 or #whileFalse: message does not evaluate to a Boolean."

	^self error: (NlsCatKRN indexedMsg: 42)  "$NLS$ receiver must be a boolean"!

mvsgetMRI: ignore1 group: ignore2

	^String new!

newPositionableStreamFrom: aPositionableStreamClass
	"Answer a new instance of @aPositionableStreamClass
	 by default.  Subclasses have an opportunity to customize
	 based on the aPositionableStreamClass
	 
	 Arguments:
		aPositionableStreamClass - <PositionableStream subclass>
	 Answers:
		<PositionableStream>"

	^aPositionableStreamClass new
		collection: self;
		reset!

newTornOffVariableBuilder

	^self newVariableBuilder!

objectHeaderSize
	"Answer the size of an object header in bytes
	 
	 Answers:
		<Integer> - number of bytes"

	^System is64BitVM ifTrue: [16] ifFalse: [12]!

openSSLByteObjectNew: aSize
	"Answer a new object with size @aSize
	 
	 Answers:
		<Object>"
	
	| species |
	
	species := self openSSLByteObjectSpecies.
	species isNil ifTrue: [^nil].
	^species new: aSize!

openSSLByteObjectSpecies
	"Answer a Class whose instance is appropriate for populating with
	 (possibly transformed) bytes from this class.
	 
	 Answers:
		<Class>"
	
	^nil!

openSSLCreateNewECGroup: anECGroupFactory
	"This object is not a valid argument type to the creational method for anECGroupFactory.
	 Answer an error object
	 
	 Arguments:
		anECGroupFactory - typically a <OSSslECGroup class> or <OSSslECKey class>
	 Answers:
		<OpenSSLError> error object"
	
	^anECGroupFactory dispatcher
		errorObject: self
		hint: anECGroupFactory name , '>>createNew: - Invalid argument type'!

openSSLCreateNewECPoint: anECPointFactory
	"This object is not a valid argument type to the creational method for anECPointFactory.
	 Answer an error object
	 
	 Arguments:
		anECPointFactory - typically a <OSSslECPoint class>
	 Answers:
		<OpenSSLError> error object"
	
	^anECPointFactory dispatcher
		errorObject: self
		hint: anECPointFactory name , '>>createNew: - Invalid argument type'!

openSSLFinishedNativeCall
	"No action required by default"
	
	!

openSSLPrepareForNativeCall
	"No action required by default"
	!

partBuilderAttribute: anAttributeName changedTo: aValue editPart: anEditPart
	"Make additional changes when an attribute is set for the part.
	Default is to do nothing"!

partClass

	^self class!

partFeatureNamed: aName ifAbsent: aBlock

	^self abtFeatureBuilderNamed: aName ifAbsent: aBlock!

partFeatures

	^self abtFeatureBuilders!

performActionNamed: actionName

	^self abtPerformActionNamed: actionName ifAbsent: [self class noSuchAction: actionName]!

performActionNamed: actionName with: arg

	^self abtPerformActionNamed: actionName 
		ifAbsent: [self class noSuchAction: actionName] 
		arguments: (Array with: arg)!

performActionNamed: actionName withArguments: args

	^self abtPerformActionNamed: actionName 
		ifAbsent: [self class noSuchAction: actionName] 
		arguments: args!

preferredConnectionFeatures

	^self class preferredConnectionFeatures!

primGetMsg: msgId group: groupId replace: replCltn
	"Answer the string specified by the input parameters
			as follows:
				msgId => integer or name of pool constant which maps to an integer.
				groupId => name of the pool used to resolve constants and message
					numbers.
				replCltn => collection of objects used to replace substitution 
					parameters in the original message.  This collection may be
					nil if no substitution is required. (Note: a nonNil single object
					will be converted into a collection of size 1.)"
	
	| mri mriGroup |

	"Get the MRI group.  If it is not available, then answer an empty string."
	(mriGroup := AbtNLSCoordinator current nlsGroupManager groupNamed: groupId) == nil
		ifTrue:[ ^Locale current preferredStringClass new ].

	(mri := mriGroup getMRI: msgId) == nil ifTrue:[
		^Locale current preferredStringClass new ].
	^AbtMRI string: ( mri asString
			replace: replCltn
			rules: mriGroup replacementRules )
		withAnnotation: mri displayableId.!

primitiveBadArgumentNumber

	"Answer the argument number which caused the error in the
	 last primitive call."

	<primitive: VMprObjectPrimitiveBadArgumentNumber>

	"This primitive cannot fail."
	^PrimArgNumNoArg!

primitiveError: errorCode
	"This is the low level primitive error reporting mechanism or the VM.
	  Report an error for the errorCode."

	^ self error: (self primitiveErrorStringFor:  errorCode)!

primitiveError: errorCode argument: argument
	"This is the low level primitive error reporting mechanism or the VM.
	  Report an error for the errorCode and argument."

	^ self error: (self primitiveErrorStringFor:  errorCode argument: argument)!

primitiveErrorCode

	"Answer the error code produced by the last primitive call."

	<primitive: VMprObjectPrimitiveErrorCode>

	"This primitive cannot fail."
	^PrimErrUnimplementedPrimitive!

primitiveErrorStringFor: errorCode
	"Answer the error string for the errorCode. 
	The argument PrimArgNumNoArg indicates that the 
	argument number is not applicable."

	^ self primitiveErrorStringFor: errorCode  argument: PrimArgNumNoArg!

primitiveErrorStringFor: errorCode argument: argument

	"Answer the string for the errorCode.
	The error code is a VM primitive error number.
	The argument is argument number (PrimArgNumNoArg = not applicable).
	Answer an unknown error string if the error does not exist."

	| errorString |

	errorCode = PrimErrOSError
		ifTrue: [^(PrimitiveErrorDescriptions at: errorCode), argument printString].

	errorCode > PrimitiveErrorDescriptions size
		ifTrue: [^ 'Error(%1)' bindWith: errorCode printString]."$NON-NLS$ No error strings, print as Error(number)."

	errorString := PrimitiveErrorDescriptions at: errorCode .

	(errorCode == PrimErrGeneralProtectionFault or: [ 
		errorCode ==	PrimErrGeneralProtectionFaultInvalidRead 	or: [ 
			errorCode == PrimErrGeneralProtectionFaultInvalidWrite or: [ 
				errorCode == PrimErrGeneralProtectionFaultInvalidInstruction]]]) 
		ifTrue: [
			Processor activeProcess attributes at: ##GPFInformation put: System platformFaultInformation]
		ifFalse: [ 
			Processor activeProcess attributes removeKey: ##GPFInformation ifAbsent: []]. 

	argument == PrimArgNumNoArg ifTrue: [ 
		^ errorString].

	argument == PrimArgNumSelf ifTrue: [ 	
		^ (NlsCatKRN residentMsg: 'MxKRN25') bindWith: errorString].    "$NLS$ %1 in receiver"

	^ (NlsCatKRN residentMsg: 'MxKRN26') bindWith: errorString with: argument printString  "$NLS$ %1 in argument %2"
	!

primitiveFailed: errorCode withArgument: argument backUp: backUp

	"Report to the user that a method that is implemented as a system primitive
	 as failed. Use errorCode and argument number report the problem.
	This error is a low level error and should not be NLS enabled."

	^self error: ((NlsCatKRN residentMsg: 'MxKRN24')   "$NLS$ Primitive failed in: %1 due to %2"
			bindWith: (Processor activeProcess methodAtFrame: backUp + 1) printString
			with: (self primitiveErrorStringFor: errorCode  argument: argument)) !

printAllAttributeValueAssignmentsOn: aStream context: aContext recursionSet: alreadyGenerated

	"do nothing."!

printCreationExpressionOn: aStream context: aContext

	^self storeOn: aStream!

printOn: aStream recursionSet: objectsAlreadySeen

	"For generic objects, the recursion set is not used."

	^self printOn: aStream!

privateInterfaceSpec

	^AbtInterfaceSpec!

privInstanceFeatures

	 ^self class instanceFeatures !

privInterfaceSpecFeatures

	 ^self privateInterfaceSpec interfaceSpecFeatures !

recursiveAccessCheck: aSet

	"Check if the receiver is in the set and if so, answer true. Otherwise add the received
	 to the set and return false. This method is used as a helper in implementing recursive
	 print and store methods."

	(aSet includes: self) ifTrue: [^true].
	aSet add: self.
	^false!

recursiveAccessClear: aSet

	"Remove the receiver is from the set indicating the object is no
	 longer being accessed recursively."

	aSet remove: self ifAbsent: [].
	^ self!

recursiveDeferredUpdateOperation
	"Deferred update operations are used to control the deferred application of updates"

	^self abrIsImmutable
		ifTrue: [self]
		ifFalse: [self abtOperationClass recursiveDeferredUpdateOperationClass new target: self]!

recursiveStoreOnError

	"Answer the error string."

	^(NlsCatKRN indexedMsg: 43)  "$NLS$ #storeOn: failed due to recursion"!

reifyAt: aPosition structure: anOSStructure
	"Unknown type descriptors are flagged as an error
	 
	Arguments:
		aPosition - <Integer> 1-based position of this type desc within @anOSStructure
		anOSStructure - <OSStructure class> containing this type desc
	Raises:
		<Error> - Unsupported type desc"

	self error:
		'Unsupported type descriptor at position ' , aPosition asString , ' within struct ' ,
			anOSStructure name asString!

replaceArray: anArray from: start to: stop startingAt: anInteger

	"Replace the contents of anArray from start to stop with the
	 contents of the receiver starting at anInteger."

	| index2 |
	index2 := anInteger.
	start to: stop do: [:index |
		anArray at: index put: (self at: index2).
		index2 := index2 + 1
	].
	^anArray!

residentClass

	^nil!

sciSslAsCertificateFor: anSciSslContext
	"Incompatible Object - answer an error
	 
	 Arguments:
		anSciSslContext - <SciSslContext>
	 Answers:
		<SciSslError> error object"
		
	^SciSslError new
		errorObject: self;
		errorHint:
			'Illegal Argument: This object can not represent itself as an X509 Certificate';
		yourself!

sciSslAsPrivateKeyFor: anSciSslContext
	"Incompatible Object - answer an error
	 
	 Arguments:
		anSciSslContext - <SciSslContext>
	 Answers:
		<SciSslError> error object"
		
	^SciSslError new
		errorObject: self;
		errorHint:
			'Illegal Argument: This object can not represent itself as a Private Key';
		yourself!

shallowCopy
	"Answer a copy of the the receiver that shares the receiver's
	 instance variables."

	<primitive: VMprObjectShallowCopy>

	^self basicShallowCopy!

shouldNotImplementError

	"Report an error that the receiver's class or superclasses do
	 not have an appropriate implementation for the method from which
	 this message was invoked."

	^(NlsCatKRN indexedMsg: 44) bindWith: self class name  "$NLS$ %1's should not implement this method"!

signalEvent: anEvent
	"Get the list of messages that have been registered as dependent
	on the primitive event anEvent and cause each one to be sent
	without replacing any arguments. Return the receiver"

	| msgs |

	(msgs := self abrPartiesInterestedIn: anEvent) == nil
		ifFalse: [
			msgs abtIsDependentsCollection
				ifTrue: [msgs signalEvent]
				ifFalse: [msgs do: [:msg | msg == nil ifFalse: [msg abrSend]]]]!

signalEvent: anEvent with: arg
	"Get the list of messages that have been registered as dependent
	on the primitive event anEvent and cause each one to be sent 
	replacing the first nil argument (if there is one) with arg. Return the 
	receiver"

	| msgs args |

	(msgs := self abrPartiesInterestedIn: anEvent) == nil
		ifFalse: [
			args := Array with: arg.
			msgs abtIsDependentsCollection
				ifTrue: [msgs signalEventWithArguments: args]
				ifFalse: [msgs do: [:msg | msg == nil ifFalse: [msg abrSendWithArguments: args]]]]!

signalEvent: anEvent with: arg with: arg2
	"Get the list of messages that have been registered as dependent
	on the primitive event anEvent and cause each one to be sent 
	replacing the first nil argument (if there is one) with arg and the second
	nil argument (if there is one) with arg2. Return the receiver"

	| msgs args |

	(msgs := self abrPartiesInterestedIn: anEvent) == nil
		ifFalse: [
			args := Array with: arg with: arg2.
			msgs abtIsDependentsCollection
				ifTrue: [msgs signalEventWithArguments: args]
				ifFalse: [msgs do: [:msg | msg == nil ifFalse: [msg abrSendWithArguments: args]]]]!

signalEvent: anEvent withArguments: args
	"Get the list of messages that have been registered as dependent
	on the primitive event anEvent and cause each one to be sent 
	replacing the nil arguments (if any) with the contents of args. 
	Return the receiver"

	| msgs |

	(msgs := self abrPartiesInterestedIn: anEvent) == nil
		ifFalse: [
			msgs abtIsDependentsCollection
				ifTrue: [msgs signalEventWithArguments: args]
				ifFalse: [msgs do: [:msg | msg == nil ifFalse: [msg abrSendWithArguments: args]]]]!

signalPrimitiveEvent: anEvent

	^self signalEvent: anEvent!

signalPrimitiveEvent: anEvent with: arg

	^self signalPrimitiveEvent: anEvent withArguments: (Array with: arg)!

signalPrimitiveEvent: anEvent withArguments: args

	^self signalEvent: anEvent withArguments: args!

species

	"Answer a Class whose instance is appropriate for populating with
	 objects contained within the instance and indexed variables of
	 the receiver."

	<primitive: VMprObjectClass>
	^self primitiveFailed!

storeOn: aStream recursionSet: objectsAlreadyCopied

	"Append to the argument aStream a sequence of characters that is a
	 Smalltalk expression whose evaluation creates an object similar to
	 the receiver.  Answer self.

	 The general format is
		(class-name basicNew
			instVarAt: index put: variable;
			basicAt: index put: element;
			yourself)
	 or
		((class-name basicNew: size )
			instVarAt: index put: variable;
			basicAt: index put: element;
			yourself)

	Fail if aStream is not a kind of Stream
	Fail if the receiver references itself either directly or indirectly
	via its instance variables."

	self storeOn: aStream.!

stsAsString

	^self printString!

stsBrowserAttributes

	^#()!

stsBrowserColor

	^nil!

stsBrowserIcon

	^StsImageManager iconFromSelector: #GrayBall!

stsCAD
	"Do nothing"!

stsComment

	^self comment!

stsDescription

	^[self description] 
		when: ExError 
		do: [:sig | sig exitWith: String new]!

stsHasReferenceToMissingMethod

	^self stsHasReferenceToMissingMethod: System!

stsHasReferenceToMissingMethod: anImage

	^false!

stsHasSubclassOverride

	^false!

stsIsAbstractMethod

	^false!

stsIsApplicationObject

	^false!

stsIsCompiledMethod

	^false!

stsIsConfigurationMap

	^false!

stsIsCurrentSupervisor

	^false!

stsIsEtWindow

	^false!

stsIsPoolDictionary

	^false!

stsIsSpecialMethodsBrowser

	^false!

stsIsSubclassOverride

	^false!

stsIsUser

	^false!

stsSuperUser

	^StsPowerToolsKernel superUser!

subpartBuilderNamed: aSubpartBuilderName ifAbsent: aBlock

	^aBlock value!

tenure

	"Insure that the receiver is tenured (not in new space).  Answer self."

	<primitive: VMprObjectTenure>
	^self primitiveFailed!

traceOn: aStream
	"Public - Allow any object to be part of a trace."
 
	^self traceOn: aStream withIndentation: ''!

traceOn: aStream withIndentation: aString
	"Allow any object to be part of a trace.

	 Since aStream will be aTranscriptTTY when running headless,
	 we need to use a temporary stream here that understands the
	 full stream protocol that may be used by #printOn:."

	| temp |
 
	self printOn: (temp := WriteStream on: (Locale current preferredStringClass new: 100)). 
	aStream nextPutAll: temp contents.!

valueOfAttributeNamed: aName
	"Return the current vaue of the attribute named attributeName.
	Fail if attributeName is not the value of an attribute of the receiver.

		Examples:

		OrderedCollection new
			valueOfAttributeNamed: #size.

		1@1
			valueOfAttributeNamed: #x
"

	^self valueOfAttributeNamed: aName ifAbsent: [self class noSuchAttribute: aName]!

valueOfAttributeNamed: aName ifAbsent: aBlock
	"Return the current vaue of the attribute named attributeName.
	If attributeName is not the name of an
	attribute supported by the receiver, return the result of evaluating
	the block aBlock. 

		Examples:

		OrderedCollection new
			valueOfAttributeNamed: #sze
			ifAbsent: ['missing'].

		1@1
			valueOfAttributeNamed: #z
			ifAbsent: ['no such attribute']
"

	^(self abtFeatureNamed: aName ifAbsent: [^aBlock value]) getValueIn: self!

valueOfAttributeNamed: aName ifAbsent: aBlock  put: aValue
	"Set the vaue of the attribute named attributeName to the value 
	aValue. If the attribute is not settable, do nothing. If attributeName 
	is not the name of an attribute supported by the receiver, return the 
	result of evaluating the block aBlock. 

		Examples:

		1@1
			valueOfAttributeNamed: #z
			ifAbsent: ['no such attribute']
			put: 2
"

	^(self abtFeatureNamed: aName ifAbsent: [^aBlock value]) 
		setValueIn: self to: aValue!

valueOfAttributeNamed: aName  put: aValue
	"Set the vaue of the attribute named attributeName to the value 
	aValue. If the attribute is not settable, do nothing. Fail if 
	attributeName is not the name of an attribute supported by the receiver. 

		Examples:

		1@1
			valueOfAttributeNamed: #x
			put: 2
"

	^self valueOfAttributeNamed: aName ifAbsent: [self class noSuchAttribute: aName] put: aValue!

valueOfAttributeNamed: aName selector: aSelector
	"Return the current vaue of the attribute named attributeName.
	Fail if attributeName is not the value of an attribute of the receiver.
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_attributeName,
	with colons replaced by _ (e.g. for the event named #first, the hint 
	would be #IS_first). Most implementations of 
	valueOfAttributeNamed:selector: can use this hint to significantly 

		Examples:

		OrderedCollection new
			valueOfAttributeNamed: #size
			selector: #IS_size.

		1@1
			valueOfAttributeNamed: #x
			selector: #IS_x
"

	^(self abtFeatureNamed: aName selector: aSelector) getValueIn: self!

valueOfAttributeNamed: aName selector: aSelector ifAbsent: aBlock
	"Return the current vaue of the attribute named attributeName.
	If attributeName is not the name of an
	attribute supported by the receiver, return the result of evaluating
	the block aBlock. 
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_attributeName,
	with colons replaced by _ (e.g. for the event named #first, the hint 
	would be #IS_first). Most implementations of 
	valueOfAttributeNamed:selector:ifAbsent: can use this hint to significantly 

		Examples:

		OrderedCollection new
			valueOfAttributeNamed: #sze
			selector: #IS_sze
			ifAbsent: ['missing'].

		1@1
			valueOfAttributeNamed: #z
			selector: #IS_z
			ifAbsent: ['no such attribute']
"

	^(self abtFeatureNamed: aName selector: aSelector ifAbsent: [^aBlock value]) getValueIn: self!

valueOfAttributeNamed: aName selector: aSelector ifAbsent: aBlock  put: aValue
	"Set the vaue of the attribute named attributeName to the value 
	aValue. If the attribute is not settable, do nothing. If attributeName 
	is not the name of an attribute supported by the receiver, return the 
	result of evaluating the block aBlock. 
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_attributeName,
	with colons replaced by _ (e.g. for the event named #first, the hint 
	would be #IS_first). Most implementations of 
	valueOfAttributeNamed:selector:ifAbsent: can use this hint to significantly 

		Examples:

		1@1
			valueOfAttributeNamed: #z
			selector: #IS_z
			ifAbsent: ['no such attribute']
			put: 2
"

	^(self abtFeatureNamed: aName selector: aSelector ifAbsent: [^aBlock value]) 
		setValueIn: self to: aValue!

valueOfAttributeNamed: aName selector: aSelector put: aValue
	"Set the vaue of the attribute named attributeName to the value 
	aValue. If the attribute is not settable, do nothing. Fail if attributeName 
	is not the name of an attribute supported by the receiver. 
	aSelector is simply a HINT that is used to optimize the execution speed
	of this call. aSelector should be a symbol of the form #IS_attributeName,
	with colons replaced by _ (e.g. for the event named #first, the hint 
	would be #IS_first). Most implementations of 
	valueOfAttributeNamed:selector:ifAbsent: can use this hint to significantly 

		Examples:

		1@1
			valueOfAttributeNamed: #x
			selector: #IS_x
			put: 2
"

	^(self abtFeatureNamed: aName selector: aSelector) 
		setValueIn: self to: aValue!

wbDrawUsing: anEwRenderContext
	"Draw the receiver using the EwRenderContext given."

	anEwRenderContext isNil ifTrue: [^self].
	^self ewDrawUsing: anEwRenderContext!

wbDrawUsing: anEwRenderContext backgroundColor: backgroundColor style: theStyle
	"Draw the receiver using the EwRenderContext given."

	anEwRenderContext isNil ifTrue: [^self].
	^self ewDrawUsing: anEwRenderContext!

wbHeightUsing: anRC
	"Answer the height of the receiver using the font and GC in the EwRenderContext given."

	anRC isNil ifTrue: [^0].
	^self ewHeightUsing: anRC !

wbWidthUsing: anRC
	"Answer the width of the receiver using the font and GC in the EwRenderContext given."

	anRC isNil ifTrue: [^0].
	^self ewWidthUsing: anRC! !

Object initializeAfterLoad!