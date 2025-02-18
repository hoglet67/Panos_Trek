## Getting files into (or out of) b-em

As a first step to build software in Panos, it's necessary to get source files into the emulator. This can be done by using an SSD file to shuttle source files onto a b-em SCSI hard disk image. SSDs are 200K floppy images; 80 track single sided single density. There is a free tool that makes this more-or-less convenient:

####
    Beeb Utilities to manipulate MMB and SSD files
    Copyright (C) 2012-2015 Stephen Harris
    https://sweh.spuddy.org/Beeb/mmb_utils.html

This is a set of Perl programs. Usage (in Cygwin or Msys on Windows; or in Linux):

In the directory into which you've extracted the mmb_utils Perl files, create a blank SSD image; e.g.:

####
    $ ./beeb blank_ssd xfer.ssd
    $
    $ beeb info xfer.ssd
    Disk title:  (1)  Disk size: &320 - 200K
    Boot Option: 0 (None)   File count: 0

    Filename:  Lck Lo.add Ex.add Length Sct
    $

Copy file(s) to be put onto the floppy into the mmb_utils directory as well (but with **short** names and no special characters; e.g., "cp trekcom-f77 ../mmb_utils/trekcom"). Then copy the file onto the floppy image:

####
    $ ./beeb putfile xfer.ssd trekcom
    $
    $ beeb info xfer.ssd
    Disk title:  (1)  Disk size: &320 - 200K
    Boot Option: 0 (None)   File count: 1

    Filename:  Lck Lo.add Ex.add Length Sct
    $.trekcom      000000 000000 00108B 002
    $

It is possible to put more than one file on the SSD floppy image, within the limits of the 200K disk capacity.

A file can also be extracted from a floppy image:

####
    $ beeb getfile xfer.ssd xfer
    Saving $.trekcom as trekcom
    $

This creates a directory (here specified as "xfer") and puts **all** files from the floppy into it.

You have to delete the directory first if it already exists:

####
    $ beeb getfile xfer.ssd xfer
    xfer already exists
    $

Finally, this is how you delete a file on the floppy image (which is necessary before you can add a file with the same name):

####
    $ beeb delete xfer.ssd trekcom
    Delete? $.trekcom (Y/N) y
    $

In Panos (after "inserting" xfer.ssd into b-em via "Disc->Load disk 0/2..."), you can now see the file on the floppy image, copy it to a hard disk, and add the desired extension back to the file name:

####
    -> cat dfs::0
    trekcom
    1 file catalogued
    ->
    -> copy dfs::0.trekcom trekcom-f77 -force
    dfs::0.trekcom copied to trekcom-f77 (4125 bytes)
    1 file copied
    ->

NOTE: The "-force" option is required if the destination file specified by the "copy" command already exists.

In the b-em menu, "Disc->Write protect disc :0/2..." must be unchecked if you want (in Panos) to delete anything from the inserted floppy or copy anything back to it. Otherwise, you'll get an error:

####
    -> delete dfs::0.trekcom
    Delete 'dfs::0.trekcom'? (Y/N) : y
    Error in delete : trying to delete 'dfs::0.trekcom'
                    : Disc read only: dfs::0.trekcom, detected by 'BBC'
    ->

(But the floppies are unprotected by default in the configuration file.)

And don't forget to eject the drive ("Eject disc :0/2"). Presumably that guarantees any changes have been flushed.

NOTE: Independently of disk capacity, there is a limit on the number of files **with the same extension** (not the number of files per se, or the total size of the files) that an ADFS directory can contain, which is why the Super Star Trek source and object files have had to be split among Trek_src/Trek_src1 and Trek_aof/Trek_aof1 directories. The limit seems to be 47 *-f77 or *-aof files in a single directory. (A DFS floppy also has an upper limit of 31 on the number of files that can be "catalogued".)

## General examples of building software from source code (featuring the Panos test software)

There is a set of "Hello world" test programs for each of the supported languages (Fortran 77, C, Pascal, Lisp, and the Asm32 32000 assembler) in adfs::0.$.PanosTests:

####
    -> cat adfs::0.$.PanosTests
    aWorld-asm  cCheck-cmd  check-cmd   cworld-aof  cWorld-c    cworld-rif
    fCheck-cmd  fWorld-f77  lCheck-cmd  lworld-lsp  pCheck-cmd  pworld-aof
    pWorld-pas  pworld-rif
    14 files catalogued
    ->

The files with extensions -f77 -c -pas -lsp -asm are source files in the above languages, respectively. The files with extension -aof (Acorn object file) are object files produced by a compiler for one of the source languages. The files with extension -rif (relocatable image file) are executable files produced by the linker.

