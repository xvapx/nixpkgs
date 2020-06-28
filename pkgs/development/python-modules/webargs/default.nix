{ buildPythonPackage, fetchPypi, lib, isPy27, marshmallow, pytest
, pytest-aiohttp, webtest, webtest-aiohttp, flask, django, bottle, tornado
, pyramid, falcon, aiohttp }:

buildPythonPackage rec {
  pname = "webargs";
  version = "6.1.0";
  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0gxvd1k5czch2l3jpvgbb53wbzl2drld25rs45jcfkrwbjrpzd7b";
  };

  checkPhase = ''
    rm tests/test_webapp2parser.py  # webapp2 doesn't support python 3
    pytest
  '';

  propagatedBuildInputs = [ marshmallow ];
  checkInputs = [
    pytest
    pytest-aiohttp
    webtest
    webtest-aiohttp
    flask
    django
    bottle
    tornado
    pyramid
    falcon
    aiohttp
  ];

  meta = with lib; {
    description =
      "Declarative parsing and validation of HTTP request objects, with built-in support for popular web frameworks";
    homepage = "https://github.com/marshmallow-code/webargs";
    license = licenses.mit;
    maintainers = with maintainers; [ cript0nauta ];
  };
}
