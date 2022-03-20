hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'pinecone'

if &t_Co >= 256

  set background=light

  hi Normal        guibg=NONE    guifg=#edc77b gui=NONE

  hi Boolean       guibg=NONE    guifg=#d7875f gui=NONE
  hi Comment       guibg=NONE    guifg=#686868 gui=NONE
  hi Constant      guibg=NONE    guifg=#d7875f gui=NONE
  hi Function      guibg=NONE    guifg=#af875f gui=NONE
  hi Identifier    guibg=NONE    guifg=#5f875f gui=NONE
  hi PreProc       guibg=NONE    guifg=#875f5f gui=NONE
  hi Special       guibg=NONE    guifg=#5f875f gui=NONE
  hi Statement     guibg=NONE    guifg=#d78700 gui=NONE
  hi String        guibg=NONE    guifg=#afaf5f gui=NONE
  hi Title         guibg=NONE    guifg=#87afaf gui=NONE
  hi Type          guibg=NONE    guifg=#af875f gui=NONE

  hi ColorColumn   guibg=#303030 guifg=NONE    gui=NONE
  hi Conceal       guibg=NONE    guifg=#8a8a8a gui=NONE
  hi CursorLineNr  guibg=NONE    guifg=#ffaf00 gui=NONE
  hi Directory     guibg=NONE    guifg=#afaf5f gui=NONE
  hi FoldColumn    guibg=NONE    guifg=#af0000 gui=NONE
  hi Folded        guibg=NONE    guifg=#af0000 gui=NONE
  hi LineNr        guibg=NONE    guifg=#626262 gui=NONE
  hi MatchParen    guibg=NONE    guifg=#87afff gui=NONE
  hi SignColumn    guibg=#121212 guifg=#6c6c6c gui=NONE
  hi SpecialKey    guibg=NONE    guifg=#686868 gui=NONE
  hi Underlined    guibg=NONE    guifg=NONE    gui=UNDERLINE

  hi Visual        guibg=#3e4f4f guifg=NONE    gui=NONE
  hi VisualNOS     guibg=NONE    guifg=NONE    gui=UNDERLINE

  hi IncSearch     guibg=#dfaf00 guifg=#262626 gui=NONE
  hi Search        guibg=#dfaf00 guifg=#262626 gui=NONE

  hi ModeMsg       guibg=NONE    guifg=#87afff gui=NONE
  hi StatusLine    guibg=#303030 guifg=#ffffd7 gui=BOLD
  hi StatusLineNC  guibg=#303030 guifg=#626262 gui=NONE
  hi VertSplit     guibg=#303030 guifg=#121212 gui=NONE
  hi WildMenu      guibg=#303030 guifg=#87afff gui=UNDERLINE

  hi DiffAdd       guibg=#32361a guifg=NONE    gui=NONE
  hi DiffDelete    guibg=#4f1111 guifg=#ff875e gui=NONE
  hi DiffChange    guibg=#1f1205 guifg=NONE    gui=NONE
  hi DiffText      guibg=#483b24 guifg=NONE    gui=NONE

  hi Pmenu         guibg=#444444 guifg=#ffd787 gui=NONE
  hi PmenuSbar     guibg=#444444 guifg=NONE    gui=NONE
  hi PmenuSel      guibg=#af875f guifg=#444444 gui=NONE
  hi PmenuThumb    guibg=#af875f guifg=NONE    gui=NONE

  hi SpellBad      guibg=NONE    guifg=NONE    gui=UNDERCURL
  hi SpellCap      guibg=NONE    guifg=NONE    gui=UNDERCURL
  hi SpellLocal    guibg=NONE    guifg=NONE    gui=UNDERCURL
  hi SpellRare     guibg=NONE    guifg=NONE    gui=UNDERCURL

  hi Error         guibg=NONE    guifg=#d75f5f gui=NONE
  hi ErrorMsg      guibg=NONE    guifg=#d75f5f gui=NONE
  hi Ignore        guibg=NONE    guifg=NONE    gui=NONE
  hi MoreMsg       guibg=NONE    guifg=#87afff gui=NONE
  hi Question      guibg=NONE    guifg=#87afff gui=NONE
  hi Todo          guibg=#ffffd7 guifg=#080808 gui=NONE
  hi WarningMsg    guibg=NONE    guifg=#ff875e gui=NONE

  hi TabLine       guibg=#303030 guifg=#626262 gui=NONE
  hi TabLineSel    guibg=#303030 guifg=#87afff gui=NONE
  hi TabLineFill   guibg=#303030 guifg=#ffffd7 gui=NONE

  hi NonText       guibg=NONE    guifg=#686868 gui=NONE

  hi Cursor        guibg=#ffffdf guifg=NONE    gui=NONE
  hi CursorColumn  guibg=#101010 guifg=NONE    gui=NONE
  hi CursorLine    guibg=#101010 guifg=NONE    gui=NONE

  hi helpleadblank guibg=NONE    guifg=NONE    gui=NONE
  hi helpnormal    guibg=NONE    guifg=NONE    gui=NONE

endif

hi link Number             Constant
hi link Character          Constant

hi link Conditional        Statement
hi link Debug              Special
hi link Define             PreProc
hi link Delimiter          Special
hi link Exception          Statement
hi link Float              Number
hi link HelpCommand        Statement
hi link HelpExample        Statement
hi link Include            PreProc
hi link Keyword            Statement
hi link Label              Statement
hi link Macro              PreProc
hi link Operator           Statement
hi link PreCondit          PreProc
hi link Repeat             Statement
hi link SpecialChar        Special
hi link SpecialComment     Special
hi link StorageClass       Type
hi link Structure          Type
hi link Tag                Special
hi link Typedef            Type

hi link htmlEndTag         htmlTagName
hi link htmlLink           Function
hi link htmlSpecialTagName htmlTagName
hi link htmlTag            htmlTagName
hi link xmlTag             Statement
hi link xmlTagName         Statement
hi link xmlEndTag          Statement

hi link markdownItalic     Preproc

hi link diffBDiffer        WarningMsg
hi link diffCommon         WarningMsg
hi link diffDiffer         WarningMsg
hi link diffIdentical      WarningMsg
hi link diffIsA            WarningMsg
hi link diffNoEOL          WarningMsg
hi link diffOnly           WarningMsg
hi link diffRemoved        WarningMsg
hi link diffAdded          String
