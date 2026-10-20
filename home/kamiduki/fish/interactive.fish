set -g fish_color_cwd brcyan --bold
set -g fish_color_command brblue
set -g fish_color_builtin brmagenta
set -g fish_color_param normal
set -g fish_color_escape brcyan

set -g fish_pager_color_prefix bryellow --bold
set -g fish_pager_color_description '#9a9a9b' --italics
set -g fish_pager_color_selected_background --background='#393953'

function fish_prompt
  set -l last_pipestatus $pipestatus
  set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
  set -l normal (set_color --reset)

  # Write pipestatus
  # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
  set -l bold_flag --bold
  set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
  if test $__fish_prompt_status_generation = $status_generation
    set bold_flag
  end
  set __fish_prompt_status_generation $status_generation
  set -l status_color (set_color $fish_color_status)
  set -l statusb_color (set_color $bold_flag $fish_color_status)
  set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

  set -l cmd_duration
  if set -q CMD_DURATION; and test "$CMD_DURATION" -gt 1000
    set -l seconds (math --scale=3 "$CMD_DURATION % 60000 / 1000")
    set -l duration "$seconds"s
    if test "$CMD_DURATION" -ge 60000
      set -l minutes (math "floor($CMD_DURATION / 60000) % 60")
      set duration "$minutes"m"$duration"
    end
    if test "$CMD_DURATION" -ge 3600000
      set -l hours (math "floor($CMD_DURATION / 3600000)")
      set duration "$hours"h"$duration"
    end
    set cmd_duration (set_color --bold bryellow)"$duration"
  end

  echo -ns $prompt_status" " $cmd_duration" " (set_color $fish_color_cwd) (prompt_pwd)" " (set_color brmagenta) (fish_vcs_prompt %s)" " (set_color --reset)
end
