{ stdenv, fetchgit, pkgs, python3Packages, makeWrapper
, enablePlayer ? true, vlc ? null, qt5, lib }:

stdenv.mkDerivation rec {
  pname = "tribler";
  version = "7.5.1";

  src = fetchgit {
    url = "https://github.com/Tribler/tribler.git";
    rev = "04b7e3d5406a893ab3e7efaac63d1fa8b9beec87";
    sha256 = "1hvgk0ncy412bqimk90mrfplwbkh59c7va9m6axr5gw341l23ckj";
    fetchSubmodules = true;
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
    libtorrentRasterbar
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
    pyyaml
    networkx
    pony
    lz4
    pyqtgraph

    # there is a BTC feature, but it requires some unclear version of
    # bitcoinlib, so this doesn't work right now.
    # python3Packages.bitcoinlib
  ];

  postPatch = ''
    ${stdenv.lib.optionalString enablePlayer ''
      substituteInPlace "./src/tribler-gui/tribler_gui/vlc.py" --replace "ctypes.CDLL(p)" "ctypes.CDLL('${vlc}/lib/libvlc.so')"
      substituteInPlace "./src/tribler-gui/tribler_gui//widgets/videoplayerpage.py" --replace "if vlc and vlc.plugin_path" "if vlc"
      substituteInPlace "./src/tribler-gui/tribler_gui//widgets/videoplayerpage.py" --replace "os.environ['VLC_PLUGIN_PATH'] = vlc.plugin_path" "os.environ['VLC_PLUGIN_PATH'] = '${vlc}/lib/vlc/plugins'"
    ''}
  '';

  installPhase = ''
    mkdir -pv $out
    # Nasty hack; call wrapPythonPrograms to set program_PYTHONPATH.
    wrapPythonPrograms
    cp -prvd ./* $out/
    install -Dm755 $out/src/run_tribler.py $out/bin/tribler
    makeWrapper ${python37Packages.python}/bin/python $out/bin/tribler \
        --set QT_QPA_PLATFORM_PLUGIN_PATH ${qt5.qtbase.bin}/lib/qt-*/plugins/platforms \
        --set _TRIBLERPATH $out \
        --set PYTHONPATH $out:$out/src/pyipv8:$out/src/anydex:$out/src/tribler-common:$out/src/tribler-core:$out/src/tribler-gui:$program_PYTHONPATH \
        --set NO_AT_BRIDGE 1 \
        --run 'cd $_TRIBLERPATH' \
        --add-flags "-O $out/src/run_tribler.py" \
        ${stdenv.lib.optionalString enablePlayer ''
          --prefix LD_LIBRARY_PATH : ${vlc}/lib
        ''}

    mkdir -p $out/share/applications $out/share/icons
    cp $out/build/debian/tribler/usr/share/applications/tribler.desktop $out/share/applications/
    cp $out/build/debian/tribler/usr/share/pixmaps/tribler{,_big}.xpm $out/share/icons/
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ xvapx ];
    homepage = "https://www.tribler.org/";
    description = "A completely decentralised P2P filesharing client based on the Bittorrent protocol";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
