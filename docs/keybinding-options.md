# Keybinding options & ideas

Running list of things discussed for this keymap but **not yet applied** to
`config/glove80.keymap`. Nothing in this document is live on the keyboard.
Treat it as a menu to come back to, not a plan in progress.

## 1. Cmd+Tab "swapper" — tap N times, go back N apps

**Goal:** replace the two-key `Cmd+Tab` chord with a single key. Tap it once
→ Cmd is held and Tab is sent (switcher opens, highlights previous app).
Tap the *same key* again → another Tab, Cmd still held → one more app back.
Press any other key → Cmd releases, confirming the selection. No holding
two keys at once.

**Status:** on hold. Blocked on a build-system gotcha (see below), not on
feasibility — the behavior itself is well-established in the ZMK community.

**What it needs:** the [`zmk-smart-toggle`](https://github.com/caksoylar/zmk-smart-toggle)
module (or the older, similar `tri-state`/"swapper" pattern). Example:

```c
// west.yml (or equivalent) — add as a module:
// - name: zmk-smart-toggle
//   url: https://github.com/caksoylar/zmk-smart-toggle
//   revision: main
//   path: modules/zmk-smart-toggle

behaviors {
    swapper: swapper {
        compatible = "zmk,behavior-smart-toggle";
        #binding-cells = <0>;
        bindings = <&kp LGUI>, <&kp TAB>;
    };
};
```

Then bind `&swapper` to one key on the base layer.

**The blocker:** this repo builds firmware via **Nix** (`config/default.nix`,
pulling ZMK straight from `moergo-sc/zmk`) rather than the standard ZMK
**west** manifest system — there is no `config/west.yml` here. The usual
"add a module to west.yml" instructions for third-party ZMK behaviors don't
directly apply. Before picking this back up: figure out whether/how
MoErgo's Nix build supports pulling in extra out-of-tree modules (check
`moergo-sc/zmk` for a flake or module mechanism), or find another way to
vendor the module's C code into the build. Not yet investigated.

## 2. Home row mods

**Goal:** the 4 innermost home-row keys per hand send a letter on tap, a
modifier on hold — so Ctrl/Shift/Alt/Cmd never require leaving the home
row. Reversible, additive, doesn't touch letter positions.

**Proposed mapping** (mirrored GACS convention, standard across the ZMK
community — same pattern the sunaku repo referenced below uses):

```
 ESC    A      S      D      F      G   |   H      J      K      L      ;      '
        ⌘hold  ⌥hold  ⌃hold  ⇧hold      |          ⇧hold  ⌃hold  ⌥hold  ⌘hold
        tap:A  tap:S  tap:D  tap:F      |          tap:J  tap:K  tap:L  tap:;
```

`ESC`, `G`, `H`, `'` stay plain — that's the standard convention (those are
stretch/outer keys, not the 4 comfortable innermost-per-hand positions).

**Devicetree:**

```c
behaviors {
    hm: home_row_mod {
        compatible = "zmk,behavior-hold-tap";
        label = "HOME_ROW_MOD";
        #binding-cells = <2>;
        tapping-term-ms = <200>;
        quick-tap-ms = <175>;
        flavor = "tap-preferred";
        bindings = <&kp>, <&kp>;
    };
};
```

```c
&kp ESC  &hm LGUI A  &hm LALT S  &hm LCTRL D  &hm LSHFT F  &kp G      &kp H  &hm LSHFT J  &hm LCTRL K  &hm LALT L  &hm LGUI SEMI  &kp SQT
```

`tap-preferred` + a generous `tapping-term-ms` is the forgiving starting
point — favors "you're typing" over "you're holding a modifier" unless you
actually pause on the key. Tightening it (e.g. `balanced`, or restricting
holds to opposite-hand rolls via `hold-trigger-key-positions`) is a later
tuning step once it feels natural, not a day-one setting.

### How this interacts with the shortcuts Tyler actually uses

- **`Cmd+Shift+[` / `Cmd+Shift+]`** (tab switching): genuinely better. Both
  mods live on the left hand (A=Cmd, F=Shift), right hand taps `[`/`]` —
  comfortable two-hand chord, no corner-key reaches.
- **`Ctrl+Tab`**: also better. Ctrl is on D (middle finger), which leaves
  the pinky free to hit Tab right above it.
