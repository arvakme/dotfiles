# dotfiles

My macOS terminal setup: zsh, Ghostty, tmux, Neovim (LazyVim), yazi, lazygit and an oh-my-posh prompt, all painted from one palette (Rosé Pine Dawn / Moon, called "Butler" here) that follows macOS light/dark.

我的 macOS 终端配置。这个仓库由我的私有配置仓库用脚本导出，只收能公开的部分；issue 和建议欢迎，但我不会直接在这里改。

## 里面有什么

| 路径 | 工具 | 说明 |
|---|---|---|
| `zsh/` | zsh | `.zshenv`（环境变量）、`.zprofile`（PATH）、`.zshrc`（交互：mise、历史、补全、提示符、插件、按键）。靠 `~/.zshenv` 里的 `ZDOTDIR` 指过来 |
| `ghostty/` | Ghostty | 主配置、明暗两套主题、光标着色器（`shaders/cursor.frag`）。半透明毛玻璃背景 |
| `tmux/` | tmux | 前缀 `Ctrl-T`；主题跟随明暗；`prefix+g` 弹出 lazygit；`prefix+y`/`prefix+u` 弹出 grok（可选，没装就不用） |
| `nvim/` | Neovim | LazyVim；本地配色 `colors/butler.lua` 跟随明暗；`<leader>ut` 切换明暗 |
| `oh-my-posh/` | 提示符 | 明暗两份，`.zshrc` 按当前模式选用 |
| `yazi/` | yazi | 文件管理器；文本一律用 nvim 打开；明暗两套 flavor |
| `lazygit/config.yml` | lazygit | 用 delta 当 pager，关掉鼠标（交给 tmux） |
| `git/` | git + delta | `shared.gitconfig`（pager、编辑器）、delta 明暗配色、全局 `ignore` |
| `theme/` | 明暗切换 | `theme light/dark/toggle/auto`；`watch` + LaunchAgent 跟随系统外观；`butler/` 是色板和生成脚本 |
| `karabiner/karabiner.json` | Karabiner-Elements | Caps Lock → Hyper（⌃⌥⇧⌘）；`Ctrl+hjkl` → 方向键；单按 Shift 切输入法；几条只对我的鼠标/键盘生效的设备规则 |
| `mise/config.toml` | mise | 全局 node 26、python 3.12、pnpm、cosign、herdr |
| `herdr/config.toml` | herdr | 终端里的 agent 多窗格管理器（可选）；主题块由生成脚本写入 |
| `install.sh` | | 先备份再软链（或 `--copy` 复制），从不删除文件 |

## 需要先装的东西

macOS + Apple Silicon（配置里写的是 `/opt/homebrew`）。

```bash
xcode-select --install          # git 和编译器（nvim 的 treesitter 要用）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install neovim tmux mise oh-my-posh git-delta lazygit yazi ripgrep fd fzf chafa pngpaste \
  zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
brew install --cask ghostty karabiner-elements \
  font-paper-mono font-maple-mono-nf-cn font-comic-shanns-mono-nerd-font
```

字体：英文和代码用 **Paper Mono**，中文回落到 **Maple Mono NF CN**（Light），图标回落到 **ComicShannsMono Nerd Font**。三个都要装，否则 Ghostty 会用系统字体。

## 安装

1. **先备份。** `install.sh` 会把挡路的旧配置挪到 `~/.dotfiles-backup/<时间>/`，但自己再留一份更安心：

   ```bash
   cp -R ~/.config ~/config-backup-$(date +%Y%m%d)
   cp ~/.zshenv ~/.zshrc ~/.zprofile ~/config-backup-$(date +%Y%m%d)/ 2>/dev/null
   ```

2. **克隆到单独的目录**（不要直接克隆成 `~/.config`），先看一眼要装什么：

   ```bash
   git clone https://github.com/arvakme/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./install.sh --dry-run
   ```

3. **安装。** 默认是软链，以后 `git pull` 就能更新，所以 `~/dotfiles` 不能删；想要一份独立的拷贝就用 `--copy`（之后可以删掉克隆目录）：

   ```bash
   ./install.sh          # 或 ./install.sh --copy
   ```

   它会：把 `ghostty herdr karabiner lazygit mise nvim oh-my-posh theme tmux yazi zsh` 链到 `~/.config/`，`git/` 下的几个文件逐个链过去；写 `~/.zshenv`（只有一行 `ZDOTDIR`）；把 `theme` 命令链到 `~/.local/bin/theme`；按系统当前明暗刷一次主题。之后原来 `~/.zshrc`、`~/.zprofile` 不再被读取（文件还在，没动）。

4. **收尾：**

   ```bash
   git config --global --add include.path ~/.config/git/shared.gitconfig   # 你的 name/email 仍在 ~/.gitconfig
   mise install                                                            # node、python 等
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm        # 然后在 tmux 里按 Ctrl-T 再按 I
   ```

   打开一个新的 Ghostty 窗口（或 `exec zsh -l`），再运行一次 `nvim`，LazyVim 会按 `lazy-lock.json` 装插件。Karabiner-Elements 打开后按提示给权限。

5. **（可选）跟随系统明暗自动切换：**

   ```bash
   sed "s|__HOME__|$HOME|g" ~/.config/theme/theme-watch.plist > ~/Library/LaunchAgents/local.dotfiles.theme-watch.plist
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.dotfiles.theme-watch.plist
   ```

   不装也行，手动 `theme light` / `theme dark` / `theme toggle`。

### 装完可能要改的地方

- `zsh/.zshenv` 把 Homebrew 指向中科大镜像（国内快）；不在国内就删掉 `HOMEBREW_API_DOMAIN` 和 `HOMEBREW_BOTTLE_DOMAIN` 两行。
- `zsh/.zprofile` 把 `~/.bun/bin`、`~/Library/pnpm`、`~/.lmstudio/bin` 放进 PATH，目录不存在也无害。
- `nvim/lua/plugins/java.lua` 假设 mise 装了 JDK 21 和 17（`mise use -g java@21` 等），不写 Java 可以删掉这个文件。
- `karabiner/karabiner.json` 里的设备规则按 vendor/product id 匹配我的外设，对别的设备不生效，留着无害。
- tmux 的 `prefix+y`/`prefix+u` 需要 `~/.local/bin/grok`，没有就忽略。

## 换配色

所有带颜色的文件（Ghostty、tmux、nvim、yazi、oh-my-posh、delta、herdr）都由一个脚本从同一份色板生成，不要手改生成出来的文件：

```bash
$EDITOR ~/.config/theme/butler/palette.json      # 改色板（light / dark 各一套）
python3 ~/.config/theme/butler/generate.py --check   # 检查对比度（含半透明背景）
python3 ~/.config/theme/butler/generate.py           # 重新生成所有主题文件
theme auto                                           # 应用到正在运行的 tmux 等
```

## 卸载

删掉 `~/.config` 下指向 `~/dotfiles` 的软链和 `~/.local/bin/theme`，再把 `~/.dotfiles-backup/<时间>/` 里的东西挪回原位。

## 致谢

[LazyVim](https://github.com/LazyVim/LazyVim)，[Rosé Pine](https://rosepinetheme.com) 色板，tmux 和 nvim 的布局参考了 [craftzdog](https://github.com/craftzdog/dotfiles-public)，字体 [Paper Mono](https://github.com/paper-design/paper-mono)、[Maple Mono](https://github.com/subframe7536/maple-font)。

## License

MIT © arvakme
