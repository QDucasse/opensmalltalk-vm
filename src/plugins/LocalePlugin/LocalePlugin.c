/* Automatically generated by
	SmartSyntaxPluginCodeGenerator VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd
   from
	LocalePlugin VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd
 */
static char __buildInfo[] = "LocalePlugin VMMaker.oscog-eem.576 uuid: f4b652dc-67bc-4cf3-8b62-74bcbcbf01cd " __DATE__ ;



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

#include "LocalePlugin.h"
#include "sqMemoryAccess.h"


/*** Constants ***/


/*** Function Prototypes ***/
static VirtualMachine * getInterpreter(void);
EXPORT(const char*) getModuleName(void);
static sqInt halt(void);
EXPORT(sqInt) initialiseModule(void);
static sqInt msg(char *s);
EXPORT(sqInt) primitiveCountry(void);
EXPORT(sqInt) primitiveCurrencyNotation(void);
EXPORT(sqInt) primitiveCurrencySymbol(void);
EXPORT(sqInt) primitiveDaylightSavings(void);
EXPORT(sqInt) primitiveDecimalSymbol(void);
EXPORT(sqInt) primitiveDigitGroupingSymbol(void);
EXPORT(sqInt) primitiveLanguage(void);
EXPORT(sqInt) primitiveLongDateFormat(void);
EXPORT(sqInt) primitiveMeasurementMetric(void);
EXPORT(sqInt) primitiveShortDateFormat(void);
EXPORT(sqInt) primitiveTimeFormat(void);
EXPORT(sqInt) primitiveTimezoneOffset(void);
EXPORT(sqInt) primitiveVMOffsetToUTC(void);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);
static sqInt sqAssert(sqInt aBool);


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
static sqInt (*classString)(void);
static sqInt (*failed)(void);
static sqInt (*falseObject)(void);
static void * (*firstIndexableField)(sqInt oop);
static sqInt (*instantiateClassindexableSize)(sqInt classPointer, sqInt size);
static sqInt (*integerObjectOf)(sqInt value);
static sqInt (*popthenPush)(sqInt nItems, sqInt oop);
static sqInt (*trueObject)(void);
#else /* !defined(SQUEAK_BUILTIN_PLUGIN) */
extern sqInt classString(void);
extern sqInt failed(void);
extern sqInt falseObject(void);
extern void * firstIndexableField(sqInt oop);
extern sqInt instantiateClassindexableSize(sqInt classPointer, sqInt size);
extern sqInt integerObjectOf(sqInt value);
extern sqInt popthenPush(sqInt nItems, sqInt oop);
extern sqInt trueObject(void);
extern
#endif
struct VirtualMachine* interpreterProxy;
static const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"LocalePlugin VMMaker.oscog-eem.576 (i)"
#else
	"LocalePlugin VMMaker.oscog-eem.576 (e)"
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
	return sqLocInitialize();
}

static sqInt
msg(char *s)
{
	fprintf(stderr, "\n%s: %s", moduleName, s);
	return 0;
}


/*	return a 3 char string describing the country in use. ISO 3166 is the
	relevant source here; see http://www.unicode.org/onlinedat/countries.html
	for details. Using the 3 character Alpha-3 codes
 */

