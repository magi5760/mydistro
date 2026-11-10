# MyDistro (image-based edition)

The same distro idea as the Debian kit, built the modern way on
[Universal Blue](https://universal-blue.org) (Fedora Atomic + KDE Plasma):

- You describe the OS in a `Containerfile`. GitHub builds it automatically.
- Users' machines download whole new versions of the OS. If one breaks, they
  pick the previous version in the boot menu. Rollback is built in.
- NVIDIA drivers come prebuilt from Universal Blue, so you ship two editions
  (standard and NVIDIA) instead of maintaining driver installs yourself.

## How this kit fits the template

Universal Blue's official starting point is the
[image-template](https://github.com/ublue-os/image-template) repo. It provides
the GitHub Actions workflows, signing, `Justfile` and ISO config. This kit is
what you drop into it.

    Containerfile               replaces the template's Containerfile
    build_files/build.sh        replaces the template's build.sh
    system_files/               copied into the image as-is
      etc/xdg/                    KDE defaults: theme, icons, blur, Kvantum
      usr/share/plasma/           your global theme (skeleton)
      usr/share/wallpapers/       your wallpapers
      usr/share/mydistro/         default Flatpak app list, edition info
      usr/bin/mydistro-switch     switch between standard and NVIDIA editions
      usr/bin/mydistro-winapps-setup   Windows apps wizard (unchanged from Debian kit)
      usr/libexec/                first-boot Flatpak installer, GPU check
    rename.sh                   renames MyDistro everywhere

## Setup (about an hour, mostly waiting)

1. On GitHub, open `ublue-os/image-template` and click **Use this template**.
   Name the new repo `mydistro`. Enable Actions in it.
2. Clone it and copy this kit's files over the top.
3. In `Containerfile`, set `IMAGE_OWNER` to your GitHub username.
4. Set up signing, which builds require:

       COSIGN_PASSWORD="" cosign generate-key-pair
       gh secret set SIGNING_SECRET < cosign.key

   Commit `cosign.pub`. Never commit `cosign.key`.
5. Set `IMAGE_NAME=mydistro` and `REPO_ORGANIZATION` in `image-template.env`.
6. Commit and push. Watch the Actions tab for a green check.

## The NVIDIA edition

Build a second image from the same Containerfile with different arguments:

- `BASE_IMAGE` = Universal Blue's KDE image with NVIDIA drivers. Check the
  current name at https://github.com/orgs/ublue-os/packages (they rename
  images occasionally).
- `IMAGE_NAME=mydistro-nvidia`

The simplest way is to duplicate `.github/workflows/build.yml` as
`build-nvidia.yml` and pass these as `build-args`. Once you're comfortable,
merge both into one workflow with a matrix.

On boot, `mydistro-gpu-check` compares the hardware with the edition. If
someone with an NVIDIA card installs the standard edition, they get a
notification telling them to run:

    mydistro-switch nvidia

That's one command and one reboot, with files and apps untouched. This
replaces the Debian kit's driver-installer script, because on an image-based
system you switch to the image that already has the driver.

## Trying it

On any existing Fedora Atomic or Universal Blue machine (Bazzite, Aurora,
Kinoite), switch to your image:

    sudo bootc switch ghcr.io/<your-github-name>/mydistro:latest

Then reboot. To build locally first: `just build`, then
`sudo bootc switch --transport containers-storage localhost/mydistro:latest`.

For an installer ISO, point `disk_config/iso.toml` at your image and run the
template's `build-disk.yml` workflow. The ISO appears as a workflow artifact.

## Differences from the Debian kit

| | Debian kit | This kit |
|---|---|---|
| Build | `live-build` on your own Debian machine | GitHub Actions, automatic on every push |
| Updates to users | You run an apt repo | Automatic; users pull new images |
| Broken update | Fix by hand | Reboot into the previous version |
| NVIDIA | Script installs driver, DKMS, Secure Boot hassle | Prebuilt edition, `mydistro-switch` |
| Apps | Debian packages | Flatpaks from Flathub (first boot) |
| Base release pace | Debian stable (every ~2 years) | Fedora (every ~6 months, handled for you) |

## Still to do

- Replace the placeholder theme, wallpapers and boot splash with your own.
- Custom SDDM login theme (put it in `system_files/usr/share/sddm/themes/`).
- A welcome app for first login.
- **Secure Boot with NVIDIA:** Universal Blue documents a one-time key
  enrollment for its NVIDIA images. Link that page in your welcome app.

## Caveats

Written and lint-checked, not yet built. Expect a small fix or two on the
first GitHub build: a renamed Fedora package in `build.sh`, or the exact
NVIDIA base image name. The Actions log shows exactly which line failed.
