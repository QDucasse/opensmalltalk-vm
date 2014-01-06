/* Automatically generated by
	SmartSyntaxPluginCodeGenerator VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd
   from
	SoundPlugin VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd
 */
static char __buildInfo[] = "SoundPlugin VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd " __DATE__ ;



#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* Default EXPORT macro that does nothing (see comment in sq.h): */
#define EXPORT(returnType) returnType

/* Do not include the entire sq.h file but just those parts needed. */
/*  The virtual machine proxy definition */
#include "sqVirtualMachine.h"
/* Configuration options */
#include "sqConfig.h"
/* Platform specific definitions */
#include "sqPlatformSpecific.h"

#define true 1
#define false 0
#define null 0  /* using 'null' because nil is predefined in Think C */
#ifdef SQUEAK_BUILTIN_PLUGIN
#undef EXPORT
// was #undef EXPORT(returnType) but screws NorCroft cc
#define EXPORT(returnType) static returnType
#endif

#include "SoundPlugin.h"
#include "sqMemoryAccess.h"


/*** Constants ***/


/*** Function Prototypes ***/
static VirtualMachine * getInterpreter(void);
EXPORT(const char*) getModuleName(void);
static sqInt halt(void);
EXPORT(sqInt) initialiseModule(void);
static sqInt msg(char *s);
EXPORT(sqInt) primitiveSoundAvailableSpace(void);
EXPORT(sqInt) primitiveSoundGetRecordingSampleRate(void);
EXPORT(sqInt) primitiveSoundGetVolume(void);
EXPORT(sqInt) primitiveSoundInsertSamples(void);
EXPORT(sqInt) primitiveSoundPlaySamples(void);
EXPORT(sqInt) primitiveSoundPlaySilence(void);
EXPORT(sqInt) primitiveSoundRecordSamples(void);
EXPORT(sqInt) primitiveSoundSetLeftVolume(void);
EXPORT(sqInt) primitiveSoundSetRecordLevel(void);
EXPORT(sqInt) primitiveSoundStart(void);
EXPORT(sqInt) primitiveSoundStartRecording(void);
EXPORT(sqInt) primitiveSoundStartWithSemaphore(void);
EXPORT(sqInt) primitiveSoundStop(void);
EXPORT(sqInt) primitiveSoundStopRecording(void);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);
EXPORT(sqInt) shutdownModule(void);
static sqInt sqAssert(sqInt aBool);


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
static sqInt (*booleanValueOf)(sqInt obj);
static sqInt (*classArray)(void);
static sqInt (*failed)(void);
static void * (*firstIndexableField)(sqInt oop);
static sqInt (*floatObjectOf)(double  aFloat);
static sqInt (*instantiateClassindexableSize)(sqInt classPointer, sqInt size);
static sqInt (*isWords)(sqInt oop);
static sqInt (*pop)(sqInt nItems);
static sqInt (*popthenPush)(sqInt nItems, sqInt oop);
static sqInt (*popRemappableOop)(void);
static sqInt (*positive32BitIntegerFor)(sqInt integerValue);
static sqInt (*pushRemappableOop)(sqInt oop);
static sqInt (*slotSizeOf)(sqInt oop);
static double (*stackFloatValue)(sqInt offset);
static sqInt (*stackIntegerValue)(sqInt offset);
static sqInt (*stackValue)(sqInt offset);
static sqInt (*storePointerofObjectwithValue)(sqInt index, sqInt oop, sqInt valuePointer);
static sqInt (*success)(sqInt aBoolean);
#else /* !defined(SQUEAK_BUILTIN_PLUGIN) */
extern sqInt booleanValueOf(sqInt obj);
extern sqInt classArray(void);
extern sqInt failed(void);
extern void * firstIndexableField(sqInt oop);
extern sqInt floatObjectOf(double  aFloat);
extern sqInt instantiateClassindexableSize(sqInt classPointer, sqInt size);
extern sqInt isWords(sqInt oop);
extern sqInt pop(sqInt nItems);
extern sqInt popthenPush(sqInt nItems, sqInt oop);
extern sqInt popRemappableOop(void);
extern sqInt positive32BitIntegerFor(sqInt integerValue);
extern sqInt pushRemappableOop(sqInt oop);
extern sqInt slotSizeOf(sqInt oop);
extern double stackFloatValue(sqInt offset);
extern sqInt stackIntegerValue(sqInt offset);
extern sqInt stackValue(sqInt offset);
extern sqInt storePointerofObjectwithValue(sqInt index, sqInt oop, sqInt valuePointer);
extern sqInt success(sqInt aBoolean);
extern
#endif
struct VirtualMachine* interpreterProxy;
static const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"SoundPlugin VMMaker.oscog-eem.576 (i)"
#else
	"SoundPlugin VMMaker.oscog-eem.576 (e)"
