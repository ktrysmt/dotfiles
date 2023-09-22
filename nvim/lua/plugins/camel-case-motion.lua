return {
  'bkad/CamelCaseMotion',
  keys = {
    { "w",  mode = "n" },
    { "b",  mode = "n" },
    { "e",  mode = "n" },
    { "ge", mode = "n" },
  },
  config = function()
    vim.cmd [[
    nmap <silent> w <Plug>CamelCaseMotion_w
    nmap <silent> b <Plug>CamelCaseMotion_b
    nmap <silent> e <Plug>CamelCaseMotion_e
    nmap <silent> ge <Plug>CamelCaseMotion_ge
    ]]
  end
}
