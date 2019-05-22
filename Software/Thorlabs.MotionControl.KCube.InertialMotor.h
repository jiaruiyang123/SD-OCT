// summary:	Declares the functions class
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the TCUBEInertialMotor_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// KCUBEINERTIALMOTOR_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef KCUBEINERTIALMOTORDLL_EXPORTS
#define KCUBEINERTIALMOTOR_API __declspec(dllexport)
#else
#define KCUBEINERTIALMOTOR_API __declspec(dllimport)
#endif

#include <OaIdl.h>

#pragma once

/** @defgroup KCubeInertialMotor KCube InertialMotor
 *  This section details the Structures and Functions relavent to the  @ref KIM101_page "InertialMotor"<br />
 *  For an example of how to connect to the device and perform simple operations use the following links:
 *  <list type=bullet>
 *    <item> \ref namespaces_kim_ex_1 "Example of using the Thorlabs.MotionControl.KCube.InertialMotor.DLL from a C or C++ project."<br />
 *									  This requires the DLL to be dynamical linked. </item>
 *    <item> \ref namespaces_kim_ex_2 "Example of using the Thorlabs.MotionControl.KCube.InertialMotor.DLL from a C# project"<br />
 *									  This uses Marshalling to load and access the C DLL. </item>
 *  </list>
 *  The Thorlabs.MotionControl.KCube.InertialMotor.DLL requires the following DLLs
 *  <list type=bullet>
 *    <item> Thorlabs.MotionControl.DeviceManager. </item>
 *  </list>
 *  @{
 */
