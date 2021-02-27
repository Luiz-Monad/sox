# SoX Resampler Library       Copyright (c) 2007-18 robs@users.sourceforge.net
# Licence for this file: LGPL v2.1                  See LICENCE for details.

cmake_minimum_required (VERSION 3.1 FATAL_ERROR)

project (sox C)
set (DESCRIPTION_SUMMARY
    "High quality, one-dimensional sample-rate conversion library")

# Release versioning:

set (PROJECT_VERSION_MAJOR 0)
set (PROJECT_VERSION_MINOR 1)
set (PROJECT_VERSION_PATCH 3)

# For shared-object; if, since the last public release:
#   1) library code changed at all: ++revision
#   2) interfaces changed at all:   ++current, revision = 0
#   3) interfaces added:            ++age
#   4) interfaces removed:          age = 0

set (SO_VERSION_CURRENT  1)
set (SO_VERSION_REVISION 2)
set (SO_VERSION_AGE      1)

math (EXPR SO_VERSION_MAJOR "${SO_VERSION_CURRENT} - ${SO_VERSION_AGE}")
math (EXPR SO_VERSION_MINOR "${SO_VERSION_AGE}")
math (EXPR SO_VERSION_PATCH "${SO_VERSION_REVISION}")

# Main options:

include (CMakeDependentOption)

if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE Release CACHE STRING
    "Build type, one of: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif ()

cmake_dependent_option (BUILD_SHARED_LIBS
  "Build shared (dynamic) soxr libraries." ON
  "NOT WITH_DEV_GPROF" OFF)

# Introspection:

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules)

include (CheckSymbolExists)
include (CheckFunctionExists)
include (CheckIncludeFiles)
include (CheckLibraryExists)
include (SetSystemProcessor)
include (TestBigEndian)

# Check for system dependent features.

set_system_processor ()
test_big_endian (WORDS_BIGENDIAN)

check_function_exists (lrint HAVE_LRINT)

# Checks for header files.

check_include_files (stdbool.h HAVE_STDBOOL_H)
check_include_files (stdint.h HAVE_STDINT_H)
check_include_files (fcntl.h HAVE_FCNTL_H)
check_include_files (unistd.h HAVE_UNISTD_H)
check_include_files (byteswap.h HAVE_BYTESWAP_H)
check_include_files (sys/ioctl.h HAVE_SYS_IOCTL_H)
check_include_files (sys/stat.h HAVE_SYS_STAT_H)
check_include_files (sys/time.h HAVE_SYS_TIME_H)
check_include_files (sys/timeb.h HAVE_SYS_TIMEB_H)
check_include_files (sys/types.h HAVE_SYS_TYPES_H)
check_include_files (sys/utsname.h HAVE_SYS_UTSNAME_H)
check_include_files (termios.h HAVE_TERMIOS_H)
check_include_files (glob.h HAVE_GLOB_H)
check_include_files (fenv.h HAVE_FENV_H)

# Checks for library functions.

check_symbol_exists (strcasecmp strings.h HAVE_STRCASECMP)
check_symbol_exists (strdup string.h HAVE_STRDUP)
check_symbol_exists (popen stdio.h HAVE_POPEN)
check_symbol_exists (vsnprintf stdio.h HAVE_VSNPRINTF)
check_symbol_exists (gettimeofday sys/time.h HAVE_GETTIMEOFDAY)
check_symbol_exists (mkstemp stdlib.h HAVE_MKSTEMP)
check_symbol_exists (fmemopen stdio.h HAVE_FMEMOPEN)
check_symbol_exists (sigaction signal.h HAVE_sigaction)

# Check if math library is needed.

check_library_exists (m pow "" NEED_LIBM)
if (NEED_LIBM)
  set (CMAKE_REQUIRED_LIBRARIES "m;${CMAKE_REQUIRED_LIBRARIES}")
  set (LIBM_LIBRARIES m)
endif ()

# Check for OpenMP

option (WITH_OPENMP "Include OpenMP threading." ON)

if (WITH_OPENMP)
  find_package (OpenMP)
  if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    if (MINGW) # Is this still needed?
      set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_C_FLAGS}")
      set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${OpenMP_C_FLAGS}")
    endif ()
  endif()
endif ()

# Options.

option (WITH_LTDL "Include LTDL." OFF)
if (WITH_LTDL)
  set (HAVE_LTDL ON)
  check_library_exists (libltdl lt_dlinit "" HAVE_LIBLTDL)
  check_include_files (ltdl.h HAVE_LTDL_H)