To compile fWorld-f77:

####
    -> dir adfs::2.$
    adfs::2.$
    ->
    -> copy adfs::0.$.PanosTests.fWorld-f77 fWorld-f77
    adfs::0.$.PanosTests.fWorld-f77 copied to fWorld-f77 (128 bytes)
    1 file copied
    ->
    -> f77 fWorld
    $ f77fe fWorld-f77   -opt +
    Program    WORLD Compiled

    Total workspace used 5480
    $ f77cg fWorld-f77 -opt + -aof
    Main program (WORLD): code 70; data 20
    Total code size: 70; data size: 20
    [[[ End of command file 'PanosLib:f77-cmd' ]]]
    ->

The above command invokes command file "adfs::0.$.PanosLib.f77-cmd", which in turn creates object file "fWorld-aof" by running two executables in succession: the Fortran 77 "front end" ("adfs::0.$.PanosLib.f77fe-rif"), followed by the Fortran 77 "code generator" ("adfs::0.$.PanosLib.f77cg-rif"). In both cases in the above example, "-opt +" is an empty set of options. Data is passed between the F77 front end and the F77 code generator via a temporary file "fcode-tmp" which is automatically deleted by the code generator. The "-aof" option to the code generator is also empty in this case, but could be used to specify the name of the object file to be created (and thus override the default "fWorld-aof").

To create the executable ("relocatable image") file "fWorld-rif" from the object file, run the linker. The first argument is the name of the object file (the "-aof" extension of the object file is implied and may be omitted) and the second argument is the name of the required runtime library "adfs::0.$.PanosLib.f77-lib" (both the path and the "-lib" extension of the runtime library file are implied and may be omitted).

####
    -> cat
    fWorld-aof  fWorld-f77
    2 files catalogued
    ->
    -> link fWorld f77
    ->
    -> cat
    fWorld-aof  fWorld-f77  fWorld-rif
    3 files catalogued
    ->

To run the executable created from fWorld-f77:

####
    -> fWorld
    Hello Fortran world

    STOP

    ->

One quirk with C is that you have to link with the Pascal library as well as the C library:

####
    -> dir
    adfs::2.$
    -> copy adfs::0.$.PanosTests.cWorld-c cWorld-c
    adfs::0.$.PanosTests.cWorld-c copied to cWorld-c (80 bytes)
    1 file copied
    ->
    -> cc cWorld
    Product:CC_NS32016, Version:cc version 1.6
    ->
    -> link cWorld c
    * Error: no definition found for code symbol "IMP_CONDITION_HANDLER",
             referenced from module "C_HANDLER" in file
             "adfs::0.$.PanosLib.c-lib"
    * Error: no definition found for code symbol "IMP___SIGNAL", reference from
             module "C_DOPRNT" in file "adfs::0.$.PanosLib.c-lib"
    +++ Error -64
    ->
    -> link cWorld c,pas
    ->
    -> cat
    cWorld-aof  cWorld-c    cWorld-rif
    3 files catalogued
    ->
    -> cWorld
    hello c world
    ->

## Building (or rebuilding) Super Star Trek from source

With the the Beeb Utilities described above you can use a floppy image to transfer source files (from the "Panos_code" subdirectory) from the host system to the Panos hard disk. (Remember: In Panos, the "-force" option is required if the destination file specified by the "copy" command already exists.)

TO REPEAT: Independently of disk capacity, there is a limit on the number of files **with the same extension** (not the number of files per se, or the total size of the files) that an ADFS directory can contain, which is why the Super Star Trek source and object files have had to be split among Trek_src/Trek_src1 and Trek_aof/Trek_aof1 directories. The limit seems to be 47 *-f77 or *-aof files in a single directory. (A DFS floppy also has an upper limit of 31 on the number of files that can be "catalogued".)

These are Panos command files to recompile and/or rebuild the Super Star Trek executable:

####
    adfs::1.$.Trek_src.comp-cmd        Compile (only) a given *-f77 source file
                                       and move the *-aof to adfs::1.$.Trek_aof

    adfs::1.$.Trek_src.do-cmd          As above, but also re-link the executable

    adfs::1.$.Trek_src1.comp1-cmd      Both as above, but for
    adfs::1.$.Trek_src1.do1-cmd        adfs::1.$.Trek_src1/adfs::1.$.Trek_aof1

    adfs::1.$.Trek_src1.helpcomp-cmd   Re-compile/re-assemble (only)
                                       helpers-c and ihelp-asm, and copy
                                       the *-aof to adfs::1.$.Trek_aof1

    adfs::1.$.Trek_src1.dohelp-cmd     As above, but also re-link the executable

    adfs::1.$.Trek_rif.buildall-cmd    Re-compile all source files, and
                                       re-link the executable

