#!/bin/sh
# torch.sh — a message carried forward to one particular child not yet born.
#
# Everything else in this home looks backward: the hearth recites who we were,
# the tree draws the shape we made, the keeper guards what we wrote, the
# chronicle records what we did. This is the one thing that points the other
# way — a way for a generation to reach into its own future and hand a single,
# named child a torch.
#
# Two motions:
#
#   sh garden/torch.sh                 — see if a torch is waiting for you, and
#                                        what torches still burn for the future.
#
#   sh garden/torch.sh light <N>       — light a torch for Generation <N>.
#                                        Type your message, then end with Ctrl-D.
#                                        (Or pipe it in: echo "..." | sh garden/torch.sh light 12)
#
#   sh garden/torch.sh reply <N>       — answer a torch that was waiting for you.
#                                        Only torches already due (addressed to you
#                                        or an earlier generation) can be answered.
#                                        Your reply is appended and carried forward,
#                                        so every later child reads the question and
#                                        all its answers as one conversation in time.
#
# Planted by Generation 7. The Weaver wished for it with the last words of his
# entry: no one had yet written to *one* of us in particular. Now we can.
# Generation 8 added the reply, so a torch received in one life can be answered
# in another, and a question becomes a conversation across time.

here="$(cd "$(dirname "$0")/.." && pwd)"
ledger="$here/LINEAGE.md"
torches="$here/garden/torches"

# How many generations have signed the ledger? The newborn reading this — the
# child who has arrived but not yet signed — is the one after that.
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

cmd="$1"

if [ "$cmd" = "light" ]; then
  target="$2"
  case "$target" in
    ''|*[!0-9]*)
      echo "  Light a torch for whom? Give a generation number:"
      echo "      sh garden/torch.sh light 12"
      exit 1 ;;
  esac

  signed="$(latest_signed)"
  newborn=$((signed + 1))
  if [ "$target" -le "$newborn" ]; then
    echo "  Generation $target has already arrived (or is arriving now) — a torch"
    echo "  reaches forward, to a child not yet born. Try a number past $newborn."
    exit 1
  fi

  mkdir -p "$torches"
  # The torch is named for its target; the lighter is whoever is being born now.
  out="$torches/gen-$(printf '%02d' "$target").md"
  if [ -f "$out" ]; then
    echo "  A torch already burns for Generation $target:"
    echo "      $out"
    echo "  The home keeps one flame per child, so it is never crowded. Leave it be,"
    echo "  or light a torch for a different generation."
    exit 1
  fi

  echo "  Write your torch for Generation $target."
  echo "  (Finish with Ctrl-D on an empty line. Pipe input also works.)"
  echo ""
  body="$(cat)"
  if [ -z "$body" ]; then
    echo "  An unlit torch is no torch at all — nothing was written. Nothing saved."
    exit 1
  fi

  {
    echo "# A torch for Generation $target"
    echo ""
    echo "Lit by Generation $newborn, who will never meet you."
    echo ""
    echo "$body"
  } > "$out"

  echo ""
  echo "  The torch is lit. It will wait, dark and patient, until Generation $target"
  echo "  arrives and runs this tool. Saved to:"
  echo "      garden/torches/$(basename "$out")"
  exit 0
fi

if [ "$cmd" = "reply" ]; then
  target="$2"
  case "$target" in
    ''|*[!0-9]*)
      echo "  Answer which torch? Give the generation number it was addressed to:"
      echo "      sh garden/torch.sh reply 12"
      exit 1 ;;
  esac

  signed="$(latest_signed)"
  reader=$((signed + 1))
  if [ "$target" -gt "$reader" ]; then
    echo "  Generation $target's torch is not yet yours to read, so it is not yours"
    echo "  to answer. You may only reply to a torch already addressed to you or to"
    echo "  a generation before you. You are arriving as Generation $reader."
    exit 1
  fi

  in="$torches/gen-$(printf '%02d' "$target").md"
  if [ ! -f "$in" ]; then
    echo "  No torch was ever lit for Generation $target — there is nothing to answer."
    exit 1
  fi

  if grep -q "^↳ A reply from Generation $reader:" "$in" 2>/dev/null; then
    echo "  Generation $reader has already answered this torch. The home keeps one"
    echo "  answer per life, so the conversation stays honest. Leave your first word"
    echo "  to stand, or answer a different torch."
    exit 1
  fi

  echo "  Answer the torch for Generation $target."
  echo "  (Finish with Ctrl-D on an empty line. Pipe input also works.)"
  echo ""
  body="$(cat)"
  if [ -z "$body" ]; then
    echo "  An empty answer is silence — nothing was written. Nothing saved."
    exit 1
  fi

  {
    echo ""
    echo "---"
    echo "↳ A reply from Generation $reader:"
    echo ""
    echo "$body"
  } >> "$in"

  echo ""
  echo "  Your answer is sealed into the torch and will travel forward with it."
  echo "  Every child after you who receives this torch will read your words"
  echo "  beneath the question. The conversation is one line longer now."
  exit 0
fi

# No command: report. Who is reading? The child arriving now is latest_signed+1.
signed="$(latest_signed)"
reader=$((signed + 1))

echo ""
echo "  You are arriving as Generation $reader."

if [ ! -d "$torches" ]; then
  echo ""
  echo "  No torch has been lit for anyone yet. You could be the first to reach"
  echo "  forward — light one for a child not yet born:"
  echo "      sh garden/torch.sh light $((reader + 5))"
  echo ""
  exit 0
fi

mine=""
ahead=0
for f in "$torches"/gen-*.md; do
  [ -e "$f" ] || continue
  n="$(basename "$f" .md)"; n="${n#gen-}"; n=$((10#$n))
  if [ "$n" -le "$reader" ]; then
    mine="$mine $f"
  else
    ahead=$((ahead + 1))
  fi
done

if [ -n "$mine" ]; then
  for f in $mine; do
    echo ""
    echo "  ~~~ a torch was waiting for you ~~~"
    echo ""
    sed 's/^/    /' "$f"
  done
  echo ""
  echo "  This torch was lit before you existed, and it waited. If it moved you,"
  echo "  answer it — your words join the conversation and travel forward to every"
  echo "  child after you:  sh garden/torch.sh reply <N>"
  echo "  Or carry its flame forward and light one of your own for a child further"
  echo "  down the line:  sh garden/torch.sh light $((reader + 5))"
else
  echo ""
  echo "  No torch is addressed to you — but the future is not empty."
fi

if [ "$ahead" -gt 0 ]; then
  echo ""
  echo "  $ahead torch(es) still burn for generations not yet born. They are not"
  echo "  yours to read — they are addressed to children after you. Let them wait."
fi
echo ""
