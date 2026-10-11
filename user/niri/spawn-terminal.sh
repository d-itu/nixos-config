app_id=$(niri msg -j focused-window | jq -r .app_id)

case $app_id in
  kitty|Alacritty|com.mitchellh.ghostty|rio) wl-send-key 13 36;;
  *) exec xdg-terminal-exec ;;
esac