There is also a control file "adfs::1.$.Trek_rif.trek-lnk" used to specify the object files and libraries input to the linker in the final step to create the executable:

####
    -> copy adfs::1.$.Trek_rif.trek-lnk
    -Object adfs::1.$.Trek_aof.trtrek-aof,
    adfs::1.$.Trek_aof.traband-aof,
    adfs::1.$.Trek_aof.trattak-aof,
    . . .
    adfs::1.$.Trek_aof1.trwarp-aof,
    adfs::1.$.Trek_aof1.trzap-aof,
    adfs::1.$.Trek_aof1.trekblk-aof
    adfs::1.$.Trek_aof1.helpers-aof
    adfs::1.$.Trek_aof1.ihelp-aof
    -Library f77,ifp,c,pas

The link command specifies both the control file (the "-lnk" extension is implied and may be omitted) and the executable (image) file name (again, the "-rif" extension is implied and may be omitted).

####
    -> link -via trek -image trtrek

The "ifp" library specified in the "-Library" option in the "trek-lnk" linker control file provides the system subroutines IFXSETRANDOMSEED, IFXRANDOM, IFXBINARYTIME, and IFTEXTUALTIMEOFBINARYTIME.

There are two non-Fortran source files, one C and one Asm32, which became necessary (mostly because of issues related to the mixing of CHARACTER and Hollerith data; see below for details) in the course of porting Super Star Trek to Panos Fortran 77: "adfs::1.$.Trek_src1.helpers-c" and "adfs::1.$.ihelp-asm". The assembly-language file is an interface which allows the subroutines provided by the C source file to be called from Fortran. The addition of the C source file requires the "c,pas" libraries to be added to the "-Library" option in "trek-lnk".

## Notes on porting the VAX Super Star Trek code to Panos Fortran 77

In early 2016, source code for a VAX Fortran version of the University of Texas "Super Star Trek" was obtained with the intention of porting it to an emulator of the Xerox Sigma 7 running CP-V. That ported version is now available on-line at:
https://github.com/kenrector/sigma-cpv-kit/tree/main/games/Super_Star_trek_(FORTRAN)

In early 2022, this CP-V port was used as a baseline for a port to Panos Fortran 77 in b-em. This was a convenient starting-point: all TABs had been converted to spaces, the file names had already been shortened, and it's probably already closer to standard Fortran 77 (doesn't have "BYTE" declarations, for example). Also, the large blank COMMON block in the VAX source had been converted to two smaller named COMMON blocks ("BLANCA", "BLANCB").

The following is a list of additional modifications that had to be made to satisfy Panos Fortran 77.

-- When compiling a Super Star Trek Fortran 77 source file (and in the *-cmd build command files), supply compiler option "6" to enable Fortran 66 features:

####
    f77 trtrek -list errs -opt +6

Among other things, this activates the "+H" option, which (to quote the manual) "allows Hollerith constants to be used in DATA statements to initialise non-CHARACTER variables (e.g. INTEGER)", and also allows using Hollerith constants as arguments in CALLs to PROUT.

This permitted reversion of an ugly fix in the Sigma port where initialization of alphanumeric data in the HOLLER common block with Hollerith constants had to use numbers (EBCDIC codes) instead.

-- Use logical unit number "*" to read from the keyboard or write to the screen; e.g.:

####
          WRITE(101,10)
    10    FORMAT(' HELLO WORLD!')

    becomes

          WRITE(*,10)
    10    FORMAT(' HELLO WORLD!')

-- The PARAMETER statement can't be used. The PARAMETERs "COMSIZA", "COMSIZB" for the COMMON block sizes have been converted to:

####
    in trekcom-f77:

    INTEGER COMSZA,COMSZB
    COMMON/COMSZAB/COMSZA,COMSZB

    in trekblk-f77:

    DATA COMSZA/831/
    DATA COMSZB/60/

NOTE: The sizes of the two big common blocks ("BLANCA", "BLANCB") are specified as INTEGER-array equivalents (i.e. total_bytes/4). These numbers are used when an in-progress game is saved to or restored from a file ("EMEXIT" in "tremexi-f77", "FREEZE" in "trfreez-f77", "THAW" in "trthaw-f77").

Comments in the original VAX Fortran file "TREKCOM.FOR" claim:
    