- **`Cmd+Tab`**: a wash, not a win. Cmd (A) and Tab share the same pinky's
  column, so you can't hold one and tap the other with the same finger.
  In practice this one keeps using the existing dedicated thumb `LGUI` key
  (already on the default layer, position 55) — which is fine, that's
  already a comfortable cross-hand combo.

### Important conflict: Neovim / hjkl

The full mirrored mapping above puts modifiers on `J`, `K`, `L` — three of
Neovim's four directional keys (`j`=down, `k`=up, `l`=right). A held
mod-tap key sends the modifier, not a repeated tap of the letter — so
**holding `j` or `k` to scroll continuously in Neovim would stop working**
under the full mirrored version (it'd hold Ctrl/Alt instead of repeating
`j`/`k`). This is a mechanical consequence of how hold-tap works, not a
tuning issue.

**Recommended variant:** left-hand-only home row mods (A/S/D/F →
Cmd/Alt/Ctrl/Shift), skip the right-hand mirror on J/K/L entirely. None of
the shortcuts above need modifiers held on *both* hands at once, so nothing
is lost — Neovim's `hjkl` stays completely untouched.

**Next step when revisited:** build the left-hand-only variant, show a
diff, try it for a few days before deciding whether to extend to the right
hand at all (and if so, on which keys other than J/K/L).

## 3. Alternative letter layouts (reference only — not being pursued now)

Came up while explaining terminology, not because there's an active plan to
switch. All of these remap *which letter sits under which key*, independent
of home row mods / layers (which are about key *behavior*, not letter
placement — the two are orthogonal and compose fine together).

| Layout | Era | Philosophy |
|---|---|---|
| QWERTY | 1870s | Not optimized for typing; historical/mechanical-typewriter default |
| Dvorak | 1936 | Oldest alternative; vowels/common consonants on home row, heavy hand-alternation |
| Colemak | 2006 | Reduces travel like Dvorak but leaves Z/X/C/V and punctuation near QWERTY positions for an easier transition |
| Colemak-DH | community mod | Colemak + fixes the D/H inward stretch; the most-recommended pick for split/columnar boards like the Glove80 |
| Workman | 2010 | Different finger-strength model than Dvorak/Colemak |
| Engram | ~2021 | Built from raw n-gram (letter-pair/trigram) frequency data; most different from QWERTY; assumes heavy thumb-key use; criticized for leaning on weaker fingers to hit its numbers |
| Graphite | newer | Extra emphasis on punctuation/symbol ergonomics — more relevant to a programmer/Vim user than to prose typists |

**If ever revisited:** switching the letter layout is a much bigger
commitment than anything else in this document — it costs real typing
speed for 1-3 weeks while muscle memory rebuilds, and it has direct
consequences for `hjkl` (all of these scatter h/j/k/l to different
fingers). Community consensus currently leans Colemak-DH as the standard
recommendation if this ever becomes a real project; Graphite is the one
worth a look specifically because of the punctuation angle. No independent,
rigorous study has actually proven any of these reduce RSI over
well-configured QWERTY — recommendations here are based on computed effort
metrics and community experience, not clinical evidence.

## 4. Reference repo: `sunaku/glove80-keymaps`

A much more elaborate personal Glove80 config, useful as a reference for
patterns (not something being adopted wholesale):

- [Miryoku](https://github.com/manna-harbour/miryoku)-style architecture:
  6 dedicated function layers (Cursor, Number, Function, Symbol, Mouse,
  System) reached via thumb keys, home row mods mirrored onto *every*
  layer, not just the base one.
- Uses the **Enthium** letter layout (same family as Engram/Graphite
  above), with QWERTY/Dvorak/Colemak also selectable.
- Generates the whole firmware from YAML via a Ruby/Rake toolchain,
  including layer diagrams and PDF docs — a full framework, not a
  hand-edited `.keymap`.

## Open questions for whenever this gets picked back up

- Home row mods: left-hand-only, or full mirrored with J/K/L specifically
  excluded/relocated? (Leaning left-hand-only per the analysis above.)
- Swapper: how does MoErgo's Nix build actually handle third-party ZMK
  modules, if at all?
- No decision yet on pursuing an alternative letter layout — parked as
  background knowledge, not a project.
