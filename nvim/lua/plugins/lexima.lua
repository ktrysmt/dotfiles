return {
  "cohama/lexima.vim",
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  keys = {
    { "/", mode = "n" },
  },
  config = function()
    -- vim.keymap.set("i", "<C-f>", "<Right>")

    -- inoremap <C-f> <C-r>=lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>
    vim.cmd [[
    function! s:lexima_alter_command_add_rule(original, alternative) abort
      let input_space = '<C-w>' . a:alternative . '<Right>'
      let input_cr    = '<C-w>' . a:alternative . '<CR>'
      let input_right = '<C-w>' . a:alternative . '<Right>'
      let rule = {
      \ 'mode': ':',
      \ 'at': '^\(''<,''>\)\?' . a:original . '\%#$',
      \ }
      call lexima#add_rule(extend(rule, { 'char': '<Space>', 'input': input_space }))
      call lexima#add_rule(extend(rule, { 'char': '<CR>',    'input': input_cr    }))
      call lexima#add_rule(extend(rule, { 'char': '<Right>', 'input': input_right }))
    endfunction

    if !exists('g:loaded_lexima_alter_command')
      command! -nargs=+ LeximaAlterCommand call <SID>lexima_alter_command_add_rule(<f-args>)
      let g:loaded_lexima_alter_command = 1
    endif

    LeximaAlterCommand sortu Sort<space>u

    LeximaAlterCommand rg Rg
    LeximaAlterCommand lz Lazy
    LeximaAlterCommand qf\%[replace] Qfreplace

    LeximaAlterCommand g Git<space>
    LeximaAlterCommand gp\%[ush] Git<space>push<space>origin<space>
    LeximaAlterCommand gb\%[lame] Git<space>blame
    " Enable ghb command only when MY_BROWSER is defined
    if !empty($MY_BROWSER)
      LeximaAlterCommand gbr !$MY_BROWSER<space>$(gh<space>browse<space>-n<space>%)
    endif

    LeximaAlterCommand gv DiffviewOpen
    LeximaAlterCommand gvc DiffviewClose
    LeximaAlterCommand gd DiffviewFileHistory

    LeximaAlterCommand %s s/\v
    LeximaAlterCommand s s/\v

    LeximaAlterCommand ti\%[gcurrent] tabnew|TigOpenCurrentFile
    LeximaAlterCommand ti\%[groot] tabnew|TigOpenProjectRootDir

    LeximaAlterCommand ww w<space>!
    LeximaAlterCommand rr r<space>!

    LeximaAlterCommand oi Oil<space>.<cr>

    nnoremap / /\v
    ]]
  end
}
