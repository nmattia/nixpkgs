{ stdenv
, cmake
, fetchFromGitHub
#, libcxx
#, llvm
#, version
  ## on musl the shared objects don't build
#, enableShared ? ! stdenv.hostPlatform.isMusl }:
, enableStatic ? true
, enableShared ? true
}:
stdenv.mkDerivation {
  pname = "libunwind";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "llvm-mirror";
    repo = "libunwind";
    rev = "6a94361a8e8cb40c5ad5b17a7d6dcaf5cc862b60";
    sha256 = "19gycsmpf5rdi4m2a20vhyakvh6qxikvk9mzg5c7avq4cjjfr3vy";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags =
    stdenv.lib.optional (!enableShared) "-DLIBUNWIND_ENABLE_SHARED=OFF" ++
    stdenv.lib.optional (!enableStatic) "-DLIBUNWIND_ENABLE_STATIC=OFF";

  #postUnpack = ''
    #unpackFile ${libcxx.src}
    #unpackFile ${llvm.src}
    #cmakeFlagsArray=($cmakeFlagsArray -DLLVM_PATH=$PWD/$(ls -d llvm-*) -DLIBCXXABI_LIBCXX_PATH=$PWD/$(ls -d libcxx-*) )
  #'' + stdenv.lib.optionalString stdenv.isDarwin ''
    #export TRIPLE=x86_64-apple-darwin
  #'' + stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
    #patch -p1 -d $(ls -d libcxx-*) -i ${../libcxx-0001-musl-hacks.patch}
  #'';

  #cmakeFlags = stdenv.lib.optional (!enableShared) "-DLIBCXXABI_ENABLE_SHARED=OFF";

  #installPhase = if stdenv.isDarwin
    #then ''
      #for file in lib/*.dylib; do
        ## this should be done in CMake, but having trouble figuring out
        ## the magic combination of necessary CMake variables
        ## if you fancy a try, take a look at
        ## http://www.cmake.org/Wiki/CMake_RPATH_handling
        #install_name_tool -id $out/$file $file
      #done
      #make install
      #install -d 755 $out/include
      #install -m 644 ../include/*.h $out/include
    #''
    #else ''
      #install -d -m 755 $out/include $out/lib
      #install -m 644 lib/libc++abi.a $out/lib
      #${stdenv.lib.optionalString enableShared "install -m 644 lib/libc++abi.so.1.0 $out/lib"}
      #install -m 644 ../include/cxxabi.h $out/include
      #${stdenv.lib.optionalString enableShared "ln -s libc++abi.so.1.0 $out/lib/libc++abi.so"}
      #${stdenv.lib.optionalString enableShared "ln -s libc++abi.so.1.0 $out/lib/libc++abi.so.1"}
    #'';

  meta = {
    homepage = http://libcxxabi.llvm.org/;
    description = "A new implementation of low level support for a standard C++ library";
    license = with stdenv.lib.licenses; [ ncsa mit ];
    maintainers = with stdenv.lib.maintainers; [ vlstill ];
    platforms = stdenv.lib.platforms.unix;
  };
}
