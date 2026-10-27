package libtiff

import "core:c"

when ODIN_OS == .Windows {
	foreign import libtiff {
		"lib/tiff.lib",
		"lib/zlibstatic.lib",
	}
} else {
	#panic(true)
}

/*
 * TIFF is defined as an incomplete type to hide the
 * library's internal data structures from clients.
 */
TIFF :: struct{}

ErrorHandler :: #type proc(a : cstring, b : cstring, args : c.va_list)

// thandle_t is some windows stuff idk..
// #ifdef _WIN32
// DECLARE_HANDLE(thandle_t); /* Win32 file handle */
// #else
// ErrorHandlerExt :: #type proc(thandle_t, a : cstring, b: cstring, args: c.va_list)
/*
 * this is the machine addressing size type, only it's signed, so make it
 * int32_t on 32bit machines, int64_t on 64bit machines
 */
tmsize_t :: i64

toff_t :: u64 /* file offset */
tdir_t :: u32 /* directory index */

/* the following are deprecated and should be replaced by their defining
   counterparts */
ttag_t    :: u32       /* directory tag */
tsample_t :: u16       /* sample number */
tstrile_t :: u32       /* strip or tile number */
tstrip_t  :: tstrile_t /* strip number */
ttile_t   :: tstrile_t /* tile number */
tsize_t   :: tmsize_t  /* i/o size in bytes */
tdata_t   :: rawptr    /* image data ref */

/*
 * Flags to pass to TIFFPrintDirectory to control
 * printing of data structures that are potentially
 * very large.   Bit-or these flags to enable printing
 * multiple items.
 */
TIFFPRINT_NONE :: 0x0           /* no extra info */
TIFFPRINT_STRIPS :: 0x1         /* strips/tiles info */
TIFFPRINT_CURVES :: 0x2         /* color/gray response curves */
TIFFPRINT_COLORMAP :: 0x4       /* colormap */
TIFFPRINT_JPEGQTABLES :: 0x100  /* JPEG Q matrices */
TIFFPRINT_JPEGACTABLES :: 0x200 /* JPEG AC tables */
TIFFPRINT_JPEGDCTABLES :: 0x200 /* JPEG DC tables */

/*
 * Colour conversion stuff
 */

/* reference white */
D65_X0 :: 95.0470
D65_Y0 :: 100.0
D65_Z0 :: 108.8827

D50_X0 :: 96.4250
D50_Y0 :: 100.0
D50_Z0 :: 82.4680

/*
 * Macros for extracting components from the
 * packed ABGR form returned by TIFFReadRGBAImage.
 */
// #define TIFFGetR(abgr) ((abgr) & 0xff)
// #define TIFFGetG(abgr) (((abgr) >> 8) & 0xff)
// #define TIFFGetB(abgr) (((abgr) >> 16) & 0xff)
// #define TIFFGetA(abgr) (((abgr) >> 24) & 0xff)

InitMethod :: #type proc(^TIFF, c.int)

Codec :: struct {
    name : cstring,
    scheme : u16,
    init : InitMethod,
}

Rational_t :: struct {
	uNum: u32,
	uDenom: u32,
}

OpenOptions :: struct{}

/*
 * RGBA-style image support.
 */
RGBAImage :: struct{}
RGBValue :: u8

/*
 * RGBA-reader state.
 */
// struct _TIFFRGBAImage {
//     TIFF *tif : ^TIFF,                /* image handle */
//     int stoponerr: c.int,            /* stop on read error */
//     int isContig: c.int,             /* data is packed/separate */
//     int alpha: c.int,                /* type of alpha data present */
//     uint32_t width: u32,           /* image width */
//     uint32_t height: u32,          /* image height */
//     uint16_t bitspersample: u16,   /* image bits/sample */
//     uint16_t samplesperpixel: u16, /* image samples/pixel */
//     uint16_t orientation: u16,     /* image orientation */
//     uint16_t req_orientation: u16, /* requested orientation */
//     uint16_t photometric: u16,     /* image photometric interp */
//     uint16_t *redcmap: ^u16,        /* colormap palette */
//     uint16_t *greencmap: ^u16,
//     uint16_t *bluecmap: ^u16,
//     /* get image data routine */
//     int (*get)(TIFFRGBAImage *, uint32_t *, uint32_t, uint32_t);
//     /* put decoded strip/tile */
//     union
//     {
//         void (*any)(TIFFRGBAImage *);
//         tileContigRoutine contig;
//         tileSeparateRoutine separate;
//     } put;
//     TIFFRGBValue *Map;       /* sample mapping array */
//     uint32_t **BWmap;        /* black&white map */
//     uint32_t **PALmap;       /* palette image map */
//     TIFFYCbCrToRGB *ycbcr;   /* YCbCr conversion state */
//     TIFFCIELabToRGB *cielab; /* CIE L*a*b conversion state */

