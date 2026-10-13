# Decompressor

A Bash script that repeatedly unpacks a file until it reaches plain text. It handles gzip, bzip2 and tar layers in any order, and can start from a hex dump.

Written while solving [OverTheWire Bandit level 12 → 13](https://overthewire.org/wargames/bandit/bandit13.html), where the password is buried under many nested compression layers. Doing it by hand meant a lot of `file`, rename and decompress, so I automated it.

## Running it

```bash
./bandit12.sh -h data.txt   # input is a hex dump (xxd format)
./bandit12.sh archive.gz    # input is already binary
```

Each intermediate layer is written to `tmp/0`, `tmp/1`, … and the script prints the type it detected at each step, then the final contents. `data.txt` is the level's file on the Bandit server; it is not included here, and neither are the solved outputs, because OverTheWire asks people not to publish level passwords.

## How it works

1. With `-h`, reverse the hex dump with `xxd -r`.
2. Run `file` on the current layer and read the detected type.
3. `gzip` → `zcat`, `bzip2` → `bzip2 -d`, `POSIX` (tar) → `tar x`.
4. Anything else is treated as the end: print it and stop.

## What I learnt

- `file` identifies content from magic bytes, not the extension, which is what makes a loop like this possible.
- `getopts` for flag parsing, and `"${@: -1}"` to take the last argument.
- `$(cmd)` runs `cmd` and then tries to *execute its output*. I originally wrapped every command in `$( )`; it only worked because those commands print nothing. They are now plain commands.
- Quote variables (`"$input_file"`) so file names with spaces do not break.

## What I would do better

- Use `mktemp -d` instead of a fixed `tmp/` folder, and clean up afterwards.
- Detect more formats (xz, zip) and stop on an unknown binary type, rather than `cat`-ing it to the terminal.
- Add `set -euo pipefail` so a failed step stops the script.
- Run it through [ShellCheck](https://www.shellcheck.net/).
