{ lib, ... }: {
  options = {
    fonts.default =
      let
        font = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          size = lib.mkOption {
            type = lib.types.number;
          };
        };
      in
      {
        ui = font;
      };
    defaultUser = lib.mkOption {
      type = lib.types.str;
    };
    cursor = {
      package = lib.mkOption {
        type = lib.types.package;
      };
      name = lib.mkOption {
        type = lib.types.str;
      };
      size = lib.mkOption {
        type = lib.types.int;
      };
    };
  };
}