endif ()

option (WITH_LADSPA "LADSPA support." OFF)
if (WITH_LADSPA)
  check_include_files (ladspa.h HAVE_LADSPA_H)
endif ()

# Various libraries.

option (WITH_MAGIC "MAGIC support." OFF)
if (WITH_MAGIC)
  check_library_exists (magic magic_open "" HAVE_MAGIC)
  check_include_files (magic.h HAVE_MAGIC_H)
endif ()

check_library_exists (zlib uncompress "" HAVE_ZLIB)
if (!HAVE_ZLIB)
  check_library_exists (z uncompress "" HAVE_ZLIB)
endif ()
check_include_files (zlib.h HAVE_ZLIB_H)

option (WITH_PNG "PNG support." OFF)
if (WITH_PNG)
  check_library_exists (png png_set_rows "" HAVE_PNG)
  check_include_files (png.h HAVE_PNG_H)
endif ()

option (WITH_ID3TAG "ID3TAG support." OFF)
if (WITH_ID3TAG)
  check_library_exists (id3tag id3_file_open "" HAVE_ID3TAG)
  check_include_files (id3tag.h HAVE_ID3TAG_H)
endif ()

option (WITH_GSM "GSM support." OFF)
if (WITH_GSM)
  check_library_exists (libgsm gsm_create "" HAVE_GSM)
  check_include_files (gsm.h HAVE_GSM_H)
  check_include_files (gsm/gsm.h HAVE_GSM_GSM_H)
endif ()

# Optional formats.

option (WITH_OPENCORE_AMRNB "OPENCORE_AMRNB support." OFF)
if (WITH_OPENCORE_AMRNB)
  check_library_exists (opencore-amrnb Decoder_Interface_init "" HAVE_OPENCORE_AMRNB)
  check_include_files (opencore-amrnb/interf_dec.h HAVE_OPENCORE_AMRNB_INTERF_DEC_H)
endif ()
if (HAVE_OPENCORE_AMRNB)
  set (HAVE_AMRNB ON)
endif ()

option (WITH_OPENCORE_AMRWB "OPENCORE_AMRWB support." OFF)
if (WITH_OPENCORE_AMRWB)
  check_library_exists (opencore-amrwb D_IF_init "" HAVE_OPENCORE_AMRWB)
  check_include_files (opencore-amrwb/dec_if.h HAVE_OPENCORE_AMRWB_DEC_IF_H)
endif ()
option (WITH_VO_AMRWBENC "VO_AMRWBENC support." OFF)
if (WITH_VO_AMRWBENC)
  check_library_exists (vo-amrwbenc E_IF_init "" HAVE_VO_AMRWBENC)
  check_include_files (vo-amrwbenc/enc_if.h HAVE_VO_AMRWBENC_ENC_IF_H)
endif ()
if (HAVE_OPENCORE_AMRWB AND HAVE_VO_AMRWBENC)
  set (HAVE_AMRWB ON)
endif ()

option (WITH_FLAC "FLAC support." ON)
if (WITH_FLAC)
  find_package (flac)
endif ()
if (FLAC_FOUND OR FLAC_FLAC_FOUND)
  set (HAVE_FLAC ON)
endif ()

option (WITH_GSM "GSM support." OFF)
if (WITH_GSM)
  find_package (libgsm)
endif ()
if (GSM_FOUND)
  set (HAVE_GSM ON)
endif ()

option (WITH_LPC10 "LPC10 support." OFF)
if (WITH_LPC10)
  check_library_exists (liblpc10 create_lpc10_encoder_state "" HAVE_LIBLPC10)
  check_include_files (lpc10.h HAVE_LPC10_H)
endif ()
if (HAVE_LIBLPC10)
  set (HAVE_LPC10 ON)
endif ()

option (WITH_MAD "MAD support." OFF)
if (WITH_MAD)
  check_library_exists (mad mad_stream_buffer "" HAVE_MAD)
  check_include_files (mad.h HAVE_MAD_H)
endif ()
option (WITH_LAME "LAME support." OFF)
if (WITH_LAME)
  check_library_exists (mp3lame lame_init "" HAVE_LAME)
  check_include_files (lame.h HAVE_LAME_H)
  check_include_files (lame/lame.h HAVE_LAME_LAME_H)
endif ()
option (WITH_TWOLAME "TWOLAME support." OFF)
if (WITH_TWOLAME)
  check_library_exists (twolame twolame_init "" HAVE_TWOLAME)
  check_include_files (twolame.h HAVE_TWOLAME_H)
