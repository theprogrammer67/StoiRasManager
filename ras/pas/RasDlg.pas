{******************************************************************}
{                                                                  }
{ Borland Delphi Runtime Library                                   }
{ RAS functions interface unit                                     }
{                                                                  }
{ Portions created by Microsoft are                                }
{ Copyright (C) 1995-1999 Microsoft Corporation.                   }
{ All Rights Reserved.                                             }
{                                                                  }
{ The original file is: rasdlg.h, released 24 Apr 1998.            }
{ The original Pascal code is: RasDlg.pas, released 31 Dec 1999.   }
{ The initial developer of the Pascal code is Petr Vones           }
{ (petr.v@mujmail.cz).                                             }
{                                                                  }
{ Portions created by Petr Vones are                               }
{ Copyright (C) 1999 Petr Vones                                    }
{                                                                  }
{ Obtained through:                                                }
{                                                                  }
{ Joint Endeavour of Delphi Innovators (Project JEDI)              }
{                                                                  }
{ You may retrieve the latest version of this file at the Project  }
{ JEDI home page, located at http://delphi-jedi.org                }
{                                                                  }
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{******************************************************************}

unit RasDlg;

{$I RAS.INC}

{$ALIGN ON}
{$MINENUMSIZE 4}
{$WEAKPACKAGEUNIT}

interface

uses
  Windows, Ras, LmCons;

(*$HPPEMIT '#include <pshpack4.h>'*)
(*$HPPEMIT '#include <ras.h>'*)
(*$HPPEMIT '#include <rasdlg.h>'*)

type
  TRasPbdDlgFuncA = procedure (dwCallbackId: DWORD; dwEvent: DWORD;
    pszText: PAnsiChar; pData: Pointer); stdcall;
  {$EXTERNALSYM TRasPbdDlgFuncA}
  TRasPbdDlgFuncW = procedure (dwCallbackId: DWORD; dwEvent: DWORD;
    pszText: PWideChar; pData: Pointer); stdcall;
  {$EXTERNALSYM TRasPbdDlgFuncW}
  TRasPbdDlgFunc = TRasPbdDlgFuncA;

const
  RASPBDEVENT_AddEntry    = 1;
  {$EXTERNALSYM RASPBDEVENT_AddEntry}
  RASPBDEVENT_EditEntry   = 2;
  {$EXTERNALSYM RASPBDEVENT_EditEntry}
  RASPBDEVENT_RemoveEntry = 3;
  {$EXTERNALSYM RASPBDEVENT_RemoveEntry}
  RASPBDEVENT_DialEntry   = 4;
  {$EXTERNALSYM RASPBDEVENT_DialEntry}
  RASPBDEVENT_EditGlobals = 5;
  {$EXTERNALSYM RASPBDEVENT_EditGlobals}
  RASPBDEVENT_NoUser      = 6;
  {$EXTERNALSYM RASPBDEVENT_NoUser}
  RASPBDEVENT_NoUserEdit  = 7;
  {$EXTERNALSYM RASPBDEVENT_NoUserEdit}

  RASNOUSER_SmartCard     = $00000001;
  {$EXTERNALSYM RASNOUSER_SmartCard}
  
// Defines the information passed in the 4th argument of RASPBDLGFUNC on
// "NoUser" and "NoUserEdit" events.  Usage shown is for "NoUser".  For
// "NoUserEdit", the timeout is ignored and the three strings are INs.

type
  PRasNoUserA = ^TRasNoUserA;
  PRasNoUserW = ^TRasNoUserW;
  PRasNoUser = PRasNoUserA;
  tagRASNOUSERA = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwTimeoutMs: DWORD;
    szUserName: packed array[0..UNLEN] of AnsiChar;
    szPassword: packed array[0..PWLEN] of AnsiChar;
    szDomain: packed array[0..DNLEN] of AnsiChar;
  end;
  {$EXTERNALSYM tagRASNOUSERA}
  tagRASNOUSERW = record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwTimeoutMs: DWORD;
    szUserName: packed array[0..UNLEN] of WideChar;
    szPassword: packed array[0..PWLEN] of WideChar;
    szDomain: packed array[0..DNLEN] of WideChar;
  end;
  {$EXTERNALSYM tagRASNOUSERW}
  tagRASNOUSER = tagRASNOUSERA;
  TRasNoUserA = tagRASNOUSERA;
  TRasNoUserW = tagRASNOUSERW;
  TRasNoUser = TRasNoUserA;
  RASNOUSERA = tagRASNOUSERA;
  {$EXTERNALSYM RASNOUSERA}
  RASNOUSERW = tagRASNOUSERW;
  {$EXTERNALSYM RASNOUSERW}
  RASNOUSER = RASNOUSERA;
  
// RasPhonebookDlg API parameters.

const
  RASPBDFLAG_PositionDlg      = $00000001;
  {$EXTERNALSYM RASPBDFLAG_PositionDlg}
  RASPBDFLAG_ForceCloseOnDial = $00000002;
  {$EXTERNALSYM RASPBDFLAG_ForceCloseOnDial}
  RASPBDFLAG_NoUser           = $00000010;
  {$EXTERNALSYM RASPBDFLAG_NoUser}
  RASPBDFLAG_UpdateDefaults   = $80000000;
  {$EXTERNALSYM RASPBDFLAG_UpdateDefaults}

type
  PRasPbdDlgA = ^TRasPbdDlgA;
  PRasPbdDlgW = ^TRasPbdDlgW;
  PRasPbdDlg = PRasPbdDlgA;
  tagRASPBDLGA = record
    dwSize: DWORD;
    hwndOwner: HWND;
    dwFlags: DWORD;
    xDlg: LongInt;
    yDlg: LongInt;
    dwCallbackId: DWORD;
    pCallback: TRasPbdDlgFuncA;
    dwError: DWORD;
    reserved: DWORD;
    reserved2: DWORD;
  end;
  {$EXTERNALSYM tagRASPBDLGA}
  tagRASPBDLGW = record
    dwSize: DWORD;
    hwndOwner: HWND;
    dwFlags: DWORD;
    xDlg: LongInt;
    yDlg: LongInt;
    dwCallbackId: DWORD;
    pCallback: TRasPbdDlgFuncW;
    dwError: DWORD;
    reserved: DWORD;
    reserved2: DWORD;
  end;
  {$EXTERNALSYM tagRASPBDLGW}
  tagRASPBDLG = tagRASPBDLGA;
  TRasPbdDlgA = tagRASPBDLGA;
  TRasPbdDlgW = tagRASPBDLGW;
  TRasPbdDlg = TRasPbdDlgA;
  RASPBDLGA = tagRASPBDLGA;
  {$EXTERNALSYM RASPBDLGA}
  RASPBDLGW = tagRASPBDLGW;
  {$EXTERNALSYM RASPBDLGW}
  RASPBDLG = RASPBDLGA;

// RasEntryDlg API parameters.

const
  RASEDFLAG_PositionDlg = $00000001;
  {$EXTERNALSYM RASEDFLAG_PositionDlg}
  RASEDFLAG_NewEntry    = $00000002;
  {$EXTERNALSYM RASEDFLAG_NewEntry}
  RASEDFLAG_CloneEntry  = $00000004;
  {$EXTERNALSYM RASEDFLAG_CloneEntry}
  RASEDFLAG_NoRename    = $00000008;
  {$EXTERNALSYM RASEDFLAG_NoRename}
  RASEDFLAG_ShellOwned  = $40000000;
  {$EXTERNALSYM RASEDFLAG_ShellOwned}

type
  PRasEntryDlgA = ^TRasEntryDlgA;
  PRasEntryDlgW = ^TRasEntryDlgW;
  PRasEntryDlg = PRasEntryDlgA;
  tagRASENTRYDLGA = record
    dwSize: DWORD;
    hwndOwner: HWND;
    dwFlags: DWORD;
    xDlg: LongInt;
    yDlg: LongInt;
    szEntry: packed array[0..RAS_MaxEntryName] of AnsiChar;
    dwError: DWORD;
    reserved: DWORD;
    reserved2: DWORD;
  end;
  {$EXTERNALSYM tagRASENTRYDLGA}
  tagRASENTRYDLGW = record
    dwSize: DWORD;
    hwndOwner: HWND;
    dwFlags: DWORD;
    xDlg: LongInt;
    yDlg: LongInt;
    szEntry: packed array[0..RAS_MaxEntryName] of WideChar;
    dwError: DWORD;
    reserved: DWORD;
    reserved2: DWORD;
  end;
  {$EXTERNALSYM tagRASENTRYDLGW}
  tagRASENTRYDLG = tagRASENTRYDLGA;
  TRasEntryDlgA = tagRASENTRYDLGA;
  TRasEntryDlgW = tagRASENTRYDLGW;
  TRasEntryDlg = TRasEntryDlgW;
  RASENTRYDLG_A = tagRASENTRYDLGA;
  {$EXTERNALSYM RASENTRYDLGA}
  RASENTRYDLG_W = tagRASENTRYDLGW;
  {$EXTERNALSYM RASENTRYDLGW}
  RASENTRYDLG_ = RASENTRYDLG_A;

// RasDialDlg API parameters.

const
  RASDDFLAG_PositionDlg = $00000001;
  {$EXTERNALSYM RASDDFLAG_PositionDlg}
  RASDDFLAG_NoPrompt    = $00000002;
  {$EXTERNALSYM RASDDFLAG_NoPrompt}
  RASDDFLAG_LinkFailure = $80000000;
  {$EXTERNALSYM RASDDFLAG_LinkFailure}

type
  PRasDialDlg = ^TRasDialDlg;
  tagRASDIALDLG = record
    dwSize: DWORD;
    hwndOwner: HWND;
    dwFlags: DWORD;
    xDlg: LongInt;
    yDlg: LongInt;
    dwSubEntry: DWORD;
    dwError: DWORD;
    reserved: DWORD;
    reserved2: DWORD;
  end;
  {$EXTERNALSYM tagRASDIALDLG}
  TRasDialDlg = tagRASDIALDLG;
  RASDIALDLG_ = tagRASDIALDLG;
  {$EXTERNALSYM RASDIALDLG}

// RasMonitorDlg API parameters.

const
  RASMDPAGE_Status            = 0;
  {$EXTERNALSYM RASMDPAGE_Status}
  RASMDPAGE_Summary           = 1;
  {$EXTERNALSYM RASMDPAGE_Summary}
  RASMDPAGE_Preferences       = 2;
  {$EXTERNALSYM RASMDPAGE_Preferences}

  RASMDFLAG_PositionDlg       = $00000001;
  {$EXTERNALSYM RASMDFLAG_PositionDlg}
  RASMDFLAG_UpdateDefaults    = $80000000;
  {$EXTERNALSYM RASMDFLAG_UpdateDefaults}

type
  PRasMonitorDlg = ^TRasMonitorDlg;
  tagRASMONITORDLG = record
    dwSize: DWORD;
    hwndOwner: HWND;
    dwFlags: DWORD;
    dwStartPage: DWORD;
    xDlg: LongInt;
    yDlg: LongInt;
    dwError: DWORD;
    reserved: DWORD;
    reserved2: DWORD;
  end;
  {$EXTERNALSYM tagRASMONITORDLG}
  TRasMonitorDlg = tagRASMONITORDLG;
  RASMONITORDLG_ = tagRASMONITORDLG;
  {$EXTERNALSYM RASMONITORDLG}

{$IFDEF WINVER_0x500_OR_GREATER}
type
  RasCustomDialDlgFnA = function(hInstDll: THandle; dwFlags: DWORD;
    lpszPhonebook, lpszEntry, lpszPhoneNumber: PAnsiChar; lpInfo: PRasDialDlg;
    pvInfo: Pointer): BOOL; stdcall;
  RasCustomDialDlgFnW = function(hInstDll: THandle; dwFlags: DWORD;
    lpszPhonebook, lpszEntry, lpszPhoneNumber: PWideChar; lpInfo: PRasDialDlg;
    pvInfo: Pointer): BOOL; stdcall;
  RasCustomDialDlgFn = RasCustomDialDlgFnA;
  RasCustomEntryDlgFnA = function(InstDll: THandle; lpszPhonebook,
    lpszEntry: PAnsiChar; lpInfo: PRasDialDlg; dwFlags: DWORD): BOOL; stdcall;
  RasCustomEntryDlgFnW = function(InstDll: THandle; lpszPhonebook,
    lpszEntry: PWideChar; lpInfo: PRasDialDlg; dwFlags: DWORD): BOOL; stdcall;
  RasCustomEntryDlgFn = RasCustomEntryDlgFnA;
{$ENDIF}

// RAS common dialog API prototypes.

function RasPhonebookDlgA(lpszPhonebook: PAnsiChar; lpszEntry: PAnsiChar;
  var lpInfo: TRasPbdDlgA): BOOL; stdcall;
{$EXTERNALSYM RasPhonebookDlgA}
function RasPhonebookDlgW(lpszPhonebook: PWideChar; lpszEntry: PWideChar;
  var lpInfo: TRasPbdDlgW): BOOL; stdcall;
{$EXTERNALSYM RasPhonebookDlgW}
function RasPhonebookDlg(lpszPhonebook: PChar; lpszEntry: PChar;
  var lpInfo: TRasPbdDlg): BOOL; stdcall;
{$EXTERNALSYM RasPhonebookDlg}

function RasEntryDlgA(lpszPhonebook: PAnsiChar; lpszEntry: PAnsiChar;
  var lpInfo : TRasEntryDlgA): BOOL; stdcall;
{$EXTERNALSYM RasEntryDlgA}
function RasEntryDlgW(lpszPhonebook: PWideChar; lpszEntry: PWideChar;
  var lpInfo : TRasEntryDlgW): BOOL; stdcall;
{$EXTERNALSYM RasEntryDlgW}
function RasEntryDlg(lpszPhonebook: PChar; lpszEntry: PChar;
  var lpInfo : TRasEntryDlg): BOOL; stdcall;
{$EXTERNALSYM RasEntryDlg}

function RasDialDlgA(lpszPhonebook: PAnsiChar; lpszEntry: PAnsiChar;
  lpszPhoneNumbe: PAnsiChar; var lpInfo: TRasDialDlg): BOOL; stdcall;
{$EXTERNALSYM RasDialDlgA}
function RasDialDlgW(lpszPhonebook: PWideChar; lpszEntry: PWideChar;
  lpszPhoneNumbe: PWideChar; var lpInfo: TRasDialDlg): BOOL; stdcall;
{$EXTERNALSYM RasDialDlgW}
function RasDialDlg(lpszPhonebook: PChar; lpszEntry: PChar;
  lpszPhoneNumbe: PChar; var lpInfo: TRasDialDlg): BOOL; stdcall;
{$EXTERNALSYM RasDialDlg}

function RasMonitorDlgA(lpszDeviceName: PAnsiChar; var lpInfo: TRasMonitorDlg): BOOL; stdcall;
{$EXTERNALSYM RasMonitorDlgA}
function RasMonitorDlgW(lpszDeviceName: PWideChar; var lpInfo: TRasMonitorDlg): BOOL; stdcall;
{$EXTERNALSYM RasMonitorDlgW}
function RasMonitorDlg(lpszDeviceName: PChar; var lpInfo: TRasMonitorDlg): BOOL; stdcall;
{$EXTERNALSYM RasMonitorDlg}

implementation

const
  rasdlglib = 'rasdlg.dll';

function RasPhonebookDlgA; external rasdlglib name 'RasPhonebookDlgA';
function RasEntryDlgA; external rasdlglib name 'RasEntryDlgA';
function RasDialDlgA; external rasdlglib name 'RasDialDlgA';
function RasMonitorDlgA; external rasdlglib name 'RasMonitorDlgA';
function RasPhonebookDlgW; external rasdlglib name 'RasPhonebookDlgW';
function RasEntryDlgW; external rasdlglib name 'RasEntryDlgW';
function RasDialDlgW; external rasdlglib name 'RasDialDlgW';
function RasMonitorDlgW; external rasdlglib name 'RasMonitorDlgW';
function RasPhonebookDlg; external rasdlglib name 'RasPhonebookDlgW';
function RasEntryDlg; external rasdlglib name 'RasEntryDlgW';
function RasDialDlg; external rasdlglib name 'RasDialDlgW';
function RasMonitorDlg; external rasdlglib name 'RasMonitorDlgW';

end.

