# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ writeShellApplication
, zip
, findutils
}:

{ name ? "bootstrap"
, contents
, compress ? true
}:

writeShellApplication {
  runtimeInputs = [
    zip
    findutils
  ];

  name = "${name}-zip";

  text = ''
    cd ${contents}
    find . -mindepth 1 | zip -q ${if compress then "-9" else "-0"} -r -@ -
  '';
}
