{ lib, buildPythonPackage, fetchPypi
, aiohttp, apispec, jinja2, webargs5
}:

buildPythonPackage rec {
  pname = "aiohttp-apispec";
  version = "2.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0hhlmh3mc3xg68znsxyhypb5k12vg59yf72qkyw6ahg8zy3qfz2m";
  };

  doCheck=false;

  propagatedBuildInputs = [ aiohttp apispec jinja2 webargs5 ];

  meta = with lib; {
    homepage = "https://github.com/maximdanilchenko/aiohttp-apispec";
    license = licenses.mit;
    maintainers = with maintainers; [ xvapx ];
  };
}

