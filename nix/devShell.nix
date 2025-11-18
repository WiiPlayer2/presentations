let
  talks =
    with builtins;
    let
      basePath = ./../talks;
      paths =
        mapAttrs
        (n: _: basePath + "/${n}")
        (readDir basePath);
    in
      paths;

  mkTalkSlidev =
    pkgs:
    talk:
    pkgs.writeShellApplication {
      name = "slidev-${talk}";
      runtimeInputs = with pkgs; [
        slidev
      ];
      text = ''
        cd "$FLAKE_ROOT/talks/${talk}"
        slidev --remote --open
      '';
    };

  talkSlidevs =
    pkgs:
    map
      (mkTalkSlidev pkgs)
      (builtins.attrNames talks);
in
{
  shellHook = ''
    export FLAKE_ROOT=$(pwd)
  '';

  packages = pkgs: with pkgs; [
    slidev
  ] ++ (talkSlidevs pkgs);
}
