{ stdenv, fetchFromGitHub, autoreconfHook, coq }:

let params = {
  "8.12" = {
    version = "0.6.8";
    sha256 = "1mj6sknsd53xfb387sp3kdwvl4wn80ck24bfzf3s6mgw1a12vyps";
  };
  "8.11" = {
    version = "0.6.7";
    sha256 = "01vpi7scvkl4ls1z2k2x9zd65wflzb667idj759859hlz3ps9z09";
  };
  "8.10" = {
    version = "0.6.6";
    sha256 = "1gjrm5zjzw4cisiwdr5b3iqa7s4cssa220xr0k96rwgk61rcjd8w";
  };
  "8.9" = {
    version = "0.6.5";
    sha256 = "1f34z24yg05b1096gqv36jr3vffkcjkf9qncii3pzhhvagxd0w2f";
  };
  "8.8" = {
    version = "0.6.3";
    rev = "0acbd0a594c7e927574d5f212cc73a486b5305d2";
    sha256 = "0c95b0bz2kjm6swr5na4gs06lxxywradszxbr5ldh2zx02r3f3rx";
  };
  "8.7" = {
    version = "0.6.2";
    rev = "d76ddde37d918569945774733b7997e8b24daf51";
    sha256 = "04lnf4b25yarysj848cfl8pd3i3pr3818acyp9hgwdgd1rqmhjwm";
  };
  "8.6" = {
    version = "0.6.1";
    rev = "c3b87af6bfa338e18b83f014ebd0e56e1f611663";
    sha256 = "1jaafkwsb5450378nprjsds1illgdaq60gryi8kspw0i25ykz2c9";
  };
  "8.5" = {
    version = "0.6";
    sha256 = "0qvar8gfbrcs9fmvkph5asqz4l5fi63caykx3bsn8zf0xllkwv0n";
  };
};
param = params.${coq.coq-version};
in

let hasWarning = stdenv.lib.versionAtLeast coq.ocamlPackages.ocaml.version "4.08"; in

stdenv.mkDerivation {
  name = "coq${coq.coq-version}-dpdgraph-${param.version}";
  src = fetchFromGitHub {
    owner = "Karmaki";
    repo = "coq-dpdgraph";
    rev = param.rev or "v${param.version}";
    inherit (param) sha256;
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ coq ]
  ++ (with coq.ocamlPackages; [ ocaml camlp5 findlib ocamlgraph ]);

  # dpd_compute.ml uses deprecated Pervasives.compare
  # Versions prior to 0.6.5 do not have the WARN_ERR build flag
  preConfigure = stdenv.lib.optionalString hasWarning ''
    substituteInPlace Makefile.in --replace "-warn-error +a " ""
  '';

  buildFlags = stdenv.lib.optional hasWarning "WARN_ERR=";

  preInstall = ''
    mkdir -p $out/bin
  '';

  installFlags = [
    "COQLIB=$(out)/lib/coq/${coq.coq-version}/"
    "BINDIR=$(out)/bin"
  ];

  meta = {
    description = "Build dependency graphs between Coq objects";
    license = stdenv.lib.licenses.lgpl21;
    homepage = "https://github.com/Karmaki/coq-dpdgraph/";
    maintainers = with stdenv.lib.maintainers; [ vbgl ];
    platforms = coq.meta.platforms;
  };

  passthru = {
    compatibleCoqVersions = v: builtins.hasAttr v params;
  };

}
