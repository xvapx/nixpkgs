{ buildPythonPackage, fetchPypi, lib, isPy27, marshmallow, pytest
, pytest-aiohttp, webtest, webtest-aiohttp, flask, django, bottle, tornado
, pyramid, falcon, aiohttp }:

buildPythonPackage rec {
  pname = "webargs";
  version = "5.5.3";
  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "16pjzc265yx579ijz5scffyfd1vsmi87fdcgnzaj2by6w2i445l7";
  };

  doCheck=false;

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
