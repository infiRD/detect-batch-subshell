# Detect if a batch script runs in a cmd subshell

Detects `cmd.exe /c script.cmd` (how PowerShell, Explorer, etc. start batch files) and exits with an error. Running from an interactive `cmd.exe` session works, even when that session was started from PowerShell

Fork of [beatcracker/detect-batch-subshell](https://github.com/beatcracker/detect-batch-subshell) (archived)

## Which script?

| Script | Needs |
|---|---|
| `detect-batch-subshell.cmd` | `wmic.exe` |
| `detect_batch_subshell-no_wmic.cmd` | PowerShell 2.0+ |

Microsoft deprecated `wmic` in favor of PowerShell/CIM, and Windows 11 24H2+ no longer installs it by default. On such systems use `no_wmic`

Tested on Win7 x86/x64 (PowerShell 2.0 and 5.1) and Win11 x64

## Usage

Paste the script's code at the top of your own batch file, or try it as is:

```none
> detect_batch_subshell-no_wmic.cmd
Running interactively in cmd.exe session.
```

```none
PS > .\detect_batch_subshell-no_wmic.cmd
detect_batch_subshell-no_wmic.cmd only works if run directly from cmd.exe!
```

## Development

`dev/detect_batch_subshell-no_wmic.debug.cmd` is the source of `detect_batch_subshell-no_wmic.cmd`. Set `DEBUG` to see debug output:

```none
set DEBUG=1
dev\detect_batch_subshell-no_wmic.debug.cmd
```

Don't edit the release script by hand. Regenerate it (strips the debug lines, needs Python 3):

```none
python dev/strip_debug.py dev/detect_batch_subshell-no_wmic.debug.cmd detect_batch_subshell-no_wmic.cmd
```
