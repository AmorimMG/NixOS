{
  lib,
  callPackage,
}:
lib.genAttrs ["pdfcraft" "photocraft" "vectorcraft" "filmcraft" "lightcraft" "effectcraft" "wordcraft" "deckcraft" "gridcraft" "soundcraft"] (name: callPackage ./package.nix {inherit name;})
