# Glove80 ZMK config

Tyler's personal fork of `moergo-sc/glove80-zmk-config`, forked to
`tylereades/glove80-zmk-config`. Used to make keyboard behavior changes
(keybindings, macros, combos, custom behaviors) and produce firmware to
flash onto the physical Glove80.

## How this repo builds firmware (important gotcha)

This is **not** a standard west-based ZMK config repo. `config/default.nix`
builds firmware with Nix, pulling ZMK straight from `moergo-sc/zmk` (MoErgo's
own ZMK fork) as a plain GitHub checkout into `src/` — there is **no
`west.yml`** anywhere in this repo. `.github/workflows/build.yml` runs
`nix-build config -o combined` on every push and uploads `glove80.uf2` as a
build artifact.

Consequence: the usual ZMK community pattern of adding a third-party
out-of-tree behavior module via a `west.yml` manifest entry **does not apply
here**. If a future binding needs a custom module (e.g.
`caksoylar/zmk-smart-toggle` for the Cmd+Tab "swapper" — see below), figure
out first whether/how MoErgo's Nix build supports extra modules (check
`moergo-sc/zmk` for a flake/module mechanism) before assuming a west.yml
edit will work. This was not yet solved as of this file's writing.

## Layout

- `config/glove80.keymap` — the actual keymap devicetree (single file, not
  yet split into includes). Layers: `DEFAULT` (0), `LOWER` (1), `MAGIC` (2),
  `FACTORY_TEST` (3). Default layer is stock/unmodified — standard Mac
  layout, `LGUI` in the usual Cmd position.
- `config/glove80.conf` — Kconfig options.
- `config/info.json` — physical key layout (positions/labels for the
  `LAYOUT` physical layout), used by keymap-drawer for rendering.
- `config/keymap.json` — MoErgo web Layout Editor's own JSON representation
  of the keymap. **Not currently kept in sync** with `glove80.keymap` — all
  edits so far go through the raw `.keymap` file directly. Don't use the web
  Layout Editor on this fork without reconciling the two, or pick one tool
  and stick with it.

## Standing workflow for a new binding request

Tyler will describe a desired keybinding/behavior in plain language. Default
process (per Tyler's stated preference — confirm before pushing):

1. Edit `config/glove80.keymap` (or split into an included `.dtsi` if it's
   getting large/unwieldy).
2. Show Tyler the diff (and the keymap-drawer SVG once regenerated) and get
   a go-ahead before pushing.
3. Commit with a descriptive message, push to `origin` (the fork) — pushing
   to `main` triggers both `.github/workflows/build.yml` (firmware) and
   `.github/workflows/keymap-drawer.yaml` (auto-generated layout picture,
   committed back to `keymap-drawer/glove80.svg`).
4. Watch the Actions run (`gh run watch` or `gh run list`), confirm it's
   green.
5. Fetch the `glove80.uf2` artifact (`gh run download`) and tell Tyler it's
   ready, along with a reminder of the flashing steps below.

For simple, standard changes (plain key remaps, `&kp` swaps, ordinary
macros/combos using only stock ZMK behaviors) this repo pipeline works fine,
but MoErgo's web Layout Editor is faster for one-off simple changes if Tyler
ever wants to use it instead — just don't mix the two without syncing
`keymap.json`.

## Flashing

Use `./flash.sh` — it lists what's in `firmware-archive/`, waits for each
half's bootloader volume to mount, and copies the firmware over. It cannot
put the keyboard *into* bootloader mode; that's a physical combo:

| Half | Combo | Volume |
|---|---|---|
| Left | `Magic + Esc` | `GLV80LHBOOT` |
| Right | `Magic + '` | `GLV80RHBOOT` |

Verified against MoErgo's docs. (An earlier note here recorded the right-half
key as "Ä" — that was a mis-transcription from an indirect source. It is the
apostrophe.)

Both the stock and sunaku keymaps bind `&bootloader` to the same physical key
positions (34 and 45, the outermost home-row keys), so these combos work
regardless of which firmware is currently flashed.

**Hardware fallback if firmware won't boot:** hold `Magic + E` while flipping
the left half's power switch. Needs no working ZMK installation.

## Open items / not yet done

See **[docs/keybinding-options.md](docs/keybinding-options.md)** for the
full running list of ideas discussed but not yet applied (Cmd+Tab swapper,
home row mods + the Neovim/hjkl conflict it raises, alternative letter
layouts, and the `sunaku/glove80-keymaps` reference repo). Check there
before re-deriving any of this from scratch.

- Keymap not yet split into included files — fine for now, revisit if
  `glove80.keymap` gets unwieldy.
