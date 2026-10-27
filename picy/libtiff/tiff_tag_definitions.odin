package libtiff

// @Note - Fulcrum: You may uncomment what you need yourself here. Dont feel like converting all this..


/*
 * NB: In the comments below,
 *  - items marked with a + are obsoleted by revision 5.0,
 *  - items marked with a ! are introduced in revision 6.0.
 *  - items marked with a % are introduced post revision 6.0.
 *  - items marked with a $ are obsoleted by revision 6.0.
 *  - items marked with a & are introduced by Adobe DNG specification.
 */

/*
 * Tag data type information.
 *
 * Note: RATIONALs are the ratio of two 32-bit integer values.
 *--:
 * Note2: TIFF_IFD8 data type is used in tiffFields[]-tag definition in order to
 distinguish the write-handling of those tags between ClassicTIFF and BigTiff:
                  For ClassicTIFF libtiff writes a 32-bit value and the TIFF_IFD
 type-id into the file For BigTIFF     libtiff writes a 64-bit value and the
 TIFF_IFD8 type-id into the file
 */
DataType :: enum u32 {
    NOTYPE    = 0,     /* placeholder */
    BYTE      = 1,     /* 8-bit unsigned integer */
    ASCII     = 2,     /* 8-bit bytes w/ last byte null */
    SHORT     = 3,     /* 16-bit unsigned integer */
    LONG      = 4,     /* 32-bit unsigned integer */
    RATIONAL  = 5,     /* 64-bit unsigned fraction */
    SBYTE     = 6,     /* !8-bit signed integer */
    UNDEFINED = 7,     /* !8-bit untyped data */
    SSHORT    = 8,     /* !16-bit signed integer */
    SLONG     = 9,     /* !32-bit signed integer */
    SRATIONAL = 10,    /* !64-bit signed fraction */
    FLOAT     = 11,    /* !32-bit IEEE floating point */
    DOUBLE    = 12,    /* !64-bit IEEE floating point */
    IFD       = 13,    /* %32-bit unsigned integer (offset) */
    LONG8     = 16,    /* BigTIFF 64-bit unsigned integer */
    SLONG8    = 17,    /* BigTIFF 64-bit signed integer */
    IFD8      = 18,    /* BigTIFF 64-bit unsigned integer (offset) */
}


/*
 * TIFF Tag Definitions.
 */

TIFFTAG_SUBFILETYPE :: 254       /* subfile data descriptor */
FILETYPE_REDUCEDIMAGE :: 0x1     /* reduced resolution version */
FILETYPE_PAGE :: 0x2             /* one page of many */
FILETYPE_MASK :: 0x4             /* transparency mask */
TIFFTAG_OSUBFILETYPE :: 255      /* +kind of data in subfile */
OFILETYPE_IMAGE :: 1             /* full resolution image data */
OFILETYPE_REDUCEDIMAGE :: 2      /* reduced size image data */
OFILETYPE_PAGE :: 3              /* one page of many */
TIFFTAG_IMAGEWIDTH :: 256        /* image width in pixels */
TIFFTAG_IMAGELENGTH :: 257       /* image height in pixels */
TIFFTAG_IMAGEHEIGHT :: TIFFTAG_IMAGELENGTH
TIFFTAG_BITSPERSAMPLE :: 258     /* bits per channel (sample) */
TIFFTAG_COMPRESSION :: 259       /* data compression technique */
COMPRESSION_NONE :: 1            /* dump mode */
COMPRESSION_CCITTRLE :: 2        /* CCITT modified Huffman RLE */
COMPRESSION_CCITTFAX3 :: 3       /* CCITT Group 3 fax encoding */
COMPRESSION_CCITT_T4 :: 3        /* CCITT T.4 (TIFF 6 name) */
COMPRESSION_CCITTFAX4 :: 4       /* CCITT Group 4 fax encoding */
COMPRESSION_CCITT_T6 :: 4        /* CCITT T.6 (TIFF 6 name) */
COMPRESSION_LZW :: 5             /* Lempel-Ziv  & Welch */
COMPRESSION_OJPEG :: 6           /* !6.0 JPEG */
COMPRESSION_JPEG :: 7            /* %JPEG DCT compression */
COMPRESSION_T85 :: 9             /* !TIFF/FX T.85 JBIG compression */
COMPRESSION_T43 :: 10            /* !TIFF/FX T.43 colour by layered JBIG compression */
COMPRESSION_NEXT :: 32766        /* NeXT 2-bit RLE */
COMPRESSION_CCITTRLEW :: 32771   /* #1 w/ word alignment */
COMPRESSION_PACKBITS :: 32773    /* Macintosh RLE */
COMPRESSION_THUNDERSCAN :: 32809 /* ThunderScan RLE */

