{ pkgs, ... }:

{
  services = {
    autorandr =
      let
        laptop_edid = "00ffffffffffff000dae0416000000000b1d0104a524147802ee95a3544c99260f505400000001010101010101010101010101010101b43b804a713834403020350063c71000001a000000fe004e3136314843412d4541330a20000000fe00434d4e0a202020202020202020000000fe004e3136314843412d4541330a200030";
        huawei_mateview_gt34_edid = "00ffffffffffff0022f6256a22f680c01a200103805021780a54b1ac5047a426115054bfcf0081408180714f81c0b300d1c0010101014ed470a0d0a0465030403a001d4e3100001ce77c70a0d0a0295030203a001d4e3100001a000000fd0030901ea03c010a202020202020000000fc005a51452d4342410a202020202001b4020344b14b1f9000010304121300025a83010000e200d567030c002000184067d85dc4017880006d1a000002013090e60000000000e305c081e30f0000e606050166661c565e00a0a0a02950302035001d4e3100001a9d6770a0d0a0225030203a001d4e3100001a464714a0a0381f40302018041d4e3100001a0000000000c4";
      in
      {
        enable = true;
        defaultTarget = "laptop";
        profiles = {
          laptop = {
            fingerprint = { "eDP" = laptop_edid; };
            config = {
              "eDP" = { enable = true; primary = true; position = "0x0"; mode = "1920x1080"; };
            };
          };

          "laptop-dual" = {
            fingerprint = { "eDP" = laptop_edid; "DisplayPort-3" = huawei_mateview_gt34_edid; };
            config = {
              "eDP" = { enable = true; primary = false; position = "0x0"; mode = "1920x1080"; };
              "DisplayPort-3" = { enable = true; primary = true; position = "1920x0"; mode = "3440x1440"; };
            };
          };

          "laptop-docked" = {
            fingerprint = { "DisplayPort-3" = huawei_mateview_gt34_edid; };
            config = {
              "DisplayPort-3" = { enable = true; primary = true; position = "0x0"; mode = "3440x1440"; };
            };
          };
        };
      };
    acpid = {
      enable = true;
      handlers = {
        LID = {
          action = "${pkgs.autorandr}/bin/autorandr --batch --change --default laptop";
          event = "button/lid.*";
        };
      };
    };
  };
}
