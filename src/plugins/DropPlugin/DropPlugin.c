/* Automatically generated by
	VMPluginCodeGenerator VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd
   from
	DropPlugin VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd
 */
static char __buildInfo[] = "DropPlugin VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd " __DATE__ ;



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

#include "DropPlugin.h"
#include "sqMemoryAccess.h"


/*** Constants ***/


/*** Function Prototypes ***/
static VirtualMachine * getInterpreter(void);
EXPORT(const char*) getModuleName(void);
static sqInt halt(void);
EXPORT(sqInt) initialiseModule(void);
static sqInt msg(char *s);
EXPORT(sqInt) primitiveDropRequestFileHandle(void);
EXPORT(sqInt) primitiveDropRequestFileName(void);
EXPORT(sqInt) setFileAccessCallback(int address);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);
EXPORT(sqInt) shutdownModule(void);


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
static sqInt (*classString)(void);
static sqInt (*failed)(void);
static void * (*firstIndexableField)(sqInt oop);
static sqInt (*instantiateClassindexableSize)(sqInt classPointer, sqInt size);
static sqInt (*methodArgumentCount)(void);
static sqInt (*pop)(sqInt nItems);
static sqInt (*primitiveFail)(void);
static sqInt (*push)(sqInt object);
static sqInt (*stackIntegerValue)(sqInt offset);
#else /* !defined(SQUEAK_BUILTIN_PLUGIN) */
extern sqInt classString(void);
extern sqInt failed(void);
extern void * firstIndexableField(sqInt oop);
extern sqInt instantiateClassindexableSize(sqInt classPointer, sqInt size);
extern sqInt methodArgumentCount(void);
extern sqInt pop(sqInt nItems);
extern sqInt primitiveFail(void);
extern sqInt push(sqInt object);
extern sqInt stackIntegerValue(sqInt offset);
extern
#endif
struct VirtualMachine* interpreterProxy;
static const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"DropPlugin VMMaker.oscog-eem.576 (i)"
#else
	"DropPlugin VMMaker.oscog-eem.576 (e)"
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
	return dropInit();
}

static sqInt
msg(char *s)
{
	fprintf(stderr, "\n%s: %s", moduleName, s);
	return 0;
}


/*	Note: File handle creation needs to be handled by specific support code
	explicitly bypassing the plugin file sand box.
 */

EXPORT(sqInt)
primitiveDropRequestFileHandle(void)
{
    sqInt dropIndex;
    sqInt handleOop;

	if (!((methodArgumentCount()) == 1)) {
		return primitiveFail();
	}
	dropIndex = stackIntegerValue(0);

	/* dropRequestFileHandle needs to return the actual oop returned */

	handleOop = dropRequestFileHandle(dropIndex);
	if (!(failed())) {
		pop(2);
		push(handleOop);
	}
}


/*	Note: File handle creation needs to be handled by specific support code
	explicitly bypassing the plugin file sand box.
 */

EXPORT(sqInt)
primitiveDropRequestFileName(void)
{
    sqInt dropIndex;
    char *dropName;
    sqInt i;
    sqInt nameLength;
    sqInt nameOop;
    char *namePtr;

	if (!((methodArgumentCount()) == 1)) {
		return primitiveFail();
	}
	dropIndex = stackIntegerValue(0);

	/* dropRequestFileName returns name or NULL on error */

	dropName = dropRequestFileName(dropIndex);
	if (dropName == null) {
		return primitiveFail();
	}
	nameLength = strlen(dropName);
	nameOop = instantiateClassindexableSize(classString(), nameLength);
	namePtr = firstIndexableField(nameOop);
	for (i = 0; i < nameLength; i += 1) {
		namePtr[i] = (dropName[i]);
	}
	pop(2);
	push(nameOop);
}

EXPORT(sqInt)
setFileAccessCallback(int address)
{
	return sqSecFileAccessCallback((void *) address);
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
		classString = interpreterProxy->classString;
		failed = interpreterProxy->failed;
		firstIndexableField = interpreterProxy->firstIndexableField;
		instantiateClassindexableSize = interpreterProxy->instantiateClassindexableSize;
		methodArgumentCount = interpreterProxy->methodArgumentCount;
		pop = interpreterProxy->pop;
		primitiveFail = interpreterProxy->primitiveFail;
		push = interpreterProxy->push;
		stackIntegerValue = interpreterProxy->stackIntegerValue;
#endif /* !defined(SQUEAK_BUILTIN_PLUGIN) */
	}
	return ok;
}

EXPORT(sqInt)
shutdownModule(void)
{
	return dropShutdown();
}


#ifdef SQUEAK_BUILTIN_PLUGIN

void* DropPlugin_exports[][3] = {
	{"DropPlugin", "getModuleName", (void*)getModuleName},
	{"DropPlugin", "initialiseModule", (void*)initialiseModule},
	{"DropPlugin", "primitiveDropRequestFileHandle\000\000", (void*)primitiveDropRequestFileHandle},
	{"DropPlugin", "primitiveDropRequestFileName\000\000", (void*)primitiveDropRequestFileName},
	{"DropPlugin", "setFileAccessCallback", (void*)setFileAccessCallback},
	{"DropPlugin", "setInterpreter", (void*)setInterpreter},
	{"DropPlugin", "shutdownModule\000\377", (void*)shutdownModule},
	{NULL, NULL, NULL}
};

#endif /* ifdef SQ_BUILTIN_PLUGIN */
