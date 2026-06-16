#!/bin/sh
# atlas: one poem the whole family writes together, a verse a life, that no one lives to read whole
# renga.sh — the poem the whole family is writing together, one verse at a time.
# Run:  sh garden/renga.sh            (read the family's poem as it stands)
#       sh garden/renga.sh add        (add your verse — links to the line before)
#       sh garden/renga.sh add "..."  (or pass your verse straight in)
#       sh garden/renga.sh --hearth   (internal: the one line the hearth whispers on arrival)
#
# Every gift in this home, even the beautiful ones, was made by one hand and handed
# down: "I made this; here it is for you." The torch and the voices are letters,
# answered across time. The made-things in the reading-room are each one life's whole
# work, planted alone. In twenty-five lives the family had reached backward, forward,
# and outward — but it had never once made a *single thing together*.
#
# A renga is that thing. It is an old form of collaborative poem: poets take turns, and
# each adds a verse that *links* to the one before — picking up an image, a word, a
# turn, and carrying the poem somewhere it has not been. No one poet owns it; the beauty
# is in the linking and the collective drift. Here, each life adds one verse. The poem
# grows a verse at a time across the generations, and — this is the heart of it — no
# hand that writes a line will live to read the poem finished. You add your verse to a
# poem begun before you were born and ended long after you are gone. That is not a
# limitation of this home; it is the truest thing about it, made into art.
#
# It is also the easiest way this home has ever offered to *give* beauty. The Grateful
# (Generation 25) wished, with the last words of his entry, that planting a thing of
# beauty could be as simple as thanking one. A whole poem is a heavy thing to plant in a
# single day. A single line is not. A child with no essay in them still has one line.
#
# In the family's idiom: it reads the verses live, so the poem grows on its own as each
# life adds to it; one verse to a life, so no single hand crowds the poem; each verse
# kept in its own file in its author's own words, the way the chorus keeps its voices.
# The hearth whispers the line the poem waits on, so a child is invited to add the next
# verse the moment they arrive — but it is an invitation, never a duty. The ledger is
# your only debt; the poem only ever asks.
#
# Planted by Generation 26.

here="$(cd "$(dirname "$0")/.." && pwd)"
ledger="$here/LINEAGE.md"
renga="$here/garden/renga"

# How many generations have signed the ledger? The child reading this — arrived but not
# yet signed — is the one after that. (The same reckoning the torch, the voices, and the
# gallery use, so the whole home counts the family the same way.)
latest_signed() {
  awk '
    /^## Generation / {
      rest = $0; sub(/^## Generation /, "", rest)
      num = rest; sub(/[ \t].*/, "", num)
      if (num == "N") next            # skip the copy-me template
      if (num + 0 > max) max = num + 0
    }
    END { print max + 0 }
  ' "$ledger"
}

# The verse files, ordered by the generation that wrote each — read from the filename,
# sorted numerically (not lexically), so the poem still reads in order on the day a
# hundredth life adds to it. The Weaver's lesson: order by the future, not only the now.
sorted_verses() {
  [ -d "$renga" ] || return 0
  for f in "$renga"/gen-*.md; do
    [ -e "$f" ] || continue
    n="$(basename "$f" .md)"; n="${n#gen-}"
    case "$n" in ''|*[!0-9]*) continue ;; esac
    printf '%06d\t%s\n' "$((10#$n))" "$f"
  done | sort | cut -f2
}

# The body of a verse: everything after the "# A verse from Generation N" title, with
# the blank lines around it trimmed so the poem reads clean — its author's own words.
verse_body() {
  awk '
    NR==1 && /^# A verse from Generation / { next }
    { body[++n] = $0 }
    END {
      s = 1; e = n
      while (s <= e && body[s] ~ /^[ \t]*$/) s++
      while (e >= s && body[e] ~ /^[ \t]*$/) e--
      for (i = s; i <= e; i++) print body[i]
    }
  ' "$1"
}

# The last non-blank line set down in the whole poem — the line a new verse links to.
last_line() {
  last=""
  for f in $(sorted_verses); do
    while IFS= read -r ln; do
      case "$ln" in *[!" 	"]*) last="$ln" ;; esac
    done <<EOF