//     uint8_t *UaToAa; /* Unassociated alpha to associated alpha conversion LUT */
//     uint8_t *Bitdepth16To8; /* LUT for conversion from 16bit to 8bit values */

//     row_offset: c.int,
//     col_offset: c.int,
// }

/*
 * The image reading and conversion routines invoke
 * ``put routines'' to copy/image/whatever tiles of
 * raw image data.  A default set of routines are
 * provided to convert/copy raw image data to 8-bit
 * packed ABGR format rasters.  Applications can supply
 * alternate routines that unpack the data into a
 * different format or, for example, unpack the data
 * and draw the unpacked raster on the display.
 */
tileContigRoutine   :: #type proc(^RGBAImage, ^u32, ^u32, ^u32, ^u32, ^u32, ^i32, ^i32, ^u8)
tileSeparateRoutine :: #type proc(^RGBAImage, ^u32, ^u32, ^u32, ^u32, ^u32, ^i32, ^i32, ^u8, ^u8, ^u8, ^u8)

Display :: struct {
    d_mat: [3][3]f32, /* XYZ -> luminance matrix */
    d_YCR: f32,       /* Light o/p for reference white */
    d_YCG: f32,
    d_YCB: f32,
    d_Vrwr: u32, /* Pixel values for ref. white */
    d_Vrwg: u32,
    d_Vrwb: u32,
    d_Y0R: f32, /* Residual light for black pixel */
    d_Y0G: f32,
    d_Y0B: f32,
    d_gammaR: f32, /* Gamma values for the three guns */
    d_gammaG: f32,
    d_gammaB: f32,
}
/* YCbCr->RGB support for TIFFYCbCrToRGBInit() and TIFFYCbCrToRGB()
 * Attention:
 * Functions TIFFYCbCrToRGBInit() and TIFFYCbCrToRGB() require a user provided
 * large memory buffer, where several tables can be setup.
 * The pointers to these tables are stored in the structure TIFFYCbCrToRGB,
 * which is located at the beginning of the buffer. Thus, this memory has to be
 * allocated as follows:
 *     TIFFYCbCrToRGB *ycbcr = (TIFFYCbCrToRGB *)_TIFFmalloc(
 *         TIFFroundup_32(sizeof(TIFFYCbCrToRGB), sizeof(long)) +
 *         4 * 256 * sizeof(TIFFRGBValue) + 2 * 256 * sizeof(int) +
 *         3 * 256 * sizeof(int32_t));
 */
YCbCrToRGB :: struct {  /* YCbCr->RGB support */
    clamptab : ^RGBValue, /* range clamping table */
    Cr_r_tab: ^c.int,
    Cb_b_tab: ^c.int,
    Cr_g_tab: ^u32,
    Cb_g_tab: ^u32,
    Y_tab: ^u32,
}

CIELABTORGB_TABLE_RANGE :: 1500
CIELabToRGB :: struct { /* CIE Lab 1976->RGB support */
    range: c.int, /* Size of conversion table */
    rstep: f32, 
    gstep: f32, 
    bstep: f32,
    X0: f32, 
    Y0: f32, 
    Z0: f32, /* Reference white point */
    display: Display,
    Yr2r: [CIELABTORGB_TABLE_RANGE + 1]f32, /* Conversion of Yr to r */
    Yg2g: [CIELABTORGB_TABLE_RANGE + 1]f32, /* Conversion of Yg to g */
    Yb2b: [CIELABTORGB_TABLE_RANGE + 1]f32, /* Conversion of Yb to b */
}


