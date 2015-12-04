" version: 0.0.1
" author : wan <one_kkm@icloud.com>
" license: mit license

let s:save_cpo = &cpo
set cpo&vim

let s:space = ' '
let s:rst_indent = '   '
let s:directive_front_symbol = '..'
let s:directive_rear_symbol = '::'

let s:directive_type_list = [
      \["CsvTableDirective", '\v^csvtable\s*.*', 'csv-table'],
      \["ListTableDirective", "\v^listtable\s*", 'list-table'],
      \["CodeBlockDirective", '\v^codeblock\s*.*', 'code-block']
      \]

let s:option_line_pattern = '\v^-\a\s+\.*(,|.)*'
let s:option_pattern = '\v^-\zs\a\ze'
let s:option_args = '\v^-\a\s+\zs.*(,|.)*'

let s:csv_content_pattern = '\v^.+(.|,)*.$'

let s:option_parse = {
      \"h": "   :header: ",
      \"w": "   :widths: ",
      \"c": "   :class: ",
      \}



function! BuildDirectiveLine(type, label)
  if a:label == ""
    return s:directive_front_symbol . s:space . a:type . s:directive_rear_symbol
  else
    return s:directive_front_symbol . s:space . a:type . s:directive_rear_symbol . s:space . a:label
  endif
endfunction


function! MatcherCallFunc() range
  for num in range(a:firstline, a:lastline)
    for args in s:directive_type_list
      if "" !=# matchstr(getline(num), args[1])
        let func = args[0]
        let directive_type = args[2]
        return call(func, [num, directive_type])
      endif
    endfor
  endfor
endfunction


function! CsvTableDirective(num, dt)
    let csv_name = matchstr(getline(a:num), '\v^csvtable\s\zs.*')
    let csv_line = BuildDirectiveLine(a:dt, csv_name)
    let repl = substitute(getline(a:num), getline(a:num), csv_line, "g")
    call setline(a:num, repl)
    let n = a:num + 1
    while getline(n) !=# ""
      if "" !=# matchstr(getline(n), s:option_line_pattern)
        let opt = matchstr(getline(n), s:option_pattern)
        let args = matchstr(getline(n), s:option_args)
        let line = s:option_parse.csv_table(opt, args)
        call setline(n, line)
      endif
      let n += 1
    endwhile
    call append(n-2, "")
endfunction


function! s:option_parse.csv_table(opt, args) dict
  let line = eval("self." . a:opt)
  let column_list = split(a:args, ",")
  for column in column_list
    let line = line . column . ', '
  endfor
  return line[:-3]
endfunction

function! ConvertCsvContent()
  let column_list = split(a:args, ",")
  let line = s:rst_indent
  for column in column_list
    let line = line . '"' . column . '"' . ', '
  endfor
  echo line
  endfor
endfunction

csvtable
-h sss,sss
aaaa,aaaa

function! CodeBlockDirective(num, end_num)
  for n in range(a:num+1, a:end_num)
   echo "aaa"
  endfor
endfunction

" Removes duplicates from a list.
function! s:uniq(list) abort
  return s:uniq_by(a:list, 'v:val')
endfunction

" Removes duplicates from a list.
function! s:uniq_by(list, f) abort
  let list = map(copy(a:list), printf('[v:val, %s]', a:f))
  let i = 0
  let seen = {}
  while i < len(list)
    let key = string(list[i][1])
    if has_key(seen, key)
      call remove(list, i)
    else
      let seen[key] = 1
      let i += 1
    endif
  endwhile
  return map(list, 'v:val[0]')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
