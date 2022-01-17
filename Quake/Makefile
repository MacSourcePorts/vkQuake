# GNU Makefile for vkQuake unix targets
# You need the SDL2 library fully installed.
# "make DEBUG=1" to build a debug client.
# "make SDL_CONFIG=/path/to/sdl2-config" for unusual SDL2 installations.
# "make DO_USERDIRS=1" to enable user directories support
# "make VULKAN_SDK=/path/to/sdk" if it is not already in path

# Enable/Disable user directories support
DO_USERDIRS=0

### Enable/Disable codecs for streaming music support
USE_CODEC_WAVE=1
USE_CODEC_FLAC=0
USE_CODEC_MP3=1
USE_CODEC_VORBIS=1
USE_CODEC_OPUS=0
# either mikmod, or xmp
USE_CODEC_MIKMOD=0
USE_CODEC_XMP=0
USE_CODEC_UMX=0

# which library to use for mp3 decoding: mad or mpg123
MP3LIB=mad
# which library to use for ogg decoding: vorbis or tremor
VORBISLIB=vorbis

# ---------------------------
# Helper functions
# ---------------------------

check_gcc = $(shell if echo | $(CC) $(1) -Werror -S -o /dev/null -xc - > /dev/null 2>&1; then echo "$(1)"; else echo "$(2)"; fi;)

# ---------------------------

