call plug#begin()


Plug 'catppuccin/nvim', { 'as' : 'catppuccin' }								" Theme
Plug 'gen740/SmoothCursor.nvim' 
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'voldikss/vim-floaterm' 												" Floating terminal 
Plug 'itchyny/lightline.vim' 												" File line at bottom 
Plug 'itchyny/vim-gitbranch' 												" Add git info to file line at bottom
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } 						" Add fuzzy finder  --> NOTE: often requires manual install https://stackoverflow.com/questions/55797918/installing-fzf-fuzzy-finder-offline
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-rooter' 													" Make vim working dir go to git root 
Plug 'jpalardy/vim-slime' 													" Jupyter-like REPL from actual files
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins', 'for': 'python' } 	" Prettier python syntax highlighting 
Plug 'ap/vim-buftabline' 													" Show buffers up top for easy switching
Plug 'neoclide/coc.nvim', {'branch': 'release'} 							" Autocomplete and general LSP stuff? --> NOTE: may require install of npm
Plug 'tpope/vim-surround'													" Lets you do stuff like `ysw'` to put single quotation marks around words
Plug 'tpope/vim-fugitive'													" Nice git utilities from inside of vim:
Plug 'tpope/vim-commentary'													" Comment in and out stuff easily
Plug 'ojroques/vim-oscyank'													" Yank things across SSH
Plug 'airblade/vim-gitgutter'  												" Show changes since last commit in sidebar
Plug 'SirVer/ultisnips'														" Make your own useful autocomplete snippets

call plug#end()
" TODO: add C++ support
" TODO: add auto-install script
" TODO: make OSCYank compatible with tmux 
" TODO: there appears to be an exponential speedup as you re-source the
" 	init.vim file and it's not solved by the autocmd!

" Associate tpp (template files) with C++
augroup FileTypes
		autocmd! 
		" augroup + autocmd! helps prevent exponential slowdown after sourcing init.vim
		autocmd BufRead,BufNewFile *.tpp set filetype=cpp
augroup END

let g:oscyank_term = 'default'

let g:python_host_prog=expand("~/.nvim-venv/bin/python")
let g:python3_host_prog=expand("~/.nvim-venv/bin/python3.11")

augroup Linters
		autocmd!
		autocmd BufWritePost *.py silent! execute ':!~/.nvim-venv/bin/python3.11 -m black --line-length 88 % && ~/.nvim-venv/bin/python3.11 -m isort --profile black %' | e
		autocmd BufWritePost *.html,*.js*,*.css,*.ts* silent! execute ':!npx prettier --write %' | e
		autocmd BufWritePost *.c,*.cc,*.h,*.cpp,*.tpp silent! execute ':!clang-format -i --style=file %' | e 
augroup END

lua require('smoothcursor').setup({ fancy = {enable = true, head = { cursor = "▶", texthl = "SmoothCursor", linehl = nil }, body = { { cursor = "●", texthl = "SmoothCursorRed" }, { cursor = "●", texthl = "SmoothCursorOrange" }, { cursor = "●", texthl = "SmoothCursorYellow" }, { cursor = "◍", texthl = "SmoothCursorGreen" }, { cursor = "◍", texthl = "SmoothCursorAqua" }, { cursor = ".", texthl = "SmoothCursorBlue" }, { cursor = ".", texthl = "SmoothCursorPurple" }, }, tail = { cursor = nil, texthl = "SmoothCursor" } }})

let g:floaterm_winblend=0.2

set encoding=utf-8
set number relativenumber								" show relative line numbers
set scrolloff=7											" show 7 lines of extra text at bottom/top while scrolling up/down
set sidescrolloff=7										" and side to side
syntax on												" Enable syntax highlighting
set noswapfile											" Disable swap files for saving in-progress work
set hlsearch											" Highlight text as you're searching
set showtabline=2										" Always show buffer tabs
set autoindent											" Auto-indentation (WILL THIS CAUSE PROBLEMS WITH MULTILINE COPY PASTE???) 
set smartindent											" auto-indent based on language
set smartcase											" searching is only case-sensitive if there is at least one uppercase letter
set updatetime=300										" Faster refresh rate (IS THIS TOO FAST FOR DEV MACHINES??)
set cursorline											" Highlight the line that the cursor is at
set backspace=indent,eol,start							" Make backspace do what I think it should do
set hidden 												" Keep buffers open even when a different one is opened
set signcolumn=yes										" Stop screen from jumping whenever you temporarily type an error (for semshi)
set tabstop=4
let g:material_terminal_italics = 1
let g:semshi#simplify_markup=v:false
let g:buftabline_numbers=2
set timeoutlen=600
set spell spelllang=en_us
set autowrite 											" May delete this, but it enables writing on quite
set autowriteall



