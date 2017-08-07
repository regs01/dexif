unit tstreadexif;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, dEXIF;

const
  // Picture with EXIF data taken from SAMSUNG camera
  co_TestPic01 = './testpictures/original/with_exif_large.jpeg';
  co_DUTPicName01 = './testpictures/DUTPic01.jpeg';

  // Picture with EXIF data taken from CANON camera
  co_TestPic02 = './testpictures/original/img_9438.jpg';
  co_DUTPicName02 = './testpictures/DUTPic03.jpeg';

type
  { TTsTBasic_dEXIF }

  TTstReadFile_dEXIF= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure StdIntTest(const AFileName, ATestTag: String;
      const AExpectedResult:Integer; const AMismatchMsg: String);
    procedure StdStringTest(const AFileName, ATestTag: String;
      const AExpectedResult, AMismatchMsg: String);

    procedure Test_ByteOrder(const AFilename: String; AExpected: Boolean);
    procedure Test_DateTime(const AFileName: String; AKind: Integer;
      AExpectedDateTime: TDateTime; const AMismatchMsg: string);
    procedure Test_ExposureTime(const AFilename: String; const AExpected: String);
    procedure Test_FNumber(const AFilename: String; AExpected: Double);
    procedure Test_FocalLength(const AFilename: String; AExpected: Double);
    procedure Test_ImageSize(const AFileName: String;
      AExpectedWidth, AExpectedHeight: Integer);
    procedure Test_Resolution(const AFileName: String;
      AExpectedXResolution, AExpectedYResolution: Integer; AExpectedUnits: String);
  end;

  { Tests for image DUTPic01, taken by SAMSUNG camera }
  TTstReadFile_dEXIF_01 = class(TTstReadFile_dEXIF)
  published
    procedure TstReadFile_ByteOrder;
    procedure TstReadFile_CameraMake;
    procedure TstReadFile_CameraModel;
    procedure TstReadFile_DateTime;
    procedure TstReadFile_ExposureTime;
    procedure TstReadFile_Flash;
    procedure TstReadFile_FNumber;
    procedure TstReadFile_FocalLength;
    procedure TstReadFile_ImageSize;
    procedure TstReadFile_ISO;
    procedure TstReadFile_Resolution;
  end;

  { Tests for image DUTPic02, taken by CANON camera }
  TTstReadFile_dEXIF_02 = class(TTstReadFile_dEXIF)
  published
    procedure TstReadFile_ByteOrder;
    procedure TstReadFile_CameraMake;
    procedure TstReadFile_CameraModel;
    procedure TstReadFile_DateTime;
    procedure TstReadFile_ExposureTime;
    procedure TstReadFile_Flash;
    procedure TstReadFile_FNumber;
    procedure TstReadFile_FocalLength;
    procedure TstReadFile_ImageSize;
    procedure TstReadFile_ISO;
    procedure TstReadFile_Resolution;
  end;


implementation

uses
  FileUtil, DateUtils, StrUtils, Math;

