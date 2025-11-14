{
  stdenv,
  fetchFromGitHub,

  nodejs,
  pnpm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "slidev";
  version = "52.8.0";

  src = fetchFromGitHub {
    owner = "slidevjs";
    repo = "slidev";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vEPfORowBby2uEnsk6szZWSsaORNLaYjk9DlTEmJrNs=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-YPCX5xz4Sy4EoZN1nHNtLG2FwKo5QuKbzPWEc07LF64=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}

    cp -r ./{packages,node_modules,docs,demo} $out/lib/
    ln -sf $out/lib/packages/slidev/bin/slidev.mjs $out/bin/slidev
  '';
})