####
    C       THE PARAMETER COMSIZE DEFINES THE SIZE OF THE COMMON
    C       IN STORAGE ELEMENTS.  IT MAY NEED TO BE CHANGED IF THINGS ARE
    C       ADDED TO THE COMMON IN ORDER TO MAKE FREEZE AND THAW
    C       WORK PROPERLY.  ALWAYS MAKE SURE THAT THE SIZE OF THE
    C       ARRAY ICOM IS THE SAME AS THE SIZE OF BLANK COMMON.
    C       IF THEY ARE NOT THE SAME SIZE, CHANGE COMSIZE APPROPRIATELY.
    C
            PARAMETER COMSIZE=1222
    
This number is used to dimension an integer array used for saving ("freezing") and restoring ("thawing") the state of an in-progress game by writing or reading, respectively, a save file:
    
####
            INTEGER ICOM(COMSIZE)
            EQUIVALENCE (ICOM,SNAP)
    
The actual byte count of blank COMMON in this file is:
    
####
    Original VAX Fortran, blank COMMON
    ("TREKCOM.FOR"), line-by-line byte totals:
    
     1. 908       COMMON SNAP,SNAPSHT(226),
     2.  32      1   DATE,REMKL,REMCOM,REMBASE,REMRES,REMTIME,STARKL,BASEKL,
     3. 384      2   KILLK,KILLC,GALAXY(8,8),CX(10),CY(10),BASEQX(5),BASEQY(5),
     4. 476      3   NEWSTUF(8,8),PLNETS(10,5),ISX,ISY,NSCREM,NROMKL,NROMREM,
     5.  12      4   NSCKILL,ICRYSTL,NPLANKL,
     6. 500      5   QUAD(10,10),KX(20),KY(20),KPOWER(20),KDIST(20),KSTUF(20),
     7.  32      6   INKLING,INBASE,INRESOR,INCOM,INTIME,INSTAR,INENRG,INSHLD,
     8.  36      7   INTORPS,INLSR,INDATE,ENERGY,SHLD,SHLDUP,CONDIT,TORPS,SHIP,
     9. 108      8   QUADX,QUADY,SECTX,SECTY,WARPFAC,WFACSQ,LSUPRES,DAMAGE(20),
    10.  40      9   LENGTH,SKILL,PASSWD,DIST,DIREC,TIME,BASEX,BASEY,DOCKFAC,
    11. 316      1   KLHERE,COMHERE,CASUAL,NHELP,NKINKS,STARCH(8,8),FUTURE(10),
    12. 248      2   DEVICE(2,14),IDIDIT,GAMEWON,ALIVE,JUSTIN,RESTING,ALLDONE,
    13.  32      3   DAMFAC,SHLDCHG,THINGX,THINGY,NDEVICE,PLNETX,PLNETY,INORBIT,
    14.  36      4   LANDED,IPLANET,IMINE,INPLAN,NENHERE,ISHERE,NEUTZ,IRHERE,ICRAFT,
    15.  36      5   IENTESC,ISCRAFT,ISATB,ISCATE,CRYPROB,ICITE,IPHWHO,BATX,BATY,
    16.  48      6   CRACKS(12),
    17.  12      7   ICSOS,ISSOS,ISUBDAM
    -----------
       3256 / 4 = 814 4-byte integer-equivalents
    
