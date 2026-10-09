# terminal_picker_cc

**Status**: 🟡 MVP | **Mode**: 🤖 Claude Code | **Updated**: 2026-10-08

A Claude-Code-style interactive picker for shell scripts. Shows a list of options with arrow-key navigation. With `--custom`, an inline textbox row is added (last row by default, first with `--custom-first`): when focused, typing goes straight into it, no extra Enter required. Options can carry a separate display string (`VALUE<TAB>DISPLAY`) with light color/attribute markup, so lists render as colored tables while still returning a clean value. Spaces and any printable ASCII are valid input. Single-file Python script using stdlib `curses`, no third-party deps.

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
picker [--header TEXT] [--custom] [--custom-first] [--custom-label TEXT]
       [--default N] [--marker STR] [ITEM ...]
```

Items can be passed as args or piped on stdin (one per line). Selection is printed to stdout. Cancel (Esc / Ctrl+C) exits with code 130.

| Flag | Meaning |
|------|---------|
| `--header TEXT` | Bold header above the list, supports newlines |
| `--custom` | Add an inline textbox row that accepts typed input the moment it is focused |
| `--custom-first` | Place the textbox row at the top instead of the bottom |
| `--custom-label TEXT` | Placeholder shown in the textbox when empty and unfocused (supports markup) |
| `--default N` | Which option starts highlighted, 0-based, default 0 |
| `--marker STR` | Prefix shown next to the highlighted line, default `> ` |

### Item format

| Form | Meaning |
|------|---------|
| `ITEM` | value and display are the same (backward compatible) |
| `VALUE<TAB>DISPLAY` | `VALUE` is returned on select; `DISPLAY` is rendered with markup |

### Colors and text attributes

`DISPLAY` (and `--custom-label`) support `{token}` markup, `{/}` resets to normal.

- Colors: `{black}` `{red}` `{green}` `{yellow}` `{blue}` `{magenta}` `{cyan}` `{white}`
- Attributes: `{bold}` `{dim}` `{underline}` `{reverse}`

Unknown tokens are shown literally. Color tokens are stripped when the terminal cannot do color. The selected row is shown bold, colors preserved.

## Keybindings

| Key | Action |
|-----|--------|
| up / down | Move highlight, wraps |
| k / j | Same as up / down, but only when not on the textbox row (so j and k can be typed) |
| enter | Confirm the highlighted option, or return the typed value when the textbox is focused and non-empty; enter on an empty textbox does nothing |
| any printable key (textbox focused) | Append to the textbox buffer (space included) |
| backspace (textbox focused) | Delete a character |
| esc / ctrl+c | Cancel the picker, exit 130 |

## Examples

```bash
# Plain list from args
choice=$(picker --header "Pick one" apple banana cherry)

# List from stdin
choice=$(ls /etc | picker --header "Files in /etc")

# With a custom-input fallback
folder=$(picker --header "Pick or type a folder" --custom drafts inbox archive)

# Type-to-create first, colored table (value<TAB>display)
picker --custom --custom-first --custom-label "{green}+{/}  {dim}new name...{/}" \
    "dev\t{cyan}●{/}  dev   2 windows  {yellow}(attached){/}" \
    "notes"

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

## Consumers

`tmux_setting` uses it for the tmux session picker (`bin/tm-picker`, `bin/tm-login`): a colored table with a type-to-create row first. `tm-picker` falls back to a plain-text chooser when the picker is absent.

## Known Limitations

- No multi-select.
- No filter-as-you-type, intentional, this is a picker, not a fuzzy finder.
- The textbox slot is at the end by default, or first with `--custom-first`.
- Only ASCII printable characters (including space) are accepted in the textbox; no unicode input.
- No scrolling for very long lists.
