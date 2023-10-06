return {
  "cohama/lexima.vim",
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  config = function()
    vim.cmd [[
    inoremap <C-f> <C-r>=lexima#insmode#leave(1, '<LT>C-G>U<LT>RIGHT>')<CR>

    function! s:lexima_alter_command_add_rule(original, alternative) abort
      let input_space = '<C-w>' . a:alternative . '<Space>'
      let input_cr    = '<C-w>' . a:alternative . '<CR>'
      let input_right = '<C-w>' . a:alternative . '<Right>'

      let rule = {
      \ 'mode': ':',
      \ 'at': '^\(''<,''>\)\?' . a:original . '\%#$',
      \ }

      call lexima#add_rule(extend(rule, { 'char': '<Space>', 'input': input_space }))
      call lexima#add_rule(extend(rule, { 'char': '<CR>',    'input': input_cr    }))
      call lexima#add_rule(extend(rule, { 'char': '<Right>', 'input': input_right }))


      "  call lexima#add_rule({'char': '<C-f>', 'at': '\%#.*', 'leave': 1})
    endfunction

    if !exists('g:loaded_lexima_alter_command')
      command! -nargs=+ LeximaAlterCommand call <SID>lexima_alter_command_add_rule(<f-args>)
      let g:loaded_lexima_alter_command = 1
    endif

    LeximaAlterCommand sortu Sort<space>u

    LeximaAlterCommand rg Rg
    LeximaAlterCommand lz Lazy
    LeximaAlterCommand qf\%[replace] Qfreplace
    LeximaAlterCommand ma\%[son] Mason

    LeximaAlterCommand g Git
    LeximaAlterCommand g\%[push] Git<space>push
    LeximaAlterCommand g\%[blame] Git<space>blame

    LeximaAlterCommand gv DiffviewOpen
    LeximaAlterCommand gvc DiffviewClose
    LeximaAlterCommand gh DiffviewFileHistory

    LeximaAlterCommand s\%[v] Subvert/
    LeximaAlterCommand %s\%[v] Subvert/

    LeximaAlterCommand p\%[cre] Pcre/
    LeximaAlterCommand %p\%[cre] Pcre/

    LeximaAlterCommand ti\%[gcurrent] TigOpenCurrentFile
    LeximaAlterCommand ti\%[groot] TigOpenProjectRootDir
    ]]
  end
}