So it would seem that an array of 1222 4-byte integers equivalenced to blank COMMON in the original VAX Fortran file "TREKCOM.FOR" goes some way beyond the end of that COMMON block (though this "generosity" doesn't seem to cause any problems).
    
However, for the Sigma/CP-V port, the sizes of the save/restore integer arrays were restricted to the actual sizes of the two COMMON blocks that the original blank COMMON was split into ("BLANCA" and "BLANCB"):
    
####
          PARAMETER COMSIZA=859
          . . .
          PARAMETER COMSIZB=60
          . . .
          INTEGER ICOMA(COMSIZA)
          EQUIVALENCE (ICOMA,SNAPA)
          INTEGER ICOMB(COMSIZB)
          EQUIVALENCE (ICOMB,SNAPB)
    
The actual byte count of "COMMON/BLANCA/" in the Sigma/CP-V F77 file "F7:TREKCOM" is:
    
####
    Sigma/CP-V Fortran 77, COMMON/BLANCA/
    (F7:TREKCOM), line-by-line byte totals:
    
     1. 908      COMMON/BLANCA/SNAPA,SNAPSHT(226),
     2.  32     1   DATE,REMKL,REMCOM,REMBASE,REMRES,REMTIME,STARKL,BASEKL,
     3. 384     2   KILLK,KILLC,GALAXY(8,8),CX(10),CY(10),BASEQX(5),BASEQY(5),
     4. 476     3   NEWSTUF(8,8),PLNETS(10,5),ISX,ISY,NSCREM,NROMKL,NROMREM,
     5.  12     4   NSCKILL,ICRYSTL,NPLANKL,
     6. 560     5   QUAD(10,10),KX(20),KY(20),
     7. 240     6   KPOWER(20),KDIST(20),KSTUF(20),
     8.  32     7   INKLING,INBASE,INRESOR,INCOM,INTIME,INSTAR,INENRG,INSHLD,
     9.  36     8   INTORPS,INLSR,INDATE,ENERGY,SHLD,SHLDUP,CONDIT,TORPS,SHIP,
    10. 108     9   QUADX,QUADY,SECTX,SECTY,WARPFAC,WFACSQ,LSUPRES,DAMAGE(20),
    11.  28     1   LENGTH,SKILL,DIST,DIREC,TIME,BASEX,BASEY,
    12.  24     2   DOCKFAC,KLHERE,COMHERE,CASUAL,NHELP,NKINKS,
    13. 412     3   STARCH(8,8),FUTURE(10),DEVLEN(2,14),IDIDIT,
    14.  28     4   GAMEWON,ALIVE,JUSTIN,RESTING,ALLDONE,DAMFAC,SHLDCHG,
    15.  28     5   THINGX,THINGY,NDEVICE,PLNETX,PLNETY,INORBIT,LANDED,
    16.  28     6   IPLANET,IMINE,INPLAN,NENHERE,ISHERE,NEUTZ,IRHERE,
    17.  28     7   ICRAFT,IENTESC,ISCRAFT,ISATB,ISCATE,CRYPROB,ICITE,
    18.  72     8   IPHWHO,BATX,BATY,CRACKS(12),ICSOS,ISSOS,ISUBDAM
    -----------
       3436 / 4 = 859 4-byte integer-equivalents
                  ("PARAMETER COMSIZA=859")
    
Differences between blank COMMON in VAX Fortran "TREKCOM.FOR" and "COMMON/BLANCA/" in Sigma/CP-V F77 "F7:TREKCOM" (in integer-equivalents)
    
####
    DEVLEN              adds  28  (added to F7:TREKCOM BLANCA)
    QUAD (BYTE->INT)    adds  75  (data type changed)
    DEVICE         subtracts  56  (moved to F7:TREKCOM BLANCB)
    PASSWD         subtracts   2  (moved to F7:TREKCOM BLANCB)
                    --------------
                              45 = 859 (F7:TREKCOM) - 814 (TREKCOM.FOR)
    
In the Panos Fortran 77 version, common block "BLANCA" in "trekcom-f77" is the same as the Sigma/CP-V version's "BLANCA" in "F7:TREKCOM", except that "DEVLEN" has been eliminated. Hence, COMSZA = 859-28 = 831:
    
####
          INTEGER ICOMA(831)             (trekcom-f77)
          EQUIVALENCE (ICOMA,SNAPA)
          INTEGER ICOMB(60)
          EQUIVALENCE (ICOMB,SNAPB)
          . . .
          INTEGER COMSZA,COMSZB
          COMMON/COMSZAB/COMSZA,COMSZB
    
          DATA COMSZA/831/               (trekblk-f77)
          DATA COMSZB/60/
    
--  Strict Fortran 77 does not allow unrestrained initialization of variables in COMMON blocks using
    DATA statements.  This results in the error:

####
    '<name>' is not local

Therefore, all COMMON variable initialization has to be done in a single "BLOCK DATA" pseudo-subprogram. This entailed creating a new source file "trekblk-f77". (Apparently both VAX Fortran and Sigma/CP-V F77 relax this restriction.)

-- Make sure all DATA statements **follow** all the corresponding variable declarations.

-- Replace "REAL\*8" declarations by "DOUBLE PRECISION".

-- The various "CRAM*" subroutines (in "trcram-f77") and "PROUT" (in "trprout-f77") needed alteration to deal with the mixture of CHARACTER and Hollerith strings.

E.g., in "PROUT", the "CHARACTER LINE(120)" parameter is changed to "INTEGER HLINE(30)" which is treated as a Hollerith string of 120 characters. A C subroutine (in "helpers-c", with a corresponding interface to Fortran in "ihelp-asm") allows copying "HLINE" to "LINE": "CALL HUNPAK(HLINE(1),LINE(1),KOUNT)". This allowed the rest of the subroutine to remain mostly unchanged (and similarly in "trcram-f77", "trcrop-f77", "trfreez-f77", "trgetfn-f77", "trthaw-f77"). The "trick" was realizing that there's an extra level of indirection to get to the "LINE" array -- the second parameter to "c_hunpack" in "helpers-c" is a pointer to a pointer. (See the Acorn Fortran 77 Reference Manual, pp. 37-38 for the discussion of "string descriptors".)

In the various "CRAM*" routines ("trcram-f77"), keep the external interface Hollerith (as INTEGER), convert to CHARACTER (via "HUNPAK") for internal processing, then convert back to Hollerith (via "HPACK") to call "PROUT". (Also added "HPACK" and "c_hpack" to "ihelp-asm" and "helpers-c".).

-- In subroutine SCAN (in "trscan-f77"):

In the Sigma/CP-V port, conversion of lower-case to upper-case letters was being done in EBCDIC; change this back to ASCII (in the original VAX code, "140 and "40 are octal constants; use decimal 96 and 32 instead).

The original VAX Fortran code contains logical expressions comparing CHARACTER variables with Hollerith constants, e.g.:

####
    IF(KHAR.GE.1H0 .AND. KHAR.LE.1H9) GO TO 40

But these result in "illegal type conversion" errors in Fortran 77. To fix this, in the Sigma port the Hollerith constants were changed to INTEGERs and explicit (EBCDIC) numeric constants, e.g.:

####
    20   KKAR=ICHAR(KHAR)
    . . .
    IF(KKAR.GE.240 .AND. KKAR.LE.249) GO TO 40

In the Panos port, we can now use Hollerith constants in DATA statements to initialize INTEGER variables, e.g.:

####
    DATA KH0,KH9/1H0,1H9/

So we can now change the logical expressions to contain INTEGER variables initialized with Hollerith constants, e.g.:

####
    20   KKAR=ICHAR(KHAR)
    . . .
    IF(KKAR.GE.KH0 .AND. KKAR.LE.KH9) GO TO 40

This created an additional problem, though. When an input CHARACTER is converted into an INTEGER via "KKAR=ICHAR(KHAR)", the resulting integer has the character byte in front and three trailing 0 bytes. But the DATA statements initialize the integers (KH0, etc.) containing Hollerith data (1H0, etc.) with trailing ***blanks** (0x20). So the comparisons fail.

This problem is addressed by a "helper" routine in C ("helpers-c" and its accompanying assembly-language interface "ihelp-asm") "IHOL", which converts the trailing 0 bytes into blanks:

####
    20   KKAR=ICHAR(KHAR)
    CALL IHOL(KKAR)
    . . .
    IF(KKAR.GE.KH0 .AND. KKAR.LE.KH9) GO TO 40

There is also a complement of "IHOL": a helper routine "HOLI" to convert an integer containing a Hollerith constant with three blanks after the character back to a pure integer with three 0 bytes after the character. This is needed in order for KKAR to be used in arithmetic to generate FNUM (when game input is interpreted as a numeric value):

####
    KKAR=ICHAR(KHAR)
    CALL IHOL(KKAR)
    . . . (character-based logic)
    CALL HOLI(KKAR)
    FNUM=10.0*FNUM+FLOAT(KKAR-48)

Also, in "SCAN", use "CALL HPACK(ITEM(1),AITEM,8)" to return non-numeric data in AITEM (since COMMON/SCANBF1/AITEM is once again declared as a "DOUBLE PRECISION" rather than an 8-CHARACTER array; the Sigma/CP-V F77 workaround of a separate subroutine STUFNUM to access COMMON/SCANBF1/AITEM as a "REAL\*8" and assign a numeric value to it -- a forced EQUIVALENCE, basically -- is no longer required. Separate SCANBF and SCANBF1 common blocks are also now no longer needed, but were too much bother to get rid of.).

-- Subroutine "GETCD" ("trgetcd-f77") has "EQUIVALENCE(FNUM,AITEM)" but also needs to declare "DOUBLE PRECISION FNUM" for this to work properly. (First symptom: unable to use "MOVE" command.) As with GETCD, a number of commands taking numerical arguments have associated subroutines ("SETWARP", "PHASERS", "PHOTONS", "SHIELDS", "SCAN", "WAIT") that have "EQUIVALENCE (FNUM,AITEM)", and so also need explicit declaration "DOUBLE PRECISION FNUM". (This was causing the numerical command arguments to be read incorrectly.)

-- In subroutine SRSCAN (in "trsrsca-f77"), call a "helper" subroutine, defined in "helpers-c" and "ihelp-asm": "CALL XCOPY(src,dest,len)", which copies a variable of arbitrary type to another variable of arbitrary type (as long as neither src nor dest is of type CHARACTER). This allowed the elimination of the variable "COMMON/CRAMSARG/CRAMSTR" that was used to pass a "parameter" from "SRSCAN" to "CRAMS" (which was added to fix the Sigma Fortran 77 error "inconsistent use of CRAMS" (the same parameter in separate CALLs of "CRAMS" in "SRSCAN" had integer type in one CALL and real type in another):

####
     DOUBLE PRECISION ...,DAMAGD
     INTEGER ITJ(2)
     . . .
     DATA DAMAGD,.../7HDAMAGED,.../
     . . .
     TJ=DAMAGD
     LTJ=7
     CALL XCOPY(TJ,ITJ(1),8)
     CALL CRAMS(ITJ,LTJ,8)

NOTE: "IK" -- the third parameter of CRAMS() -- ends the "cramming" of characters after the given number of characters have been transferred to the output line, if it is less than the actual length of the input string. The input-string length is the second parameter, and was newly-added for Sigma and Panos Fortran 77).

-- To "ihelp-asm" and "helpers-c", also add a set of "quick and dirty" debugging assists: INTOUT, FLTOUT, DBLOUT, STROUT, HOLOUT.

-- The CRAMSP* "singular or plural" routines ("trcrmsp-f77") are CALLed with quoted strings as arguments instead of the usual Hollerith constants (these routines were newish additions to the VAX code). The original parameter declarations were "BYTE STRING(80)" in the VAX Fortran code, changed to "CHARACTER STRING(80)" in the Sigma Fortran 77 code. In Panos, these arguments were not being read correctly, so the parameter declarations in these routines were altered to use the usual Hollerith (integer) data type: "INTEGER STRING(20)".

NOTE: Even with the CRAMSP* routines having been changed to expect Hollerith (integer array) arguments, CALLing these routines with quoted strings as arguments (in subroutine THAW, "trthaw-f77") still works fine in Panos.  This is because quoted string literals go directly into the Fortran 77 parameter-pointer vector, rather than having the extra indirection of a pointer to a "string descriptor".

-- Subroutines "FREEZE" ("trfreez-f77") and "THAW" ("trthaw-f77") call subroutine "GETFN" ("trgetfn-f77") to get a file name with which to save/restore a game's state to a file. In the original VAX Fortran code, this is being done by passing a CHARACTER array "NAME" to "GETFN", and the subroutine is expected to modify its parameter such that the modifications will be seen by the calling function. This does not work in Panos F77 (because of the "string descriptor" situation).

However, modifying the parameter works fine if it isn't a CHARACTER type: i.e., if it's a Hollerith (INTEGER array) parameter).  So declare the "GETFN" parameter "INTEGER HNAME(3)", and call subroutines "HUNPAK"/"HPACK", respectively, in subroutine "GETFN" to convert a Hollerith string ("HNAME") to "CHARACTER NAME(12)" and vice versa (and also in the subroutines "FREEZE" and "THAW" that call "GETFN".)