/* codes 32895-32898 are reserved for ANSI IT8 TIFF/IT <dkelly@apago.com) */
COMPRESSION_IT8CTPAD :: 32895 /* IT8 CT w/padding */
COMPRESSION_IT8LW :: 32896    /* IT8 Linework RLE */
COMPRESSION_IT8MP :: 32897    /* IT8 Monochrome picture */
COMPRESSION_IT8BL :: 32898    /* IT8 Binary line art */
/* compression codes 32908-32911 are reserved for Pixar */
COMPRESSION_PIXARFILM :: 32908 /* Pixar companded 10bit LZW */
COMPRESSION_PIXARLOG :: 32909  /* Pixar companded 11bit ZIP */
COMPRESSION_DEFLATE :: 32946   /* Deflate compression, legacy tag */
COMPRESSION_ADOBE_DEFLATE :: 8 /* Deflate compression, as recognized by Adobe */
/* compression code 32947 is reserved for Oceana Matrix <dev@oceana.com> */
COMPRESSION_DCS :: 32947      /* Kodak DCS encoding */
COMPRESSION_JBIG :: 34661     /* ISO JBIG */
COMPRESSION_SGILOG :: 34676   /* SGI Log Luminance RLE */
COMPRESSION_SGILOG24 :: 34677 /* SGI Log 24-bit packed */
COMPRESSION_JP2000 :: 34712   /* Leadtools JPEG2000 */
COMPRESSION_LERC :: 34887     /* ESRI Lerc codec: https://github.com/Esri/lerc */
/* compression codes 34887-34889 are reserved for ESRI */
COMPRESSION_LZMA :: 34925             /* LZMA2 */
COMPRESSION_ZSTD :: 50000             /* ZSTD: WARNING not registered in Adobe-maintained registry */
COMPRESSION_WEBP :: 50001             /* WEBP: WARNING not registered in Adobe-maintained registry */
COMPRESSION_JXL :: 50002              /* JPEGXL: WARNING not registered in Adobe-maintained registry */
COMPRESSION_JXL_DNG_1_7 :: 52546      /* JPEGXL from DNG 1.7 specification */
TIFFTAG_PHOTOMETRIC :: 262            /* photometric interpretation */
PHOTOMETRIC_MINISWHITE :: 0           /* min value is white */
PHOTOMETRIC_MINISBLACK :: 1           /* min value is black */
PHOTOMETRIC_RGB :: 2                  /* RGB color model */
PHOTOMETRIC_PALETTE :: 3              /* color map indexed */
PHOTOMETRIC_MASK :: 4                 /* $holdout mask */
PHOTOMETRIC_SEPARATED :: 5            /* !color separations */
PHOTOMETRIC_YCBCR :: 6                /* !CCIR 601 */
PHOTOMETRIC_CIELAB :: 8               /* !1976 CIE L*a*b* */
PHOTOMETRIC_ICCLAB :: 9               /* ICC L*a*b* [Adobe TIFF Technote 4] */
PHOTOMETRIC_ITULAB :: 10              /* ITU L*a*b* */
PHOTOMETRIC_CFA :: 32803              /* color filter array */
PHOTOMETRIC_LOGL :: 32844             /* CIE Log2(L) */
PHOTOMETRIC_LOGLUV :: 32845           /* CIE Log2(L) (u',v') */
TIFFTAG_THRESHHOLDING :: 263          /* +thresholding used on data */
THRESHHOLD_BILEVEL :: 1               /* b&w art scan */
THRESHHOLD_HALFTONE :: 2              /* or dithered scan */
THRESHHOLD_ERRORDIFFUSE :: 3          /* usually floyd-steinberg */
TIFFTAG_CELLWIDTH :: 264              /* +dithering matrix width */
TIFFTAG_CELLLENGTH :: 265             /* +dithering matrix height */
TIFFTAG_FILLORDER :: 266              /* data order within a byte */
FILLORDER_MSB2LSB :: 1                /* most significant -> least */
FILLORDER_LSB2MSB :: 2                /* least significant -> most */
TIFFTAG_DOCUMENTNAME :: 269           /* name of doc. image is from */
TIFFTAG_IMAGEDESCRIPTION :: 270       /* info about image */
TIFFTAG_MAKE :: 271                   /* scanner manufacturer name */
TIFFTAG_MODEL :: 272                  /* scanner model name/number */
TIFFTAG_STRIPOFFSETS :: 273           /* offsets to data strips */
TIFFTAG_ORIENTATION :: 274            /* +image orientation */
ORIENTATION_TOPLEFT  :: 1             /* row 0 top, col 0 lhs */
ORIENTATION_TOPRIGHT :: 2             /* row 0 top, col 0 rhs */
ORIENTATION_BOTRIGHT :: 3             /* row 0 bottom, col 0 rhs */
ORIENTATION_BOTLEFT  :: 4             /* row 0 bottom, col 0 lhs */
ORIENTATION_LEFTTOP  :: 5             /* row 0 lhs, col 0 top */
ORIENTATION_RIGHTTOP :: 6             /* row 0 rhs, col 0 top */
ORIENTATION_RIGHTBOT :: 7             /* row 0 rhs, col 0 bottom */
ORIENTATION_LEFTBOT  :: 8             /* row 0 lhs, col 0 bottom */
TIFFTAG_SAMPLESPERPIXEL :: 277        /* samples per pixel */
TIFFTAG_ROWSPERSTRIP    :: 278        /* rows per strip of data */
TIFFTAG_STRIPBYTECOUNTS :: 279        /* bytes counts for strips */
TIFFTAG_MINSAMPLEVALUE  :: 280        /* +minimum sample value */
TIFFTAG_MAXSAMPLEVALUE :: 281         /* +maximum sample value */
TIFFTAG_XRESOLUTION :: 282            /* pixels/resolution in x */
TIFFTAG_YRESOLUTION :: 283            /* pixels/resolution in y */
TIFFTAG_PLANARCONFIG :: 284           /* storage organization */
PLANARCONFIG_CONTIG :: 1              /* single image plane */
PLANARCONFIG_SEPARATE :: 2            /* separate planes of data */
TIFFTAG_PAGENAME :: 285               /* page name image is from */
TIFFTAG_XPOSITION :: 286              /* x page offset of image lhs */
TIFFTAG_YPOSITION :: 287              /* y page offset of image lhs */
TIFFTAG_FREEOFFSETS :: 288            /* +byte offset to free block */
TIFFTAG_FREEBYTECOUNTS :: 289         /* +sizes of free blocks */
TIFFTAG_GRAYRESPONSEUNIT :: 290       /* $gray scale curve accuracy */
GRAYRESPONSEUNIT_10S :: 1             /* tenths of a unit */
GRAYRESPONSEUNIT_100S :: 2            /* hundredths of a unit */
GRAYRESPONSEUNIT_1000S :: 3           /* thousandths of a unit */
GRAYRESPONSEUNIT_10000S :: 4          /* ten-thousandths of a unit */
GRAYRESPONSEUNIT_100000S :: 5         /* hundred-thousandths */
TIFFTAG_GRAYRESPONSECURVE :: 291      /* $gray scale response curve */
TIFFTAG_GROUP3OPTIONS :: 292          /* 32 flag bits */
TIFFTAG_T4OPTIONS :: 292              /* TIFF 6.0 proper name alias */
GROUP3OPT_2DENCODING :: 0x1           /* 2-dimensional coding */
GROUP3OPT_UNCOMPRESSED :: 0x2         /* data not compressed */
GROUP3OPT_FILLBITS :: 0x4             /* fill to byte boundary */
TIFFTAG_GROUP4OPTIONS :: 293          /* 32 flag bits */
TIFFTAG_T6OPTIONS :: 293              /* TIFF 6.0 proper name */
GROUP4OPT_UNCOMPRESSED :: 0x2         /* data not compressed */
TIFFTAG_RESOLUTIONUNIT :: 296         /* units of resolutions */
RESUNIT_NONE :: 1                     /* no meaningful units */
RESUNIT_INCH :: 2                     /* english */
RESUNIT_CENTIMETER :: 3               /* metric */
TIFFTAG_PAGENUMBER :: 297             /* page numbers of multi-page */
TIFFTAG_COLORRESPONSEUNIT :: 300      /* $color curve accuracy */
COLORRESPONSEUNIT_10S :: 1            /* tenths of a unit */
COLORRESPONSEUNIT_100S :: 2           /* hundredths of a unit */
COLORRESPONSEUNIT_1000S :: 3          /* thousandths of a unit */
COLORRESPONSEUNIT_10000S :: 4         /* ten-thousandths of a unit */
COLORRESPONSEUNIT_100000S :: 5        /* hundred-thousandths */
TIFFTAG_TRANSFERFUNCTION :: 301       /* !colorimetry info */
TIFFTAG_SOFTWARE :: 305               /* name & release */
TIFFTAG_DATETIME :: 306               /* creation date and time */
TIFFTAG_ARTIST :: 315                 /* creator of image */
TIFFTAG_HOSTCOMPUTER :: 316           /* machine where created */
TIFFTAG_PREDICTOR :: 317              /* prediction scheme w/ LZW */
PREDICTOR_NONE :: 1                   /* no prediction scheme used */
PREDICTOR_HORIZONTAL :: 2             /* horizontal differencing */
PREDICTOR_FLOATINGPOINT :: 3          /* floating point predictor */
TIFFTAG_WHITEPOINT :: 318             /* image white point */
TIFFTAG_PRIMARYCHROMATICITIES :: 319  /* !primary chromaticities */
TIFFTAG_COLORMAP :: 320               /* RGB map for palette image */
TIFFTAG_HALFTONEHINTS :: 321          /* !highlight+shadow info */
TIFFTAG_TILEWIDTH :: 322              /* !tile width in pixels */
TIFFTAG_TILELENGTH :: 323             /* !tile height in pixels */
TIFFTAG_TILEOFFSETS :: 324            /* !offsets to data tiles */
TIFFTAG_TILEBYTECOUNTS :: 325         /* !byte counts for tiles */
TIFFTAG_BADFAXLINES :: 326            /* lines w/ wrong pixel count */
TIFFTAG_CLEANFAXDATA :: 327           /* regenerated line info */
CLEANFAXDATA_CLEAN :: 0               /* no errors detected */
CLEANFAXDATA_REGENERATED :: 1         /* receiver regenerated lines */
CLEANFAXDATA_UNCLEAN :: 2             /* uncorrected errors exist */
TIFFTAG_CONSECUTIVEBADFAXLINES :: 328 /* max consecutive bad lines */
TIFFTAG_SUBIFD :: 330                 /* subimage descriptors */
TIFFTAG_INKSET :: 332                 /* !inks in separated image */
INKSET_CMYK :: 1                      /* !cyan-magenta-yellow-black color */
INKSET_MULTIINK :: 2                  /* !multi-ink or hi-fi color */
TIFFTAG_INKNAMES :: 333               /* !ascii names of inks */
TIFFTAG_NUMBEROFINKS :: 334           /* !number of inks */
TIFFTAG_DOTRANGE :: 336               /* !0% and 100% dot codes */
TIFFTAG_TARGETPRINTER :: 337          /* !separation target */
TIFFTAG_EXTRASAMPLES :: 338           /* !info about extra samples */
EXTRASAMPLE_UNSPECIFIED :: 0          /* !unspecified data */
EXTRASAMPLE_ASSOCALPHA :: 1           /* !associated alpha data */
EXTRASAMPLE_UNASSALPHA :: 2           /* !unassociated alpha data */
TIFFTAG_SAMPLEFORMAT :: 339           /* !data sample format */
SAMPLEFORMAT_UINT :: 1                /* !unsigned integer data */
SAMPLEFORMAT_INT :: 2                 /* !signed integer data */
SAMPLEFORMAT_IEEEFP :: 3              /* !IEEE floating point data */
SAMPLEFORMAT_VOID :: 4                /* !untyped data */
SAMPLEFORMAT_COMPLEXINT :: 5          /* !complex signed int */
SAMPLEFORMAT_COMPLEXIEEEFP :: 6       /* !complex ieee floating */
TIFFTAG_SMINSAMPLEVALUE :: 340        /* !variable MinSampleValue */
TIFFTAG_SMAXSAMPLEVALUE :: 341        /* !variable MaxSampleValue */
TIFFTAG_CLIPPATH :: 343               /* %ClipPath [Adobe TIFF technote 2] */
TIFFTAG_XCLIPPATHUNITS :: 344         /* %XClipPathUnits [Adobe TIFF technote 2] */
TIFFTAG_YCLIPPATHUNITS :: 345         /* %YClipPathUnits [Adobe TIFF technote 2] */
TIFFTAG_INDEXED :: 346                /* %Indexed [Adobe TIFF Technote 3] */
TIFFTAG_JPEGTABLES :: 347             /* %JPEG table stream */
TIFFTAG_OPIPROXY :: 351               /* %OPI Proxy [Adobe TIFF technote] */
/* Tags 400-435 are from the TIFF/FX spec */
TIFFTAG_GLOBALPARAMETERSIFD :: 400 /* ! */
TIFFTAG_PROFILETYPE :: 401         /* ! */
PROFILETYPE_UNSPECIFIED :: 0       /* ! */
PROFILETYPE_G3_FAX :: 1            /* ! */
TIFFTAG_FAXPROFILE :: 402          /* ! */
FAXPROFILE_S :: 1                  /* !TIFF/FX FAX profile S */
FAXPROFILE_F :: 2                  /* !TIFF/FX FAX profile F */
FAXPROFILE_J :: 3                  /* !TIFF/FX FAX profile J */
FAXPROFILE_C :: 4                  /* !TIFF/FX FAX profile C */
FAXPROFILE_L :: 5                  /* !TIFF/FX FAX profile L */
FAXPROFILE_M :: 6                  /* !TIFF/FX FAX profile LM */
TIFFTAG_CODINGMETHODS :: 403       /* !TIFF/FX coding methods */
CODINGMETHODS_T4_1D :: (1 << 1)    /* !T.4 1D */
CODINGMETHODS_T4_2D :: (1 << 2)    /* !T.4 2D */
CODINGMETHODS_T6 :: (1 << 3)       /* !T.6 */
CODINGMETHODS_T85 :: (1 << 4)      /* !T.85 JBIG */
CODINGMETHODS_T42 :: (1 << 5)      /* !T.42 JPEG */
CODINGMETHODS_T43 :: (1 << 6)      /* !T.43 colour by layered JBIG */
TIFFTAG_VERSIONYEAR :: 404         /* !TIFF/FX version year */
TIFFTAG_MODENUMBER :: 405          /* !TIFF/FX mode number */
TIFFTAG_DECODE :: 433              /* !TIFF/FX decode */
TIFFTAG_IMAGEBASECOLOR :: 434      /* !TIFF/FX image base colour */
TIFFTAG_T82OPTIONS :: 435          /* !TIFF/FX T.82 options */
/*
 * Tags 512-521 are obsoleted by Technical Note #2 which specifies a
 * revised JPEG-in-TIFF scheme.
 */
