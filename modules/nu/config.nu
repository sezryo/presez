# Incarnation via Nushell

source ~/.cache/starship/init.nu
source ~/.zoxide.nu
source ~/presez/modules/nu/functions.nu


let pink = "#f5a9b8"

module completions {

  # This is a simplified version of completions for git branches and git remotes
  def "nu-complete git branches" [] {
    ^git branch | lines | each { |line| $line | str replace '[\*\+] ' '' | str trim }
  }

  def "nu-complete git remotes" [] {
    ^git remote | lines | each { |line| $line | str trim }
  }

  # Completions for nu itself
  export extern "nu" [
    --help(-h)                # Display this help message
    --stdin                   # redirect the stdin
    --login(-l)               # start as a login shell
    --interactive(-i)         # start as an interactive shell
    --version(-v)             # print the version
    --perf(-p)                # start and print performance metrics during startup
    --testbin:string          # run internal test binary
    --commands(-c):string     # run the given commands and then exit
    --config:string           # start with an alternate config file
    --env-config:string       # start with an alternate environment config file
    --log-level:string        # log level for performance logs
    --threads:int             # threads to use for parallel commands
    --table-mode(-m):string   # the table mode to use. rounded is default.
  ]

}

# Get just the extern definitions without the custom completion commands
use completions *

# for more information on themes see
# https://www.nushell.sh/book/coloring_and_theming.html
let sezTheme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: $pink
    empty: cyan
    bool: white
    int: white
    filesize: white
    duration: white
    date: white
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: pink
    record: white
    list: white
    block: white
    hints: dark_gray

    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
    shape_binary: green_bold
    shape_bool: light_cyan
    shape_int: green_bold
    shape_float: green_bold
    shape_range: yellow_bold
    shape_internalcall: $pink
    shape_external: purple
    shape_externalarg: $pink
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: $pink
    shape_datetime: $pink
    shape_list: $pink
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: $pink
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
}

let-env config = {
  ls: {
    use_ls_colors: true # use the LS_COLORS environment variable to colorize output
    clickable_links: true # enable or disable clickable links. Your terminal has to support links.
  }
  rm: {
    always_trash: true # always act as if -t was given. Can be overridden with -p
  }
  cd: {
    abbreviations: true # allows `cd s/o/f` to expand to `cd some/other/folder`
  }
  table: {
    mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
    trim: {
      methodology: wrapping # wrapping or truncating
      wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
      truncating_suffix: "..." # A suffix used by the 'truncating' methodology
    }
  }
  history: {
    max_size: 8964 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
    file_format: "plaintext" # "sqlite" or "plaintext"
  }
  completions: {
    case_sensitive: false # set to true to enable case-sensitive completions
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    partial: true  # set this to false to prevent partial filling of the prompt
    algorithm: "fuzzy"  # prefix or fuzzy
    external: {
      enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
      max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
      completer: null # check 'carapace_completer' above as an example
    }
  }
  filesize: {
    metric: true
    format: "auto"
  }
  color_config: $sezTheme
  use_grid_icons: true
  footer_mode: "25" # always, never, number_of_rows, auto
  float_precision: 5
  buffer_editor: "emacs" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
  use_ansi_coloring: true
  edit_mode: emacs # emacs, vi
  shell_integration: true # enables terminal markers and a workaround to arrow keys stop working issue
  show_banner: false

  hooks: {
    pre_prompt: [{||
      $nothing  # replace with source code to run before the prompt is shown
    }]
    pre_execution: [{||
      $nothing  # replace with source code to run before the repl input is run
    }]
    env_change: {
      PWD: [{|before, after|
        $nothing  # replace with source code to run if the PWD environment is different since the last repl input
      }]
    }
  }
  menus: [
      {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
      }
      # Example of extra menus created using a nushell source
      # Use the source field to create a list of records that populates
      # the menu
      {
        name: commands_menu
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where command =~ $buffer
            | each { |it| {value: $it.command description: $it.usage} }
        }
      }
      {
        name: vars_menu
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.vars
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
        }
      }
      {
        name: commands_with_description
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where command =~ $buffer
            | each { |it| {value: $it.command description: $it.usage} }
        }
      }
      {
        name: fzf_history_menu_fzf_ui
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
        source: { |buffer, position|
            open -r $nu.history-path | fzf +s --tac | str trim
            | where $it =~ $buffer
            | each { |v| {value: ($v | str trim) } }
        }
      }
      {
        name: fzf_menu_nu_ui
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: "#66ff66"
            selected_text: { fg: "#66ff66" attr: r }
            description_text: yellow
        }
        source: { |buffer, position|
            open -r $nu.history-path
            | fzf -f $buffer
            | lines
            | each { |v| {value: ($v | str trim) } }
        }
      }
  ]
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: emacs
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menuprevious }
    }
    {
      name: history_menu
      modifier: control
      keycode: char_h
      mode: emacs
      event: { send: menu name: history_menu }
    }
    {
      name: next_page
      modifier: control
      keycode: char_x
      mode: emacs
      event: { send: menupagenext }
    }
    {
      name: undo_or_previous_page
      modifier: control
      keycode: char_z
      mode: emacs
      event: {
        until: [
          { send: menupageprevious }
          { edit: undo }
        ]
       }
    }

    {
      name: commands_with_description
      modifier: control
      keycode: char_u
      mode: emacs
      event: { send: menu name: commands_with_description }
    }
    {
      name: change_dir_with_fzf
      modifier: control
      keycode: char_f
      mode: emacs
      event: {
        send: executehostcommand,
        cmd: "cd (ls | where type == dir | each { |it| $it.name} | str collect (char nl) | fzf | decode utf-8 | str trim)"
      }
    }
    {
      name: fzf_history_menu_fzf_ui
      modifier: control
      keycode: char_e
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: fzf_history_menu_fzf_ui }
    }
    {
      name: fzf_menu_nu_ui
      modifier: control
      keycode: char_w
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: fzf_menu_nu_ui }
    }
  ]
}
