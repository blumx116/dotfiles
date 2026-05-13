# Installation

(Kitty SSH compatibility)
```
infocmp xterm-kitty > /dev/null 2>&1 || tic -x <(infocmp -a xterm-kitty 2>/dev/null || curl -sL https://raw.githubusercontent.com/kovidgoyal/kitty/master/terminfo/kitty.terminfo)
```


```
git clone https://github.com/blumx116/dotfiles.git && cd dotfiles && chmod +x ./setup.sh && ./setup.sh
```