TIFFTAG_JPEGPROC :: 512               /* !JPEG processing algorithm */
JPEGPROC_BASELINE :: 1                /* !baseline sequential */
JPEGPROC_LOSSLESS :: 14               /* !Huffman coded lossless */
TIFFTAG_JPEGIFOFFSET :: 513           /* !pointer to SOI marker */
TIFFTAG_JPEGIFBYTECOUNT :: 514        /* !JFIF stream length */
TIFFTAG_JPEGRESTARTINTERVAL :: 515    /* !restart interval length */
TIFFTAG_JPEGLOSSLESSPREDICTORS :: 517 /* !lossless proc predictor */
TIFFTAG_JPEGPOINTTRANSFORM :: 518     /* !lossless point transform */
TIFFTAG_JPEGQTABLES :: 519            /* !Q matrix offsets */
TIFFTAG_JPEGDCTABLES :: 520           /* !DCT table offsets */
TIFFTAG_JPEGACTABLES :: 521           /* !AC coefficient offsets */
TIFFTAG_YCBCRCOEFFICIENTS :: 529      /* !RGB -> YCbCr transform */
TIFFTAG_YCBCRSUBSAMPLING :: 530       /* !YCbCr subsampling factors */
TIFFTAG_YCBCRPOSITIONING :: 531       /* !subsample positioning */
YCBCRPOSITION_CENTERED :: 1           /* !as in PostScript Level 2 */
YCBCRPOSITION_COSITED :: 2            /* !as in CCIR 601-1 */
TIFFTAG_REFERENCEBLACKWHITE :: 532    /* !colorimetry info */
TIFFTAG_STRIPROWCOUNTS :: 559         /* !TIFF/FX strip row counts */
TIFFTAG_XMLPACKET :: 700              /* %XML packet [Adobe XMP Specification, January 2004 */
TIFFTAG_OPIIMAGEID :: 32781           /* %OPI ImageID [Adobe TIFF technote] */
/* For eiStream Annotation Specification, Version 1.00.06 see
 * http://web.archive.org/web/20050309141348/http://www.kofile.com/support%20pro/faqs/annospec.htm */
TIFFTAG_TIFFANNOTATIONDATA :: 32932
/* tags 32952-32956 are private tags registered to Island Graphics */
TIFFTAG_REFPTS :: 32953            /* image reference points */
TIFFTAG_REGIONTACKPOINT :: 32954   /* region-xform tack point */
TIFFTAG_REGIONWARPCORNERS :: 32955 /* warp quadrilateral */
TIFFTAG_REGIONAFFINE :: 32956      /* affine transformation mat */
/* tags 32995-32999 are private tags registered to SGI */
TIFFTAG_MATTEING :: 32995   /* $use ExtraSamples */
TIFFTAG_DATATYPE :: 32996   /* $use SampleFormat */
TIFFTAG_IMAGEDEPTH :: 32997 /* z depth of image */
TIFFTAG_TILEDEPTH :: 32998  /* z depth/data tile */
/* tags 33300-33309 are private tags registered to Pixar */
/*
 * TIFFTAG_PIXAR_IMAGEFULLWIDTH and TIFFTAG_PIXAR_IMAGEFULLLENGTH
 * are set when an image has been cropped out of a larger image.
 * They reflect the size of the original uncropped image.
 * The TIFFTAG_XPOSITION and TIFFTAG_YPOSITION can be used
 * to determine the position of the smaller image in the larger one.
 */
TIFFTAG_PIXAR_IMAGEFULLWIDTH :: 33300  /* full image size in x */
TIFFTAG_PIXAR_IMAGEFULLLENGTH :: 33301 /* full image size in y */
/* Tags 33302-33306 are used to identify special image modes and data
 * used by Pixar's texture formats.
 */
// TIFFTAG_PIXAR_TEXTUREFORMAT 33302 /* texture map format */
// TIFFTAG_PIXAR_WRAPMODES 33303     /* s & t wrap modes */
// TIFFTAG_PIXAR_FOVCOT 33304        /* cotan(fov) for env. maps */
// TIFFTAG_PIXAR_MATRIX_WORLDTOSCREEN 33305
// TIFFTAG_PIXAR_MATRIX_WORLDTOCAMERA 33306
/* tag 33405 is a private tag registered to Eastman Kodak */
// TIFFTAG_WRITERSERIALNUMBER 33405  /* device serial number */
// TIFFTAG_CFAREPEATPATTERNDIM 33421 /* (alias for TIFFTAG_EP_CFAREPEATPATTERNDIM)*/
// TIFFTAG_CFAPATTERN 33422          /* (alias for TIFFTAG_EP_CFAPATTERN) */
// TIFFTAG_BATTERYLEVEL 33423        /* (alias for TIFFTAG_EP_BATTERYLEVEL) */
/* tag 33432 is listed in the 6.0 spec w/ unknown ownership */
// TIFFTAG_COPYRIGHT 33432 /* copyright string */
/* Tags 33445-33452 are used for Molecular Dynamics GEL fileformat,
 * see http://research.stowers-institute.org/mcm/efg/ScientificSoftware/Utility/TiffTags/GEL-FileFormat.pdf
 * (2023: the above web site is unavailable but tags are explained briefly at
 * https://www.awaresystems.be/imaging/tiff/tifftags/docs/gel.html
 */
