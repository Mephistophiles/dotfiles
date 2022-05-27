# vim:expandtab ts=2 sw=2

{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ gopass pavucontrol ];
  programs = {
    i3status-rust = {
      enable = true;
      bars = {
        bar = {
          icons = "awesome";
          theme = "slick";
          blocks = [
            {
              block = "bluetooth";
              hide_disconnected = true;
              mac = "D8:7E:90:21:54:A6";
              label = "MX Master 2S";
              format = "{percentage}";
            }

            {
              block = "bluetooth";
              hide_disconnected = true;
              mac = "E5:F4:D8:D6:B2:AC";
              label = "Razer Pro Click";
              format = "{percentage}";
            }

            {
              block = "bluetooth";
              hide_disconnected = true;
              mac = "FB:D2:2F:69:83:1A";
              label = "Razer Pro Type";
              format = "{percentage}";
            }

            {
              block = "weather";
              format = "{temp}";
              service = {
                name = "openweathermap";
                api_key = config.vault.openWeatherMapAPIKey;
                city_id = config.vault.openWeatherMapCityID;
                units = "metric";
              };

            }

            { block = "uptime"; }

            {
              block = "networkmanager";
              interface_name_exclude = [ "br\\-[0-9a-f]{12}" "docker\\d+" ];
            }

            {
              block = "temperature";
              collapsed = true;
              interval = 10;
              format = "{average}";
              chip = "k10temp-pci-*";
            }

            {
              block = "cpu";
              interval = 1;
              format = "{barchart}";
            }

            {
              block = "memory";
              display_type = "memory";
              format_mem = "{mem_used_percents}";
              format_swap = "{swap_used_percents}";
            }

            (if config.variables.withWayland then ({
              block = "keyboard_layout";
              driver = "sway";
              mappings = {
                "English (US)" = "EN";
                "Russian (N/A)" = "RU";
              };
            }) else ({
              block = "custom";
              command =
                "${pkgs.xkblayout-state}/bin/xkblayout-state print '%s'";
              interval = 1;
            }))

            {
              block = "battery";
              interval = 10;
              format = "{percentage} {time}";
              info = 80;
              good = 90;
            }
            { block = "backlight"; }
            {
              block = "custom";
              command = "${config.xdg.configHome}/i3status-rust/pushcheck.sh";
              on_click =
                "${config.xdg.configHome}/i3status-rust/pushcheck-toggle.sh";
              interval = 5;
              json = true;
              hide_when_empty = true;
            }
            {
              block = "github";
              hide_if_total_is_zero = true;
            }
            { block = "sound"; }
            {
              block = "notify";
              format = "{state}";
            }
            {
              block = "time";
              interval = 60;
              format = "%a %d/%m %R";
            }
          ];
        };
      };
    };
  };

  home.file.".config/i3status-rust/pushcheck.sh" = {
    text = ''
      #!${pkgs.bash}/bin/bash

      if ! ip r get 192.168.161.35 | grep -q tun; then
        echo '{"text": ""}'
        exit 0
      fi

      RES=$(timeout 2s pushlockctl check)
      ret=$?

      if [ "$RES" = "Unknown error" ]; then
        echo '{"state":"Critical", "text": "🔥 Server Error"}'
        exit 0
      fi

      case $ret in
        0)
          echo '{"state":"Idle", "text": "⚡️"}'
          ;;
        1)
          echo '{"state": "Critical", "text": "🚧 '$RES'"}'
          ;;
        2)
          echo '{"state":"Warning", "text": "👷 Locked by me"}'
          ;;
        101|124)
          echo '{"state":"Critical", "text": "🔥 Server Error"}'
          ;;
        *)
          echo '{"text": ""}'
          ;;
      esac
    '';
    executable = true;
  };

  home.file.".config/i3status-rust/pushcheck-toggle.sh" = {
    text = ''
      #!${pkgs.bash}/bin/bash

      RES=$(pushlockctl check)

      case $? in
        0)
          pushlockctl lock
          ;;
        1)
          echo "$RES"
          ;;
        2)
          pushlockctl unlock
          echo "Locked by me"
          ;;
      esac
    '';
    executable = true;
  };
}