{ Output of ExifTool for DUTPic01.jpeg:

    ExifTool Version Number         : 10.60
    File Name                       : DUTPic01.jpeg
    Directory                       : .
    File Size                       : 2.9 MB
    File Modification Date/Time     : 2017:08:05 11:16:56+02:00
    File Access Date/Time           : 2017:08:05 11:16:56+02:00
    File Creation Date/Time         : 2017:08:05 11:16:56+02:00
    File Permissions                : rw-rw-rw-
    File Type                       : JPEG
    File Type Extension             : jpg
    MIME Type                       : image/jpeg
    JFIF Version                    : 1.01

    Resolution Unit                 : inches
+   X Resolution                    : 300
+   Y Resolution                    : 300
+   Exif Byte Order                 : Big-endian (Motorola, MM)
+   Make                            : SAMSUNG
+   Camera Model Name               : SM-G850F
+   Exposure Time                   : 1/3376
+   F Number                        : 2.2
+   ISO                             : 40, 0                                     Tag "ISOSpeedRatings"
+   Date/Time Original              : 2017:03:15 10:35:11
+   Focal Length                    : 4.1 mm                                    Tag "FocalLength"
+   Image Width                     : 4608
+   Image Height                    : 2592
    Encoding Process                : Baseline DCT, Huffman coding
    Bits Per Sample                 : 8
    Color Components                : 3
    Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
+   Aperture                        : 2.2                                       Tag "FNumber"
    Image Size                      : 4608x2592
    Megapixels                      : 11.9
+   Shutter Speed                   : 1/3376                                    Tag "ExposureTime"
+   Focal Length                    : 4.1 mm                                    Tag "FocalLength"
    Light Value                     : 15.3

--------------------------------------------------------------------------------

Output of EXIFTool for DUTPic03.jpeg

    ExifTool Version Number         : 10.60
    File Name                       : DUTPic03.jpeg
    Directory                       : .
    File Size                       : 1478 kB
    File Modification Date/Time     : 2017:02:15 18:53:32+01:00
    File Access Date/Time           : 2017:08:07 09:51:19+02:00
    File Creation Date/Time         : 2017:08:07 09:51:19+02:00
    File Permissions                : rw-rw-rw-
    File Type                       : JPEG
    File Type Extension             : jpg
    MIME Type                       : image/jpeg
    Exif Byte Order                 : Little-endian (Intel, II)
    Make                            : Canon
    Camera Model Name               : Canon PowerShot S5 IS
    Orientation                     : Horizontal (normal)
    X Resolution                    : 180
    Y Resolution                    : 180
    Resolution Unit                 : inches
    Modify Date                     : 2017:02:11 15:09:39
    Y Cb Cr Positioning             : Centered
    Exposure Time                   : 1/1600
    F Number                        : 2.7
    ISO                             : 160
    Exif Version                    : 0220
    Date/Time Original              : 2017:02:11 15:09:39
    Create Date                     : 2017:02:11 15:09:39
    Components Configuration        : Y, Cb, Cr, -
    Compressed Bits Per Pixel       : 3
    Shutter Speed Value             : 1/1614
    Aperture Value                  : 2.7
    Max Aperture Value              : 2.7
    Flash                           : Off, Did not fire
    Focal Length                    : 6.0 mm
    Macro Mode                      : Normal
    Self Timer                      : Off
    Quality                         : Fine
    Canon Flash Mode                : Off
    Continuous Drive                : Single
    Focus Mode                      : Single
    Record Mode                     : JPEG
    Canon Image Size                : Widescreen
    Easy Mode                       : Full auto
    Digital Zoom                    : None
    Contrast                        : Normal
    Saturation                      : Normal
    Sharpness                       : 0
    Camera ISO                      : Auto High
    Metering Mode                   : Evaluative
    Focus Range                     : Auto
    AF Point                        : Manual AF point selection
    Canon Exposure Mode             : Easy
    Lens Type                       : n/a
    Max Focal Length                : 72 mm
    Min Focal Length                : 6 mm
    Focal Units                     : 100/mm
    Max Aperture                    : 2.7
    Min Aperture                    : 8
    Flash Activity                  : 0
    Flash Bits                      : (none)
    Focus Continuous                : Continuous
    AE Setting                      : Normal AE
    Image Stabilization             : On
    Display Aperture                : 2.7
    Zoom Source Width               : 3264
    Zoom Target Width               : 3264
    Spot Metering Mode              : Center
    Manual Flash Output             : n/a
    Focal Type                      : Zoom
    Focal Plane X Size              : 5.84 mm
    Focal Plane Y Size              : 4.39 mm
    Auto ISO                        : 161
    Base ISO                        : 100
    Measured EV                     : 13.38
    Target Aperture                 : 2.7
    Target Exposure Time            : 1/1614
    Exposure Compensation           : 0
    White Balance                   : Auto
    Slow Shutter                    : Off
    Shot Number In Continuous Burst : 0
    Optical Zoom Code               : 6
    Flash Guide Number              : 0
    Flash Exposure Compensation     : 0
    Auto Exposure Bracketing        : Off
    AEB Bracket Value               : 0
    Control Mode                    : Camera Local Control
    Focus Distance Upper            : 65.53 m
    Focus Distance Lower            : 0 m
    Bulb Duration                   : 0
    Camera Type                     : Compact
    Auto Rotate                     : None
    ND Filter                       : Off
    Self Timer 2                    : 0
    Flash Output                    : 0
    Canon Image Type                : IMG:PowerShot S5 IS JPEG
    Canon Firmware Version          : Firmware Version 1.01
    File Number                     : 100-9438
    Owner Name                      :
    Rotation                        : 0
    Camera Temperature              : 16 C
    Canon Model ID                  : PowerShot S5 IS
    AF Area Mode                    : Single-point AF
    Num AF Points                   : 9
    Valid AF Points                 : 1
    Canon Image Width               : 3264
    Canon Image Height              : 1832
    AF Image Width                  : 1088
    AF Image Height                 : 245
    AF Area Widths                  : 196 0 0 0 0 0 0 0 0
    AF Area Heights                 : 44 0 0 0 0 0 0 0 0
    AF Area X Positions             : 0 0 0 0 0 0 0 0 0
    AF Area Y Positions             : 0 0 0 0 0 0 0 0 0
    AF Points In Focus              : 0
    Primary AF Point                : 0
    Thumbnail Image Valid Area      : 0 159 15 104
    Super Macro                     : Off
    Date Stamp Mode                 : Off
    My Color Mode                   : Off
    Firmware Revision               : 1.01 rev 2.00
    Categories                      : (none)
    Face Detect Frame Size          : 0 0
    Face Width                      : 35
    Faces Detected                  : 0
    Image Unique ID                 : 80304b30b8ff9067a4c6cab0bda0c784
    User Comment                    :
    Flashpix Version                : 0100
    Color Space                     : sRGB
    Exif Image Width                : 3264
    Exif Image Height               : 1832
    Interoperability Index          : R98 - DCF basic file (sRGB)
    Interoperability Version        : 0100
    Related Image Width             : 3264
    Related Image Height            : 1832
    Focal Plane X Resolution        : 14506.66667
    Focal Plane Y Resolution        : 10840.23669
    Focal Plane Resolution Unit     : inches
    Sensing Method                  : One-chip color area
    File Source                     : Digital Camera
    Custom Rendered                 : Normal
    Exposure Mode                   : Auto
    Digital Zoom Ratio              : 1
    Scene Capture Type              : Standard
    Compression                     : JPEG (old-style)
    Thumbnail Offset                : 5120
    Thumbnail Length                : 4734
    Image Width                     : 3264
    Image Height                    : 1832
    Encoding Process                : Baseline DCT, Huffman coding
    Bits Per Sample                 : 8
    Color Components                : 3
    Y Cb Cr Sub Sampling            : YCbCr4:2:2 (2 1)
    Aperture                        : 2.7
    Drive Mode                      : Single-frame Shooting
    Image Size                      : 3264x1832
    Lens                            : 6.0 - 72.0 mm
    Lens ID                         : Unknown 6-72mm
    Megapixels                      : 6.0
    Scale Factor To 35 mm Equivalent: 6.1
    Shooting Mode                   : Full auto
    Shutter Speed                   : 1/1600
    Thumbnail Image                 : (Binary data 4734 bytes, use -b option to extract)
    Circle Of Confusion             : 0.005 mm
    Depth Of Field                  : inf (2.48 m - inf)
    Field Of View                   : 52.7 deg
    Focal Length                    : 6.0 mm (35 mm equivalent: 36.3 mm)
    Hyperfocal Distance             : 2.69 m
    Lens                            : 6.0 - 72.0 mm (35 mm equivalent: 36.3 - 435.8 mm)
    Light Value                     : 12.8

--------------------------------------------------------------------------------

+  <--- test is passed
-  <--- test fails, Tag not found by dExif
}