// TIFFTAG_MD_FILETAG 33445    /* Specifies the pixel data format encoding in the GEL file format. */
// TIFFTAG_MD_SCALEPIXEL 33446 /* scale factor */
// TIFFTAG_MD_COLORTABLE 33447 /* conversion from 16bit to 8bit */
// TIFFTAG_MD_LABNAME 33448    /* name of the lab that scanned this file. */
// TIFFTAG_MD_SAMPLEINFO 33449 /* information about the scanned GEL sample */
// TIFFTAG_MD_PREPDATE 33450   /* information about the date the sample was prepared YY/MM/DD */
// TIFFTAG_MD_PREPTIME 33451   /* information about the time the sample was prepared HH:MM*/
// TIFFTAG_MD_FILEUNITS 33452  /* Units for data in this file, as used in the GEL file format. */
/* IPTC TAG from RichTIFF specifications */
// TIFFTAG_RICHTIFFIPTC 33723
// TIFFTAG_INGR_PACKET_DATA_TAG 33918       /* Intergraph Application specific storage. */
// TIFFTAG_INGR_FLAG_REGISTERS 33919        /* Intergraph Application specific flags. */
// TIFFTAG_IRASB_TRANSORMATION_MATRIX 33920 /* Originally part of Intergraph's GeoTIFF tags, but likely understood by IrasB only. */
// TIFFTAG_MODELTIEPOINTTAG 33922           /* GeoTIFF */
/* 34016-34029 are reserved for ANSI IT8 TIFF/IT <dkelly@apago.com) */
// TIFFTAG_IT8SITE 34016                     /* site name */
// TIFFTAG_IT8COLORSEQUENCE 34017            /* color seq. [RGB,CMYK,etc] */
// TIFFTAG_IT8HEADER 34018                   /* DDES Header */
// TIFFTAG_IT8RASTERPADDING 34019            /* raster scanline padding */
// TIFFTAG_IT8BITSPERRUNLENGTH 34020         /* # of bits in short run */
// TIFFTAG_IT8BITSPEREXTENDEDRUNLENGTH 34021 /* # of bits in long run */
// TIFFTAG_IT8COLORTABLE 34022               /* LW colortable */
// TIFFTAG_IT8IMAGECOLORINDICATOR 34023      /* BP/BL image color switch */
// TIFFTAG_IT8BKGCOLORINDICATOR 34024        /* BP/BL bg color switch */
// TIFFTAG_IT8IMAGECOLORVALUE 34025          /* BP/BL image color value */
// TIFFTAG_IT8BKGCOLORVALUE 34026            /* BP/BL bg color value */
// TIFFTAG_IT8PIXELINTENSITYRANGE 34027      /* MP pixel intensity value */
// TIFFTAG_IT8TRANSPARENCYINDICATOR 34028    /* HC transparency switch */
// TIFFTAG_IT8COLORCHARACTERIZATION 34029    /* color character. table */
// TIFFTAG_IT8HCUSAGE 34030                  /* HC usage indicator */
// TIFFTAG_IT8TRAPINDICATOR 34031            /* Trapping indicator (untrapped=0, trapped=1) */
// TIFFTAG_IT8CMYKEQUIVALENT 34032           /* CMYK color equivalents */
/* tags 34232-34236 are private tags registered to Texas Instruments */
// TIFFTAG_FRAMECOUNT 34232             /* Sequence Frame Count */
// TIFFTAG_MODELTRANSFORMATIONTAG 34264 /* Used in interchangeable GeoTIFF files */
/* tag 34377 is private tag registered to Adobe for PhotoShop */
// TIFFTAG_PHOTOSHOP 34377
/* tags 34665, 34853 and 40965 are documented in EXIF specification */
// TIFFTAG_EXIFIFD 34665 /* Pointer to EXIF private directory */
/* tag 34750 is a private tag registered to Adobe? */
// TIFFTAG_ICCPROFILE 34675 /* ICC profile data */
// TIFFTAG_IMAGELAYER 34732 /* !TIFF/FX image layer information */
/* tag 34750 is a private tag registered to Pixel Magic */
// TIFFTAG_JBIGOPTIONS 34750 /* JBIG options */
// TIFFTAG_GPSIFD 34853      /* Pointer to EXIF GPS private directory */
/* tags 34908-34914 are private tags registered to SGI */
// TIFFTAG_FAXRECVPARAMS 34908 /* encoded Class 2 ses. params */
// TIFFTAG_FAXSUBADDRESS 34909 /* received SubAddr string */
// TIFFTAG_FAXRECVTIME 34910   /* receive time (secs) */
// TIFFTAG_FAXDCS 34911        /* encoded fax ses. params, Table 2/T.30 */
/* tags 37439-37443 are registered to SGI <gregl@sgi.com> */
// TIFFTAG_STONITS 37439 /* Sample value to Nits */

/* tag 34929 is a private tag registered to FedEx */
// TIFFTAG_FEDEX_EDR 34929                /* unknown use */
// TIFFTAG_IMAGESOURCEDATA 37724          /* http://justsolve.archiveteam.org/wiki/PSD, http://www.adobe.com/devnet-apps/photoshop/fileformatashtml/ */
// TIFFTAG_INTEROPERABILITYIFD 40965      /* Pointer to EXIF Interoperability private directory */
// TIFFTAG_GDAL_METADATA 42112            /* Used by the GDAL library */
// TIFFTAG_GDAL_NODATA 42113              /* Used by the GDAL library */
// TIFFTAG_OCE_SCANJOB_DESCRIPTION 50215  /* Used in the Oce scanning process */
// TIFFTAG_OCE_APPLICATION_SELECTOR 50216 /* Used in the Oce scanning process. */
// TIFFTAG_OCE_IDENTIFICATION_NUMBER 50217
// TIFFTAG_OCE_IMAGELOGIC_CHARACTERISTICS 50218
/* tags 50674 to 50677 are reserved for ESRI */
// TIFFTAG_LERC_PARAMETERS 50674 /* Stores LERC version and additional compression method */

/* Adobe Digital Negative (DNG) format tags */
// TIFFTAG_DNGVERSION 50706           /* &DNG version number */
// TIFFTAG_DNGBACKWARDVERSION 50707   /* &DNG compatibility version */
// TIFFTAG_UNIQUECAMERAMODEL 50708    /* &name for the camera model */
// TIFFTAG_LOCALIZEDCAMERAMODEL 50709 /* &localized camera model name (UTF-8) */
// TIFFTAG_CFAPLANECOLOR 50710        /* &CFAPattern->LinearRaw space mapping */
// TIFFTAG_CFALAYOUT 50711            /* &spatial layout of the CFA */
// TIFFTAG_LINEARIZATIONTABLE 50712   /* &lookup table description */
// TIFFTAG_BLACKLEVELREPEATDIM 50713  /* &repeat pattern size for the BlackLevel tag */
// TIFFTAG_BLACKLEVEL 50714           /* &zero light encoding level */
// TIFFTAG_BLACKLEVELDELTAH 50715     /* &zero light encoding level differences (columns) */
// TIFFTAG_BLACKLEVELDELTAV 50716     /* &zero light encoding level differences (rows) */
// TIFFTAG_WHITELEVEL 50717           /* &fully saturated encoding level */
// TIFFTAG_DEFAULTSCALE 50718         /* &default scale factors */
// TIFFTAG_DEFAULTCROPORIGIN 50719    /* &origin of the final image area */
// TIFFTAG_DEFAULTCROPSIZE 50720      /* &size of the final image area */
// TIFFTAG_COLORMATRIX1 50721         /* &XYZ->reference color space transformation matrix 1 */
// TIFFTAG_COLORMATRIX2 50722         /* &XYZ->reference color space transformation matrix 2 */
// TIFFTAG_CAMERACALIBRATION1 50723   /* &calibration matrix 1 */
// TIFFTAG_CAMERACALIBRATION2 50724   /* &calibration matrix 2 */
// TIFFTAG_REDUCTIONMATRIX1 50725     /* &dimensionality reduction matrix 1 */
// TIFFTAG_REDUCTIONMATRIX2 50726     /* &dimensionality reduction matrix 2 */
// TIFFTAG_ANALOGBALANCE 50727        /* &gain applied the stored raw values*/
// TIFFTAG_ASSHOTNEUTRAL 50728        /* &selected white balance in linear reference space */
// TIFFTAG_ASSHOTWHITEXY 50729        /* &selected white balance in x-y chromaticity coordinates */
// TIFFTAG_BASELINEEXPOSURE 50730     /* &how much to move the zero point */
// TIFFTAG_BASELINENOISE 50731        /* &relative noise level */
// TIFFTAG_BASELINESHARPNESS 50732    /* &relative amount of sharpening */
/* TIFFTAG_BAYERGREENSPLIT: &how closely the values of the green pixels in the blue/green rows
 * track the values of the green pixels in the red/green rows */