Field :: struct{}  // _TIFFField
FieldArray :: struct{} // _TIFFFieldArray


@(default_calling_convention="c")
@(link_prefix = "TIFF")
foreign libtiff {

	GetVersion :: proc() -> cstring ---

	FindCODEC :: proc(a : u16) -> ^Codec ---

	// extern TIFFCodec *TIFFRegisterCODEC(uint16_t, const char *, TIFFInitMethod) -> ^Codec ---
	UnRegisterCODEC :: proc (codec : ^Codec) ---
	IsCODECConfigured :: proc(scheme : u16) -> c.int ---
	GetConfiguredCODECs :: proc() -> ^Codec ---

	_TIFFmemset :: proc(p: rawptr, v: c.int, c: tmsize_t) ---
	_TIFFmemcpy :: proc(d: rawptr, s: rawptr, c: tmsize_t) ---
	_TIFFmemcmp :: proc(p1: rawptr, p2: rawptr, c_: tmsize_t) -> c.int ---

	/*
	** Stuff, related to tag handling and creating custom tags.
	*/
	GetTagListCount :: proc(tiff: ^TIFF) -> c.int ---
	GetTagListEntry :: proc(tiff: ^TIFF, tag_index: c.int) -> u32 ---

	// #define TIFF_ANY TIFF_NOTYPE /* for field descriptor searching */
	// #define TIFF_VARIABLE -1     /* marker for variable length tags */
	// #define TIFF_SPP -2          /* marker for SamplesPerPixel tags */
	// #define TIFF_VARIABLE2 -3    /* marker for uint32_t var-length tags */
	// #define FIELD_CUSTOM 65

	FindField :: proc(tiff: ^TIFF, tag : u32, dt : DataType) -> ^Field ---
	FieldWithTag :: proc(tiff: ^TIFF, tag : u32) -> ^Field ---
	FieldWithName :: proc(tiff: ^TIFF, n : cstring) -> ^Field ---

	FieldTag :: proc(field: ^Field) -> u32 ---
	FieldName :: proc(field: ^Field) -> cstring ---
	FieldDataType :: proc(field: ^Field) -> DataType ---
	FieldPassCount :: proc(field: ^Field) -> c.int ---
	FieldReadCount :: proc(field: ^Field) -> c.int ---
	FieldWriteCount :: proc(field: ^Field) -> c.int ---
	FieldSetGetSize :: proc(field: ^Field) -> c.int --- /* returns internal storage size of TIFFSetGetFieldType in bytes. */
	FieldSetGetCountSize :: proc(field: ^Field) -> c.int --- /* returns size of count parameter 0=none,2=uint16_t, 4=uint32_t */
	FieldIsAnonymous :: proc(field: ^Field) -> c.int ---

	// typedef int (*TIFFVSetMethod)(TIFF *, uint32_t, va_list);
	// typedef int (*TIFFVGetMethod)(TIFF *, uint32_t, va_list);
	// typedef void (*TIFFPrintMethod)(TIFF *, FILE *, long);

	// typedef struct
	// {
	//     TIFFVSetMethod vsetfield; /* tag set routine */
	//     TIFFVGetMethod vgetfield; /* tag get routine */
	//     TIFFPrintMethod printdir; /* directory print routine */
	// } TIFFTagMethods;

	// extern TIFFTagMethods *TIFFAccessTagMethods(TIFF *);
	// extern void *TIFFGetClientInfo(TIFF *, const char *);
	// extern void TIFFSetClientInfo(TIFF *, void *, const char *);

	Cleanup   :: proc(tiff: ^TIFF) ---
	Close     :: proc(tiff: ^TIFF) ---
	Flush     :: proc(tiff: ^TIFF) -> c.int ---
	FlushData :: proc(tiff: ^TIFF) -> c.int ---
	GetField  :: proc(tif: ^TIFF, tag: u32, #c_vararg args: ..any) -> c.int ---
	VGetField :: proc(tif: ^TIFF, tag: u32, ap : ^c.va_list) -> c.int ---

	GetFieldDefaulted :: proc(tiff: ^TIFF, tag: u32, #c_vararg args: ..any) -> c.int ---
	VGetFieldDefaulted :: proc(tiff: ^TIFF, tag: u32, ap : ^c.va_list) -> c.int ---
	ReadDirectory :: proc(tiff: ^TIFF) -> c.int ---
	ReadCustomDirectory :: proc(tiff: ^TIFF, diroff: toff_t, infoarray: ^FieldArray) -> c.int ---
	ReadEXIFDirectory :: proc(tiff: ^TIFF, diroff: toff_t) -> c.int ---
	ReadGPSDirectory :: proc(tiff: ^TIFF, diroff: toff_t) -> c.int ---

	ScanlineSize64 :: proc(tif : ^TIFF) -> u64 ---
	ScanlineSize :: proc(tif : ^TIFF) -> tmsize_t ---

	RasterScanlineSize64 :: proc(tif: ^TIFF) -> u64 ---
	RasterScanlineSize :: proc(tif: ^TIFF) -> tmsize_t ---

	StripSize64 :: proc(tif : ^TIFF) -> u64 ---
	StripSize :: proc(tif: ^TIFF) -> tmsize_t ---

	RawStripSize64 :: proc(tiff: ^TIFF, strip: u32) -> u64 ---
	RawStripSize :: proc(tiff: ^TIFF, strip: u32) -> tmsize_t ---
	VStripSize64 :: proc(tiff: ^TIFF, nrows : u32) -> u64 ---
	VStripSize :: proc(tiff: ^TIFF, nrows: u32) -> tmsize_t ---
	TileRowSize64 :: proc(tiff: ^TIFF) -> u64 ---
	TileRowSize :: proc(tiff: ^TIFF) -> tmsize_t ---
	TileSize64 :: proc(tiff: ^TIFF) -> u64 ---
	TileSize :: proc(tiff: ^TIFF) -> tmsize_t ---
	VTileSize64 :: proc(tiff: ^TIFF, nrows: u32) -> u64 ---
	VTileSize :: proc(tiff: ^TIFF, nrows: u32) -> tmsize_t ---
	DefaultStripSize :: proc(tiff: ^TIFF, request: u32) -> u32 ---
	DefaultTileSize :: proc(tiff: ^TIFF, tw: ^u32, th: ^u32) ---

	Fileno :: proc(tiff: ^TIFF) -> c.int ---
	SetFileno :: proc(tiff: ^TIFF, fileno: int) -> c.int ---

	// extern thandle_t TIFFClientdata(TIFF *);
	// extern thandle_t TIFFSetClientdata(TIFF *, thandle_t);

	GetMode :: proc(tiff: ^TIFF) -> c.int ---
	SetMode :: proc(tiff: ^TIFF, mode: c.int) -> c.int ---
	IsTiled :: proc(tiff: ^TIFF) -> c.int ---
	IsByteSwapped :: proc(tiff: ^TIFF) -> c.int ---
	IsUpSampled :: proc(tiff: ^TIFF) -> c.int ---
	IsMSB2LSB :: proc(tiff: ^TIFF) -> c.int ---
	IsBigEndian :: proc(tiff: ^TIFF) -> c.int ---
	IsBigTIFF :: proc(tiff: ^TIFF) -> c.int ---

	// extern TIFFReadWriteProc TIFFGetReadProc(TIFF *);
	// extern TIFFReadWriteProc TIFFGetWriteProc(TIFF *);
	// extern TIFFSeekProc TIFFGetSeekProc(TIFF *);
	// extern TIFFCloseProc TIFFGetCloseProc(TIFF *);
	// extern TIFFSizeProc TIFFGetSizeProc(TIFF *);
	// extern TIFFMapFileProc TIFFGetMapFileProc(TIFF *);
	// extern TIFFUnmapFileProc TIFFGetUnmapFileProc(TIFF *);

	CurrentRow :: proc(tiff: ^TIFF) -> u32 ---
	CurrentDirectory :: proc(tiff: ^TIFF) -> tdir_t ---
	NumberOfDirectories :: proc(tiff: ^TIFF) -> tdir_t ---
	CurrentDirOffset :: proc(tiff: ^TIFF) -> u64 ---
	CurrentStrip :: proc(tiff: ^TIFF) -> u32 ---
	CurrentTile :: proc(tiff: ^TIFF) -> u32 ---

	ReadBufferSetup :: proc(tiff: ^TIFF, bp: rawptr, size: tmsize_t) -> c.int ---
	WriteBufferSetup :: proc(tiff: ^TIFF,bp: rawptr, size: tmsize_t) -> c.int ---
	SetupStrips :: proc(tiff: ^TIFF) -> c.int ---
	WriteCheck :: proc(tiff: ^TIFF, tiles: c.int, module: cstring) -> c.int ---
	FreeDirectory :: proc(tiff: ^TIFF) ---
	CreateDirectory :: proc(tiff: ^TIFF) -> c.int ---

	CreateCustomDirectory :: proc(tiff: ^TIFF, fa: ^FieldArray) -> c.int ---
	CreateEXIFDirectory :: proc(tiff: ^TIFF) -> c.int ---
	CreateGPSDirectory :: proc(tiff: ^TIFF) -> c.int ---
	LastDirectory :: proc(tiff: ^TIFF) -> c.int ---
	SetDirectory :: proc(tiff: ^TIFF, dirn: tdir_t) -> c.int ---
	SetSubDirectory :: proc(tiff: ^TIFF, diroff: u64) -> c.int ---
	UnlinkDirectory :: proc(tiff: ^TIFF, dirn: tdir_t) -> c.int ---
	SetField :: proc(tiff: ^TIFF, tag : u32, #c_vararg args: ..any) -> c.int ---
	VSetField :: proc(tiff: ^TIFF, tag : u32, ap : ^c.va_list) -> c.int ---
	UnsetField :: proc(tiff: ^TIFF, tag : u32) -> c.int ---
	WriteDirectory :: proc(tiff: ^TIFF) -> c.int ---
	WriteCustomDirectory :: proc(tiff: ^TIFF, pdiroff: ^u64) -> c.int ---
	CheckpointDirectory :: proc(tiff: ^TIFF) -> c.int ---
	RewriteDirectory :: proc(tiff: ^TIFF) -> c.int ---
	DeferStrileArrayWriting :: proc(tiff: ^TIFF) -> c.int ---
	ForceStrileArrayWriting :: proc(tiff: ^TIFF) -> c.int ---
    // PrintDirectory :: proc(tiff: ^TIFF, FILE *, long = 0) ---
  
    ReadScanline :: proc(tiff : ^TIFF, buf: rawptr, row: u32, sample: u16 = 0) -> c.int ---
    WriteScanline :: proc(tiff: ^TIFF, buf: rawptr, row: u32, sample: u16 = 0) -> c.int ---
    ReadRGBAImage :: proc(tiff : ^TIFF, width: u32, height: u32, raster: ^u32, stop_on_error: c.int = 0) -> c.int ---
    ReadRGBAImageOriented :: proc(tiff: ^TIFF, width: u32, height: u32, raster: ^u32, orientation: c.int = ORIENTATION_BOTLEFT, stop_on_error : c.int = 0) -> c.int ---
	ReadRGBAStrip :: proc(tiff: ^TIFF , row: u32, raster: ^u32) -> c.int ---
	ReadRGBATile :: proc(tiff : ^TIFF, x: u32, y: u32, raster : ^u32) -> c.int ---

	ReadRGBAStripExt :: proc(tiff : ^TIFF, row: u32, raster : ^u32, stop_on_error : c.int) -> c.int ---
	ReadRGBATileExt :: proc(tiff: ^TIFF, row: u32, col: u32, raster: ^u32, stop_on_error : c.int) -> c.int ---
	RGBAImageOK    :: proc (tiff: ^TIFF, emsg: [1024]byte) -> c.int ---
	RGBAImageBegin :: proc (img: ^RGBAImage, tiff: ^TIFF, stop: c.int, emsg: [1024]byte) -> c.int ---
	RGBAImageGet   :: proc (img: ^RGBAImage, raster : ^u32, w: u32, h: u32) -> c.int ---
	RGBAImageEnd   :: proc (img: ^RGBAImage) ---

	FileName :: proc(tiff : ^TIFF) -> cstring ---
	SetFileName :: proc(tiff : ^TIFF, name: cstring) -> cstring ---

	Error :: proc(module: cstring, fmt : cstring, #c_vararg args: ..any) ---
	//     TIFF_ATTRIBUTE((__format__(__printf__, 2, 3)));
	// extern void TIFFErrorExt(thandle_t, const char *, const char *, ...)
	//     TIFF_ATTRIBUTE((__format__(__printf__, 3, 4)));
	Warning :: proc(module : cstring, fmt : cstring, #c_vararg args: ..any) ---
	//     TIFF_ATTRIBUTE((__format__(__printf__, 2, 3)));
	// extern void TIFFWarningExt(thandle_t, const char *, const char *, ...)
	//     TIFF_ATTRIBUTE((__format__(__printf__, 3, 4)));


	SetErrorHandler :: proc(handler : ErrorHandler) -> ErrorHandler ---
	// extern TIFFErrorHandlerExt TIFFSetErrorHandlerExt(TIFFErrorHandlerExt);
	SetWarningHandler :: proc(handler : ErrorHandler) -> ErrorHandler ---
	// extern TIFFErrorHandlerExt TIFFSetWarningHandlerExt(TIFFErrorHandlerExt);

	WarningExtR :: proc(tiff: ^TIFF, module : cstring, fmt : cstring, #c_vararg args: ..any) ---
	//         TIFF_ATTRIBUTE((__format__(__printf__, 3, 4)));
	ErrorExtR :: proc(tiff: ^TIFF, module : cstring, fmt : cstring, #c_vararg args: ..any) ---
	//         TIFF_ATTRIBUTE((__format__(__printf__, 3, 4)));

	OpenOptionsAlloc :: proc() -> ^OpenOptions ---

	OpenOptionsFree :: proc(opts : ^OpenOptions) ---

	OpenOptionsSetMaxSingleMemAlloc    :: proc(opts : ^OpenOptions, max_single_mem_alloc : i64) ---
    OpenOptionsSetMaxCumulatedMemAlloc :: proc(opts : ^OpenOptions, max_cumulated_mem_alloc: tmsize_t) ---
    OpenOptionsSetWarnAboutUnknownTags :: proc(opts : ^OpenOptions, warn_about_unknown_tags: c.int) ---
    // OpenOptionsSetErrorHandlerExtR     :: proc(opts : ^OpenOptions,,TIFFErrorHandlerExtR handler,errorhandler_user_data: rawptr) ---
    // OpenOptionsSetWarningHandlerExtR   :: proc(opts : ^OpenOptions,,TIFFErrorHandlerExtR handler,warnhandler_user_data: rawptr) ---
	
	//@Note - fulcrum: use mode == "r" for Read and mode == "w" for Writing
    Open :: proc(filepath : cstring, mode : cstring) -> ^TIFF ---
    OpenExt :: proc(fileapath : cstring, mode : cstring, opts : ^OpenOptions) -> ^TIFF ---

	//@Note - fulcrum: Nobody needs this...
	// #ifdef _WIN32
	//     extern TIFF *TIFFOpenW(const wchar_t *, const char *);
	//     extern TIFF *TIFFOpenWExt(const wchar_t *, const char *, TIFFOpenOptions *opts);
	// #endif /* _WIN32 */

	FdOpen    :: proc(ifd: c.int, name: cstring, mode: cstring) -> ^TIFF ---
	FdOpenExt :: proc(ifd: c.int, name: cstring, mode: cstring, opts : ^OpenOptions) -> ^TIFF ---

    // extern TIFF *TIFFClientOpen(const char *, const char *, thandle_t,TIFFReadWriteProc, TIFFReadWriteProc,TIFFSeekProc, TIFFCloseProc, TIFFSizeProc,TIFFMapFileProc, TIFFUnmapFileProc);
    // extern TIFF *TIFFClientOpenExt(const char *, const char *, thandle_t,TIFFReadWriteProc, TIFFReadWriteProc,TIFFSeekProc, TIFFCloseProc, TIFFSizeProc,TIFFMapFileProc, TIFFUnmapFileProc,TIFFOpenOptions *opts);
    // extern TIFFExtendProc TIFFSetTagExtender(TIFFExtendProc);

	ComputeTile :: proc(tiff: ^TIFF, x: u32, y: u32,  z: u32, s: u16) -> u32 ---
	CheckTile :: proc(tiff: ^TIFF, x: u32, y: u32, z: u32, s: u16) -> c.int ---

	NumberOfTiles :: proc(tiff: ^TIFF) -> u32 ---
	ReadTile  :: proc(tiff: ^TIFF, buf: rawptr, x: u32, y: u32, z: u32, s: u16) -> tmsize_t ---
	WriteTile :: proc(tiff: ^TIFF, buf: rawptr, x: u32, y: u32, z: u32, s: u16) -> tmsize_t ---
	ComputeStrip :: proc(tiff: ^TIFF, row: u32, sample: u16) -> u32 ---
	NumberOfStrips :: proc(tif : ^TIFF) -> u32 ---
	ReadEncodedStrip :: proc(tif: ^TIFF, strip: u32, buf: rawptr, size: tmsize_t) -> tmsize_t ---

	ReadRawStrip       :: proc(tiff: ^TIFF, strip: u32, buf: rawptr, size : tmsize_t) -> tmsize_t ---
	ReadEncodedTile    :: proc(tiff: ^TIFF, tile: u32, buf: rawptr, size: tmsize_t) -> tmsize_t ---
	ReadRawTile        :: proc(tiff: ^TIFF, tile: u32, buf: rawptr, size: tmsize_t) -> tmsize_t ---
	ReadFromUserBuffer :: proc(tiff: ^TIFF, strile: u32, inbuf: rawptr, insize: tmsize_t, outbuf: rawptr, outsize: tmsize_t) -> c.int ---
	WriteEncodedStrip  :: proc(tiff: ^TIFF, strip: u32, data: rawptr, cc: tmsize_t) -> tmsize_t ---
	WriteRawStrip      :: proc(tiff: ^TIFF, strip: u32, data: rawptr, cc: tmsize_t) -> tmsize_t ---
	WriteEncodedTile   :: proc(tiff: ^TIFF, tile: u32, data: rawptr, cc: tmsize_t) -> tmsize_t ---
	WriteRawTile       :: proc(tiff: ^TIFF, tile: u32, data: rawptr, cc: tmsize_t) -> tmsize_t ---

    GetMaxCompressionRatio :: proc(tiff: ^TIFF) -> u64 ---

    DataWidth :: proc(dt: DataType) -> c.int --- /* table of tag datatype widths within TIFF file. */
    SetWriteOffset :: proc(tiff: ^TIFF, off: toff_t) ---
    SwabShort :: proc(v: ^u16) ---
    SwabLong :: proc(v: ^u32) ---
    SwabLong8 :: proc(v: ^u64) ---
    SwabFloat :: proc(v: ^c.float) ---
    SwabDouble :: proc(v: ^c.double) ---

    SwabArrayOfShort :: proc(wp: ^u16, n: tmsize_t) ---
    SwabArrayOfTriples :: proc(tp: ^u8, n: tmsize_t) ---
    SwabArrayOfLong :: proc(lp: ^u32, n: tmsize_t) ---
    SwabArrayOfLong8 :: proc(lp: ^u64, n: tmsize_t) ---
    SwabArrayOfFloat :: proc(fp: ^c.float, n: tmsize_t) ---
    SwabArrayOfDouble :: proc(dp: ^c.double, n: tmsize_t) ---
    ReverseBits :: proc(cp: ^u8, n: tmsize_t) ---
    // extern const unsigned char *TIFFGetBitRevTable(int);

    GetStrileOffset           :: proc(tiff: ^TIFF, strile: u32) -> u64 ---
    GetStrileByteCount        :: proc(tiff: ^TIFF, strile: u32) -> u64 ---
    GetStrileOffsetWithErr    :: proc(tiff: ^TIFF, strile: u32, pbErr: ^c.int) -> u64 ---
    GetStrileByteCountWithErr :: proc(tiff: ^TIFF, strile: u32, pbErr: ^c.int) -> u64 ---
}