HOST_OS := $(shell uname|sed -e s/_.*//|tr '[:upper:]' '[:lower:]')

DEBUG   ?= 0

# ---------------------------
# build variables
# ---------------------------

CC ?= gcc
LINKER = $(CC)

STRIP ?= strip

CPUFLAGS=
DFLAGS ?=
CFLAGS ?=
CFLAGS += -Wall -Wno-trigraphs -Wno-unused-function -Werror -std=gnu11
CFLAGS += $(CPUFLAGS)
ifneq ($(DEBUG),0)
DFLAGS += -D_DEBUG
CFLAGS += -g
do_strip=
else
DFLAGS += -DNDEBUG
CFLAGS += -O3
CFLAGS += $(call check_gcc,-fweb,)
CFLAGS += $(call check_gcc,-frename-registers,)
cmd_strip=$(STRIP) $(1)
define do_strip
	$(call cmd_strip,$(1));
endef
endif

ifneq ($(VULKAN_SDK),)
LDFLAGS += -L$(VULKAN_SDK)/lib
CFLAGS += -I$(VULKAN_SDK)/include
endif

ifeq ($(DO_USERDIRS),1)
CFLAGS += -DDO_USERDIRS=1
endif

SDL_CONFIG ?= sdl2-config
SDL_CFLAGS := $(shell $(SDL_CONFIG) --cflags)
SDL_LIBS   := $(shell $(SDL_CONFIG) --libs)

ifeq ($(HOST_OS),sunos)
NET_LIBS   :=-lsocket -lnsl -lresolv
else
NET_LIBS   :=
endif

ifneq ($(VORBISLIB),vorbis)
ifneq ($(VORBISLIB),tremor)
$(error Invalid VORBISLIB setting)
endif
endif
ifneq ($(MP3LIB),mpg123)
ifneq ($(MP3LIB),mad)
$(error Invalid MP3LIB setting)
endif
endif
ifeq ($(MP3LIB),mad)
mp3_obj=snd_mp3
lib_mp3dec=-lmad
endif
ifeq ($(MP3LIB),mpg123)
mp3_obj=snd_mpg123
lib_mp3dec=-lmpg123
endif
ifeq ($(VORBISLIB),vorbis)
cpp_vorbisdec=
lib_vorbisdec=-lvorbisfile -lvorbis -logg
endif
ifeq ($(VORBISLIB),tremor)
cpp_vorbisdec=-DVORBIS_USE_TREMOR
lib_vorbisdec=-lvorbisidec -logg
endif

CODECLIBS  :=
ifeq ($(USE_CODEC_WAVE),1)
CFLAGS+= -DUSE_CODEC_WAVE
endif
ifeq ($(USE_CODEC_FLAC),1)
CFLAGS+= -DUSE_CODEC_FLAC
CODECLIBS+= -lFLAC
endif
ifeq ($(USE_CODEC_OPUS),1)
# opus and opusfile put their *.h under <includedir>/opus,
# but they include the headers without the opus directory
# prefix and rely on pkg-config. ewww...
CFLAGS+= -DUSE_CODEC_OPUS
CFLAGS+= $(shell pkg-config --cflags opusfile)
CODECLIBS+= $(shell pkg-config --libs   opusfile)
endif
ifeq ($(USE_CODEC_VORBIS),1)
CFLAGS+= -DUSE_CODEC_VORBIS $(cpp_vorbisdec)
CODECLIBS+= $(lib_vorbisdec)
endif
ifeq ($(USE_CODEC_MP3),1)
CFLAGS+= -DUSE_CODEC_MP3
CODECLIBS+= $(lib_mp3dec)
endif
ifeq ($(USE_CODEC_MIKMOD),1)
CFLAGS+= -DUSE_CODEC_MIKMOD
CODECLIBS+= -lmikmod
endif
ifeq ($(USE_CODEC_XMP),1)
CFLAGS+= -DUSE_CODEC_XMP
CODECLIBS+= -lxmp
endif
ifeq ($(USE_CODEC_UMX),1)
CFLAGS+= -DUSE_CODEC_UMX
endif

COMMON_LIBS:= -lm

ifneq ($(HOST_OS),darwin)
COMMON_LIBS+= -lvulkan
CFLAGS+= -DLINUX
else
LDFLAGS+= -mmacosx-version-min=10.7
ifeq ($(ARCH),arm64)
COMMON_LIBS+= -L/opt/homebrew/lib
CFLAGS+= -I/opt/homebrew/include
else
COMMON_LIBS+= -L/usr/local/lib
CFLAGS+= -I/usr/local/include
endif
COMMON_LIBS+= -lMoltenVK
endif

LIBS := $(COMMON_LIBS) $(NET_LIBS) $(CODECLIBS)

# ---------------------------
# targets
# ---------------------------

.PHONY:	clean debug release

DEFAULT_TARGET := vkquake

# ---------------------------
# rules
# ---------------------------

$(ARCH)/%.o:	%.c
	$(CC) -arch $(ARCH) $(DFLAGS) -c $(CFLAGS) $(SDL_CFLAGS) -o $@ $<
ifeq ($(DEBUG),0)
$(ARCH)/%.o:	../Shaders/Compiled/Release/%.c
	$(CC) -arch $(ARCH) $(DFLAGS) -c $(CFLAGS) $(SDL_CFLAGS) -o $@ $^
else
$(ARCH)/%.o:	../Shaders/Compiled/Debug/%.c
	$(CC) -arch $(ARCH) $(DFLAGS) -c $(CFLAGS) $(SDL_CFLAGS) -o $@ $^
endif

# ----------------------------------------------------------------------------
# objects
# ----------------------------------------------------------------------------

MUSIC_OBJS:= $(ARCH)/bgmusic.o \
	$(ARCH)/snd_codec.o \
	$(ARCH)/snd_flac.o \
	$(ARCH)/snd_wave.o \
	$(ARCH)/snd_vorbis.o \
	$(ARCH)/snd_opus.o \
	$(ARCH)/$(mp3_obj).o \
	$(ARCH)/snd_mp3tag.o \
	$(ARCH)/snd_mikmod.o \
	$(ARCH)/snd_xmp.o \
	$(ARCH)/snd_umx.o
COMOBJ_SND := $(ARCH)/snd_dma.o $(ARCH)/snd_mix.o $(ARCH)/snd_mem.o $(MUSIC_OBJS)
SYSOBJ_SND := $(ARCH)/snd_sdl.o
SYSOBJ_CDA := $(ARCH)/cd_sdl.o
SYSOBJ_INPUT := $(ARCH)/in_sdl.o
SYSOBJ_GL_VID:= $(ARCH)/gl_vidsdl.o
SYSOBJ_NET := $(ARCH)/net_bsd.o $(ARCH)/net_udp.o
SYSOBJ_SYS := $(ARCH)/pl_linux.o $(ARCH)/sys_sdl_unix.o
SYSOBJ_MAIN:= $(ARCH)/main_sdl.o
SYSOBJ_RES :=

SHADER_OBJS = \
	$(ARCH)/alias.frag.o \
	$(ARCH)/alias_alphatest.frag.o \
	$(ARCH)/alias.vert.o \
	$(ARCH)/basic_alphatest.frag.o \
	$(ARCH)/screen_effects_8bit.comp.o \
	$(ARCH)/screen_effects_8bit_scale.comp.o \
	$(ARCH)/screen_effects_8bit_scale_sops.comp.o \
	$(ARCH)/screen_effects_10bit.comp.o \
	$(ARCH)/screen_effects_10bit_scale.comp.o \
	$(ARCH)/screen_effects_10bit_scale_sops.comp.o \
	$(ARCH)/cs_tex_warp.comp.o \
	$(ARCH)/basic.frag.o \
	$(ARCH)/basic_notex.frag.o \
	$(ARCH)/basic.vert.o \
	$(ARCH)/sky_layer.frag.o \
	$(ARCH)/sky_layer.vert.o \
	$(ARCH)/sky_box.frag.o \
	$(ARCH)/postprocess.frag.o \
	$(ARCH)/postprocess.vert.o \
	$(ARCH)/world.frag.o \
	$(ARCH)/world.vert.o \
	$(ARCH)/showtris.frag.o \
	$(ARCH)/showtris.vert.o \
	$(ARCH)/update_lightmap.comp.o

GLOBJS = \
	$(SHADER_OBJS) \
	$(ARCH)/gl_refrag.o \
	$(ARCH)/gl_rlight.o \
	$(ARCH)/gl_rmain.o \
	$(ARCH)/gl_fog.o \
	$(ARCH)/gl_rmisc.o \
	$(ARCH)/r_part.o \
	$(ARCH)/r_part_fte.o \
	$(ARCH)/r_world.o \
	$(ARCH)/gl_screen.o \
	$(ARCH)/gl_sky.o \
	$(ARCH)/gl_warp.o \
	$(SYSOBJ_GL_VID) \
	$(ARCH)/gl_draw.o \
	$(ARCH)/image.o \
	$(ARCH)/gl_texmgr.o \
	$(ARCH)/gl_mesh.o \
	$(ARCH)/gl_heap.o \
	$(ARCH)/r_sprite.o \
	$(ARCH)/r_alias.o \
	$(ARCH)/r_brush.o \
	$(ARCH)/gl_model.o

OBJS := $(ARCH)/strlcat.o \
	$(ARCH)/strlcpy.o \
	$(GLOBJS) \
	$(SYSOBJ_INPUT) \
	$(COMOBJ_SND) \
	$(SYSOBJ_SND) \
	$(SYSOBJ_CDA) \
	$(SYSOBJ_NET) \
	$(ARCH)/net_dgrm.o \
	$(ARCH)/net_loop.o \
	$(ARCH)/net_main.o \
	$(ARCH)/chase.o \
	$(ARCH)/cl_demo.o \
	$(ARCH)/cl_input.o \
	$(ARCH)/cl_main.o \
	$(ARCH)/cl_parse.o \
	$(ARCH)/cl_tent.o \
	$(ARCH)/console.o \
	$(ARCH)/keys.o \
	$(ARCH)/menu.o \
	$(ARCH)/sbar.o \
	$(ARCH)/view.o \
	$(ARCH)/wad.o \
	$(ARCH)/cmd.o \
	$(ARCH)/common.o \
	$(ARCH)/miniz.o \
	$(ARCH)/crc.o \
	$(ARCH)/cvar.o \
	$(ARCH)/cfgfile.o \
	$(ARCH)/host.o \
	$(ARCH)/host_cmd.o \
	$(ARCH)/mathlib.o \
	$(ARCH)/mdfour.o \
	$(ARCH)/pr_cmds.o \
	$(ARCH)/pr_ext.o \
	$(ARCH)/pr_edict.o \
	$(ARCH)/pr_exec.o \
	$(ARCH)/sv_main.o \
	$(ARCH)/sv_move.o \
	$(ARCH)/sv_phys.o \
	$(ARCH)/sv_user.o \
	$(ARCH)/world.o \
	$(ARCH)/zone.o \
	$(SYSOBJ_SYS) $(SYSOBJ_MAIN) $(SYSOBJ_RES)

# ------------------------
# Linux build rules
# ------------------------

vkquake:	$(OBJS)
	$(LINKER) -arch $(ARCH) $(OBJS) $(LDFLAGS) $(LIBS) $(SDL_LIBS) -o $(ARCH)/$@
	$(call do_strip,$(ARCH)/$@)

image.o: lodepng.c lodepng.h stb_image_write.h

release:	vkquake
debug:
	$(error Use "make DEBUG=1")

clean:
	rm -f $(shell find . \( -name '*~' -o -name '#*#' -o -name '*.o' -o -name '*.res' -o -name $(DEFAULT_TARGET) \) -print)

prefix ?= /usr
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/games
sbindir ?= $(exec_prefix)/sbin
INSTALL ?= install
INSTALL_PROGRAM ?= $(INSTALL)
INSTALL_DATA ?= ${INSTALL} -m 644
install: vkquake
	$(INSTALL_PROGRAM) $(CURDIR)/vkquake $(DESTDIR)$(bindir)/vkquake