// TIFFTAG_BAYERGREENSPLIT 50733
// TIFFTAG_LINEARRESPONSELIMIT 50734     /* &non-linear encoding range */
// TIFFTAG_CAMERASERIALNUMBER 50735      /* &camera's serial number */
// TIFFTAG_LENSINFO 50736                /* info about the lens */
// TIFFTAG_CHROMABLURRADIUS 50737        /* &chroma blur radius */
// TIFFTAG_ANTIALIASSTRENGTH 50738       /* &relative strength of the camera's anti-alias filter */
// TIFFTAG_SHADOWSCALE 50739             /* &used by Adobe Camera Raw */
// TIFFTAG_DNGPRIVATEDATA 50740          /* &manufacturer's private data */
// TIFFTAG_MAKERNOTESAFETY 50741         /* &whether the EXIF MakerNote tag is safe to preserve along with the rest of the EXIF data */
// TIFFTAG_CALIBRATIONILLUMINANT1 50778  /* &illuminant 1 */
// TIFFTAG_CALIBRATIONILLUMINANT2 50779  /* &illuminant 2 */
// TIFFTAG_BESTQUALITYSCALE 50780        /* &best quality multiplier */
// TIFFTAG_RAWDATAUNIQUEID 50781         /* &unique identifier for the raw image data */
// TIFFTAG_ORIGINALRAWFILENAME 50827     /* &file name of the original raw file (UTF-8) */
// TIFFTAG_ORIGINALRAWFILEDATA 50828     /* &contents of the original raw file */
// TIFFTAG_ACTIVEAREA 50829              /* &active (non-masked) pixels of the sensor */
// TIFFTAG_MASKEDAREAS 50830             /* &list of coordinates of fully masked pixels */
// TIFFTAG_ASSHOTICCPROFILE 50831        /* &these two tags used to */
// TIFFTAG_ASSHOTPREPROFILEMATRIX 50832  /* map cameras's color space  into ICC profile space */
// TIFFTAG_CURRENTICCPROFILE 50833       /* & */
// TIFFTAG_CURRENTPREPROFILEMATRIX 50834 /* & */

/* DNG 1.2.0.0 */
// TIFFTAG_COLORIMETRICREFERENCE 50879       /* &colorimetric reference */
// TIFFTAG_CAMERACALIBRATIONSIGNATURE 50931  /* &camera calibration signature (UTF-8) */
// TIFFTAG_PROFILECALIBRATIONSIGNATURE 50932 /* &profile calibration signature (UTF-8) */
/* TIFFTAG_EXTRACAMERAPROFILES 50933 &extra camera profiles : is already defined for GeoTIFF DGIWG */
// TIFFTAG_ASSHOTPROFILENAME 50934           /* &as shot profile name (UTF-8) */
// TIFFTAG_NOISEREDUCTIONAPPLIED 50935       /* &amount of applied noise reduction */
// TIFFTAG_PROFILENAME 50936                 /* &camera profile name (UTF-8) */
// TIFFTAG_PROFILEHUESATMAPDIMS 50937        /* &dimensions of HSV mapping */
// TIFFTAG_PROFILEHUESATMAPDATA1 50938       /* &first HSV mapping table */
// TIFFTAG_PROFILEHUESATMAPDATA2 50939       /* &second HSV mapping table */
// TIFFTAG_PROFILETONECURVE 50940            /* &default tone curve */
// TIFFTAG_PROFILEEMBEDPOLICY 50941          /* &profile embedding policy */
// TIFFTAG_PROFILECOPYRIGHT 50942            /* &profile copyright information (UTF-8) */
// TIFFTAG_FORWARDMATRIX1 50964              /* &matrix for mapping white balanced camera colors to XYZ D50 */
// TIFFTAG_FORWARDMATRIX2 50965              /* &matrix for mapping white balanced camera colors to XYZ D50 */
// TIFFTAG_PREVIEWAPPLICATIONNAME 50966      /* &name of application that created preview (UTF-8) */
// TIFFTAG_PREVIEWAPPLICATIONVERSION 50967   /* &version of application that created preview (UTF-8) */
// TIFFTAG_PREVIEWSETTINGSNAME 50968         /* &name of conversion settings (UTF-8) */
// TIFFTAG_PREVIEWSETTINGSDIGEST 50969       /* &unique id of conversion settings */
// TIFFTAG_PREVIEWCOLORSPACE 50970           /* &preview color space */
// TIFFTAG_PREVIEWDATETIME 50971             /* &date/time preview was rendered */
// TIFFTAG_RAWIMAGEDIGEST 50972              /* &md5 of raw image data */
// TIFFTAG_ORIGINALRAWFILEDIGEST 50973       /* &md5 of the data stored in the OriginalRawFileData tag */
// TIFFTAG_SUBTILEBLOCKSIZE 50974            /* &subtile block size */
// TIFFTAG_ROWINTERLEAVEFACTOR 50975         /* &number of interleaved fields */
// TIFFTAG_PROFILELOOKTABLEDIMS 50981        /* &num of input samples in each dim of default "look" table */
// TIFFTAG_PROFILELOOKTABLEDATA 50982        /* &default "look" table for use as starting point */

/* DNG 1.3.0.0 */
// TIFFTAG_OPCODELIST1 51008  /* &opcodes that should be applied to raw image after reading */
// TIFFTAG_OPCODELIST2 51009  /* &opcodes that should be applied after mapping to linear reference */
// TIFFTAG_OPCODELIST3 51022  /* &opcodes that should be applied after demosaicing */
// TIFFTAG_NOISEPROFILE 51041 /* &noise profile */

/* DNG 1.4.0.0 */
// TIFFTAG_DEFAULTUSERCROP 51125              /* &default user crop rectangle in relative coords */
// TIFFTAG_DEFAULTBLACKRENDER 51110           /* &black rendering hint */
// TIFFTAG_BASELINEEXPOSUREOFFSET 51109       /* &baseline exposure offset */
// TIFFTAG_PROFILELOOKTABLEENCODING 51108     /* &3D LookTable indexing conversion */
// TIFFTAG_PROFILEHUESATMAPENCODING 51107     /* &3D HueSatMap indexing conversion */
// TIFFTAG_ORIGINALDEFAULTFINALSIZE 51089     /* &default final size of larger original file for this proxy */
// TIFFTAG_ORIGINALBESTQUALITYFINALSIZE 51090 /* &best quality final size of larger original file for this proxy */
// TIFFTAG_ORIGINALDEFAULTCROPSIZE 51091      /* &the default crop size of larger original file for this proxy */
// TIFFTAG_NEWRAWIMAGEDIGEST 51111            /* &modified MD5 digest of the raw image data */
// TIFFTAG_RAWTOPREVIEWGAIN 51112             /* &The gain between the main raw FD and the preview IFD containing this tag */

/* DNG 1.5.0.0 */
// TIFFTAG_DEPTHFORMAT 51177      /* &encoding of the depth data in the file */
// TIFFTAG_DEPTHNEAR 51178        /* &distance from the camera represented by value 0 in the depth map */
// TIFFTAG_DEPTHFAR 51179         /* &distance from the camera represented by the maximum value in the depth map */
// TIFFTAG_DEPTHUNITS 51180       /* &measurement units for DepthNear and DepthFar */
// TIFFTAG_DEPTHMEASURETYPE 51181 /* &measurement geometry for the depth map */
// TIFFTAG_ENHANCEPARAMS 51182    /* &a string that documents how the enhanced image data was processed. */

