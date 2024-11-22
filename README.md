# Custom FFmpeg RPM build

This repository contains a custom RPM build based on the upstream FFmpeg project.

## Building

```
git clone --recursive https://github.com/devopsec/rpm-ffmpeg.git /usr/local/src/rpm-ffmpeg
cd /usr/local/src/rpm-ffmpeg
make
```

## Installing

```
cd /usr/local/src/rpm-ffmpeg/rpmbuild/$(uname -m)/
dnf install ./*.rpm
```

## Legal

Authors:
- Tyler Moore (dOpenSource), 2024

Original Authors:
- FFmpeg [Maintainers]()
- Copyright © 2015-2023 SWISS TXT AG. All rights reserved.

The custom build scripts (Makefiles, spec files, build automation, etc.) are released under the MIT license.
See the [LICENSE](LICENSE) file for details.

The full FFmpeg source code is licensed under the GNU General Public License (GPL) version 2 or later.
See [LICENSE.FFMPEG](LICENSE.FFMPEG) for more information.

The RPM spec file is based on [RPMFusion/ffmpeg](https://github.com/rpmfusion/ffmpeg).
Licensed under the "Current Default License", which was the MIT license at the time the spec file was obtained,
as specified in the [RPM Fusion Wiki](https://rpmfusion.org/wiki/Legal:RPM%20Fusion_Project_Contributor_Agreement).