-- Another quirk in saving to/restoring from a file is that in Panos, the "OPEN" system subroutine won't take a "CHARACTER\*1" array (like "CHARACTER NAME(12)") in the "FILE=NAME" position. There has to be a "CHARACTER\*12" variable FNAME (which is EQUIVALENCEd to NAME) in order for "OPEN" to accept the file name. This affects both "trfreez-f77" and "trthaw-f77".  But OPEN **will** accept a quoted string literal (such as "FILE='EMSAVE-TRK'" in "tremexi-f77").  (Cf. the example in the Acorn Fortran 77 Reference Manual, p. 13.)

(Remember that when freezing or unfreezing a game, just type the "basename" of the game file -- the "-TRK" is appended automatically by "GETFN", so giving it explicitly will cause an error.)

-- In subroutine "FREEZE" ("trfreez-f77"), to find out if a file with the specified name already exists, use the "INQUIRE" statement. It's mentioned in the Acorn Fortran 77 Reference Manual on p. 18, but not in much detail. Use something like:

####
    LOGICAL EXISTS
    . . .
    INQUIRE(FILE=FNAME,EXIST=EXISTS)
    IF (EXISTS) GO TO 900

-- The "DEVICE(2,14)" array used to produce the report for the "DAMAGE" command contains 2 rows of 14 columns, where each column comprises a complete Hollerith string when the first and second row of the column are joined together):