procedure TTstReadFile_dEXIF.SetUp;
begin
  if not FileExists(co_DUTPicName01) then
    if FileExists(co_TestPic01) then
      CopyFile(co_TestPic01, co_DUTPicName01);

  if not FileExists(co_DUTPicName02) then
    if FileExists(co_TestPic02) then
      CopyFile(co_TestPic02, co_DUTPicName02);
end;

procedure TTstReadFile_dEXIF.TearDown;
begin
  //if FileExists(co_DUTPicName01) then
  //  DeleteFile(co_DUTPicName01);
end;


{ Generic tests }

procedure TTstReadFile_dEXIF.StdIntTest(const AFileName, ATestTag: String;
  const AExpectedResult: Integer; const AMismatchMsg: String);
var
  DUT: TImgData;
  currIntValue: Integer;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currIntValue := DUT.ExifObj.GetRawInt(ATestTag); //LookupTagInt(ATestTag);
    CheckEquals(AExpectedResult, currIntValue, AMismatchMsg);
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF.StdStringTest(
  const AFileName, ATestTag, AExpectedResult, AMismatchMsg: String);
var
  DUT: TImgData;
  currStrValue: String;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal(ATestTag);

    // dEXIF strings sometimes are quoted...
    if (currStrValue <> '') and (currStrValue[1] = '"') then
      Delete(currStrValue, 1,1);
    if (currStrValue <> '') and (currStrValue[Length(currStrValue)] = '"') then
      Delete(currStrValue, Length(currStrValue), 1);

    CheckEquals(AExpectedResult, currStrValue, AMismatchMsg);
  finally
    DUT.Free;
  end;
