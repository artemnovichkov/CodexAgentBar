# ClaudeAgentBar

A macOS menu bar app for tracking Claude Agent stats from Xcode.

<p align="center">
  <img src=".github/app.png" alt="app" width="50%" />
</p>

## Features

- Weekly activity chart (messages, sessions, tool calls)
- All time stats with peak hour
- Longest session details
- Model usage with token counts
- Hourly distribution chart
- Auto-updates when stats change

## Installation

### Homebrew

```bash
brew install --cask artemnovichkov/tap/claudeagentbar
```

> The app is not notarized. On first launch you may need to right-click the app → Open, or run `xattr -dr com.apple.quarantine /Applications/ClaudeAgentBar.app`.

### Manual

1. Clone this repository.
2. Open in Xcode.
3. Build and run.
4. The app appears in the menu bar.

## Author

Artem Novichkov, https://artemnovichkov.com

## License

The project is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
