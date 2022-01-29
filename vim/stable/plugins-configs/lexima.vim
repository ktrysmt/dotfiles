call lexima#add_rule({'char': ')', 'at': '\%#)', 'input': '<Right>'})
call lexima#add_rule({'char': ')', 'at': '.*\%#)', 'input': '<Right>'})
call lexima#add_rule({'char': '(', 'at': '\%#()', 'input': '<Right><Right>'})
call lexima#add_rule({'char': '"', 'at': '\%#"', 'input': '<Right>'})
call lexima#add_rule({'char': '"', 'at': '.*\%#"', 'input': '<Right>'})