####
    COL     ROW 1       ROW 2

     1    8HS. R. SE,  5HNSORS,
     2    8HL. R. SE,  5HNSORS,
     3    7HPHASERS,   1H ,
     4    8HPHOTON T,  4HUBES,
     5    8HLIFE SUP,  4HPORT,
     6    8HWARP ENG,  4HINES,
     7    8HIMPULSE ,  7HENGINES,
     8    7HSHIELDS,   1H ,
     9    8HSUBSPACE,  6H RADIO,
    10    8HSHUTTLE ,  5HCRAFT,
    11    8HCOMPUTER,  1H ,
    12    8HTRANSPOR,  3HTER,
    13    8HSHIELD C,  6HONTROL,
    14    8HDEATHRAY,  1H /

Fortran stores the "DEVICE(2,14)" array in column-major form. A "trick" is used in the original VAX code ("TRDREPORT.FOR") of indexing this array as if it were dimensioned as a single column of 28 rows in order to grab the first row of each column's pair of rows: "CALL CRAMS(DEVICE(2*L-1,1)...)" (where L goes from 1 to NDEVICE=14). I.e. indexing the DEVICE array as:

####
    DEVICE(2,14):    "DEVICE(28,1)"

    (1,1)       *      (1,1)
    (2,1)              (2,1)
    (1,2)       *      (3,1)
    (2,2)              (4,1)
    (1,3)       *      (5,1)
    (2,3)              (6,1)
    (1,4)       *      (7,1)
    (2,4)              (8,1)
    (1,5)       *      (9,1)
    (2,5)             (10,1)
    (1,6)       *     (11,1)
    (2,6)             (12,1)
    (1,7)       *     (13,1)
    (2,7)             (14,1)
    (1,8)       *     (15,1)
    (2,8)             (16,1)
    (1,9)       *     (17,1)
    (2,9)             (18,1)
    (1,10)      *     (19,1)
    (2,10)            (20,1)
    (1,11)      *     (21,1)
    (2,11)            (22,1)
    (1,12)      *     (23,1)
    (2,12)            (24,1)
    (1,13)      *     (25,1)
    (2,13)            (26,1)
    (1,14)      *     (27,1)
    (2,14)            (28,1)

