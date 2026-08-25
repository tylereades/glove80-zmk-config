# Firmware archive

Known-good `.uf2` builds kept permanently so there is always a way back.
These are checked into git (via a `!firmware-archive/*.uf2` exception in
`.gitignore`) specifically so they survive a wiped laptop or a cleaned-out
Downloads folder.

## `baseline-v25.11-factory-macos-swapped-command.uf2`

**This is Tyler's rollback point — the layout he was running before any
customization work started.**

- Source: built via MoErgo's web Layout Editor, downloaded 2026-08-22.
- Original filename:
  `6394d58f-b617-4075-bfb1-6bc37009fd0b_v25.11_Glove80 Factory Default Layout for macOS - swapped command.uf2`
- MoErgo layout UUID: `6394d58f-b617-4075-bfb1-6bc37009fd0b`
- Firmware version: v25.11
- SHA-256: `6dc9af81ac102923407e561875cebf4e015e748ccff1fb34269585d3823c75ec`
- Size: 819712 bytes

**Important:** this is the factory macOS layout **with Command swapped**, so
it is *not* byte-identical to what `config/glove80.keymap` in this repo
builds. That file is the vanilla MoErgo default and does **not** include the
command swap. If the goal is "put it back exactly how it was," flash *this*
file, not a fresh build of this repo.

(Left open: `config/glove80.keymap` has not been reconciled with the command
swap. If this repo's keymap ever becomes the daily driver, that swap needs to
be ported into it first, or it will silently regress.)

## `sunaku-glorious-engrammer-qwerty-macos-diff1.uf2`

**The trial keymap** — sunaku's Glorious Engrammer, for A/B testing against
the baseline. Flashing this is reversible; flash the baseline to go back.

- Built from the `sunaku` branch of this repo (`config/glove80.keymap` there
  is a vendored copy of `keymap.zmk` from `sunaku/glove80-keymaps`).
- Build: GitHub Actions run 32804897394, commit `fd2ce74`.
- SHA-256: `703a475f429210851769f41b9f26cebaf783f1a7ec63e2b88d3d9d1a1313aed6`
- Size: 1077248 bytes

Two settings changed from sunaku's defaults:

| Setting | His default | Ours | Why |
|---|---|---|---|
| `OPERATING_SYSTEM` | `'L'` (Linux) | `'M'` (macOS) | he targets Linux; this matters a lot |
| `DIFFICULTY_LEVEL` | `0` (his custom 150ms) | `1` (500ms) | most forgiving, for learning |

Base alpha layer is QWERTY. Other layouts (Enthium, Dvorak, Colemak) are
reachable at runtime via the Magic layer, so switching does not require a
reflash.

To rebuild after changing settings: edit `config/glove80.keymap` on the
`sunaku` branch, push, and grab the artifact from the Build workflow.

## Flashing

Each half is flashed separately by copying the `.uf2` onto the mass-storage
volume that appears when that half is put into bootloader mode. Verify the
current bootloader key combo against MoErgo's docs (docs.moergo.com Glove80
user guide, "Putting into bootloader for firmware loading") rather than
relying on memory.
