{ python, lib, src, version }:

let
  buildAzureCliPackage = with py.pkgs; attrs: buildPythonPackage (attrs // {
    # Remove overly restrictive version contraints and obsolete namespace setup
    prePatch = (attrs.prePatch or "") + ''
      rm -f azure_bdist_wheel.py tox.ini
      substituteInPlace setup.py \
        --replace "wheel==0.30.0" "wheel"
      sed -i "/azure-namespace-package/c\ " setup.cfg
    '';

    # Prevent these __init__'s from violating PEP420, only needed for python2
    postInstall = (attrs.postInstall or "") + ''
      rm $out/${python.sitePackages}/azure/{,__pycache__/}__init__.* \
         $out/${python.sitePackages}/azure/cli/{,__pycache__/}__init__.*
    '';

    checkInputs = [ mock pytest ] ++ (attrs.checkInputs or []);
    checkPhase = attrs.checkPhase or ''
      cd azure
      HOME=$TMPDIR pytest
    '';
  });

  overrideAzureMgmtPackage = package: version: extension: sha256:
    package.overrideAttrs(oldAttrs: rec {
      inherit version;

      src = py.pkgs.fetchPypi {
        inherit (oldAttrs) pname;
        inherit version sha256 extension;
      };

      preBuild = ''
        rm -f azure_bdist_wheel.py
        substituteInPlace setup.cfg \
          --replace "azure-namespace-package = azure-mgmt-nspkg" ""
      '';
    });

  py = python.override {
    packageOverrides = self: super: {
      inherit buildAzureCliPackage;

      # core and the actual application are highly coupled
      azure-cli-core = buildAzureCliPackage {
        pname = "azure-cli-core";
        inherit version src;

        sourceRoot = "source/src/azure-cli-core";

        propagatedBuildInputs = with self; [
          adal
          argcomplete
          azure-cli-telemetry
          colorama
          jmespath
          humanfriendly
          knack
          msrest
          msrestazure
          paramiko
          pygments
          pyjwt
          pyopenssl
          pyyaml
          requests
          six
          azure-mgmt-resource
          tabulate
          pyperclip
          psutil
        ]
        ++ lib.optionals isPy3k [ antlr4-python3-runtime ]
        ++ lib.optionals (!isPy3k) [ enum34 futures antlr4-python2-runtime ndg-httpsclient ];

        # ignore test that does network call
        checkPhase = ''
          HOME=$TMPDIR pytest --ignore=azure/cli/core/tests/test_profile.py
        '';

        pythonImportsCheck = [
          "azure.cli.telemetry"
          "azure.cli.core"
        ];
      };

      azure-cli-telemetry = buildAzureCliPackage {
        pname = "azure-cli-telemetry";
        version = "1.0.4"; # might be wrong, but doesn't really matter
        inherit src;

        sourceRoot = "source/src/azure-cli-telemetry";

        propagatedBuildInputs = with super; [
          applicationinsights
          portalocker
        ];

        # ignore flaky test
        checkPhase = ''
          cd azure
          HOME=$TMPDIR pytest -k 'not test_create_telemetry_note_file_from_scratch'
        '';
      };

      azure-mgmt-resource = overrideAzureMgmtPackage super.azure-mgmt-resource "4.0.0" "zip"
        "0gy89bi89ikg5hps8rvnq28r33lixci3sk2m86jvziv9fh9rz41b";

      azure-mgmt-compute = overrideAzureMgmtPackage super.azure-mgmt-compute "8.0.0" "zip"
        "06hmf9iq2yqpmmvw7pr9zm4v427q03i436lnin3aczizfndrk76i";

      azure-mgmt-consumption = overrideAzureMgmtPackage super.azure-mgmt-consumption "2.0.0" "zip"
        "12ai4qps73ivawh0yzvgb148ksx02r30pqlvfihx497j62gsi1cs";

      azure-mgmt-containerservice = overrideAzureMgmtPackage super.azure-mgmt-containerservice "7.0.0" "zip"
        "104w7rxv7hy84yzddbbpkjqha04ghr0zz9qy788n3wl69cj4cv1a";

      azure-mgmt-iothub = overrideAzureMgmtPackage super.azure-mgmt-iothub "0.8.2" "zip"
        "0w3w1d156rnkwjdarv3qvycklxr3z2j7lry7a3jfgj3ykzny12rq";

      azure-mgmt-kusto = overrideAzureMgmtPackage super.azure-mgmt-kusto "0.3.0" "zip"
        "1pmcdgimd66h964a3d5m2j2fbydshcwhrk87wblhwhfl3xwbgf4y";

      azure-mgmt-devtestlabs = overrideAzureMgmtPackage super.azure-mgmt-devtestlabs "2.2.0" "zip"
        "15lpyv9z8ss47rjmg1wx5akh22p9br2vckaj7jk3639vi38ac5nl";

      azure-mgmt-netapp = overrideAzureMgmtPackage super.azure-mgmt-netapp "0.6.0" "zip"
        "10ymvyj386z9bjdm2g1b5a4vfnn87ig2zm6xn2xddvbpy0jxnyfv";

      azure-mgmt-dns = overrideAzureMgmtPackage super.azure-mgmt-dns "2.1.0" "zip"
        "1l55py4fzzwhxlmnwa41gpmqk9v2ncc79w7zq11sm9a5ynrv2c1p";

      azure-mgmt-network = overrideAzureMgmtPackage super.azure-mgmt-network "7.0.0" "zip"
        "0ss5yc9k3dh78lb88nfh3z98yz1pcd8d7d7cfjlxmv4n3dlr1kij";

      azure-mgmt-msi = overrideAzureMgmtPackage super.azure-mgmt-msi "0.2.0" "zip"
        "0rvik03njz940x2hvqg6iiq8k0d88gyygsr86w8s0sa12sdbq8l6";

      azure-mgmt-web = overrideAzureMgmtPackage super.azure-mgmt-web "0.42.0" "zip"
        "0vp40i9aaw5ycz7s7qqir6jq7327f7zg9j9i8g31qkfl1h1c7pdn";

      azure-mgmt-reservations = overrideAzureMgmtPackage super.azure-mgmt-reservations "0.3.2" "zip"
        "0nksxjh5kh09dr0zw667fg8mzik4ymvfq3dipwag6pynbqr9ls4l";

      azure-mgmt-security = overrideAzureMgmtPackage super.azure-mgmt-security "0.1.0" "zip"
        "1cb466722bs0ribrirb32kc299716pl0pwivz3jyn40dd78cwhhx";

      azure-mgmt-datamigration = overrideAzureMgmtPackage super.azure-mgmt-datamigration "0.1.0" "zip"
        "1pq5rn32yvrf5kqjafnj0kc92gpfg435w2l0k7cm8gvlja4r4m77";

      azure-mgmt-relay = overrideAzureMgmtPackage super.azure-mgmt-relay "0.1.0" "zip"
        "1jss6qhvif8l5s0lblqw3qzijjf0h88agciiydaa7f4q577qgyfr";

      azure-mgmt-eventhub = overrideAzureMgmtPackage super.azure-mgmt-eventhub "2.6.0" "zip"
        "1nnp2ki4iz4f4897psmwb0v5khrwh84fgxja7nl7g73g3ym20sz8";

      azure-mgmt-keyvault = overrideAzureMgmtPackage super.azure-mgmt-keyvault "1.1.0" "zip"
        "16a0d3j5dilbp7pd7gbwf8jr46vzbjim1p9alcmisi12m4km7885";

      azure-mgmt-containerregistry = overrideAzureMgmtPackage super.azure-mgmt-containerregistry "3.0.0rc7" "zip"
        "1bzfpbz186dhnxn0blgr20xxnk67gkr8ysn2b3f1r41bq9hz97xp";

      azure-mgmt-monitor = overrideAzureMgmtPackage super.azure-mgmt-monitor "0.5.2" "zip"
        "1r01aq5rbynbc1my4qljdifjdj9h65bh8cdzgd7vm4ij7r48v9gi";

      azure-mgmt-advisor =  overrideAzureMgmtPackage super.azure-mgmt-advisor "2.0.1" "zip"
        "1wsfkprdrn22mwm24y2zlcms8ppp7jwq3s86r3ymbl29pbaxca8r";

      azure-mgmt-applicationinsights = overrideAzureMgmtPackage super.azure-mgmt-applicationinsights "0.1.1" "zip"
        "16raxr5naszrxmgbfhsvh7rqcph5cx6x3f480790m79ykvmjj0pi";

      azure-mgmt-authorization = overrideAzureMgmtPackage super.azure-mgmt-authorization "0.52.0" "zip"
        "0357laxgldb7lvvws81r8xb6mrq9dwwnr1bnwdnyj4bw6p21i9hn";

      azure-mgmt-storage = overrideAzureMgmtPackage super.azure-mgmt-storage "5.0.0" "zip"
        "1gzsscfnnfb8gxs34dq9hs339hidlzas7kgivw0234v3qz4gy9yx";

      azure-mgmt-servicefabric = overrideAzureMgmtPackage super.azure-mgmt-servicefabric "0.2.0" "zip"
        "1bcq6fcgrsvmk6q7v8mxzn1180jm2qijdqkqbv1m117zp1wj5gxj";

      azure-mgmt-hdinsight = overrideAzureMgmtPackage super.azure-mgmt-hdinsight "1.1.0" "zip"
        "0lj9dhb14dx4ag5pgd2zvrmn9y5ziq2qywvw38ccbv9g3bxpglkn";

      azure-graphrbac = super.azure-graphrbac.overrideAttrs(oldAttrs: rec {
        version = "0.60.0";

        src = super.fetchPypi {
          inherit (oldAttrs) pname;
          inherit version;
          sha256 = "1zna5vb887clvpyfp5439vhlz3j4z95blw9r7y86n6cfpzc65fyh";
          extension = "zip";
        };
      });

      azure-storage-blob = super.azure-storage-blob.overrideAttrs(oldAttrs: rec {
        version = "1.5.0";
        src = super.fetchPypi {
          inherit (oldAttrs) pname;
          inherit version;
          sha256 = "0b15dzy75fml994gdfmaw5qcyij15gvh968mk3hg94d1wxwai1zi";
        };
      });

      azure-storage-common = super.azure-storage-common.overrideAttrs(oldAttrs: rec {
        version = "1.4.2";
        src = super.fetchPypi {
          inherit (oldAttrs) pname;
          inherit version;
          sha256 = "00g41b5q4ijlv02zvzjgfwrwy71cgr3lc3if4nayqmyl6xsprj2f";
        };
      });

      # part of azure.mgmt.datalake namespace
      azure-mgmt-datalake-analytics = super.azure-mgmt-datalake-analytics.overrideAttrs(oldAttrs: rec {
        version = "0.2.1";

        src = super.fetchPypi {
          inherit (oldAttrs) pname;
          inherit version;
          sha256 = "192icfx82gcl3igr18w062744376r2ivh63c8nd7v17mjk860yac";
          extension = "zip";
        };

        preBuild = ''
          rm azure_bdist_wheel.py
          substituteInPlace setup.cfg \
            --replace "azure-namespace-package = azure-mgmt-datalake-nspkg" ""
        '';
      });












    };
  };
in
  py
