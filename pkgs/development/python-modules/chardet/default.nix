{ lib, buildPythonPackage, fetchPypi, fetchpatch
, pytest, pytestrunner, hypothesis }:

buildPythonPackage rec {
  pname = "chardet";
  version = "4.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ykr04qyhgpc0h5b7dhqw4g92b1xv7ki2ky910mhy4mlbnhm6vqd";
  };

  checkInputs = [ pytest pytestrunner hypothesis ];

  meta = with lib; {
    homepage = "https://github.com/chardet/chardet";
    description = "Universal encoding detector";
    license = licenses.lgpl2;
    maintainers = with maintainers; [ domenkozar ];
  };
}
