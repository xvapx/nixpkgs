{ stdenv, fetchurl, python3Packages, makeWrapper
, enablePlayer ? true, libvlc, qt5, lib }:

stdenv.mkDerivation rec {
  pname = "tribler";
  version = "7.8.0";

  src = fetchurl {
    url = "https://github.com/Tribler/tribler/releases/download/v${version}/Tribler-v${version}.tar.xz";
    sha256 = "0934v4v2dq33v7br99c3zsab8xqlgjd7hk2jym5pwx98yzvdjy87";
  };

  nativeBuildInputs = [
    python3Packages.wrapPython
    makeWrapper
  ];

  buildInputs = [
    python3Packages.python
  ];

  pythonPath = with python3Packages; [
    aiohttp
    aiohttp-apispec
    twisted
    netifaces
    pycrypto
    pyasn1
    requests
    m2crypto
    pyqt5
    chardet
    cherrypy
    cryptography
    libnacl
    configobj
    decorator
    feedparser
    service-identity
    psutil
    pillow
    networkx
    pony
    lz4
    pyqtgraph
  ];

  postPatch = ''
    ${lib.optionalString enablePlayer ''
      substituteInPlace "./src/tribler-gui/tribler_gui/vlc.py" --replace "ctypes.CDLL(p)" "ctypes.CDLL('${libvlc}/lib/libvlc.so')"
      substituteInPlace "./src/tribler-gui/tribler_gui//widgets/videoplayerpage.py" \
        --replace "if vlc and vlc.plugin_path" "if vlc" \
        --replace "os.environ['VLC_PLUGIN_PATH'] = vlc.plugin_path" "os.environ['VLC_PLUGIN_PATH'] = '${libvlc}/lib/vlc/plugins'"
    ''}
  '';

  installPhase = ''
        mkdir -pv $out
    # Nasty hack; call wrapPythonPrograms to set program_PYTHONPATH.
    wrapPythonPrograms
    cp -prvd ./* $out/
    install -Dm755 $out/src/run_tribler.py $out/bin/tribler
    makeWrapper ${python3Packages.python}/bin/python $out/bin/tribler \
        --set QT_QPA_PLATFORM_PLUGIN_PATH ${qt5.qtbase.bin}/lib/qt-*/plugins/platforms \
        --set _TRIBLERPATH $out \
        --set PYTHONPATH $out:$out/src/pyipv8:$out/src/anydex:$out/src/tribler-common:$out/src/tribler-core:$out/src/tribler-gui:$program_PYTHONPATH \
        --set NO_AT_BRIDGE 1 \
        --run 'cd $_TRIBLERPATH' \
        --add-flags "-O $out/run_tribler.py" \
        ${lib.optionalString enablePlayer ''
          --prefix LD_LIBRARY_PATH : ${libvlc}/lib
        ''}
    mkdir -p $out/share/applications $out/share/icons
    cp $out/build/debian/tribler/usr/share/applications/tribler.desktop $out/share/applications/
    cp $out/build/debian/tribler/usr/share/pixmaps/tribler{,_big}.xpm $out/share/icons/
  '';

  meta = with lib; {
    maintainers = with maintainers; [ xvapx ];
    homepage = "https://www.tribler.org/";
    description = "A completely decentralised P2P filesharing client based on the Bittorrent protocol";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}

