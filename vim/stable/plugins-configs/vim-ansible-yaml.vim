augroup VimAnsibleYamlSetting
  autocmd!
  au BufNewFile,BufRead *.yml.j2,*.yaml.j2 set ft=ansible " or, set ft=ansible by vim-ansible-yaml plugin
  au BufNewFile,BufRead *.conf,*.conf.j2 set ft=conf
augroup END
