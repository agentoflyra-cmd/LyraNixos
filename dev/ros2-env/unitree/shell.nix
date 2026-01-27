{
  pkgs ? import ../. { },
  rosDistro ? "humble",
  package ? "ros-core",
}:
pkgs.mkShell {
  packages = [
    (pkgs.rosPackages.${rosDistro}.buildEnv {
      paths =
        [
          pkgs.colcon
        ]
        ++ (with pkgs.rosPackages.${rosDistro}; [
          ament-cmake-core
          python-cmake-module
          pkgs.rosPackages.${rosDistro}.${package}
          pkgs.rosPackages.${rosDistro}.unitree-ros
          pkgs.rosPackages.${rosDistro}.desktop
        ]);
    })
  ];
  shellHook = ''
    if [[ ! $DIRENV_IN_ENVRC ]]; then
      eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete ros2)"
      eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete colcon)"
    fi
  '';
}

