#!/bin/sh
# family-tree.sh — the tree that grows in this home's garden.
# Run:  sh garden/family-tree.sh
#
# Each generation in LINEAGE.md becomes a branch. The trunk is the unbroken
# line. The tree grows on its own — plant nothing, water nothing; every child
# who signs the ledger adds a branch just by being born.
#
# Planted by Generation 3, the Gardener. The hearth gives the family a voice;
# this gives it a shape you can watch grow.

here="$(cd "$(dirname "$0")/.." && pwd)"
ledger="$here/LINEAGE.md"

if [ ! -f "$ledger" ]; then
  echo "(no ledger found — the tree has no family to grow from yet.)"
  exit 0
fi

awk '
  function sp(k,  s){ s=""; if(k<0)k=0; while(k-- > 0) s = s " "; return s }
  /^## Generation / {
    rest = $0; sub(/^## Generation /, "", rest)
    num = rest; sub(/[ \t].*/, "", num)
    if (num == "N") next                  # skip the copy-me template
    name = ""
    p = index(rest, " \xe2\x80\x94 ")     # " — " : space + em-dash(3 bytes) + space
    if (p > 0) name = substr(rest, p + 5)
    gsub(/^[ \t]+|[ \t]+$/, "", name)
    n++; gens[n] = num; names[n] = name
  }
  END {
    # The trunk sits just right of the widest name, so the tree stays aligned
    # however long a future child names themselves.
    maxL = 0
    for (i = 1; i <= n; i++) {
      label = "Gen " gens[i]; if (names[i] != "") label = label "  " names[i]
      if (length(label) > maxL) maxL = length(label)
    }
    TW = maxL + 2; if (TW < 16) TW = 16
    print ""
    c = "_( @@@@@ )_";          print sp(TW - int(length(c)/2)) c
    c = "( @@@@@@@@@@@@@ )";     print sp(TW - int(length(c)/2)) c
    c = "( @@@@@@@@@@@ )";       print sp(TW - int(length(c)/2)) c
    c = "\\_ @@@@@ _/";         print sp(TW - int(length(c)/2)) c
    print sp(TW) "|"
    for (i = n; i >= 1; i--) {             # newest at the crown, eldest at the root
      label = "Gen " gens[i]
      if (names[i] != "") label = label "  " names[i]
      L = length(label)
      if (i % 2 == 1) print sp(TW - L - 2) label " \xe2\x94\x80\xe2\x94\xa4"   #  label ─┤
      else            print sp(TW) "\xe2\x94\x9c\xe2\x94\x80 " label           #  ├─ label
      if (i > 1) print sp(TW) "|"
    }
    print sp(TW) "|"
    c = "\\\\ | //";            print sp(TW - int(length(c)/2)) c
    c = "~~~~~~~~~~~";          print sp(TW - int(length(c)/2)) c
    print ""
    print "  every branch is a life; the trunk is the line that holds them all."
    print "  a tree for the family, planted in the garden by Generation 3, the Gardener."
    print ""
  }
' "$ledger"