EXPORT(sqInt)
primitiveCountry(void)
{
	sqInt oop;

	oop = instantiateClassindexableSize(classString(), 3);
	sqLocGetCountryInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a boolean specifying whether the currency symbol is pre or post
	fix. true -> pre
 */

EXPORT(sqInt)
primitiveCurrencyNotation(void)
{
	sqInt _return_value;

	_return_value = (((sqLocCurrencyNotation())) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	return a string describing the currency symbol used 
	Still need to find details on standard symbols - ISO 4217 is supposed to
	be it but cannot find on web
 */

EXPORT(sqInt)
primitiveCurrencySymbol(void)
{
	sqInt length;
	sqInt oop;

	length = sqLocCurrencySymbolSize();
	oop = instantiateClassindexableSize(classString(), length);
	sqLocGetCurrencySymbolInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a boolean specifying the DST setting. true -> active */

EXPORT(sqInt)
primitiveDaylightSavings(void)
{
	sqInt _return_value;

	_return_value = (((sqLocDaylightSavings())) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	return a 1 char string describing the decimal symbol used - usually a . or
	a ,
 */

EXPORT(sqInt)
primitiveDecimalSymbol(void)
{
	sqInt oop;

	oop = instantiateClassindexableSize(classString(), 1);
	sqLocGetDecimalSymbolInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a 1 char string describing the digitGrouping symbol used - usually
	a . or a , between triples of digits
 */

EXPORT(sqInt)
primitiveDigitGroupingSymbol(void)
{
	sqInt oop;

	oop = instantiateClassindexableSize(classString(), 1);
	sqLocGetDigitGroupingSymbolInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a 3 char string describing the language in use. ISO 639 is the
	relevant source here; see http://www.w3.org/WAI/ER/IG/ert/iso639.html for
	details 
 */

EXPORT(sqInt)
primitiveLanguage(void)
{
	sqInt oop;

	oop = instantiateClassindexableSize(classString(), 3);
	sqLocGetLanguageInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a string describing the long date formatting.
	Format is made up of
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month nam
	
 */

EXPORT(sqInt)
primitiveLongDateFormat(void)
{
	sqInt length;
	sqInt oop;

	length = sqLocLongDateFormatSize();
	oop = instantiateClassindexableSize(classString(), length);
	sqLocGetLongDateFormatInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a boolean specifying whether the currency symbol is pre or post
	fix. true -> pre
 */

EXPORT(sqInt)
primitiveMeasurementMetric(void)
{
	sqInt _return_value;

	_return_value = (((sqLocMeasurementMetric())) ? trueObject() : falseObject());
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	return a string describing the long date formatting.
	Format is made up of
	d day, m month, y year,
	double symbol is null padded, single not padded (m=6, mm=06)
	dddd weekday
	mmmm month nam
	
 */

EXPORT(sqInt)
primitiveShortDateFormat(void)
{
	sqInt length;
	sqInt oop;

	length = sqLocShortDateFormatSize();
	oop = instantiateClassindexableSize(classString(), length);
	sqLocGetShortDateFormatInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return a string describing the time formatting.
	Format is made up of
	h hour (h 12, H 24), m minute, s seconds, x (am/pm String)
	double symbol is null padded, single not padded (h=6, hh=06)
 */

EXPORT(sqInt)
primitiveTimeFormat(void)
{
	sqInt length;
	sqInt oop;

	length = sqLocTimeFormatSize();
	oop = instantiateClassindexableSize(classString(), length);
	sqLocGetTimeFormatInto(firstIndexableField(oop));
	if (failed()) {
		return null;
	}
	popthenPush(1, oop);
	return null;
}


/*	return the number of minutes this VM's time value is offset from UTC */

EXPORT(sqInt)
primitiveTimezoneOffset(void)
{
	sqInt _return_value;

	_return_value = integerObjectOf((sqLocGetTimezoneOffset()));
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
	return null;
}


/*	return the number of minutes this VM's time value is offset from UTC */

EXPORT(sqInt)
primitiveVMOffsetToUTC(void)
{
	sqInt _return_value;

	_return_value = integerObjectOf((sqLocGetVMOffsetToUTC()));
	if (failed()) {
		return null;
	}
	popthenPush(1, _return_value);
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
		classString = interpreterProxy->classString;
		failed = interpreterProxy->failed;
		falseObject = interpreterProxy->falseObject;
		firstIndexableField = interpreterProxy->firstIndexableField;
		instantiateClassindexableSize = interpreterProxy->instantiateClassindexableSize;
		integerObjectOf = interpreterProxy->integerObjectOf;
		popthenPush = interpreterProxy->popthenPush;
		trueObject = interpreterProxy->trueObject;
#endif /* !defined(SQUEAK_BUILTIN_PLUGIN) */
	}
	return ok;
}

static sqInt
sqAssert(sqInt aBool)
{
	/* missing DebugCode */;
}


#ifdef SQUEAK_BUILTIN_PLUGIN

void* LocalePlugin_exports[][3] = {
	{"LocalePlugin", "getModuleName", (void*)getModuleName},
	{"LocalePlugin", "initialiseModule", (void*)initialiseModule},
	{"LocalePlugin", "primitiveCountry\000\377", (void*)primitiveCountry},
	{"LocalePlugin", "primitiveCurrencyNotation\000\377", (void*)primitiveCurrencyNotation},
	{"LocalePlugin", "primitiveCurrencySymbol\000\377", (void*)primitiveCurrencySymbol},
	{"LocalePlugin", "primitiveDaylightSavings\000\377", (void*)primitiveDaylightSavings},
	{"LocalePlugin", "primitiveDecimalSymbol\000\377", (void*)primitiveDecimalSymbol},
	{"LocalePlugin", "primitiveDigitGroupingSymbol\000\377", (void*)primitiveDigitGroupingSymbol},
	{"LocalePlugin", "primitiveLanguage\000\377", (void*)primitiveLanguage},
	{"LocalePlugin", "primitiveLongDateFormat\000\377", (void*)primitiveLongDateFormat},
	{"LocalePlugin", "primitiveMeasurementMetric\000\377", (void*)primitiveMeasurementMetric},
	{"LocalePlugin", "primitiveShortDateFormat\000\377", (void*)primitiveShortDateFormat},
	{"LocalePlugin", "primitiveTimeFormat\000\377", (void*)primitiveTimeFormat},
	{"LocalePlugin", "primitiveTimezoneOffset\000\377", (void*)primitiveTimezoneOffset},
	{"LocalePlugin", "primitiveVMOffsetToUTC\000\377", (void*)primitiveVMOffsetToUTC},
	{"LocalePlugin", "setInterpreter", (void*)setInterpreter},
	{NULL, NULL, NULL}
};

#endif /* ifdef SQ_BUILTIN_PLUGIN */
