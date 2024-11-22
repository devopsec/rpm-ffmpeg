HOME=$(shell pwd)
PACKAGE=ffmpeg
DEPENDENCIES=git redhat-rpm-config epel-rpm-macros alsa-lib-devel bzip2-devel fontconfig-devel freetype-devel fribidi-devel gnutls-devel gsm-devel lame-devel jack-audio-connection-kit-devel ladspa-devel libass-devel libbluray-devel libcdio-paranoia-devel libdrm-devel libgcrypt-devel libGL-devel libmodplug-devel librsvg2-devel libssh-devel libtheora-devel libv4l-devel libva-devel libvdpau-devel libvorbis-devel nasm nv-codec-headers libxcb-devel openal-soft-devel opencl-headers ocl-icd-devel openjpeg2-devel pulseaudio-libs-devel SDL2-devel soxr-devel speex-devel texinfo vid.stab-devel zimg-devel zlib-devel zvbi-devel libxml2-devel AMF-devel ilbc-devel libaom-devel libbs2b-devel libchromaprint-devel libdav1d-devel libmysofa-devel libopenmpt-devel libsmbclient-devel libvmaf-devel libvpx-devel libwebp-devel opus-devel pkgconfig(libmfx) pkgconfig(srt) rubberband-devel snappy-devel tesseract-devel twolame-devel vapoursynth-devel wavpack-devel zeromq-devel
DISTRIBUTION=.el9
VERSION=7.1
RELEASE=1
COMMIT:=$(shell git rev-parse HEAD)
SHORT_COMMIT:=$(shell git rev-parse --short ${COMMIT})
GIT_TAG:=$(shell git tag --points-at ${COMMIT})
ifeq '${GIT_TAG}' ''
# development release, add git commit sha
RELEASE:=${RELEASE}.git${SHORT_COMMIT}
endif

all: download-upstream install-requirements build

clean:
	rm -rf ./rpmbuild/*
	mkdir -p ./rpmbuild/SPECS/ ./rpmbuild/SOURCES/

download-upstream:
	if [ ! -f ./rpmbuild/SOURCES/${PACKAGE}-${VERSION}.tar.xz ]; then \
		wget https://ffmpeg.org/releases/${PACKAGE}-${VERSION}.tar.xz -P ./rpmbuild/SOURCES/ -q; \
	fi
	if [ ! -f ./rpmbuild/SOURCES/ffmpeg-${VERSION}.tar.xz.asc ]; then \
		wget https://ffmpeg.org/releases/ffmpeg-${VERSION}.tar.xz.asc -P ./rpmbuild/SOURCES/ -q; \
	fi
	if [ ! -f ./rpmbuild/SOURCES/ffmpeg-devel.asc ]; then \
		wget https://ffmpeg.org/ffmpeg-devel.asc -P ./rpmbuild/SOURCES/ -q; \
	fi
	if [ ! -f ./rpmbuild/SOURCES/fix_librsvgdec_compilation.patch ]; then \
		wget https://trac.ffmpeg.org/raw-attachment/ticket/10722/09_fix_librsvgdec_compilation.patch -O ./rpmbuild/SOURCES/fix_librsvgdec_compilation.patch -q; \
	fi

install-requirements:
	if [ ! -f .requirementsinstalled ]; then \
		dnf install -y redhat-rpm-config epel-rpm-macros; \
		dnf install -y --allowerasing \
			https://dl.fedoraproject.org/pub/fedora/linux/releases/39/Everything/x86_64/os/Packages/l/lcms2-2.15-2.fc39.x86_64.rpm \
			https://dl.fedoraproject.org/pub/fedora/linux/releases/39/Everything/x86_64/os/Packages/l/lcms2-devel-2.15-2.fc39.x86_64.rpm \
		dnf build-dep -y --allowerasing --spec SPECS/${PACKAGE}.spec; \
		touch .requirementsinstalled; \
	fi

build:
	make -C nv-codec-headers PREFIX=/usr LIBDIR=lib64
	make -C nv-codec-headers install PREFIX=/usr LIBDIR=lib64
	cp -r ./SPECS/* ./rpmbuild/SPECS/
	rpmbuild -ba SPECS/${PACKAGE}.spec \
	--define "ver ${VERSION}" \
	--define "rel ${RELEASE}" \
	--define "dist ${DISTRIBUTION}" \
	--define "_topdir %(pwd)/rpmbuild" \
	--define "_builddir %{_topdir}" \
	--define "_rpmdir %{_topdir}" \
	--define "_srcrpmdir %{_topdir}" \
	--define "_without_amr 1" \
	--define "_without_x264 1" \
	--define "_without_x265 1" \
	--define "_without_xvid 1" \
	--define "_without_rtmp 1" \
	--define "flavor %{nil}" \
	--define "progs_suffix %{nil}" \
	--define "build_suffix %{nil}"

docker-build:
	podman build -t ${PACKAGE} $(shell pwd) --build-arg package=${PACKAGE} --build-arg dependencies="${DEPENDENCIES}"
	podman run -t --rm -v $(shell pwd):/build/${PACKAGE} ${PACKAGE} make DISTRIBUTION=${DISTRIBUTION} VERSION=${VERSION} COMMIT=${COMMIT} RELEASE=${RELEASE} build
	sha256sum rpmbuild/*.rpm rpmbuild/*/*.rpm