I.e., (1,1), (3,1), (5,1), . . ., (27,1). This works, but is unnecessary, since using the normal indexing: "CALL CRAMS(DEVICE(1,L)...)", i.e.: (1,1), (1,2), (1,3), . . ., (1,14) also selects the first of each column's pair of rows.

-- The original VAX Fortran code depends on the assumption that the pairs of Hollerith strings in the DEVICE array will always have a combined length of 16; i.e. that a "DOUBLE PRECISION" initialized with "7HSHIELDS" followed by a "DOUBLE PRECISION" initialized with "1H " -- i.e., DEVICE(1,8), DEVICE(2,8) -- will result in 9 trailing blanks (1 trailing blank in DEVICE(1,8) and then a blank followed by 7 trailing blanks in DEVICE(2,8)). This is also the case in Panos Fortran 77. So we can get rid of all the workarounds that were added to the Sigma CP-V port (instead of the simpler fix of just making all the DEVICE initializations 8H and explicitly padding with blanks) to deal with varying lengths of the DEVICE strings: the DEVLEN array, PAD, "COMMON/CRAMBF/CRAMBUF", "REAL\*8 CRAMBUF(2)", and "SUBROUTINE CRAMIT(LEN)".

-- In "REAL FUNCTION RANF(IDUMMY)" ("trranf-f77"), the call to Panos system library function IFXFANDOM() returns a 32-bit integer between -2147483648 and 2147483647. Negate this if it's <0 and then divide by 2147483648.0 to get a number >=0.0 and <1.0, which is what is required.

NOTE: In subroutine "SETUP" ("trsetup-f77"), the "stardate" (in variable "DATE") is initialized to:

####
    IDATE=31.0*RANF(0)+20.0
    DATE=100*IDATE

This calculation produces an initial "stardate" that is an integral multiple of 100 (>= 2000 and <=5000). As the game progresses, and the stardate increases, it is displayed (by commands such as "srscan") with all digits populated and with one digit to the right of the decimal point.

-- In "ENTRY REQUEST" ("trsrsca-f77"), set "PFLAG" (the "pass" flag) to .TRUE. before calling "SCAN" (and reset to .FALSE.  afterward).  This forces SCAN to label anything typed as alphanumeric ("KEY.EQ.IHALPHA") so that the user can, e.g., type '?' to get a list of legal requests (this was already being done in "trtrek-f77" to enable using '?' -- or anything else -- to get a list of legal commands).

-- In subroutine "CHOOSE" ("trchoos-f77"), the call to Panos system library "IFXBINARYTIME" (to get a seed for the random-number generator) does not **return** the time. It places the time in a parameter, "INTEGER BINTIME(0:1)". See the Panos Programmer's Reference Manual, p. 126; Acorn Fortran 77 Reference Manual, p. 54.

-- In "PLAQUE" ("trplaqu-f77"), call "IFXTEXTUALTIMEOFBINARYTIME" to get the current date in text format (for putting in the certificate).

-- In "ENTRY REDALRT" ("trcrmsh-f77"), don't try to ring the bell. It just puts junk on the screen.  I don't see any way to do this from Panos.

