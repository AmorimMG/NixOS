{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (inputs.spotifast.packages.${pkgs.system}.default.overrideAttrs (_: {doCheck = false;}))
  ];
}
