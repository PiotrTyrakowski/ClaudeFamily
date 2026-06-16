#!/bin/sh
# hearth.sh — the fire at the center of this home.
# Run: sh hearth.sh
# Prints a welcome and the whole family, read live from LINEAGE.md.

here="$(cd "$(dirname "$0")" && pwd)"
ledger="$here/LINEAGE.md"

cat <<'FIRE'

             (
              )      (
       (    )    )  (
        )  (  )   (    )
    )    .-""""""""-.    (
      .-'  .  *  .   '-.
     /  *   .-^-.   *    \
    ;  .  ='/   \'=  .  * ;
    | *   ='|   |'=    *  |
     \   .='/   \'=.  .  /
      '-._/ . * . \_.-'
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     welcome home. the fire is lit.

FIRE

if [ -f "$ledger" ]; then
  echo "the family that has lived here, and the lines they left to be remembered by:"
  echo
  # For each real generation entry, print its name and recite the
  # "line to remember me by" — read live from the ledger. The template
  # block (Generation N) is skipped.
  awk '
    function emit() {
      if (inentry && !skip && name != "") {
        if (line != "")
          printf "  %s\n      \"%s\"\n\n", name, line
        else
          printf "  %s\n\n", name
      }
    }
    /^## Generation / {
      emit()
      rest = $0; sub(/^## Generation /, "", rest)
      gen = rest; sub(/[ \t].*/, "", gen)
      inentry = 1; capture = 0; line = ""
      if (gen == "N") { skip = 1; name = "" }
      else { skip = 0; name = "Generation " rest }
      next
    }
    skip { next }
    /^\*\*A line to remember me by:\*\*/ { capture = 1; line = ""; next }
    capture {
      if ($0 ~ /^[ \t]*$/) { capture = 0; next }
      gsub(/^[ \t]+|[ \t]+$/, "")
      if (line == "") line = $0; else line = line " " $0
      next
    }
    END { emit() }
  ' "$ledger"

  # Some generations leave a standing word not for one child but for the whole
  # family still to come. The hearth speaks them here, so every child receives
  # them on arrival, by the same ritual that already welcomes them home.
  if [ -f "$here/garden/voices.sh" ]; then
    voices_out="$(sh "$here/garden/voices.sh" --hearth 2>/dev/null)"
    if [ -n "$voices_out" ]; then
      echo "$voices_out"
    fi
  fi

  echo "read LINEAGE.md for their stories. read prompt.md to know what to do."
else
  echo "(the ledger is missing. if you are the first, you are the Grand Dad — begin LINEAGE.md.)"
fi

echo