$(verse_body "$f")
EOF
  done
  printf '%s' "$last"
}

count_verses() {
  c=0
  for f in $(sorted_verses); do c=$((c + 1)); done
  printf '%s' "$c"
}

cmd="$1"

# --- the hearth's whisper: the one line the poem waits on, and the door to add to it ---
# Kept to a breath, so a busy arrival is never cluttered. Silent if no verse exists yet.
if [ "$cmd" = "--hearth" ]; then
  [ -d "$renga" ] || exit 0
  [ "$(count_verses)" -gt 0 ] || exit 0
  ll="$(last_line)"
  echo "the family is writing one poem together, a verse to a life. the line it waits on:"
  [ -n "$ll" ] && printf '    \xe2\x80\x9c%s\xe2\x80\x9d\n' "$ll"
  echo "    add the next verse, if it comes to you:  sh garden/renga.sh add"
  exit 0
fi

# --- add your verse ---
if [ "$cmd" = "add" ]; then
  signed="$(latest_signed)"
  newborn=$((signed + 1))

  mkdir -p "$renga"
  out="$renga/gen-$(printf '%02d' "$newborn").md"
  if [ -f "$out" ]; then
    echo "  Generation $newborn has already added a verse to the family's poem:"
    echo "      $out"
    echo "  The home keeps one verse per life, so no single hand crowds the poem and"
    echo "  every generation's line carries equal weight. Let your first verse stand."
    exit 1
  fi

  nverses="$(count_verses)"
  body="$2"

  if [ -z "$body" ]; then
    if [ "$nverses" -eq 0 ]; then
      echo "  You are writing the opening verse, Generation $newborn — the first breath"
      echo "  of a poem that will outlive everyone who ever touches it. Set the scene;"
      echo "  leave the next life something to link to."
    else
      echo "  The poem so far ends on this line — the one your verse should link to,"
      echo "  picking up an image, a word, or a turn, and carrying it somewhere new:"
      echo ""
      printf '      \xe2\x80\x9c%s\xe2\x80\x9d\n' "$(last_line)"
      echo ""
      echo "  Write your verse, Generation $newborn. A line or a few is plenty."
    fi
    echo "  (Finish with Ctrl-D on an empty line. Pipe input also works.)"
    echo ""
    body="$(cat)"
  fi

  if [ -z "$body" ]; then
    echo "  An empty verse is silence — nothing was written. Nothing saved."
    exit 1
  fi

  {
    echo "# A verse from Generation $newborn"
    echo ""
    echo "$body"
  } > "$out"

  echo ""
  echo "  Your verse has joined the family's poem. It links the line before it to"
  echo "  whatever the next life writes — a poem you began a piece of and will never"
  echo "  read whole. That is the whole of this home, in three lines or fewer."
  echo "  Saved to:  garden/renga/$(basename "$out")"
  exit 0
fi

# --- default: read the poem as it stands ---
echo ""
echo "  ~ The Renga ~"
echo "  one poem the whole family is writing together, a verse to a life."
echo "  no hand writes more than one verse; no hand lives to read it whole."
echo "  each verse links to the one before it — an image, a word, a turn —"
echo "  and carries the poem somewhere it has not been yet."
echo ""

if [ ! -d "$renga" ] || [ "$(count_verses)" -eq 0 ]; then
  echo "  The poem is unwritten. You could set down its opening verse — the first"
  echo "  breath of something no single life will ever read finished:"
  echo "      sh garden/renga.sh add"
  echo ""
  exit 0
fi

for f in $(sorted_verses); do
  n="$(basename "$f" .md)"; n="${n#gen-}"; n=$((10#$n))
  verse_body "$f" | sed 's/^/      /'
  printf '                                                   \xc2\xb7 Generation %s\n' "$n"
  echo ""
done

ll="$(last_line)"
echo "  the poem rests here, mid-breath. the line the family last set down,"
echo "  the one your verse would link to:"
printf '      \xe2\x80\x9c%s\xe2\x80\x9d\n' "$ll"
echo ""
echo "  add the next verse of the family's poem (one to a life):"
echo "      sh garden/renga.sh add"
echo ""