/* DNG 1.6.0.0 */
// TIFFTAG_PROFILEGAINTABLEMAP 52525    /* &spatially varying gain tables that can be applied as starting point */
// TIFFTAG_SEMANTICNAME 52526           /* &a string that identifies the semantic mask */
// TIFFTAG_SEMANTICINSTANCEID 52528     /* &a string that identifies a specific instance in a semantic mask */
// TIFFTAG_MASKSUBAREA 52536            /* &the crop rectangle of this IFD's mask, relative to the main image */
// TIFFTAG_RGBTABLES 52543              /* &color transforms to apply to masked image regions */
// TIFFTAG_CALIBRATIONILLUMINANT3 52529 /* &the illuminant used for the third set of color calibration tags */
// TIFFTAG_COLORMATRIX3 52531           /* &matrix to convert XYZ values to reference camera native color space under CalibrationIlluminant3 */
// TIFFTAG_CAMERACALIBRATION3 52530     /* &matrix to transform reference camera native space values to individual camera native space values under CalibrationIlluminant3 */
// TIFFTAG_REDUCTIONMATRIX3 52538       /* &dimensionality reduction matrix for use in color conversion to XYZ under CalibrationIlluminant3 */
// TIFFTAG_PROFILEHUESATMAPDATA3 52537  /* &the data for the third HSV table */
// TIFFTAG_FORWARDMATRIX3 52532         /* &matrix to map white balanced camera colors to XYZ D50 */
// TIFFTAG_ILLUMINANTDATA1 52533        /* &data for the first calibration illuminant */
// TIFFTAG_ILLUMINANTDATA2 52534        /* &data for the second calibration illuminant */
// TIFFTAG_ILLUMINANTDATA3 52535        /* &data for the third calibration illuminant */

/* TIFF/EP */
// TIFFTAG_EP_CFAREPEATPATTERNDIM 33421      /* dimensions of CFA pattern */
// TIFFTAG_EP_CFAPATTERN 33422               /* color filter array pattern */
// TIFFTAG_EP_BATTERYLEVEL 33423             /* battery level (rational or ASCII) */
// TIFFTAG_EP_INTERLACE 34857                /* Number of multi-field images */
/* TIFFTAG_EP_IPTC_NAA and TIFFTAG_RICHTIFFIPTC share the same tag number (33723)
 *   LibTIFF type is UNDEFINED or BYTE, but often times incorrectly specified as LONG,
 *   because TIFF/EP (ISO/DIS 12234-2) specifies type LONG or ASCII. */
// TIFFTAG_EP_IPTC_NAA 33723                 /* Alias IPTC/NAA Newspaper Association RichTIFF */
// TIFFTAG_EP_TIMEZONEOFFSET 34858           /* Time zone offset relative to UTC */
// TIFFTAG_EP_SELFTIMERMODE 34859            /* Number of seconds capture was delayed from button press */
// TIFFTAG_EP_FLASHENERGY 37387              /* Flash energy, or range if there is uncertainty */
// TIFFTAG_EP_SPATIALFREQUENCYRESPONSE 37388 /* Spatial frequency response */
// TIFFTAG_EP_NOISE 37389                    /* Camera noise measurement values */
// TIFFTAG_EP_FOCALPLANEXRESOLUTION 37390    /* Focal plane X resolution */
// TIFFTAG_EP_FOCALPLANEYRESOLUTION 37391    /* Focal plane Y resolution */
// TIFFTAG_EP_FOCALPLANERESOLUTIONUNIT 37392 /* Focal plane resolution unit */
// TIFFTAG_EP_IMAGENUMBER 37393              /* Number of image when several of burst shot stored in same TIFF/EP */
// TIFFTAG_EP_SECURITYCLASSIFICATION 37394   /* Security classification */
// TIFFTAG_EP_IMAGEHISTORY 37395             /* Record of what has been done to the image */
// TIFFTAG_EP_EXPOSUREINDEX 37397            /* Exposure index */
// TIFFTAG_EP_STANDARDID 37398               /* TIFF/EP standard version, n.n.n.n */
// TIFFTAG_EP_SENSINGMETHOD 37399            /* Type of image sensor */
/*
 * TIFF/EP tags equivalent to EXIF tags
 *     Note that TIFF-EP and EXIF use nearly the same metadata tag set, but TIFF-EP stores the tags in IFD 0,
 *     while EXIF store the tags in a separate IFD. Either location is allowed by DNG, but the EXIF location is preferred.
 */
// TIFFTAG_EP_EXPOSURETIME 33434             /* Exposure time */
// TIFFTAG_EP_FNUMBER 33437                  /* F number */
// TIFFTAG_EP_EXPOSUREPROGRAM 34850          /* Exposure program */
// TIFFTAG_EP_SPECTRALSENSITIVITY 34852      /* Spectral sensitivity */
// TIFFTAG_EP_ISOSPEEDRATINGS 34855          /* ISO speed rating */
// TIFFTAG_EP_OECF 34856                     /* Optoelectric conversion factor */
// TIFFTAG_EP_DATETIMEORIGINAL 36867         /* Date and time of original data generation */
// TIFFTAG_EP_COMPRESSEDBITSPERPIXEL 37122   /* Image compression mode */
// TIFFTAG_EP_SHUTTERSPEEDVALUE 37377        /* Shutter speed */
// TIFFTAG_EP_APERTUREVALUE 37378            /* Aperture */
// TIFFTAG_EP_BRIGHTNESSVALUE 37379          /* Brightness */
// TIFFTAG_EP_EXPOSUREBIASVALUE 37380        /* Exposure bias */
// TIFFTAG_EP_MAXAPERTUREVALUE 37381         /* Maximum lens aperture */
// TIFFTAG_EP_SUBJECTDISTANCE 37382          /* Subject distance */
// TIFFTAG_EP_METERINGMODE 37383             /* Metering mode */
// TIFFTAG_EP_LIGHTSOURCE 37384              /* Light source */
// TIFFTAG_EP_FLASH 37385                    /* Flash */
// TIFFTAG_EP_FOCALLENGTH 37386              /* Lens focal length */
// TIFFTAG_EP_SUBJECTLOCATION 37396          /* Subject location (area) */

// TIFFTAG_RPCCOEFFICIENT 50844       /* Define by GDAL for geospatial georeferencing through RPC: http://geotiff.maptools.org/rpc_prop.html */
// TIFFTAG_ALIAS_LAYER_METADATA 50784 /* Alias Sketchbook Pro layer usage description. */

/* GeoTIFF DGIWG */
// TIFFTAG_TIFF_RSID 50908           /* https://www.awaresystems.be/imaging/tiff/tifftags/tiff_rsid.html */
// TIFFTAG_GEO_METADATA 50909        /* https://www.awaresystems.be/imaging/tiff/tifftags/geo_metadata.html */
// TIFFTAG_EXTRACAMERAPROFILES 50933 /* http://wwwimages.adobe.com/www.adobe.com/content/dam/Adobe/en/products/photoshop/pdfs/dng_spec_1.4.0.0.pdf */

/* tag 65535 is an undefined tag used by Eastman Kodak */
// TIFFTAG_DCSHUESHIFTVALUES 65535 /* hue shift correction data */

/*
 * The following are ``pseudo tags'' that can be used to control
 * codec-specific functionality.  These tags are not written to file.
 * Note that these values start at 0xffff+1 so that they'll never
 * collide with Aldus-assigned tags.
 *
 * If you want your private pseudo tags ``registered'' (i.e. added to
 * this file), please post a bug report via the tracking system at
 * http://www.remotesensing.org/libtiff/bugs.html with the appropriate
 * C definitions to add.
 */
