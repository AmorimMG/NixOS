{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (inputs.zapfast.packages.${pkgs.system}.default.overrideAttrs (_: {doCheck = false;}))
  ];
}
