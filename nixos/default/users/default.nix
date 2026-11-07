{
  lib,
  ...
}:
{
  imports =
    builtins.readDir ./.
    |> lib.filterAttrs (_: type: type == "directory")
    |> lib.mapAttrsToList (name: _: ./${name});
}
