syntax on
set noswapfile
set hlsearch
set ignorecase
set incsearch
set tabstop=4
set autoindent
set cursorline
set shiftwidth=4

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

hi Normal ctermbg=none
hi NonText ctermbg=none