#endif
;



/*	Note: This is coded so that plugins can be run from Squeak. */

static VirtualMachine *
getInterpreter(void)
{
	return interpreterProxy;
}


/*	Note: This is hardcoded so it can be run from Squeak.
	The module name is used for validating a module *after*
	it is loaded to check if it does really contain the module
	we're thinking it contains. This is important! */

EXPORT(const char*)
getModuleName(void)
{
	return moduleName;
}

static sqInt
halt(void)
{
	;
	return 0;
}

EXPORT(sqInt)
initialiseModule(void)
{
	return soundInit();
}

static sqInt
msg(char *s)
{
	fprintf(stderr, "\n%s: %s", moduleName, s);
	return 0;
}


/*	Returns the number of bytes of available sound output buffer space. This
	should be (frames*4) if the device is in stereo mode, or (frames*2)
	otherwise 
 */

EXPORT(sqInt)
primitiveSoundAvailableSpace(void)
{
	sqInt frames;
	sqInt _return_value;


	/* -1 if sound output not started */

	frames = snd_AvailableSpace();
	success(frames >= 0);
	_return_value = positive32BitIntegerFor(frames);
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	Return a float representing the actual sampling rate during recording.
	Fail if not currently recording.
 */

EXPORT(sqInt)
primitiveSoundGetRecordingSampleRate(void)
{
	double  rate;
	sqInt _return_value;


	/* fail if not recording */

	rate = snd_GetRecordingSampleRate();
	_return_value = floatObjectOf(rate);
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	Set the sound input recording level. */

EXPORT(sqInt)
primitiveSoundGetVolume(void)
{
	double left;
	sqInt results;
	double right;

	left = 0;
	right = 0;
	snd_Volume((double *) &left,(double *) &right);
	pushRemappableOop(floatObjectOf(right));
	pushRemappableOop(floatObjectOf(left));
	pushRemappableOop(instantiateClassindexableSize(classArray(), 2));
	results = popRemappableOop();
	storePointerofObjectwithValue(0, results, popRemappableOop());
	storePointerofObjectwithValue(1, results, popRemappableOop());
	if (failed()) {
		return null;
	}
	popthenPush(1, results);
	return null;
}


/*	Insert a buffer's worth of sound samples into the currently playing 
	buffer. Used to make a sound start playing as quickly as possible. The 
	new sound is mixed with the previously buffered sampled. */
/*	Details: Unlike primitiveSoundPlaySamples, this primitive always starts 
	with the first sample the given sample buffer. Its third argument 
	specifies the number of samples past the estimated sound output buffer 
	position the inserted sound should start. If successful, it returns the 
	number of samples inserted. */

EXPORT(sqInt)
primitiveSoundInsertSamples(void)
{
	unsigned *buf;
	sqInt frameCount;
	sqInt framesPlayed;
	sqInt leadTime;
	sqInt _return_value;

	frameCount = stackIntegerValue(2);
	success(isWords(stackValue(1)));
	buf = ((unsigned *) (firstIndexableField(stackValue(1))));
	leadTime = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	success(frameCount <= (slotSizeOf(((sqInt)(long)(buf) - BaseHeaderSize))));
	if (!(failed())) {
		framesPlayed = snd_InsertSamplesFromLeadTime(frameCount, (void *)buf, leadTime);
		success(framesPlayed >= 0);
	}
	_return_value = positive32BitIntegerFor(framesPlayed);
	if (failed()) {
		return null;
	}
	popthenPush(4, _return_value);
	return null;
}


/*	Output a buffer's worth of sound samples. */

EXPORT(sqInt)
primitiveSoundPlaySamples(void)
{
	unsigned *buf;
	sqInt frameCount;
	sqInt framesPlayed;
	sqInt startIndex;
	sqInt _return_value;

	frameCount = stackIntegerValue(2);
	success(isWords(stackValue(1)));
	buf = ((unsigned *) (firstIndexableField(stackValue(1))));
	startIndex = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	success((startIndex >= 1)
	 && (((startIndex + frameCount) - 1) <= (slotSizeOf(((sqInt)(long)(buf) - BaseHeaderSize)))));
	if (!(failed())) {
		framesPlayed = snd_PlaySamplesFromAtLength(frameCount, (void *)buf, startIndex - 1);
		success(framesPlayed >= 0);
	}
	_return_value = positive32BitIntegerFor(framesPlayed);
	if (failed()) {
		return null;
	}
	popthenPush(4, _return_value);
	return null;
}


/*	Output a buffer's worth of silence. Returns the number of sample frames
	played. 
 */

EXPORT(sqInt)
primitiveSoundPlaySilence(void)
{
	sqInt framesPlayed;
	sqInt _return_value;


	/* -1 if sound output not started */

	framesPlayed = snd_PlaySilence();
	success(framesPlayed >= 0);
	_return_value = positive32BitIntegerFor(framesPlayed);
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	Record a buffer's worth of 16-bit sound samples. */

EXPORT(sqInt)
primitiveSoundRecordSamples(void)
{
	unsigned *buf;
	sqInt bufLen;
	char*bufPtr;
	sqInt bufSizeInBytes;
	sqInt byteOffset;
	sqInt samplesRecorded;
	sqInt startWordIndex;
	sqInt _return_value;

	success(isWords(stackValue(1)));
	buf = ((unsigned *) (firstIndexableField(stackValue(1))));
	startWordIndex = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	if (!(failed())) {
		bufSizeInBytes = (slotSizeOf(((sqInt)(long)(buf) - BaseHeaderSize))) * 4;
		success((startWordIndex >= 1)
		 && (((startWordIndex - 1) * 2) < bufSizeInBytes));
	}
	if (!(failed())) {
		byteOffset = (startWordIndex - 1) * 2;
		bufPtr = (((char*) buf)) + byteOffset;
		bufLen = bufSizeInBytes - byteOffset;
		samplesRecorded = snd_RecordSamplesIntoAtLength(bufPtr, 0, bufLen);
	}
	_return_value = positive32BitIntegerFor(samplesRecorded);
	if (failed()) {
		return null;
	}
	popthenPush(3, _return_value);
	return null;
}


/*	Set the sound input recording level. */

EXPORT(sqInt)
primitiveSoundSetLeftVolume(void)
{
	double aLeftVolume;
	double aRightVolume;

	aLeftVolume = stackFloatValue(1);
	aRightVolume = stackFloatValue(0);
	if (failed()) {
		return null;
	}
	if (!(failed())) {
		snd_SetVolume(aLeftVolume,aRightVolume);
	}
	if (failed()) {
		return null;
	}
	pop(2);
	return null;
}


/*	Set the sound input recording level. */

EXPORT(sqInt)
primitiveSoundSetRecordLevel(void)
{
	sqInt level;

	level = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	if (!(failed())) {
		snd_SetRecordLevel(level);
	}
	if (failed()) {
		return null;
	}
	pop(1);
	return null;
}


/*	Start the double-buffered sound output with the given buffer size, sample
	rate, and stereo flag.
 */

EXPORT(sqInt)
primitiveSoundStart(void)
{
	sqInt bufFrames;
	sqInt samplesPerSec;
	sqInt stereoFlag;

	bufFrames = stackIntegerValue(2);
	samplesPerSec = stackIntegerValue(1);
	stereoFlag = booleanValueOf(stackValue(0));
	if (failed()) {
		return null;
	}
	success(snd_Start(bufFrames, samplesPerSec, stereoFlag, 0));
	if (failed()) {
		return null;
	}
	pop(3);
	return null;
}


/*	Start recording sound with the given parameters. */

EXPORT(sqInt)
primitiveSoundStartRecording(void)
{
	sqInt desiredSamplesPerSec;
	sqInt semaIndex;
	sqInt stereoFlag;

	desiredSamplesPerSec = stackIntegerValue(2);
	stereoFlag = booleanValueOf(stackValue(1));
	semaIndex = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	snd_StartRecording(desiredSamplesPerSec, stereoFlag, semaIndex);
	if (failed()) {
		return null;
	}
	pop(3);
	return null;
}


/*	Start the double-buffered sound output with the given buffer size, sample
	rate, stereo flag, and semaphore index.
 */

EXPORT(sqInt)
primitiveSoundStartWithSemaphore(void)
{
	sqInt bufFrames;
	sqInt samplesPerSec;
	sqInt semaIndex;
	sqInt stereoFlag;

	bufFrames = stackIntegerValue(3);
	samplesPerSec = stackIntegerValue(2);
	stereoFlag = booleanValueOf(stackValue(1));
	semaIndex = stackIntegerValue(0);
	if (failed()) {
		return null;
	}
	success(snd_Start(bufFrames, samplesPerSec, stereoFlag, semaIndex));
	if (failed()) {
		return null;
	}
	pop(4);
	return null;
}


/*	Stop double-buffered sound output. */

EXPORT(sqInt)
primitiveSoundStop(void)
{
	snd_Stop();
	if (failed()) {
		return null;
	}
	return null;
}


/*	Stop recording sound. */

EXPORT(sqInt)
primitiveSoundStopRecording(void)
{
	snd_StopRecording();
	if (failed()) {
		return null;
	}
	return null;
}


/*	Note: This is coded so that it can be run in Squeak. */

EXPORT(sqInt)
setInterpreter(struct VirtualMachine*anInterpreter)
{
	sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));
	if (ok) {
		
#if !defined(SQUEAK_BUILTIN_PLUGIN)
		booleanValueOf = interpreterProxy->booleanValueOf;
		classArray = interpreterProxy->classArray;
		failed = interpreterProxy->failed;
		firstIndexableField = interpreterProxy->firstIndexableField;
		floatObjectOf = interpreterProxy->floatObjectOf;
		instantiateClassindexableSize = interpreterProxy->instantiateClassindexableSize;
		isWords = interpreterProxy->isWords;
		pop = interpreterProxy->pop;
		popthenPush = interpreterProxy->popthenPush;
		popRemappableOop = interpreterProxy->popRemappableOop;
		positive32BitIntegerFor = interpreterProxy->positive32BitIntegerFor;
		pushRemappableOop = interpreterProxy->pushRemappableOop;
		slotSizeOf = interpreterProxy->slotSizeOf;
		stackFloatValue = interpreterProxy->stackFloatValue;
		stackIntegerValue = interpreterProxy->stackIntegerValue;
		stackValue = interpreterProxy->stackValue;
		storePointerofObjectwithValue = interpreterProxy->storePointerofObjectwithValue;
		success = interpreterProxy->success;
#endif /* !defined(SQUEAK_BUILTIN_PLUGIN) */
	}
	return ok;
}

EXPORT(sqInt)
shutdownModule(void)
{
	return soundShutdown();
}

static sqInt
sqAssert(sqInt aBool)
{
	/* missing DebugCode */;
}


#ifdef SQUEAK_BUILTIN_PLUGIN

void* SoundPlugin_exports[][3] = {
	{"SoundPlugin", "getModuleName", (void*)getModuleName},
	{"SoundPlugin", "initialiseModule", (void*)initialiseModule},
	{"SoundPlugin", "primitiveSoundAvailableSpace\000\377", (void*)primitiveSoundAvailableSpace},
	{"SoundPlugin", "primitiveSoundGetRecordingSampleRate\000\377", (void*)primitiveSoundGetRecordingSampleRate},
	{"SoundPlugin", "primitiveSoundGetVolume\000\377", (void*)primitiveSoundGetVolume},
	{"SoundPlugin", "primitiveSoundInsertSamples\000\000", (void*)primitiveSoundInsertSamples},
	{"SoundPlugin", "primitiveSoundPlaySamples\000\000", (void*)primitiveSoundPlaySamples},
	{"SoundPlugin", "primitiveSoundPlaySilence\000\377", (void*)primitiveSoundPlaySilence},
	{"SoundPlugin", "primitiveSoundRecordSamples\000\000", (void*)primitiveSoundRecordSamples},
	{"SoundPlugin", "primitiveSoundSetLeftVolume\000\000", (void*)primitiveSoundSetLeftVolume},
	{"SoundPlugin", "primitiveSoundSetRecordLevel\000\000", (void*)primitiveSoundSetRecordLevel},
	{"SoundPlugin", "primitiveSoundStart\000\000", (void*)primitiveSoundStart},
	{"SoundPlugin", "primitiveSoundStartRecording\000\000", (void*)primitiveSoundStartRecording},
	{"SoundPlugin", "primitiveSoundStartWithSemaphore\000\000", (void*)primitiveSoundStartWithSemaphore},
	{"SoundPlugin", "primitiveSoundStop\000\377", (void*)primitiveSoundStop},
	{"SoundPlugin", "primitiveSoundStopRecording\000\377", (void*)primitiveSoundStopRecording},
	{"SoundPlugin", "setInterpreter", (void*)setInterpreter},
	{"SoundPlugin", "shutdownModule\000\377", (void*)shutdownModule},
	{NULL, NULL, NULL}
};

#endif /* ifdef SQ_BUILTIN_PLUGIN */
