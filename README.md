# terminal_picker_cc

**Status**: 🔴 POC | **Mode**: 🤖 Claude Code | **Updated**: 2026-05-05

A Claude-Code-style interactive picker for shell scripts. Shows a list of options with arrow-key navigation and an optional inline textbox for typing a custom value. Single-file Python script using stdlib `curses`, no third-party deps.

## Why

`fzf` is a fuzzy filter, not a list picker, and `gum` is an extra install. Claude Code's `AskUserQuestion` UI (arrow nav with an inline "Other" textbox) does not exist as a shell tool. This package reproduces that UX in a small reusable CLI.

## Install

Pick one:

```bash
# 1) symlink onto your PATH
ln -s "$HOME/public/terminal_picker_cc/picker" "$HOME/.local/bin/picker"

# 2) add this directory to PATH in your shell rc
export PATH="$PATH:$HOME/public/terminal_picker_cc"

# 3) call it by absolute path from your scripts
"$HOME/public/terminal_picker_cc/picker" --custom foo bar
```

## Usage

```
picker [--header TEXT] [--custom] [--custom-label TEXT]
       [--default N] [--marker STR] [ITEM ...]
```

Items can be passed as args or piped on stdin (one per line). Selection is printed to stdout. Cancel (Esc / Ctrl+C) exits with code 130.

| Flag | Meaning |
|------|---------|
| `--header TEXT` | Bold header above the list, supports newlines |
| `--custom` | Append an entry whose label is "Type a new name..." that expands to an inline textbox when selected |
| `--custom-label TEXT` | Change that entry's label |
| `--default N` | Which option starts highlighted, 0-based, default 0 |
| `--marker STR` | Prefix shown next to the highlighted line, default `> ` |

## Keybindings

| Key | Action |
|-----|--------|
| up / k | Move highlight up, wraps |
| down / j | Move highlight down, wraps |
| enter | Select the highlighted option, or on the custom entry, switch to typing |
| enter while typing | Confirm typed value |
| esc while typing | Cancel typing, return to list |
| backspace while typing | Delete a character |
| esc / ctrl+c | Cancel the picker, exit 130 |

## Examples

```bash
# Plain list from args
choice=$(picker --header "Pick one" apple banana cherry)

# List from stdin
choice=$(ls /etc | picker --header "Files in /etc")

# With a custom-input fallback
folder=$(picker --header "Pick or type a folder" --custom drafts inbox archive)

# Detect custom vs listed value
selection=$(picker --custom apple banana)
case "$selection" in
    apple|banana) echo "picked from list" ;;
    "")           echo "cancelled" ;;
    *)            echo "typed: $selection" ;;
esac
```

## Implementation Notes

- Uses `curses` from the Python stdlib, so works on any system with `python3`.
- Reads keys and renders to `/dev/tty` so that the caller can capture stdout: `selection=$(picker ...)` works as expected.
- Stdin can carry the option list because it is consumed before `/dev/tty` is dup'd onto fd 0.

## Files

- `picker`: the executable script
- `readme.log`: source of this README in loglog format
- `STATUS.log`: project status
- `CLAUDE.md`: project conventions

## Known Limitations

- No multi-select.
- No filter-as-you-type, intentional, this is a picker, not a fuzzy finder.
- The custom textbox slot is fixed at the end of the list.
- Only ASCII printable characters are accepted in the textbox.
