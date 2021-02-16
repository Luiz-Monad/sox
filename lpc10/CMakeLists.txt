
include_directories(${KDE4_INCLUDES} ${KDE4_INCLUDE_DIR} ${QT_INCLUDES} )


########### next target ###############

set(lpc10_STAT_SRCS
    analys.c
    bsynz.c
    chanwr.c
    dcbias.c
    \)

kde4_add_library(lpc10 STATIC ${lpc10_STAT_SRCS})


########### install files ###############




#original Makefile.am contents follow:

#if HAVE_LIBLPC10
#EXTRA_DIST = analys.c bsynz.c chanwr.c dcbias.c \
#  decode.c deemp.c difmag.c dyptrk.c encode.c energy.c f2c.h f2clib.c \
#  ham84.c hp100.c invert.c irc2pc.c ivfilt.c lpcdec.c lpcenc.c lpcini.c \
#  lpfilt.c median.c mload.c onset.c pitsyn.c placea.c placev.c preemp.c \
#  prepro.c random.c rcchk.c synths.c tbdm.c voicin.c vparms.c lpc10.h
#else
#noinst_LTLIBRARIES = liblpc10.la
#noinst_HEADERS = lpc10.h
#liblpc10_la_SOURCES = analys.c bsynz.c chanwr.c dcbias.c \
#  decode.c deemp.c difmag.c dyptrk.c encode.c energy.c f2c.h f2clib.c \
#  ham84.c hp100.c invert.c irc2pc.c ivfilt.c lpcdec.c lpcenc.c lpcini.c \
#  lpfilt.c median.c mload.c onset.c pitsyn.c placea.c placev.c preemp.c \
#  prepro.c random.c rcchk.c synths.c tbdm.c voicin.c vparms.c
#AM_CPPFLAGS=-I../src
#if HAVE_LIBLTDL
#AM_LDFLAGS=-avoid-version -module
#endif
#endif
