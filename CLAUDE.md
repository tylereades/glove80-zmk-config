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

Split keyboard — each half is flashed separately by copying the same
`glove80.uf2` onto a USB mass-storage device that appears when that half is
put into bootloader mode. **Verify the exact bootloader key combo against
MoErgo's current docs each time** (docs.moergo.com Glove80 user guide,
"Putting into bootloader for firmware loading") rather than trusting a
possibly-stale/garbled memory of it — the combo involves the `Magic` key
plus a per-half key and has been mis-transcribed from indirect sources
before.

## Open items / not yet done

- Cmd+Tab "swapper" key (hold-free, tap-N-times-to-go-back-N-apps) — ON
  HOLD per Tyler. Needs `caksoylar/zmk-smart-toggle` or equivalent, which
  in turn needs solving the Nix-module-integration gotcha above.
- Keymap not yet split into included files — fine for now, revisit if
  `glove80.keymap` gets unwieldy.