end;


{ Byte order }

procedure TTstReadFile_dEXIF.Test_ByteOrder(const AFilename: String;
  AExpected: Boolean);
var
  DUT: TImgData;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    CheckEquals(AExpected, DUT.ExifObj.MotorolaOrder, 'ByteOrder mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_ByteOrder;
begin
  Test_ByteOrder(co_DUTPicName01, true);
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ByteOrder;
begin
  Test_ByteOrder(co_DUTPicName02, false);
end;


{ Camera Make }

procedure TTstReadFile_dEXIF_01.TstReadFile_CameraMake;
begin
  StdStringTest(co_DUTPicName01, 'Make', 'SAMSUNG', 'Camera Make mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_CameraMake;
begin
  StdStringTest(co_DUTPicName02, 'Make', 'Canon', 'Camera Make mismatch');
end;


{ Camera model }

procedure TTstReadFile_dEXIF_01.TstReadFile_CameraModel;
begin
  StdStringTest(co_DUTPicName01, 'Model', 'SM-G850F', 'Camera model mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_CameraModel;
begin
  StdStringTest(co_DUTPicName02, 'Model', 'Canon PowerShot S5 IS', 'Camera model mismatch');
end;


{ Generic Date/time test }

procedure TTstReadFile_dEXIF.Test_DateTime(const AFileName: String; AKind: Integer;
  AExpectedDateTime: TDateTime; const AMismatchMsg: String);
var
  DUT: TImgData;
  currValue: TDateTime;
begin
  DUT := TImgData.Create();
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file:'+co_DUTPicName01);
    case AKind of
      0: currValue := DUT.EXIFObj.GetImgDateTime;  // any date/time
    end;
    CheckEquals(AExpectedDateTime, currValue, AMismatchMsg); //'Date/time mismatch (GetImgDateTime)');
//    currvalue := ScanDateTime('yyyy-mm-dd hh:nn:ss', DUT.ExifObj.DateTime);
//    CheckEquals(ExpectedDateTime, currValue, 'Date/time mismatch (ExifObj.DateTime)');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_DateTime;
begin
  Test_DateTime(co_DUTPicName01, 0, EncodeDateTime(2017,03,15, 10,35,11,0), 'Date/time mismatch');
    // 2017:03:15 10:35:11
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_DateTime;
begin
  Test_DateTime(co_DUTPicName02, 0, EncodeDateTime(2017,02,11, 15,09,39,0), 'Date/time mismatch');
    // 2017:02:11 15:09:39
end;


{ Exposure time }

procedure TTstReadFile_dEXIF.Test_ExposureTime(const AFilename: String;
  const AExpected: String);
var
  DUT: TImgData;
  currStrValue: String;
  p: Integer;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFilename);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal('ExposureTime');
    if currStrValue <> AExpected then begin
      p := pos('sec', currStrValue);
      if p <> 0 then Delete(currStrValue, p, MaxInt);
      p := pos('sec', AExpected);
      if p <> 0 then Delete(currStrValue, p, MaxInt);
    end;
    CheckEquals(trim(AExpected), trim(currStrValue), 'Exposure time mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_ExposureTime;
begin
  Test_ExposureTime(co_DUTPicName01, '1/3376');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ExposureTime;
begin
  Test_ExposureTime(co_DUTPicName02, '1/1600');
end;


{ Flash }

procedure TTstReadFile_dEXIF_01.TstReadFile_Flash;
begin
  StdIntTest(co_DUTPicName01, 'Flash', -1, 'Flash usage mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_Flash;
begin
  StdIntTest(co_DUTPicName02, 'Flash', 16, 'Flash usage mismatch');  // "Off, Did not fire"
  // see https://stackoverflow.com/questions/44579889/using-bitwise-to-enumerate-exif-flash-readable-string
  // "Off, did not fire" corresponds to Flash value = 16
end;


{ F Number }

procedure TTstReadFile_dEXIF.Test_FNumber(const AFilename: String;
  AExpected: Double);         // Use NaN if not specified in EXIF tool output
var
  DUT: TImgData;
  currStrValue: String;
  F: Double;
  res: Integer;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal('FNumber');
    while (currstrValue <> '') and (currStrValue[1] in ['F', 'f', ' ']) do
      Delete(currStrValue, 1, 1);
    currStrValue := StringReplace(trim(currStrValue), ',', '.', []);
    if IsNaN(AExpected) then begin
      CheckTrue(currStrValue <> '', 'FNumber found, but not expected.')
    end else begin
      val(currStrValue, F, res);
      if res = 0 then
        CheckEquals(FormatFloat('0.0', AExpected), FormatFloat('0.0', F), 'FNumber mismatch')
      else
        Fail('Cannot read FNumber');
    end;
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_FNumber;
begin
  Test_FNumber(co_DUTPicName01, 2.2);
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FNumber;
begin
  Test_FNumber(co_DUTPicName02, 2.7);
end;


{ Focal length }

procedure StripUnits(s: String; out AValue: Double; out AUnits: String);
var
  i: Integer;
  valStr: String;
  res: Integer;
begin
  valStr := '';
  AUnits := '';
  for i := 1 to Length(s) do begin
    if s[i] in ['0'..'9', '.'] then
      valStr := valstr + s[i]
    else if s[i] = ',' then
      valStr := valstr + '.'
    else if s[i] <> ' ' then
      AUnits := AUnits + s[i];
  end;

  val(valstr, AValue, res);
  if res <> 0 then
    AValue := -999;
end;

procedure TTstReadFile_dEXIF.Test_FocalLength(const AFilename: String;
  AExpected: Double);  // assuming focal length to be given in mm
var
  DUT: TImgData;
  currStrValue: String;
  curr_val: double;
  curr_units: String;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currStrValue := DUT.ExifObj.LookupTagVal('FocalLength');
    StripUnits(currStrValue, curr_val, curr_units);
    if (curr_units = '') or (curr_units = 'mm') then
      CheckEquals(FormatFloat('0.0', AExpected), FormatFloat('0.0', curr_val), 'Focal length mismatch')
    else
      Ignore('Focal length expected to be given in mm.');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_FocalLength;
begin
  Test_FocalLength(co_DUTPicName01, 4.1);
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_FocalLength;
begin
  Test_Focallength(co_DUTPicName02, 6.0);
end;


{ Image width and image height }

procedure TTstReadFile_dEXIF.Test_ImageSize(const AFileName: String;
  AExpectedWidth, AExpectedHeight: Integer);
var
  DUT: TImgData;
begin
  DUT := TImgData.Create;
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    CheckEquals(AExpectedWidth,  DUT.Width,  'Image width mismatch');
    CheckEquals(AExpectedHeight, DUT.Height, 'Image height mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_ImageSize;
begin
  Test_ImageSize(co_DUTPicName01, 4608, 2592);
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ImageSize;
begin
  Test_ImageSize(co_DUTPicName02, 3264, 1832);
end;


{ ISO }

procedure TTstReadFile_dEXIF_01.TstReadFile_ISO;
begin
  StdStringTest(co_DUTPicName01, 'ISOSpeedRatings', '40, 0', 'ISO mismatch');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_ISO;
begin
  StdStringTest(co_DUTPicName02, 'ISOSpeedRatings', '160', 'ISO mismatch');
end;


{ Resolution }

procedure TTstReadFile_dEXIF.Test_Resolution(const AFileName: String;
  AExpectedXResolution, AExpectedYResolution: Integer; AExpectedUnits: String);
var
  DUT: TImgData;
  currIntValue: Integer;
  currStrValue: String;
begin
  DUT := TImgData.Create();
  try
    DUT.ProcessFile(AFileName);
    CheckTRUE(DUT.HasEXIF, 'TImgData cannot detect EXIF in file "'+AFileName+'"');
    currIntValue := DUT.XResolution;
    CheckEquals(AExpectedXRESOLUTION, currIntValue, 'X resolution mismatch');
    currIntValue := DUT.YResolution;
    CheckEquals(AExpectedYRESOLUTION, currIntValue, 'Y resolution mismatch');
    currStrValue := DUT.ResolutionUnit;
    CheckEquals(lowercase(AExpectedUnits), lowercase(currStrValue), 'Resolution unit mismatch');
  finally
    DUT.Free;
  end;
end;

procedure TTstReadFile_dEXIF_01.TstReadFile_Resolution;
begin
  Test_Resolution(co_DUTPicName01, 300, 300, 'inches');
end;

procedure TTstReadFile_dEXIF_02.TstReadFile_Resolution;
begin
  Test_Resolution(co_DUTPicName02, 180, 180, 'inch');
end;




initialization
  RegisterTest(TTstReadFile_dEXIF_01);
  RegisterTest(TTstReadFile_dEXIF_02);

end.