" ------------------- QOL KEYMAPPINGS ----------------------------------
inoremap jj <Esc>
" Symbol renaming.
" Set spacebar to be leader
nnoremap <SPACE> <Nop>
let mapleader=" "
" set timeoutlen=600
nmap <leader>vv :e $XDG_DATA_HOME/nvim/init.vim<CR>
nmap <leader>a gg^VG$

nnoremap <leader>* :g!/<C-R>=expand("<cword>")<CR>/d<CR>
" filters files to only the lines that include the word under the cursor.
nnoremap /* :%s/<c-r><c-w>/<c-r><c-w>/g<c-f>$F
" /* renames all instances of the word under the cursor
nnoremap <leader>p bvep

augroup VimRCSource
		autocmd!
		autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

nnoremap <leader>sp :e .scratch.py<CR>
nnoremap <leader>sb :e .scratch.sh<CR>
nnoremap <leader>sm :e .scratch.md<CR>
nnoremap <leader>sc :e .scratch.h<CR>
nnoremap <leader>st :e .scratch.txt<CR>

" ---------------- COC  (AUTOCOMPLETE)  -------------------------------
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
inoremap <silent><expr> <c-space> coc#refresh()
nmap <leader>qf <Plug>(coc-fix-current)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-rename)
" Use K to show documentation in preview window. Defined in $XDG_DATA_HOME/nvim/config/fzf.cfg.vim

" ---------------------- RECORDING ------------------------------------
" I accidentally hit the recording button all the time when I'm vimming but I
" don't actually use it yet - this disables the button.

nmap q <Nop>
nmap Q <Nop>

" ---------------- slime (repl interop) -------------------------------
nnoremap <leader>r <Plug>SlimeParagraphSend
xnoremap <leader>r <Plug>SlimeRegionSend

let g:slime_target="tmux" "Use tmux for vim slime -- note! You need to open another tmux pane for this to work
let g:slime_bracketed_paste = 1 " Fix issue where pasting in to ipython leads to annoying error text but no functionality change
let g:slime_no_mappings = 1 " Ignore default slime mappings
let g:slime_default_config = {"socket_name": "default", "target_pane": "0"}
let g:slime_dont_ask_default = 1


" ---------------- BUFFER AND WINDOW NAVIGATION  -------------------------------
" Save a keystroke when switching windows. Also less chance of Carpal Tunnel
" Syndrome 
nnoremap <leader>l <C-w>l
nnoremap <leader>k <C-w>k
nnoremap <leader>j <C-w>j
nnoremap <leader>h <C-w>h
nnoremap <leader>w :w<CR>

nnoremap L :bnext<CR>
nnoremap H :bprev<CR>

nmap <leader>q :bd<CR>
nmap <leader>wq :w<CR> :bd<CR>
nmap <leader>qq :bd! <CR>
nmap <leader>qqq :qa!<CR>

nmap <leader>1 <Plug>BufTabLine.Go(1)
nmap <leader>2 <Plug>BufTabLine.Go(2)
nmap <leader>3 <Plug>BufTabLine.Go(3)
nmap <leader>4 <Plug>BufTabLine.Go(4)
nmap <leader>5 <Plug>BufTabLine.Go(5)
nmap <leader>6 <Plug>BufTabLine.Go(6)
nmap <leader>7 <Plug>BufTabLine.Go(7)
nmap <leader>8 <Plug>BufTabLine.Go(8)
nmap <leader>9 <Plug>BufTabLine.Go(9)
nmap <leader>0 <Plug>BufTabLine.Go(10)

" --------------------- FUGITIVE (GIT) -----------------------------
"  Quicker shortcut for opening vim fugitive 
nmap <leader>g :Git<CR>
nmap <leader>gp :Git push -u<CR>
nmap <leader>gk :Git checkout 
nmap <leader>gb :Git checkout -b 
nmap <leader>gm :Git merge 
nmap <leader>gd :Git branch -d 
nmap <leader>gr :Git rm -f %
nmap <leader>gs :Git stash<CR>
nmap <leader>gsp :Git stash pop<CR>
nmap <leader>gl :Git log<CR>
nmap <leader>gf :Git diff main %<CR>
nmap <leader>gw :call GitWebLink('origin')<CR>
nmap <leader>gwu :call GitWebLink('upstream')<CR>



function! GitWebLink(remote)
    let l:url = system("git remote get-url " . a:remote)
	let l:url = substitute(l:url, ':', '\/', 'g')
	let l:url = substitute(l:url, 'git@', 'https:\/\/', 'g')
	let l:url = substitute(l:url, '\.git', '', 'g')
	:call OSCYank(l:url)
endfunction



function! GitPull()
  let branch = gitbranch#name()
  let upstream = system('git remote | grep upstream')

  if upstream != '' && branch ==# 'main'
    :Git pull upstream main
  else
    :Git pull
  endif
endfunction

nnoremap <silent> <leader>gu :call GitPull()<CR>
" --------------------- FZF (FILE SEARCH) --------------------------
" $make fzf respect gitignore
let $FZF_DEFAULT_COMMAND='ag -g ""'
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>



nnoremap F :Ag<CR>
command! -bang -nargs=* AgLike call fzf#vim#ag(<q-args>,"--" . b:current_syntax, fzf#vim#with_preview(), <bang>0)
nnoremap FF :AgLike<CR>
" runs Ag but only searching for the current file type 

inoremap fff <plug>(fzf-complete-path)
" --------------------- FLOATERM -----------------------------------
" Make esc-key work 'like it should' in terminal mode
nnoremap <leader>t :FloatermToggle<CR>
" For long-running processes
let g:floaterm_autoinsert=0
augroup FloaTerm
		autocmd!
		autocmd FileType floaterm nnoremap <silent><buffer> gf :call <SID>open_in_normal_window()<CR>
		autocmd FileType floaterm nnoremap <silent><buffer> H :FloatermPrev<CR>
		autocmd FileType floaterm nnoremap <silent><buffer> L :FloatermNext<CR>
		autocmd FileType floaterm nnoremap <silent><buffer> T :FloatermNew<CR>
augroup END
tnoremap <Esc> <C-\><C-n>
tnoremap jj <C-\><C-n>
" Make Space+t toggle terminal

" ---------------------- NERDTREE (FILE BROWSER) -------------------
augroup NerdTree
		autocmd!
		autocmd StdinReadPre * let s:std_in=1
augroup END


" Exit Vim if NERDTree is the only window remaining in the only tab.
" autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

nnoremap <leader>o :NERDTreeToggle<CR>
" Trying out fzf over NerdTree ATM
" Quit NERDTree when opening a file let NERDTreeQuitOnOpen = 1
let g:NERDTreeMinimalUI = 1
let NERDTreeQuitOnOpen=1

let g:NERDTreeHijackNetrw=1 " Use NERDTree instead of netrw when opening on directory
" ---------------------- THEME ------------------------------------
set background=dark
let g:catppuccin_flavor = "macchiato" 

lua require("catppuccin").setup({ transparent_background=true, term_colors = true })

colorscheme catppuccin 
let &t_ut='' " Fix bug where background color changes weirdly

" --------------------- LIGHTLINE (BOTTOM STATUS BAR) -------------
function! LightlineFilename()
  let root = fnamemodify(get(b:, 'gitbranch_path'), ':h:h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

function! LightlineFoldername()
  let root = fnamemodify(get(b:, 'gitbranch_path'), ':h:h')
  let folders = split(root, "\/")
  if len(folders) > 1
    return join(folders[-2:], "/")
  endif
  return root
endfunction

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'folder', 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'folder': 'LightlineFoldername',
      \   'gitbranch': 'gitbranch#name',
      \   'filename': 'LightlineFilename',
      \ },
	  \ }

" ---------------------- USE gf in Floaterm --------------------
function s:open_in_normal_window() abort
  let f = findfile(expand('<cfile>'))
  if !empty(f) && has_key(nvim_win_get_config(win_getid()), 'anchor')
    FloatermHide
    execute 'e ' . f
  endif
endfunction

" ------------------------ UltiSnips ---------------------------
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:snips_author="Carter Blum"
nnoremap <leader>uu :UltiSnipsEdit<CR>
nnoremap <leader>ua :e $XDG_DATA_HOME/nvim/UltiSnips/all.snippets<CR>


" -------------------- OSCYank (yank across SSH) ----------------
vnoremap <leader>c :OSCYank<CR>
nmap <leader>c <Plug>OSCYank
augroup OSCYank
		autocmd!
		autocmd TextYankPost *
			\ if v:event.operator is 'y' |
		    \ execute 'OSCYankRegister "' |
			\ endif
augroup END
set backupdir=~/.vim/backup,/tmp


" -------------------- Highlight spellcheck in red  ----------------
hi clear SpellBad
hi SpellBad gui=undercurl,bold
hi SpellBad guifg=orange
augroup AutoComplete
		autocmd Syntax * syntax match quoteblock /\v`[^`]+`/ contains=@NoSpell
		autocmd Syntax * syntax match quoteblock '"[^"]\+"' contains=@NoSpell
		autocmd Syntax * syntax match quoteblock "'[^']\+'" contains=@NoSpell
augroup END


" ------------------ Send Text To FLAN-UL2 -------------------------
" Add this to your init.vim
function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction


function! s:SendContentToEndpoint(endpoint, use_visual_selection) abort
  " Save content
  if a:use_visual_selection
    let l:content = s:get_visual_selection()
  else
    let l:content = join(getline(1, '$'), "\n")
  endif

  echo l:content 

  " Prepare JSON payload
  let l:payload = {
        \ 'instances': [
        \   {
        \     'context': l:content,
        \     'mode': 'generate',
        \     'top_p': 0.9,
        \     'num_beams': 10
        \   }
        \ ]
        \}

  " Encode JSON payload
  let l:json_payload = json_encode(l:payload)

  " Send POST request using curl
  let l:cmd = 'curl -s -X POST -H "Content-Type: application/json" -d ' . shellescape(l:json_payload) . ' ' . a:endpoint
  let l:response_json = system(l:cmd)

  " Decode JSON response
  let l:response = json_decode(l:response_json)

  " Insert the response into the buffer
  if has_key(l:response, 'predictions') && len(l:response.predictions) > 0
    let l:output_text = l:response.predictions[0].output

    let [line_end, column_end] = getpos("'>")[1:2]
    execute 'normal! i' . l:output_text
  else
    echo 'Error: Invalid response from endpoint'
  endif
endfunction

" Create buffer-local mappings for the function
nnoremap <buffer> <leader>ttt :call <SID>SendContentToEndpoint('https://codegen-16b-mono-s-nlpplatform.ds-pw-dev02.dsp.bce.dev.bloomberg.com/v1/models/codegen-16b-mono:predict', 0)<CR>
xnoremap <buffer> <leader>ttt :<C-u>call <SID>SendContentToEndpoint('https://codegen-16b-mono-s-nlpplatform.ds-pw-dev02.dsp.bce.dev.bloomberg.com/v1/models/codegen-16b-mono:predict', 1)<CR>
nnoremap <buffer> <silent> <leader><S-Tab> :call <SID>SendContentToEndpoint("https://flan-ul2-dev-s-ailm.inference-dev-01-pw.dsp.dev.bloomberg.com/v1/models/flan-ul2:predict", 0)<CR>
xnoremap <buffer> <silent> <leader><S-Tab> :<C-u>call <SID>SendContentToEndpoint("https://flan-ul2-dev-s-ailm.inference-dev-01-pw.dsp.dev.bloomberg.com/v1/models/flan-ul2:predict", 1)<CR>

" ------------------- TEMPORARY -------------
function! s:replace_true_false()
		:%s/true/True/ge
		:%s/false/False/ge
endfunction

nnoremap <leader>tf :call <SID>replace_true_false()<CR>

nnoremap <leader>lb :%s/\.\zs \ze\(\n\)\@!/\r/g<CR>
vnoremap <leader>lb :s/\.\zs \ze\(\n\)\@!/\r/g<CR>


