# SoX Resampler Library       Copyright (c) 2007-16 robs@users.sourceforge.net
# Licence for this file: LGPL v2.1                  See LICENCE for details.

# Format handlers and utils source
set (SOURCES 
  adpcms.c adpcms.h aiff.c aiff.h cvsd.c cvsd.h cvsdfilt.h
  g711.c g711.h g721.c g723_24.c g723_40.c g72x.c g72x.h vox.c vox.h
  raw.c raw.h formats.c formats.h formats_i.c sox_i.h skelform.c
  xmalloc.c xmalloc.h getopt.c
  util.c util.h libsox.c libsox_i.c sox-fmt.c soxomp.h)

# Effects source
list (APPEND SOURCES
  band.h bend.c biquad.c biquad.h biquads.c chorus.c compand.c
  compandt.c compandt.h contrast.c dcshift.c delay.c dft_filter.c
  dft_filter.h dither.c dither.h divide.c downsample.c earwax.c
  echo.c echos.c effects.c effects.h effects_i.c effects_i_dsp.c
  fade.c fft4g.c fft4g.h fifo.h fir.c firfit.c flanger.c gain.c
  hilbert.c input.c ladspa.h ladspa.c loudness.c mcompand.c
  mcompand_xover.h noiseprof.c noisered.c
  noisered.h output.c overdrive.c pad.c phaser.c rate.c
  rate_filters.h rate_half_fir.h rate_poly_fir0.h rate_poly_fir.h
  remix.c repeat.c reverb.c reverse.c silence.c sinc.c skeleff.c
  speed.c splice.c stat.c stats.c stretch.c swap.c
  synth.c tempo.c tremolo.c trim.c upsample.c vad.c vol.c)

if (HAVE_PNG)
  list (APPEND SOURCES spectrogram.c)
endif ()

# File Formats

# Uncomment for bit-rot detection on linux
#list (APPEND SOURCES coreaudio.c sndio.c sunaudio.c)

list (APPEND SOURCES 
  raw-fmt.c s1-fmt.c s2-fmt.c s3-fmt.c
  s4-fmt.c u1-fmt.c u2-fmt.c u3-fmt.c u4-fmt.c al-fmt.c la-fmt.c ul-fmt.c
  lu-fmt.c 8svx.c aiff-fmt.c aifc-fmt.c au.c avr.c cdr.c cvsd-fmt.c
  dvms-fmt.c dat.c hcom.c htk.c maud.c prc.c sf.c smp.c
  sounder.c soundtool.c sphere.c tx16w.c voc.c vox-fmt.c ima-fmt.c adpcm.c adpcm.h
  ima_rw.c ima_rw.h wav.c wve.c xa.c nulfile.c f4-fmt.c f8-fmt.c gsrt.c
  id3.c id3.h)

# Optional formats

if (HAVE_ALSA)
  list (APPEND SOURCES alsa.c)
endif ()

if (HAVE_AMRNB)
  list (APPEND SOURCES amr-nb.c amr.h)
endif ()

if (HAVE_AMRWB)
  list (APPEND SOURCES amr-wb.c amr.h)
endif ()

if (HAVE_AO)
  list (APPEND SOURCES ao.c)
endif ()

if (HAVE_COREAUDIO)
  list (APPEND SOURCES coreaudio.c)
endif ()

if (HAVE_FLAC)
  list (APPEND SOURCES flac.c)
endif ()

if (HAVE_GSM)
  list (APPEND SOURCES gsm.c)
endif ()

if (HAVE_LPC10)
  list (APPEND SOURCES lpc10.c)
endif ()

if (HAVE_MP3)
  list (APPEND SOURCES mp3.c mp3-util.h)
endif ()

if (HAVE_OPUS)
  list (APPEND SOURCES opus.c)
endif ()

if (HAVE_OSS)
  list (APPEND SOURCES oss.c)
endif ()

if (HAVE_PULSEAUDIO)
  list (APPEND SOURCES pulseaudio.c)
endif ()

if (HAVE_WAVEAUDIO)
  list (APPEND SOURCES waveaudio.c)
endif ()

if (HAVE_SNDIO)
  list (APPEND SOURCES sndio.c)
endif ()

if (HAVE_SUNAUDIO)
  list (APPEND SOURCES sunaudio.c)
endif ()

if (HAVE_OGGVORBIS)
  list (APPEND SOURCES vorbis.c)
endif ()

if (HAVE_WAVPACK)
  list (APPEND SOURCES wavpack.c)
endif ()

if (HAVE_SNDFILE)
  list (APPEND SOURCES sndfile.c caf.c mat4.c mat5.c paf.c fap.c w64.c xi.c pvf.c sd2.c)
endif ()

# Libsoxr:

add_library ("${PROJECT_NAME}-lib" STATIC ${SOURCES})
target_link_libraries ("${PROJECT_NAME}-lib" PRIVATE ${LIBM_LIBRARIES})

add_library (${PROJECT_NAME} ${LIB_TYPE} "${PROJECT_NAME}.c")
target_link_libraries (${PROJECT_NAME} PRIVATE "${PROJECT_NAME}-lib")
set_target_properties (${PROJECT_NAME} PROPERTIES
  VERSION "${SO_VERSION}"
  SOVERSION ${SO_VERSION_MAJOR}
  INSTALL_NAME_DIR ${LIB_INSTALL_DIR}
  LINK_INTERFACE_LIBRARIES ""
  PUBLIC_HEADER "${PROJECT_NAME}.h")
if (BUILD_FRAMEWORK)
  set_target_properties (${PROJECT_NAME} PROPERTIES FRAMEWORK TRUE)
endif ()

# Executable:

add_executable ("${PROJECT_NAME}-exe" sox.c)
target_link_libraries ("${PROJECT_NAME}-exe" "${PROJECT_NAME}-lib")

# Installation (from build from source):

install (TARGETS ${PROJECT_NAME}
  FRAMEWORK DESTINATION ${FRAMEWORK_INSTALL_DIR}
  LIBRARY DESTINATION ${LIB_INSTALL_DIR}
  RUNTIME DESTINATION ${BIN_INSTALL_DIR}
  ARCHIVE DESTINATION ${LIB_INSTALL_DIR}
  PUBLIC_HEADER DESTINATION ${INCLUDE_INSTALL_DIR})
