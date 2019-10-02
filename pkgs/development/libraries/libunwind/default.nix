{ stdenv, fetchurl, autoreconfHook, xz }:

stdenv.mkDerivation rec {
  pname = "libunwind";
  version = "1.3.1";

  src = fetchurl {
    url = "mirror://savannah/libunwind/${pname}-${version}.tar.gz";
    sha256 = "1y0l08k6ak1mqbfj6accf9s5686kljwgsl4vcqpxzk5n74wpm6a3";
  };

  # There's no "gcc_s" (shared gcc lib) on musl.
  preAutoreconf = stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
    sed -i 's/lgcc_s/lgcc/' configure.ac
  '';

  patches = [ ./backtrace-only-with-glibc.patch ];

  nativeBuildInputs = [ autoreconfHook ];

  outputs = [ "out" "dev" ];

  propagatedBuildInputs = [ xz ];

  postInstall = ''
    find $out -name \*.la | while read file; do
      sed -i 's,-llzma,${xz.out}/lib/liblzma.la,' $file
    done
  '';

  doCheck = false; # fails

  meta = with stdenv.lib; {
    homepage = https://www.nongnu.org/libunwind;
    description = "A portable and efficient API to determine the call-chain of a program";
    maintainers = with maintainers; [ orivej ];
    platforms = platforms.linux;
    license = licenses.mit;
  };

  passthru.supportsHost = !stdenv.hostPlatform.isRiscV;
}
