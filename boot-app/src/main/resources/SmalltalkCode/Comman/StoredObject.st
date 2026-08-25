
Object subclass: #StoredObject
    classInstanceVariableNames: 'manager '
    instanceVariableNames: 'data status lock storageKey '
    classVariableNames: ''
    poolDictionaries: ''!

!StoredObject class publicMethods !

clean
	"storageKey, data and database are not initialized."
	^super new makeClean!

clear
	manager := nil!

configurationClass
	^self symbol!

data: aData
	"Returns existing object stored in aData."

	^self manager fetchObjectData: aData!

database
	^self manager database!

dataClass
	"Returns class of StoredData."

	^self manager dataClass!

defaultDataClass
	^self system storedDataFor: self configurationClass!

defaultManager
	^StoredObjectManager class: self dataClass: self defaultDataClass!

externalID: aString
	"Returns existing object stored at externalID (else exception). "

	^self manager fetchObjectAtExternalID: aString!

fetchAll
	^self manager fetchAll!

fetchAllUsing: anSQLStatement
	^self manager fetchAllUsing: anSQLStatement!

getNameList
	^(self fetchAll asOrderedCollection) collect: [ :each | each storageKey ].

!

manager
	manager isNil
		ifTrue: [manager := self defaultManager].
	^manager!

new
	^super new initializeNew!

newWithoutKey
	^super new initializeNewWithoutKey!

newWithoutStorage
	^super new makeNew!

proxy
	^StoredObjectProxy new
		proxyClass: self!

register: anObject
	self manager register: anObject!

storageKey: anObject
	"Returns existing object stored at key anObject (else error)."

	^self manager fetchObjectAtStorageKey: anObject!

unregister: anObject
	self manager unregister: anObject! !

!StoredObject publicMethods !

<= aStoredObject
	^aStoredObject isStorageObject
			and: [storageKey <= aStoredObject storageKey]!

= aStoredObject
	"Note that key determines if the entire object is equal"
	^aStoredObject isStorageObject
			and: [self cacheKey = aStoredObject cacheKey]!

asProxy
	^(self class proxy storageKey: self storageKey) object: self!

cacheKey
	^self storageKey!

clone
	"Create clean object, deepCopy all variables of receiver object, and initialize it as a new storedObject.  Clone contained objects as needed, and return new object."

	| copy |
	copy := self class clean.
	copy := self deepCopy.
	^copy initializeNew!

createDataObject
	^self class dataClass on: self!

delete
	self deleteForKey: nil!

deleteForKey: anObject
	data deleteForKey: anObject.
	self unregister!

discardAllChanges
	| key |
	key := self storageKey.
	self unregister.
	self become: (self class storageKey: key).
	^self!

externalID
	^nil!

generateKey
	"^self system getInternalID: self class name asSymbol"
	^self system getInternalID: nil!

hash
	^self storageKey hash!

initializeNew
	self makeNew.
	self initializeStoredData.
	self initializeStorageKey!

initializeNewWithoutKey
	self makeNew.
	self initializeStoredData!

initializeStorageKey
	self setStorageKey: self generateKey.
	self register!

initializeStoredData
	self setData: self createDataObject.
	self setDatabase: self class manager database!

isClean
	^status = #clean!

isDirty	
	^status = #dirty or: [ self isNew ]!

isNew	
	^status = #new!

isStorageObject
	^true!

lock
	^lock!

lock: aLock
	^lock := aLock!

makeClean
	status := #clean!

makeDirty
	self isNew ifFalse: [status := #dirty]!

makeNew
	status := #new!

objectID
	^storageKey!

prepareForStorage
	storageKey notNil ifTrue: [^nil].
	self initializeNew!

register
	self class register: self!

remove
	"remove connections to other StoredObjects"
	self removeForKey: nil!

removeForKey: anObject
	"remove connections to other StoredObjects"
	data removeForKey: anObject.
	self unregister!

retainStatusDo: aBlock
	"Evaluates aBlock while saving and restoring initial status."

	| oldStatus |
	oldStatus := status.
	aBlock value.
	status := oldStatus!

setData: aData
	data := aData.!

setDatabase: aDatabase
	data setDatabase: aDatabase!

setStorageKey: anObject
	storageKey := anObject!

storageKey
	^storageKey!

unregister
	self class unregister: self!

write: aContext
	"In this method, aContext is intended to represent a unit of work. If no unit or work"
	"control is needed, nil can be used.  Eventually, we will need to protect this so that"
	"the object stays dirty if the write fails."
	self
		write: aContext
		forKey: nil!

write: aContext forKey: anObject
	"In this method, aContext is intended to represent a unit of work. If no unit or work"
	"control is needed, nil can be used.  Eventually, we will need to protect this so that"
	"the object stays dirty if the write fails."

	self writeLocal: aContext forKey: anObject!

writeLocal: aContext
	"Later, protect this so it stays dirty if the write fails. TSH: This needs to reviewed"

	self writeLocal: aContext forKey: nil!

writeLocal: aContext forKey: anObject
	"In this method, aContext is intended to represent a unit of work. If no unit or work"
	"control is needed, nil can be used.  Eventually, we will need to protect this so that"
	"the object stays dirty if the write fails."

	data write: aContext forKey: anObject.
	self unregister.
	self makeClean! !

StoredObject initializeAfterLoad!