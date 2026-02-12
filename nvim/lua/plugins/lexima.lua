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
    " Custom vsplit command that opens to the right
    function! g:LeximaVsplitRight(...) abort
      let save_splitright = &splitright
      set splitright
      execute 'vsplit' (a:0 > 0 ? a:1 : '')
      let &splitright = save_splitright
    endfunction
    command! -nargs=? -complete=file Vsr call g:LeximaVsplitRight(<f-args>)

    function! g:LeximaAlterCommandAddRule(original, alternative) abort
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
      command! -nargs=+ LeximaAlterCommand call g:LeximaAlterCommandAddRule(<f-args>)
      let g:loaded_lexima_alter_command = 1
    endif

    LeximaAlterCommand sortu Sort<space>u

    LeximaAlterCommand rg Rg
    LeximaAlterCommand lz Lazy
    LeximaAlterCommand qf\%[replace] Qfreplace

    LeximaAlterCommand g\%[it] Git<space>
    LeximaAlterCommand gp\%[ush] Git<space>push<space>origin<space>
    LeximaAlterCommand gb\%[lame] Git<space>blame

    LeximaAlterCommand gv DiffviewOpen
    LeximaAlterCommand gvc DiffviewClose
    LeximaAlterCommand gvh DiffviewFileHistory

    LeximaAlterCommand %s s/\v
    LeximaAlterCommand s s/\v

    " LeximaAlterCommand ti\%[gcurrent] TigOpenCurrentFile
    " LeximaAlterCommand ti\%[groot] TigOpenProjectRootDir
    LeximaAlterCommand t\%[ig] Vsr|TigOpenCurrentFile

    LeximaAlterCommand ww w<space>!
    LeximaAlterCommand rr r<space>!

    LeximaAlterCommand oi\%[l] Oil<space>.<cr>

    LeximaAlterCommand mdf !column<space>-t<space>-s<space>'|'<space>-o<space>'|'

    " LeximaAlterCommand vsr Vsr|TigOpenCurrentFile

    LeximaAlterCommand o\%[cto] Octo<space>

    nnoremap / /\v
    ]]

    -- Enable gbr command with browser support (secure Lua-based env check)
    local my_browser = vim.env.MY_BROWSER
    if my_browser and my_browser ~= "" then
      local escaped = vim.fn.shellescape(my_browser)
      vim.cmd(string.format([[LeximaAlterCommand gbr !%s<space>$(gh<space>browse<space>-n<space>%%)]], escaped))
    else
      vim.cmd [[LeximaAlterCommand gbr !gh<space>browse<space>%]]
    end
  end
}
