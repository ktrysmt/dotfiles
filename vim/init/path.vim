"" Resolve PATH
function! s:configure_path(name, pathlist) abort
  let path_separator = ':'
  let pathlist = split(expand(a:name), path_separator)
  for path in map(filter(a:pathlist, '!empty(v:val)'), 'expand(v:val)')
    if isdirectory(path) && index(pathlist, path) == -1
      call insert(pathlist, path, 0)
    endif
  endfor
  execute printf('let %s = join(pathlist, ''%s'')', a:name, path_separator)
endfunction
call s:configure_path('$PATH', [
    \ '/usr/local/bin',
    \])
call s:configure_path('$MANPATH', [
    \ '/usr/local/share/man/',
    \ '/usr/share/man/',
    \])

"" Fix python version
function! s:pick_executable(pathspecs) abort
  for pathspec in filter(a:pathspecs, '!empty(v:val)')
    for path in reverse(glob(pathspec, 0, 1))
      if executable(path)
        return path
      endif
    endfor
  endfor
  return ''
endfunction
let g:python3_host_prog = s:pick_executable([
    \ '/usr/local/bin/python3',
    \ '/home/linuxbrew/.linuxbrew/bin/python3',
    \ '/usr/bin/python3',
    \ '/bin/python3',
    \])