endif ()
if (HAVE_MAD AND HAVE_LAME AND HAVE_TWOLAME)
  set (HAVE_MP3 ON)
endif ()

option (WITH_OGGVORBIS "OGGVORBIS support." OFF)
if (WITH_OGGVORBIS)
  find_package (ogg)
endif ()
if (OGGVORBIS_FOUND)
  set (HAVE_OGGVORBIS ON)
endif ()

option (WITH_OPUS "OPUS support." OFF)
if (WITH_OPUS)
  find_package (opus)
endif ()
if (OPUS_FOUND)
  set (HAVE_OPUS ON)
endif ()

option (WITH_SNDFILE "SNDFILE support." OFF)
if (WITH_SNDFILE)
  check_library_exists (libsndfile sf_open_virtual "" HAVE_LIBSNDFILE)
  check_include_files (sndfile.h HAVE_SNDFILE_H)
endif ()
if (HAVE_LIBSNDFILE)
  set (HAVE_SNDFILE ON)
endif ()

option (WITH_WAVPACK "WAVPACK support." OFF)
if (WITH_WAVPACK)
  check_library_exists (wavpack WavpackGetSampleRate "" HAVE_LIBWAVPACK)
  check_include_files (wavpack/wavpack.h HAVE_WAVPACK_WAVPACK_H)
endif ()
if (HAVE_LIBWAVPACK)
  set (HAVE_WAVPACK ON)
endif ()

# Audio devices

option (WITH_ALSA "ALSA support." OFF)
if (WITH_ALSA)
  check_library_exists (asound snd_pcm_open "" HAVE_LIBALSA)
  check_include_files (alsa/asoundlib.h HAVE_ALSA_ASOUNDLIB_H)
endif ()
if (HAVE_LIBALSA)
  set (HAVE_ALSA ON)
endif ()

option (WITH_AO "AO support." OFF)
if (WITH_AO)
  check_library_exists (ao ao_play "" HAVE_LIBAO)
  check_include_files (ao/ao.h HAVE_AO_AO_H)
endif ()
if (HAVE_LIBAO)
  set (HAVE_AO ON)
endif ()

option (WITH_COREAUDIO "COREAUDIO support." OFF)
if (WITH_COREAUDIO)
  check_library_exists (coreaudio AudioDeviceStart "" HAVE_LIBCOREAUDIO)
  check_include_files (CoreAudio/CoreAudio.h HAVE_COREAUDIO_COREAUDIO_H)
endif ()
if (HAVE_LIBCOREAUDIO)
  set (HAVE_COREAUDIO ON)
endif ()

option (WITH_PULSEAUDIO "PULSEAUDIO support." OFF)
if (WITH_PULSEAUDIO)
  check_library_exists (pulseaudio PULSEAUDIO_play "" HAVE_LIBPULSEAUDIO)
  check_include_files (pulse/simple.h HAVE_PULSEAUDIO_PULSEAUDIO_H)
endif ()
if (HAVE_LIBPULSEAUDIO)
  set (HAVE_PULSEAUDIO ON)
endif ()

option (WITH_OSS "OSS support." OFF)
if (WITH_OSS)
  check_symbol_exists (SOUND_MIXER_MUTE sys/soundcard.h "" HAVE_LIBOSS)
  check_include_files (sys/soundcard.h HAVE_SYS_SOUNDCARD_H)
endif ()
if (HAVE_LIBOSS)
  set (HAVE_OSS ON)
endif ()

option (WITH_SNDIO "SNDIO support." OFF)
if (WITH_SNDIO)
  check_library_exists (sndio sio_open "" HAVE_LIBSNDIO)
  check_include_files (sndio.h HAVE_SNDIO_H)
endif ()
if (HAVE_LIBSNDIO)
  set (HAVE_SNDIO ON)
endif ()

option (WITH_SUNAUDIO "SUNAUDIO support." OFF)
if (WITH_SUNAUDIO)
  check_symbol_exists (AUDIO_GETINFO sun/audioio.h "" HAVE_LIBSUNAUDIO)
  check_include_files (sys/audioio.h HAVE_SUNAUDIO_SUNAUDIO_H)
  check_include_files (sun/audioio.h HAVE_SUNAUDIO_SUNAUDIO_H)
endif ()
if (HAVE_LIBSUNAUDIO)
  set (HAVE_SUNAUDIO ON)
endif ()

