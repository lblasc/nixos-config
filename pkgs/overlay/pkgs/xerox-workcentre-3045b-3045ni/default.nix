{ lib, stdenv, fetchzip, rpmextract, unzip, autoPatchelfHook, cups }:

stdenv.mkDerivation {
  name = "xerox-workcentre-3045b-3045ni";

  src = fetchzip {
    url = "https://www.support.xerox.com/download/118988#driver.zip";
    sha256 = "1wzi9p59klpnqz8nzych6fq3n5icmsp7v9a2bbnv9abnr2yq72a9";
  };

  buildInputs = [ unzip rpmextract autoPatchelfHook cups ];

  installPhase = ''
    mkdir $out
    rpmextract Xerox-WorkCentre-3045B_3045NI-1.0-28.i586.rpm
    mv usr/share $out/share
    mv usr/lib $out/lib
  '';

  meta = with lib; {
    description = "xerox workcentre 3045b-3045ni cups driver";
    platforms = platforms.all;
    maintainers = with maintainers; [ lblasc ];
  };
}

