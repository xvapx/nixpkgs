{ lib
, fetchFromGitHub
, buildPythonPackage
, pytestCheckHook
, pytestcov
}:

buildPythonPackage rec {
  pname = "semver";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "python-semver";
    repo = "python-semver";
    rev = version;
    sha256 = "133kjhsnliyvw72h441w0306p5i59ir1yp0vjr810is9zzyfhr11";
  };

  preCheck = "rm -rf dist"; # confuses source vs dist imports in pytest
  checkInputs = [ pytestCheckHook pytestcov ];

  meta = with lib; {
    description = "Python package to work with Semantic Versioning (http://semver.org/)";
    homepage = "https://python-semver.readthedocs.io/en/latest/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ np ];
  };
}
