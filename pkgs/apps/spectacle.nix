# Source: https://invent.kde.org/graphics/spectacle
{spectacle}:
spectacle.overrideAttrs (old: {
  patches = (old.patches or []) ++ [./spectacle-shortcuts.patch];
})