// TIFFTAG_FAXMODE 65536        /* Group 3/4 format control */
// FAXMODE_CLASSIC 0x0000       /* default, include RTC */
// FAXMODE_NORTC 0x0001         /* no RTC at end of data */
// FAXMODE_NOEOL 0x0002         /* no EOL code at end of row */
// FAXMODE_BYTEALIGN 0x0004     /* byte align row */
// FAXMODE_WORDALIGN 0x0008     /* word align row */
// FAXMODE_CLASSF FAXMODE_NORTC /* TIFF Class F */
// TIFFTAG_JPEGQUALITY 65537    /* Compression quality level */
/* Note: quality level is on the IJG 0-100 scale.  Default value is 75 */
// TIFFTAG_JPEGCOLORMODE 65538  /* Auto RGB<=>YCbCr convert? */
// JPEGCOLORMODE_RAW 0x0000     /* no conversion (default) */
// JPEGCOLORMODE_RGB 0x0001     /* do auto conversion */
// TIFFTAG_JPEGTABLESMODE 65539 /* What to put in JPEGTables */
// JPEGTABLESMODE_QUANT 0x0001  /* include quantization tbls */
// JPEGTABLESMODE_HUFF 0x0002   /* include Huffman tbls */
/* Note: default is JPEGTABLESMODE_QUANT | JPEGTABLESMODE_HUFF */
// TIFFTAG_FAXFILLFUNC 65540     /* G3/G4 fill function */
// TIFFTAG_PIXARLOGDATAFMT 65549 /* PixarLogCodec I/O data sz */
// PIXARLOGDATAFMT_8BIT 0        /* regular u_char samples */
// PIXARLOGDATAFMT_8BITABGR 1    /* ABGR-order u_chars */
// PIXARLOGDATAFMT_11BITLOG 2    /* 11-bit log-encoded (raw) */
// PIXARLOGDATAFMT_12BITPICIO 3  /* as per PICIO (1.0==2048) */
// PIXARLOGDATAFMT_16BIT 4       /* signed short samples */
// PIXARLOGDATAFMT_FLOAT 5       /* IEEE float samples */
/* 65550-65556 are allocated to Oceana Matrix <dev@oceana.com> */
// TIFFTAG_DCSIMAGERTYPE 65550     /* imager model & filter */
// DCSIMAGERMODEL_M3 0             /* M3 chip (1280 x 1024) */
// DCSIMAGERMODEL_M5 1             /* M5 chip (1536 x 1024) */
// DCSIMAGERMODEL_M6 2             /* M6 chip (3072 x 2048) */
// DCSIMAGERFILTER_IR 0            /* infrared filter */
// DCSIMAGERFILTER_MONO 1          /* monochrome filter */
// DCSIMAGERFILTER_CFA 2           /* color filter array */
// DCSIMAGERFILTER_OTHER 3         /* other filter */
// TIFFTAG_DCSINTERPMODE 65551     /* interpolation mode */
// DCSINTERPMODE_NORMAL 0x0        /* whole image, default */
// DCSINTERPMODE_PREVIEW 0x1       /* preview of image (384x256) */
// TIFFTAG_DCSBALANCEARRAY 65552   /* color balance values */
// TIFFTAG_DCSCORRECTMATRIX 65553  /* color correction values */
// TIFFTAG_DCSGAMMA 65554          /* gamma value */
// TIFFTAG_DCSTOESHOULDERPTS 65555 /* toe & shoulder points */
// TIFFTAG_DCSCALIBRATIONFD 65556  /* calibration file desc */
/* Note: quality level is on the ZLIB 1-9 scale. Default value is -1 */
// TIFFTAG_ZIPQUALITY 65557      /* compression quality level */
// TIFFTAG_PIXARLOGQUALITY 65558 /* PixarLog uses same scale */
/* 65559 is allocated to Oceana Matrix <dev@oceana.com> */
// TIFFTAG_DCSCLIPRECTANGLE 65559 /* area of image to acquire */
// TIFFTAG_SGILOGDATAFMT 65560    /* SGILog user data format */
// SGILOGDATAFMT_FLOAT 0          /* IEEE float samples */
// SGILOGDATAFMT_16BIT 1          /* 16-bit samples */
// SGILOGDATAFMT_RAW 2            /* uninterpreted data */
// SGILOGDATAFMT_8BIT 3           /* 8-bit RGB monitor values */
// TIFFTAG_SGILOGENCODE 65561     /* SGILog data encoding control*/
// SGILOGENCODE_NODITHER 0        /* do not dither encoded values*/
// SGILOGENCODE_RANDITHER 1       /* randomly dither encd values */
// TIFFTAG_LZMAPRESET 65562       /* LZMA2 preset (compression level) */
// TIFFTAG_PERSAMPLE 65563        /* interface for per sample tags */
// PERSAMPLE_MERGED 0             /* present as a single value */
// PERSAMPLE_MULTI 1              /* present as multiple values */
// TIFFTAG_ZSTD_LEVEL 65564       /* ZSTD compression level */
// TIFFTAG_LERC_VERSION 65565     /* LERC version */
// LERC_VERSION_2_4 4
// TIFFTAG_LERC_ADD_COMPRESSION 65566 /* LERC additional compression */
// LERC_ADD_COMPRESSION_NONE 0
// LERC_ADD_COMPRESSION_DEFLATE 1
// LERC_ADD_COMPRESSION_ZSTD 2
// TIFFTAG_LERC_MAXZERROR 65567   /* LERC maximum error */
// TIFFTAG_WEBP_LEVEL 65568       /* WebP compression level */
// TIFFTAG_WEBP_LOSSLESS 65569    /* WebP lossless/lossy */
// TIFFTAG_WEBP_LOSSLESS_EXACT 65571  /* WebP lossless exact mode. Set-only mode. Default is 1. Can be set to 0 to increase compression rate, but R,G,B in areas where alpha = 0 will not be preserved */
// TIFFTAG_DEFLATE_SUBCODEC 65570 /* ZIP codec: to get/set the sub-codec to use. Will default to libdeflate when available */
// DEFLATE_SUBCODEC_ZLIB 0
// DEFLATE_SUBCODEC_LIBDEFLATE 1

/*
 * EXIF tags
 */
// #define EXIFTAG_EXPOSURETIME 33434             /* Exposure time */
// #define EXIFTAG_FNUMBER 33437                  /* F number */
// #define EXIFTAG_EXPOSUREPROGRAM 34850          /* Exposure program */
// #define EXIFTAG_SPECTRALSENSITIVITY 34852      /* Spectral sensitivity */
// /* After EXIF 2.2.1 ISOSpeedRatings is named PhotographicSensitivity.
//    In addition, while "Count=Any", only 1 count should be used. */
// #define EXIFTAG_ISOSPEEDRATINGS 34855          /* ISO speed rating */
// #define EXIFTAG_PHOTOGRAPHICSENSITIVITY 34855  /* Photographic Sensitivity (new name for tag 34855) */
// #define EXIFTAG_OECF 34856                     /* Optoelectric conversion factor */
// #define EXIFTAG_EXIFVERSION 36864              /* Exif version */
// #define EXIFTAG_DATETIMEORIGINAL 36867         /* Date and time of original data generation */
// #define EXIFTAG_DATETIMEDIGITIZED 36868        /* Date and time of digital data generation */
// #define EXIFTAG_COMPONENTSCONFIGURATION 37121  /* Meaning of each component */
// #define EXIFTAG_COMPRESSEDBITSPERPIXEL 37122   /* Image compression mode */
// #define EXIFTAG_SHUTTERSPEEDVALUE 37377        /* Shutter speed */
// #define EXIFTAG_APERTUREVALUE 37378            /* Aperture */
// #define EXIFTAG_BRIGHTNESSVALUE 37379          /* Brightness */
// #define EXIFTAG_EXPOSUREBIASVALUE 37380        /* Exposure bias */
// #define EXIFTAG_MAXAPERTUREVALUE 37381         /* Maximum lens aperture */
// #define EXIFTAG_SUBJECTDISTANCE 37382          /* Subject distance */
// #define EXIFTAG_METERINGMODE 37383             /* Metering mode */
// #define EXIFTAG_LIGHTSOURCE 37384              /* Light source */
// #define EXIFTAG_FLASH 37385                    /* Flash */
// #define EXIFTAG_FOCALLENGTH 37386              /* Lens focal length */
// #define EXIFTAG_SUBJECTAREA 37396              /* Subject area */
// #define EXIFTAG_MAKERNOTE 37500                /* Manufacturer notes */
// #define EXIFTAG_USERCOMMENT 37510              /* User comments */
// #define EXIFTAG_SUBSECTIME 37520               /* DateTime subseconds */
// #define EXIFTAG_SUBSECTIMEORIGINAL 37521       /* DateTimeOriginal subseconds */
// #define EXIFTAG_SUBSECTIMEDIGITIZED 37522      /* DateTimeDigitized subseconds */
// #define EXIFTAG_FLASHPIXVERSION 40960          /* Supported Flashpix version */
// #define EXIFTAG_COLORSPACE 40961               /* Color space information */
// #define EXIFTAG_PIXELXDIMENSION 40962          /* Valid image width */
// #define EXIFTAG_PIXELYDIMENSION 40963          /* Valid image height */
// #define EXIFTAG_RELATEDSOUNDFILE 40964         /* Related audio file */
// #define EXIFTAG_FLASHENERGY 41483              /* Flash energy */
// #define EXIFTAG_SPATIALFREQUENCYRESPONSE 41484 /* Spatial frequency response */
// #define EXIFTAG_FOCALPLANEXRESOLUTION 41486    /* Focal plane X resolution */
// #define EXIFTAG_FOCALPLANEYRESOLUTION 41487    /* Focal plane Y resolution */
// #define EXIFTAG_FOCALPLANERESOLUTIONUNIT 41488 /* Focal plane resolution unit */
// #define EXIFTAG_SUBJECTLOCATION 41492          /* Subject location */
// #define EXIFTAG_EXPOSUREINDEX 41493            /* Exposure index */
// #define EXIFTAG_SENSINGMETHOD 41495            /* Sensing method */
// #define EXIFTAG_FILESOURCE 41728               /* File source */
// #define EXIFTAG_SCENETYPE 41729                /* Scene type */
// #define EXIFTAG_CFAPATTERN 41730               /* CFA pattern */
// #define EXIFTAG_CUSTOMRENDERED 41985           /* Custom image processing */
// #define EXIFTAG_EXPOSUREMODE 41986             /* Exposure mode */
// #define EXIFTAG_WHITEBALANCE 41987             /* White balance */
// #define EXIFTAG_DIGITALZOOMRATIO 41988         /* Digital zoom ratio */
// #define EXIFTAG_FOCALLENGTHIN35MMFILM 41989    /* Focal length in 35 mm film */
// #define EXIFTAG_SCENECAPTURETYPE 41990         /* Scene capture type */
// #define EXIFTAG_GAINCONTROL 41991              /* Gain control */
// #define EXIFTAG_CONTRAST 41992                 /* Contrast */
// #define EXIFTAG_SATURATION 41993               /* Saturation */
// #define EXIFTAG_SHARPNESS 41994                /* Sharpness */
// #define EXIFTAG_DEVICESETTINGDESCRIPTION 41995 /* Device settings description */
// #define EXIFTAG_SUBJECTDISTANCERANGE 41996     /* Subject distance range */
// #define EXIFTAG_IMAGEUNIQUEID 42016            /* Unique image ID */