option (WITH_WAVEAUDIO "WAVEAUDIO support." OFF)
if (WITH_WAVEAUDIO)
  set (HAVE_WAVEAUDIO ON)
  check_library_exists (winmm waveOutOpen "" HAVE_LIBWAVEAUDIO)
  check_include_files (mmsystem.h HAVE_MMSYSTEM_H)
endif ()
if (HAVE_LIBWAVEAUDIO)
  set (HAVE_WAVEAUDIO ON)
endif ()

# Compiler configuration:

if (CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set (PROJECT_CXX_FLAGS "${PROJECT_CXX_FLAGS} -Wconversion -Wall -Wextra \
      -pedantic -Wundef -Wpointer-arith -Wno-long-long")
  if (CMAKE_C_COMPILER_ID STREQUAL "Clang")
    set (PROJECT_CXX_FLAGS "${PROJECT_CXX_FLAGS} -Wno-keyword-macro")
  endif ()
  if (WITH_DEV_GPROF)
    set (PROJECT_CXX_FLAGS "${PROJECT_CXX_FLAGS} -pg")
  endif ()
  # Can use std=c89, but gnu89 should give faster sinf, cosf, etc.:
  set (PROJECT_C_FLAGS "${PROJECT_CXX_FLAGS} \
       -std=gnu89 -Wnested-externs -Wmissing-prototypes -Wstrict-prototypes")
  if (CMAKE_BUILD_TYPE STREQUAL "Release")
    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -s") # strip
  endif ()
  cmake_dependent_option (VISIBILITY_HIDDEN
    "Build shared libraries with -fvisibility=hidden." ON
    "BUILD_SHARED_LIBS" OFF)
  mark_as_advanced (VISIBILITY_HIDDEN)
  if (VISIBILITY_HIDDEN)
    add_definitions (-fvisibility=hidden -DSOXR_VISIBILITY)
  endif ()
endif ()

if (MSVC)
  add_definitions (-D_USE_MATH_DEFINES -D_CRT_SECURE_NO_WARNINGS)
  option (BUILD_SHARED_RUNTIME "MSVC, link with runtime dynamically."  ON)
  if (NOT BUILD_SHARED_RUNTIME)
    foreach (flag_var
        CMAKE_C_FLAGS                CMAKE_CXX_FLAGS
        CMAKE_C_FLAGS_DEBUG          CMAKE_CXX_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL     CMAKE_CXX_FLAGS_MINSIZEREL
        CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_CXX_FLAGS_RELWITHDEBINFO)
      string (REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    endforeach ()
  endif ()
  # By default, do not warn when built on machines using only VS Express:
  if (NOT DEFINED CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS)
    set (CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS ON)
  endif ()
endif ()

# Build configuration:

set (LIB_TYPE STATIC)
if (BUILD_SHARED_LIBS)
  set (LIB_TYPE SHARED)
  if (MSVC)
    add_definitions (-DSOXR_DLL)
  endif ()
endif ()

if (CMAKE_BUILD_TYPE STREQUAL "None") # As used by some distros.
  add_definitions (-DNDEBUG)
endif ()

# Installation configuration:

if (APPLE)
  option (BUILD_FRAMEWORK "Build an OS X framework." OFF)
  set (FRAMEWORK_INSTALL_DIR
      "/Library/Frameworks" CACHE STRING "Directory to install frameworks to.")
endif ()

# Top-level:

set (PROJECT_VERSION
  ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
set (SO_VERSION ${SO_VERSION_MAJOR}.${SO_VERSION_MINOR}.${SO_VERSION_PATCH})

configure_file (
  ${PROJECT_SOURCE_DIR}/src/${PROJECT_NAME}-config.h.in
  ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.h)
include_directories (${PROJECT_BINARY_DIR})

if (NOT CMAKE_CROSSCOMPILING AND (BUILD_TESTS OR BUILD_LSR_TESTS))
  enable_testing ()
endif ()

file(GLOB DOCS "README.*")
install(FILES ${DOCS} DESTINATION ${CMAKE_INSTALL_DOCDIR}/docs)

# Subdirectories:

include_directories (${PROJECT_SOURCE_DIR}/src)

add_subdirectory (src)
if (BUILD_TESTS)
  add_subdirectory (tests)
endif ()
if (BUILD_LSR_TESTS)
  add_subdirectory (lsr-tests)
endif ()
if (BUILD_EXAMPLES OR BUILD_TESTS)
  add_subdirectory (examples)
endif ()
