return {
  'hrsh7th/nvim-insx',
  event = { 'InsertEnter' },
  config = function()
    require('insx.preset.standard').setup()

    local insx = require('insx')

    insx.add(
      "'",
      insx.with(require('insx.recipe.auto_pair')({
        open = "'",
        close = "'"
      }), {
        insx.with.in_string(false),
        insx.with.in_comment(false),
        insx.with.nomatch([[\\\%#]]),
        insx.with.nomatch([[\a\%#]])
      })
    )

    local esc = require('insx').helper.regex.esc
    require('insx').add('<Space>', require('insx.recipe.pair_spacing').increase({
      open_pat = esc('('),
      close_pat = esc(')')
    }))
    require('insx').add('<BS>', require('insx.recipe.pair_spacing').decrease({
      open_pat = esc('('),
      close_pat = esc(')')
    }))
  end
}
