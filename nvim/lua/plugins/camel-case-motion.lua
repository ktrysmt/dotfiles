return {
  'bkad/CamelCaseMotion',
  keys = {
    { "w",  mode = { "n", "v" } },
    { "b",  mode = { "n", "v" } },
    { "e",  mode = { "n", "v" } },
    { "ge", mode = { "n", "v" } },
  },
  config = function()
    vim.cmd [[
    nmap <silent> w <Plug>CamelCaseMotion_w
    nmap <silent> b <Plug>CamelCaseMotion_b
    nmap <silent> e <Plug>CamelCaseMotion_e
    nmap <silent> ge <Plug>CamelCaseMotion_ge
    vmap <silent> w <Plug>CamelCaseMotion_w
    vmap <silent> b <Plug>CamelCaseMotion_b
    vmap <silent> e <Plug>CamelCaseMotion_e
    vmap <silent> ge <Plug>CamelCaseMotion_ge
    ]]
  end
}