extern "C"
{
	/// \cond NOT_MASTER

	/// <summary> Values that represent FT_Status. </summary>
	typedef enum FT_Status : short
	{
		FT_OK = 0x00, /// <OK - no error.
		FT_InvalidHandle = 0x01, ///<Invalid handle.
		FT_DeviceNotFound = 0x02, ///<Device not found.
		FT_DeviceNotOpened = 0x03, ///<Device not opened.
		FT_IOError = 0x04, ///<I/O error.
		FT_InsufficientResources = 0x05, ///<Insufficient resources.
		FT_InvalidParameter = 0x06, ///<Invalid parameter.
		FT_DeviceNotPresent = 0x07, ///<Device not present.
		FT_IncorrectDevice = 0x08 ///<Incorrect device.
	 } FT_Status;

	/// <summary> Values that represent THORLABSDEVICE_API. </summary>
	typedef enum MOT_MotorTypes
	{
		MOT_NotMotor = 0,
		MOT_DCMotor = 1,
		MOT_StepperMotor = 2,
		MOT_BrushlessMotor = 3,
		MOT_CustomMotor = 100,
	} MOT_MotorTypes;

#pragma pack(1)

	/// <summary> Values that represent KIM_Channels. </summary>
	typedef enum KIM_Channels : unsigned short
	{
		/// <summary> An enum constant representing the channel 1 option. </summary>
		Channel1 = 1,
		/// <summary> An enum constant representing the channel 2 option. </summary>
		Channel2,
		/// <summary> An enum constant representing the channel 3 option. </summary>
		Channel3,
		/// <summary> An enum constant representing the channel 4 option. </summary>
		Channel4
	} KIM_Channels;

	/// <summary> Values that represent KIM_JogMode. </summary>
	typedef enum KIM_JogMode : unsigned __int16
	{
		/// <summary> An enum constant representing the jog continuous option. </summary>
		JogContinuous = 0x01,
		/// <summary> An enum constant representing the jog step option. </summary>
		JogStep = 0x02,
	} KIM_JogMode;

	/// <summary> Values that represent KIM_ButtonsMode. </summary>
	typedef enum KIM_ButtonsMode : unsigned __int16
	{
		/// <summary> An enum constant representing the jog option. </summary>
		Jog = 0x01,
		/// <summary> An enum constant representing the position option. </summary>
		Position = 0x02,
	} KIM_ButtonsMode;

	/// <summary> Values that represent KIM_Direction. </summary>
	typedef enum KIM_Direction : byte
	{
		/// <summary> An enum constant representing the forward option. </summary>
		Forward = 0x01,
		/// <summary> An enum constant representing the reverse option. </summary>
		Reverse = 0x02,
	} KIM_Direction;

	/// <summary> KIM Drive Operation Parameters. </summary>
	typedef struct KIM_DriveOPParameters
	{
		/// <summary> The maximum voltage. </summary>
		__int16 _maxVoltage;
		/// <summary> The step rate. </summary>
		__int32 _stepRate;
		/// <summary> The step acceleration. </summary>
		__int32 _stepAcceleration;
	} KIM_DriveOPParameters;

	/// <summary> Tim jog parameters. </summary>
	typedef struct KIM_JogParameters
	{
		/// <summary> The jog mode. </summary>
		KIM_JogMode _jogMode;
		/// <summary> Size of the jog step. </summary>
		__int32 _jogStepSize;
		/// <summary> The jog step rate. </summary>
		__int32 _jogStepRate;
		/// <summary> The jog step acceleration. </summary>
		__int32 _jogStepAcceleration;
	} KIM_JogParameters;

	/// <summary> Tim button parameters. </summary>
	typedef struct KIM_ButtonParameters
	{
		/// <summary> The button mode. </summary>
		KIM_ButtonsMode _buttonMode;
		/// <summary> The first position. </summary>
		__int32 _position1;
		/// <summary> The second position. </summary>
		__int32 _position2;
		/// <summary> The reserved fields. </summary>
		__int16 _reserved[2];
	} KIM_ButtonParameters;

	/// <summary> Tim status. </summary>
	typedef struct KIM_Status
	{
		/// <summary> The position. </summary>
		__int32 _position;
		/// <summary> Number of encoders. </summary>
		__int32 _encoderCount;
		/// <summary> The status bits. </summary>
		unsigned __int32 _statusBits;
	} KIM_Status;

	/// \endcond

#pragma pack()

#pragma pack(1)

	/// <summary> Information about the device generated from serial number. </summary>
	typedef struct TLI_DeviceInfo
	{
		/// <summary> The device Type ID, see \ref C_DEVICEID_page "Device serial numbers". </summary>
		DWORD typeID;
		/// <summary> The device description. </summary>
		char description[65];
		/// <summary> The device serial number. </summary>
		char serialNo[9];
		/// <summary> The USB PID number. </summary>
		DWORD PID;

		/// <summary> <c>true</c> if this object is a type known to the Motion Control software. </summary>
		bool isKnownType;
		/// <summary> The motor type (if a motor).
		/// 		  <list type=table>
		///				<item><term>MOT_NotMotor</term><term>0</term></item>
		///				<item><term>MOT_DCMotor</term><term>1</term></item>
		///				<item><term>MOT_StepperMotor</term><term>2</term></item>
		///				<item><term>MOT_BrushlessMotor</term><term>3</term></item>
		///				<item><term>MOT_CustomMotor</term><term>100</term></item>
		/// 		  </list> </summary>
		MOT_MotorTypes motorType;

		/// <summary> <c>true</c> if the device is a piezo device. </summary>
		bool isPiezoDevice;
		/// <summary> <c>true</c> if the device is a laser. </summary>
		bool isLaser;
		/// <summary> <c>true</c> if the device is a custom type. </summary>
		bool isCustomType;
		/// <summary> <c>true</c> if the device is a rack. </summary>
		bool isRack;
		/// <summary> Defines the number of channels available in this device. </summary>
		short maxChannels;
	} TLI_DeviceInfo;

	/// <summary> Structure containing the Hardware Information. </summary>
	/// <value> Hardware Information retrieved from tthe device. </value>
	typedef struct TLI_HardwareInformation
	{
		/// <summary> The device serial number. </summary>
		/// <remarks> The device serial number is a serial number,<br />starting with 2 digits representing the device type<br /> and a 6 digit unique value.</remarks>
		DWORD serialNumber;
		/// <summary> The device model number. </summary>
		/// <remarks> The model number uniquely identifies the device type as a string. </remarks>
		char modelNumber[8];
		/// <summary> The device type. </summary>
		/// <remarks> Each device type has a unique Type ID: see \ref C_DEVICEID_page "Device serial numbers" </remarks>
		WORD type;
		/// <summary> The device firmware version. </summary>
		DWORD firmwareVersion;
		/// <summary> The device notes read from the device. </summary>
		char notes[48];
		/// <summary> The device dependant data. </summary>
		BYTE deviceDependantData[12];
		/// <summary> The device hardware version. </summary>
		WORD hardwareVersion;
		/// <summary> The device modification state. </summary>
		WORD modificationState;
		/// <summary> The number of channels the device provides. </summary>
		short numChannels;
	} TLI_HardwareInformation;

#pragma pack()

    /// <summary> Build the DeviceList. </summary>
    /// <remarks> This function builds an internal collection of all devices found on the USB that are not currently open. <br />
    /// 		  NOTE, if a device is open, it will not appear in the list until the device has been closed. </remarks>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_BuildDeviceList(void);

	/// <summary> Gets the device list size. </summary>
	/// 		  \include CodeSnippet_identification.cpp
	/// <returns> Number of devices in device list. </returns>
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceListSize();

	/// <summary> Get the entire contents of the device list. </summary>
	/// <param name="stringsReceiver"> Outputs a SAFEARRAY of strings holding device serial numbers. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceList(SAFEARRAY** stringsReceiver);

	/// <summary> Get the contents of the device list which match the supplied typeID. </summary>
	/// <param name="stringsReceiver"> Outputs a SAFEARRAY of strings holding device serial numbers. </param>
	/// <param name="typeID">The typeID of devices to match, see \ref C_DEVICEID_page "Device serial numbers". </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID);

	/// <summary> Get the contents of the device list which match the supplied typeIDs. </summary>
	/// <param name="stringsReceiver"> Outputs a SAFEARRAY of strings holding device serial numbers. </param>
	/// <param name="typeIDs"> list of typeIDs of devices to be matched, see \ref C_DEVICEID_page "Device serial numbers"</param>
	/// <param name="length"> length of type list</param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length);

	/// <summary> Get the entire contents of the device list. </summary>
	/// <param name="receiveBuffer"> a buffer in which to receive the list as a comma separated string. </param>
	/// <param name="sizeOfBuffer">	The size of the output string buffer. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer);

	/// <summary> Get the contents of the device list which match the supplied typeID. </summary>
	/// <param name="receiveBuffer"> a buffer in which to receive the list as a comma separated string. </param>
	/// <param name="sizeOfBuffer">	The size of the output string buffer. </param>
	/// <param name="typeID"> The typeID of devices to be matched, see \ref C_DEVICEID_page "Device serial numbers"</param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID);

	/// <summary> Get the contents of the device list which match the supplied typeIDs. </summary>
	/// <param name="receiveBuffer"> a buffer in which to receive the list as a comma separated string. </param>
	/// <param name="sizeOfBuffer">	The size of the output string buffer. </param>
	/// <param name="typeIDs"> list of typeIDs of devices to be matched, see \ref C_DEVICEID_page "Device serial numbers"</param>
	/// <param name="length"> length of type list</param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length);

	/// <summary> Get the device information from the USB port. </summary>
	/// <remarks> The Device Info is read from the USB port not from the device itself.<remarks>
	/// <param name="serialNo"> The serial number of the device. </param>
	/// <param name="info">    The <see cref="TLI_DeviceInfo"/> device information. </param>
	/// <returns> 1 if successful, 0 if not. </returns>
    /// 		  \include CodeSnippet_identification.cpp
	/// <seealso cref="TLI_GetDeviceListSize()" />
	/// <seealso cref="TLI_BuildDeviceList()" />
	/// <seealso cref="TLI_GetDeviceList(SAFEARRAY** stringsReceiver)" />
	/// <seealso cref="TLI_GetDeviceListByType(SAFEARRAY** stringsReceiver, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypes(SAFEARRAY** stringsReceiver, int * typeIDs, int length)" />
	/// <seealso cref="TLI_GetDeviceListExt(char *receiveBuffer, DWORD sizeOfBuffer)" />
	/// <seealso cref="TLI_GetDeviceListByTypeExt(char *receiveBuffer, DWORD sizeOfBuffer, int typeID)" />
	/// <seealso cref="TLI_GetDeviceListByTypesExt(char *receiveBuffer, DWORD sizeOfBuffer, int * typeIDs, int length)" />
	KCUBEINERTIALMOTOR_API short __cdecl TLI_GetDeviceInfo(char const * serialNo, TLI_DeviceInfo *info);

	/// <summary> Open the device for communications. </summary>
	/// <param name="serialNo">	The serial no of the device to be connected. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_connection1.cpp
	/// <seealso cref="KIM_Close(char const * serialNo)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_Open(char const * serialNo);

	/// <summary> Disconnect and close the device. </summary>
	/// <param name="serialNo">	The serial no of the device to be disconnected. </param>
    /// 		  \include CodeSnippet_connection1.cpp
	/// <seealso cref="KIM_Open(char const * serialNo)" />
	KCUBEINERTIALMOTOR_API void __cdecl KIM_Close(char const * serialNo);

	/// <summary>	Check connection. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> true if the USB is listed by the ftdi controller</returns>
	/// \include CodeSnippet_CheckConnection.cpp
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_CheckConnection(char const * serialNo);

	/// <summary> Sends a command to the device to make it identify iteself. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	KCUBEINERTIALMOTOR_API void __cdecl KIM_Identify(char const * serialNo);

	/// <summary> Gets the hardware information from the device. </summary>
	/// <param name="serialNo">		    The device serial no. </param>
	/// <param name="modelNo">		    Address of a buffer to receive the model number string. Minimum 8 characters </param>
	/// <param name="sizeOfModelNo">	    The size of the model number buffer, minimum of 8 characters. </param>
	/// <param name="type">		    Address of a WORD to receive the hardware type number. </param>
	/// <param name="numChannels">	    Address of a short to receive the  number of channels. </param>
	/// <param name="notes">		    Address of a buffer to receive the notes describing the device. </param>
	/// <param name="sizeOfNotes">		    The size of the notes buffer, minimum of 48 characters. </param>
	/// <param name="firmwareVersion"> Address of a DWORD to receive the  firmware version number made up of 4 byte parts. </param>
	/// <param name="hardwareVersion"> Address of a WORD to receive the  hardware version number. </param>
	/// <param name="modificationState">	    Address of a WORD to receive the hardware modification state number. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identify.cpp
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetHardwareInfo(char const * serialNo, char * modelNo, DWORD sizeOfModelNo, WORD * type, WORD * numChannels, 
													char * notes, DWORD sizeOfNotes, DWORD * firmwareVersion, WORD * hardwareVersion, WORD * modificationState);

	/// <summary> Gets the hardware information in a block. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="hardwareInfo"> Address of a TLI_HardwareInformation structure to receive the hardware information. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
    /// 		  \include CodeSnippet_identify.cpp
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetHardwareInfoBlock(char const *serialNo, TLI_HardwareInformation *hardwareInfo);

	/// <summary> Gets version number of the device firmware. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The device firmware version number made up of 4 byte parts. </returns>
    /// 		  \include CodeSnippet_identify.cpp
	KCUBEINERTIALMOTOR_API DWORD __cdecl KIM_GetFirmwareVersion(char const * serialNo);

	/// <summary> Gets version number of the device software. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The device software version number made up of 4 byte parts. </returns>
    /// 		  \include CodeSnippet_identify.cpp
	KCUBEINERTIALMOTOR_API DWORD __cdecl KIM_GetSoftwareVersion(char const * serialNo);

	/// <summary> Update device with stored settings. </summary>
	/// <param name="serialNo"> The device serial no. </param>
	/// <returns> <c>true</c> if successful, false if not. </returns>
    /// 		  \include CodeSnippet_connection1.cpp
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_LoadSettings(char const * serialNo);

	/// <summary> persist the devices current settings. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> <c>true</c> if successful, false if not. </returns>
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_PersistSettings(char const * serialNo);

	/// <summary> Disable cube. </summary>

	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	/// <seealso cref="KIM_Enable(char const * serialNo)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_Disable(char const * serialNo);

	/// <summary> Enable cube for computer control. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	/// <seealso cref="KIM_Disable(char const * serialNo)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_Enable(char const * serialNo);

	/// <summary> Reset the device. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_Reset(char const * serialNo);

	/// <summary> Tells the device that it is being disconnected. </summary>
	/// <remarks> This does not disconnect the communications.<br />
	/// 		  To disconnect the communications, call the <see cref="KIM_Close(char const * serialNo)" /> function. </remarks>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_Disconnect(char const * serialNo);

	/// <summary> Clears the device message queue. </summary>
	/// <remarks> see \ref C_MESSAGES_page "Device Messages" for details on how to use messages. </remarks>
	/// <param name="serialNo"> The device serial no. </param>
	KCUBEINERTIALMOTOR_API void __cdecl KIM_ClearMessageQueue(char const * serialNo);

	/// <summary> Registers a callback on the message queue. </summary>
	/// <remarks> see \ref C_MESSAGES_page "Device Messages" for details on how to use messages. </remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="functionPointer"> A function pointer to be called whenever messages are received. </param>
	/// <seealso cref="KIM_MessageQueueSize(char const * serialNo)" />
	/// <seealso cref="KIM_GetNextMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData)" />
	/// <seealso cref="KIM_WaitForMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData)" />
	KCUBEINERTIALMOTOR_API void __cdecl KIM_RegisterMessageCallback(char const * serialNo, void (* functionPointer)());

	/// <summary> Gets the MessageQueue size. </summary>
	/// <remarks> see \ref C_MESSAGES_page "Device Messages" for details on how to use messages. </remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <returns> number of messages in the queue. </returns>
	/// <seealso cref="KIM_RegisterMessageCallback(char const * serialNo, void (* functionPointer)())" />
	/// <seealso cref="KIM_GetNextMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData)" />
	/// <seealso cref="KIM_WaitForMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData)" />
	KCUBEINERTIALMOTOR_API int __cdecl KIM_MessageQueueSize(char const * serialNo);

	/// <summary> Get the next MessageQueue item. </summary>
	/// <remarks> see \ref C_MESSAGES_page "Device Messages" for details on how to use messages. </remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="messageType"> The address of the parameter to receive the message Type. </param>
	/// <param name="messageID">   The address of the parameter to receive the message id. </param>
	/// <param name="messageData"> The address of the parameter to receive the message data. </param>
	/// <returns> <c>true</c> if successful, false if not. </returns>
	/// <seealso cref="KIM_RegisterMessageCallback(char const * serialNo, void (* functionPointer)())" />
	/// <seealso cref="KIM_MessageQueueSize(char const * serialNo)" />
	/// <seealso cref="KIM_WaitForMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData)" />
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_GetNextMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData);

	/// <summary> Wait for next MessageQueue item. </summary>
	/// <remarks> see \ref C_MESSAGES_page "Device Messages" for details on how to use messages. </remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="messageType"> The address of the parameter to receive the message Type. </param>
	/// <param name="messageID">   The address of the parameter to receive the message id. </param>
	/// <param name="messageData"> The address of the parameter to receive the message data. </param>
	/// <returns> <c>true</c> if successful, false if not. </returns>
	/// <seealso cref="KIM_RegisterMessageCallback(char const * serialNo, void (* functionPointer)())" />
	/// <seealso cref="KIM_MessageQueueSize(char const * serialNo)" />
	/// <seealso cref="KIM_GetNextMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData)" />
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_WaitForMessage(char const * serialNo, WORD * messageType, WORD * messageID, DWORD *messageData);

	/// <summary> Sets the current position to the Home position (Position = 0). </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">  The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_Home(char const * serialNo, KIM_Channels channel);

	/// <summary> set the position. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">  The channel. </param>
	/// <param name="position"> The position. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetPosition(char const * serialNo, KIM_Channels channel, long position);

	/// <summary> Move absolute. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">  The channel. </param>
	/// <param name="position"> The position. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_MoveAbsolute(char const * serialNo, KIM_Channels channel, __int32 position);

	/// <summary> Move jog. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">	    The channel. </param>
	/// <param name="jogDirection"> The jog direction. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_MoveJog(char const * serialNo, KIM_Channels channel, KIM_Direction jogDirection);

	/// <summary> Move stop. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel"> The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_MoveStop(char const * serialNo, KIM_Channels channel);

	/// <summary> Requests the operation drive parameters. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">	The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestDriveOPParameters(char const * serialNo, KIM_Channels channel);

	/// <summary> Sets the operation drive parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">		    The channel. </param>
	/// <param name="maxVoltage">	    The maximum voltage. </param>
	/// <param name="stepRate">		    The step rate. </param>
	/// <param name="stepAcceleration"> The step acceleration. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetDriveOPParameters(char const * serialNo, KIM_Channels channel, __int16 maxVoltage, __int32 stepRate, __int32 stepAcceleration);

	/// <summary> Gets the operation drive parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">		    The channel. </param>
	/// <param name="maxVoltage">	    The maximum voltage. </param>
	/// <param name="stepRate">		    The step rate. </param>
	/// <param name="stepAcceleration"> The step acceleration. </param>
	/// <returns> The operation drive parameters. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetDriveOPParameters(char const * serialNo, KIM_Channels channel, __int16 &maxVoltage, __int32 &stepRate, __int32 &stepAcceleration);

	/// <summary> Sets the operation drive parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">			 The channel. </param>
	/// <param name="driveOPParameters"> Options for controlling the drive operation. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetDriveOPParametersStruct(char const * serialNo, KIM_Channels channel, KIM_DriveOPParameters &driveOPParameters);

	/// <summary> Gets the operation drive parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">			 The channel. </param>
	/// <param name="driveOPParameters"> Options for controlling the drive operation. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetDriveOPParametersStruct(char const * serialNo, KIM_Channels channel, KIM_DriveOPParameters &driveOPParameters);

	/// <summary> Requests the jog parameters. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">	The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestJogParameters(char const * serialNo, KIM_Channels channel);

	/// <summary> Sets the jog parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">			   The channel. </param>
	/// <param name="jogMode">			   The jog mode. </param>
	/// <param name="jogStepSize">		   Size of the jog step. </param>
	/// <param name="jogStepRate">		   The jog step rate. </param>
	/// <param name="jogStepAcceleration"> The jog step acceleration. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetJogParameters(char const * serialNo, KIM_Channels channel, KIM_JogMode jogMode, __int32 jogStepSize, __int32 jogStepRate, __int32 jogStepAcceleration);

	/// <summary> Gets the jog parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">			   The channel. </param>
	/// <param name="jogMode">			   The jog mode. </param>
	/// <param name="jogStepSize">		   Size of the jog step. </param>
	/// <param name="jogStepRate">		   The jog step rate. </param>
	/// <param name="jogStepAcceleration"> The jog step acceleration. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetJogParameters(char const * serialNo, KIM_Channels channel, KIM_JogMode &jogMode, __int32 &jogStepSize, __int32 &jogStepRate, __int32 &jogStepAcceleration);

	/// <summary> Sets the jog parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">			 The channel. </param>
	/// <param name="jogParameters"> Options for controlling the drive operation. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetJogParametersStruct(char const * serialNo, KIM_Channels channel, KIM_JogParameters &jogParameters);

	/// <summary> Gets the jog parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">			 The channel. </param>
	/// <param name="jogParameters"> Options for controlling the drive operation. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetJogParametersStruct(char const * serialNo, KIM_Channels channel, KIM_JogParameters &jogParameters);

	/// <summary> Requests the button parameters. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">	The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestButtonParameters(char const * serialNo, KIM_Channels channel);

	/// <summary> Sets a button parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">    The channel. </param>
	/// <param name="buttonMode"> The button mode. </param>
	/// <param name="position1">  The first position. </param>
	/// <param name="position2">  The second position. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetButtonParameters(char const * serialNo, KIM_Channels channel, KIM_ButtonsMode buttonMode, __int32 position1, __int32 position2);

	/// <summary> Gets a button parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">    The channel. </param>
	/// <param name="buttonMode"> The button mode. </param>
	/// <param name="position1">  The first position. </param>
	/// <param name="position2">  The second position. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetButtonParameters(char const * serialNo, KIM_Channels channel, KIM_ButtonsMode &buttonMode, __int32 &position1, __int32 &position2);

	/// <summary> Sets a button parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">		    The channel. </param>
	/// <param name="buttonParameters"> Options for controlling the button. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetButtonParametersStruct(char const * serialNo, KIM_Channels channel, KIM_ButtonParameters &buttonParameters);

	/// <summary> Gets a button parameters. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">		    The channel. </param>
	/// <param name="buttonParameters"> Options for controlling the button. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetButtonParametersStruct(char const * serialNo, KIM_Channels channel, KIM_ButtonParameters &buttonParameters);

	/// <summary> Sets a maximum pot step rate. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel">		  The channel. </param>
	/// <param name="maxPotStepRate"> The maximum pot step rate. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	/// <seealso cref="KIM_RequestMaxPotStepRate(char const * serialNo, KIM_Channels channel)" />
	/// <seealso cref="KIM_GetMaxPotStepRate(char const * serialNo, KIM_Channels channel)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetMaxPotStepRate(char const * serialNo, KIM_Channels channel, __int32 maxPotStepRate);

	/// <summary> Requests the maximum potentiometer step rate. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">	The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	/// <seealso cref="KIM_GetMaxPotStepRate(char const * serialNo, KIM_Channels channel)" />
	/// <seealso cref="KIM_SetMaxPotStepRate(char const * serialNo, KIM_Channels channel, __int32 maxPotStepRate)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestMaxPotStepRate(char const * serialNo, KIM_Channels channel);

	/// <summary> Gets the maximum potentiometer step rate. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="channel"> The channel. </param>
	/// <returns> The maximum pot step rate or 0 if an error occured. </returns>
	/// <seealso cref="KIM_RequestMaxPotStepRate(char const * serialNo, KIM_Channels channel)" />
	/// <seealso cref="KIM_SetMaxPotStepRate(char const * serialNo, KIM_Channels channel, __int32 maxPotStepRate)" />
	KCUBEINERTIALMOTOR_API __int32 __cdecl KIM_GetMaxPotStepRate(char const * serialNo, KIM_Channels channel);

	/// <summary> Gets the LED brightness. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> Intensity from 0 (off) to 255. </returns>
	/// <seealso cref="KIM_SetLEDBrightness(char const * serialNo, short brightness)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_GetLEDBrightness(char const * serialNo);

	/// <summary> Sets the LED brightness. </summary>
	/// <param name="serialNo">	The device serial no. </param>
	/// <param name="brightness"> Intensity from 0 (off) to 255. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	/// <seealso cref="KIM_GetLEDBrightness(char const * serialNo)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_SetLEDBrightness(char const * serialNo, short brightness);

	/// <summary> Requests the state quantities (actual temperature, current and status bits). </summary>
	/// <remarks> This needs to be called to get the device to send it's current status.<br />
	/// 		  NOTE this is called automatically if Polling is enabled for the device using <see cref="KIM_StartPolling(char const * serialNo, int milliseconds)" />. </remarks>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successfully requested. </returns>
	/// <seealso cref="KIM_RequestReadings(char const * serialNo)" />
	/// <seealso cref="KIM_RequestStatusBits(char const * serialNo)" />
	/// <seealso cref="KIM_GetCurrentReading(char const * serialNo)" />
	/// <seealso cref="KIM_GetTemperatureReading(char const * serialNo)" />
	/// <seealso cref="KIM_GetStatusBits(char const * serialNo)" />
	/// <seealso cref="KIM_StartPolling(char const * serialNo, int milliseconds)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestStatus(char const * serialNo);

	/// <summary> Request the status bits which identify the current device state. </summary>
	/// <remarks> This needs to be called to get the device to send it's current status bits.<br />
	/// 		  NOTE this is called automatically if Polling is enabled for the device using <see cref="KIM_StartPolling(char const * serialNo, int milliseconds)" />. </remarks>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successfully requested. </returns>
	/// <seealso cref="KIM_GetStatusBits(char const * serialNo)" />
	/// <seealso cref="KIM_RequestStatus(char const * serialNo)" />
	/// <seealso cref="KIM_RequestReadings(char const * serialNo)" />
	/// <seealso cref="KIM_StartPolling(char const * serialNo, int milliseconds)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestStatusBits(char const * serialNo);

	/// <summary> Requests the current position. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">	The channel. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successful. </returns>
	/// <seealso cref="KIM_GetCurrentPosition(char const * serialNo, KIM_Channels channel)" />
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestCurrentPosition(char const * serialNo, KIM_Channels channel);

	/// <summary> Gets current position. </summary>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="channel">  The channel. </param>
	/// <returns> The position. </returns>
	/// <seealso cref="KIM_RequestCurrentPosition(char const * serialNo, KIM_Channels channel)" />
	KCUBEINERTIALMOTOR_API __int32 __cdecl KIM_GetCurrentPosition(char const * serialNo, KIM_Channels channel);

	/// <summary> Tc get status bits. </summary>
	/// <param name="serialNo"> The serial no. </param>
	/// <param name="channel">  The channel. </param>
	/// <returns> . </returns>
	KCUBEINERTIALMOTOR_API DWORD __cdecl KIM_GetStatusBits(char const * serialNo, KIM_Channels channel);

	/// <summary> Starts the internal polling loop which continuously requests position and status. </summary>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="milliseconds">The milliseconds polling rate. </param>
	/// <returns> <c>true</c> if successful, false if not. </returns>
	/// <seealso cref="KIM_StopPolling(char const * serialNo)" />
	/// <seealso cref="KIM_PollingDuration(char const * serialNo)" />
	/// <seealso cref="KIM_RequestStatusBits(char const * serialNo)" />
	/// <seealso cref="KIM_RequestPosition(char const * serialNo)" />
	/// \include CodeSnippet_connection1.cpp
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_StartPolling(char const * serialNo, int milliseconds);

	/// <summary> Gets the polling loop duration. </summary>
	/// <param name="serialNo"> The device serial no. </param>
	/// <returns> The time between polls in milliseconds or 0 if polling is not active. </returns>
	/// <seealso cref="KIM_StartPolling(char const * serialNo, int milliseconds)" />
	/// <seealso cref="KIM_StopPolling(char const * serialNo)" />
	/// \include CodeSnippet_connection1.cpp
	KCUBEINERTIALMOTOR_API long __cdecl KIM_PollingDuration(char const * serialNo);

	/// <summary> Stops the internal polling loop. </summary>
	/// <param name="serialNo"> The device serial no. </param>
	/// <seealso cref="KIM_StartPolling(char const * serialNo, int milliseconds)" />
	/// <seealso cref="KIM_PollingDuration(char const * serialNo)" />
	/// \include CodeSnippet_connection1.cpp
	KCUBEINERTIALMOTOR_API void __cdecl KIM_StopPolling(char const * serialNo);

	/// <summary> Gets the time in milliseconds since tha last message was received from the device. </summary>
	/// <remarks> This can be used to determine whether communications with the device is still good</remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="lastUpdateTimeMS"> The time since the last message was received in milliseconds. </param>
	/// <returns> True if monitoring is enabled otherwize False. </returns>
	/// <seealso cref="KIM_EnableLastMsgTimer(char const * serialNo, bool enable, __int32 lastMsgTimeout )" />
	/// <seealso cref="KIM_HasLastMsgTimerOverrun(char const * serialNo)" />
	/// \include CodeSnippet_connectionMonitoring.cpp
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_TimeSinceLastMsgReceived(char const * serialNo, __int64 &lastUpdateTimeMS );

	/// <summary> Enables the last message monitoring timer. </summary>
	/// <remarks> This can be used to determine whether communications with the device is still good</remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <param name="enable"> True to enable monitoring otherwise False to disable. </param>
	/// <param name="lastMsgTimeout"> The last message error timeout in ms. 0 to disable. </param>
	/// <seealso cref="KIM_TimeSinceLastMsgReceived(char const * serialNo, __int64 &lastUpdateTimeMS )" />
	/// <seealso cref="KIM_HasLastMsgTimerOverrun(char const * serialNo)" />
	/// \include CodeSnippet_connectionMonitoring.cpp
	KCUBEINERTIALMOTOR_API void __cdecl KIM_EnableLastMsgTimer(char const * serialNo, bool enable, __int32 lastMsgTimeout );

	/// <summary> Queries if the time since the last message has exceeded the lastMsgTimeout set by <see cref="KIM_EnableLastMsgTimer(char const * serialNo, bool enable, __int32 lastMsgTimeout )"/>. </summary>
	/// <remarks> This can be used to determine whether communications with the device is still good</remarks>
	/// <param name="serialNo"> The device serial no. </param>
	/// <returns> True if last message timer has elapsed, False if monitoring is not enabled or if time of last message received is less than lastMsgTimeout. </returns>
	/// <seealso cref="KIM_TimeSinceLastMsgReceived(char const * serialNo, __int64 &lastUpdateTimeMS )" />
	/// <seealso cref="KIM_EnableLastMsgTimer(char const * serialNo, bool enable, __int32 lastMsgTimeout )" />
	/// \include CodeSnippet_connectionMonitoring.cpp
	KCUBEINERTIALMOTOR_API bool __cdecl KIM_HasLastMsgTimerOverrun(char const * serialNo);

	/// <summary> Requests that all settings are download from device. </summary>
	/// <remarks> This function requests that the device upload all it's settings to the DLL.</remarks>
	/// <param name="serialNo">	The device serial no. </param>
	/// <returns> The error code (see \ref C_DLL_ERRORCODES_page "Error Codes") or zero if successfully requested. </returns>
	KCUBEINERTIALMOTOR_API short __cdecl KIM_RequestSettings(char const * serialNo);
}
/** @} */ // KCubeInertialMotor