/*--: New for EXIF-Version 2.32, May 2019 ... */
// EXIFTAG_SENSITIVITYTYPE 34864           /* The SensitivityType tag indicates which one of the parameters of ISO12232 is the PhotographicSensitivity tag. */
// EXIFTAG_STANDARDOUTPUTSENSITIVITY 34865 /* This tag indicates the standard output sensitivity value of a camera or input device defined in ISO 12232. */
// EXIFTAG_RECOMMENDEDEXPOSUREINDEX 34866  /* recommended exposure index   */
// EXIFTAG_ISOSPEED 34867                  /* ISO speed value */
// EXIFTAG_ISOSPEEDLATITUDEYYY 34868       /* ISO speed latitude yyy */
// EXIFTAG_ISOSPEEDLATITUDEZZZ 34869       /* ISO speed latitude zzz */
// EXIFTAG_OFFSETTIME 36880                /* offset from UTC of the time of DateTime tag. */
// EXIFTAG_OFFSETTIMEORIGINAL 36881        /* offset from UTC of the time of DateTimeOriginal tag. */
// EXIFTAG_OFFSETTIMEDIGITIZED 36882       /* offset from UTC of the time of DateTimeDigitized tag. */
// EXIFTAG_TEMPERATURE 37888               /* Temperature as the ambient situation at the shot in dergee Celsius */
// EXIFTAG_HUMIDITY 37889                  /* Humidity as the ambient situation at the shot in percent */
// EXIFTAG_PRESSURE 37890                  /* Pressure as the ambient situation at the shot hecto-Pascal (hPa) */
// EXIFTAG_WATERDEPTH 37891                /* WaterDepth as the ambient situation at the shot in meter (m) */
// EXIFTAG_ACCELERATION 37892              /* Acceleration (a scalar regardless of direction) as the ambientsituation at the shot in units of mGal (10-5 m/s^2) */
/* EXIFTAG_CAMERAELEVATIONANGLE: Elevation/depression. angle of the orientation of the  camera(imaging optical axis)
 *                               as the ambient situation at the shot in degree from -180deg to +180deg. */
// EXIFTAG_CAMERAELEVATIONANGLE 37893
// EXIFTAG_CAMERAOWNERNAME 42032  /* owner of a camera */
// EXIFTAG_BODYSERIALNUMBER 42033 /* serial number of the body of the camera */
/* EXIFTAG_LENSSPECIFICATION: minimum focal length (in mm), maximum focal length (in mm),minimum F number in the minimum focal length,
 *                            and minimum F number in the maximum focal length, */
// EXIFTAG_LENSSPECIFICATION 42034
// EXIFTAG_LENSMAKE 42035                            /* the lens manufacturer */
// EXIFTAG_LENSMODEL 42036                           /* the lens model name and model number */
// EXIFTAG_LENSSERIALNUMBER 42037                    /* the serial number of the interchangeable lens */
// EXIFTAG_GAMMA 42240                               /* value of coefficient gamma */
// EXIFTAG_COMPOSITEIMAGE 42080                      /* composite image */
// EXIFTAG_SOURCEIMAGENUMBEROFCOMPOSITEIMAGE 42081   /* source image number of composite image */
// EXIFTAG_SOURCEEXPOSURETIMESOFCOMPOSITEIMAGE 42082 /* source exposure times of composite image */

/*
 * EXIF-GPS tags  (Version 2.31, July 2016)
 */
// GPSTAG_VERSIONID 0             /* Indicates the version of GPSInfoIFD. */
// GPSTAG_LATITUDEREF 1           /* Indicates whether the latitude is north or south latitude. */
// GPSTAG_LATITUDE 2              /* Indicates the latitude. */
// GPSTAG_LONGITUDEREF 3          /* Indicates whether the longitude is east or west longitude. */
// GPSTAG_LONGITUDE 4             /* Indicates the longitude. */
// GPSTAG_ALTITUDEREF 5           /* Indicates the altitude used as the reference altitude. */
// GPSTAG_ALTITUDE 6              /* Indicates the altitude based on the reference in GPSAltitudeRef. */
// GPSTAG_TIMESTAMP 7             /*Indicates the time as UTC (Coordinated Universal Time). */
// GPSTAG_SATELLITES 8            /*Indicates the GPS satellites used for measurements. */
// GPSTAG_STATUS 9                /* Indicates the status of the GPS receiver when the image is  recorded. */
// GPSTAG_MEASUREMODE 10          /* Indicates the GPS measurement mode. */
// GPSTAG_DOP 11                  /* Indicates the GPS DOP (data degree of precision). */
// GPSTAG_SPEEDREF 12             /* Indicates the unit used to express the GPS receiver speed of movement. */
// GPSTAG_SPEED 13                /* Indicates the speed of GPS receiver movement. */
// GPSTAG_TRACKREF 14             /* Indicates the reference for giving the direction of GPS receiver movement. */
// GPSTAG_TRACK 15                /* Indicates the direction of GPS receiver movement. */
// GPSTAG_IMGDIRECTIONREF 16      /* Indicates the reference for giving the direction of the image when it is captured. */
// GPSTAG_IMGDIRECTION 17         /* Indicates the direction of the image when it was captured. */
// GPSTAG_MAPDATUM 18             /* Indicates the geodetic survey data used by the GPS receiver. (e.g. WGS-84) */
// GPSTAG_DESTLATITUDEREF 19      /* Indicates whether the latitude of the destination point is north or south latitude. */
// GPSTAG_DESTLATITUDE 20         /* Indicates the latitude of the destination point. */
// GPSTAG_DESTLONGITUDEREF 21     /* Indicates whether the longitude of the destination point is east or west longitude. */
// GPSTAG_DESTLONGITUDE 22        /* Indicates the longitude of the destination point. */
// GPSTAG_DESTBEARINGREF 23       /* Indicates the reference used for giving the bearing to the destination point. */
// GPSTAG_DESTBEARING 24          /* Indicates the bearing to the destination point. */
// GPSTAG_DESTDISTANCEREF 25      /* Indicates the unit used to express the distance to the destination point. */
// GPSTAG_DESTDISTANCE 26         /* Indicates the distance to the destination point. */
// GPSTAG_PROCESSINGMETHOD 27     /* A character string recording the name of the method used for location finding. */
// GPSTAG_AREAINFORMATION 28      /* A character string recording the name of the GPS area. */
// GPSTAG_DATESTAMP 29            /* A character string recording date and time information relative to UTC (Coordinated Universal Time). */
// GPSTAG_DIFFERENTIAL 30         /* Indicates whether differential correction is applied to the GPS receiver. */
// GPSTAG_GPSHPOSITIONINGERROR 31 /* Indicates horizontal positioning errors in meters. */