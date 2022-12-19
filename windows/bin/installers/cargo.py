"""
.EXAMPLE
- Install with manager.
python3 cargo.py

- Uninstall global packages.
python3 cargo.py --uni
python3 cargo.py --uninstall
"""
import sys
from typing import Literal
from shutil import which
from os import system
import argparse


# --------------------------------------------------------------------------------------------------
# Install global library
# --------------------------------------------------------------------------------------------------
libs = [
    # For update libs
    {
        "name": "bingrep",
        "url": "https://wonderwall.hatenablog.com/entry/rust-command-line-tools",
        "description": "Greps through binaries from various OSs and architectures.",
    },
    {
        "name": "cargo-update",
        "url": "https://github.com/nabijaczleweli/cargo-update",
        "description": "Checking and applying updates to installed executables.",
    },
    {"name": "cargo-edit", "description": "cargo add command"},
    {
        "name": "cargo-binutils",
        "url": "https://github.com/rust-embedded/cargo-binutils",
        "description": "Invoke the LLVM tools shipped with the Rust toolchain",
    },
    # Development
    {
        "name": "cargo-generate",
        "url": "https://github.com/cargo-generate/cargo-generate",
        "description": "A new Rust project by leveraging a pre-existing git repository as a template.",
    },
    {
        "name": "cargo-make",
        "url": "https://github.com/sagiegurari/cargo-make",
        "description": "Rust task runner and build tool.",
    },
    {
        "name": "git-cliff",
        "url": "https://github.com/orhun/git-cliff",
        "description": "generate changelog files.",
    },
    {
        "name": "trunk",
        "url": "https://github.com/thedodd/trunk",
        "description": "Build, bundle & ship your Rust WASM application to the web.",
    },
    {
        "name": "rustfilt",
        "url": "https://github.com/luser/rustfilt",
        "description": "Demangle Rust symbol names using rustc-demangle. ",
    },
    # WebAssembly
    {
        "name": "wasm-pack",
        "url": "https://github.com/luser/rustfilt",
        "description": "generated WebAssembly. WARN: need openssl & perl.",
    },
    # calculation + conversion. (e.g. cpc '1KB to Byte' => 1000 Byte)
    {
        "name": "cpc",
        "url": "https://github.com/rustwasm/wasm-pack",
        "description": "cpc parses and evaluates strings of math.",
    },
    {
        "name": "choose",
        "url": "https://github.com/theryangeary/choose",
        "description": "similar to Python's list slices",
    },
]


class Color:
    BLACK = "\033[30m"  # (letter) black
    RED = "\033[31m"  # (letter) red
    GREEN = "\033[32m"  # (letter) green
    YELLOW = "\033[33m"  # (letter)
    BLUE = "\033[34m"  # (letter) blue
    MAGENTA = "\033[35m"  # (letter) magenta
    CYAN = "\033[36m"  # (letter) cyan
    WHITE = "\033[37m"  # (character) white
    COLOR_DEFAULT = "\033[39m"  # Reset the character color to default
    BOLD = "\033[1m"  # Bold text
    UNDERLINE = "\033[4m"  # Underline
    INVISIBLE = "\033[08m"  # invisible
    REVERSE = "\033[07m"  # Reverses text and background color
    BG_BLACK = "\033[40m"  # (background) black
    BG_RED = "\033[41m"  # (background) red
    BG_GREEN = "\033[42m"  # (background) green
    BG_YELLOW = "\033[43m"  # (background) yellow
    BG_BLUE = "\033[44m"  # (background) blue
    BG_MAGENTA = "\033[45m"  # (background)magenta
    BG_CYAN = "\033[46m"  # (background) cyan
    BG_WHITE = "\033[47m"  # (background) white
    BG_DEFAULT = "\033[49m"  # Reset background color to default
    RESET = "\033[0m"  # Reset all


# --------------------------------------------------------------------------------------------------
# Installer functions
# --------------------------------------------------------------------------------------------------


def check_rustup_available():
    if which("rustup"):
        return True
    print("rustup is not installed.")
    if which("scoop"):
        print(f"{Color.CYAN}Trying to install with scoop...{Color.RESET}")
        # Rust Package Manager(e.g: rustup (1.24.3))
        system("scoop install rustup")
        return True
    else:
        print(f"{Color.RED} Scoop is not installed. Install scoop first.{Color.RESET}")
        print(
            "\
            You can install it in one of the following ways.\
\
            Manually install: \
            Go to https: // rust.org \
\
\
            Install with Scoop:\
\
            Invoke - WebRequest - useb get.scoop.sh | Invoke - Expression \
            scoop install rustup \
            "
        )
        sys.exit(-1)


def get_args():
    # prepare
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "-uni", "--uninstall", help="Change uninstall mode.", action="store_true"
    )

    return parser.parse_args()


def manage_libs(mode: Literal["install", "uninstall"]):
    manage_lib(mode, libs)


def manage_lib(mode: Literal["install", "uninstall"], libraries: list[dict[str, str]]):
    for lib in libraries:
        [name, description] = [lib["name"], lib["description"]]

        print(f"{Color.GREEN} Installing {name} ...{Color.RESET}")
        print(f"{Color.BLUE} INFO: {description} {Color.RESET}")
        if lib["url"]:
            url = lib["url"]
            print(f"URL: {url}")

        if lib["installer"]:
            system(lib["installer"])
            continue
        system(f"cargo {mode} {name}")

        print("")


def install_rustup_libs():
    system("rustup target add wasm32-unknown-unknown")


def main():
    check_rustup_available()

    if uninstall:
        manage_libs("uninstall")
    else:
        manage_libs("install")

    install_rustup_libs()

    print(f"{Color.GREEN}Successes: Finished working on all libraries.{Color.RESET}")


if __name__ == "__main__":
    args = get_args()
    if uninstall := [args.uninstall]:
        print("Uninstall mode has been selected.")
    main()
