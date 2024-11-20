# ChatGPT Subtitle Translation Plugin for PotPlayer

This plugin integrates OpenAI's ChatGPT API into PotPlayer to translate subtitles.

## Installation

1. **Download**:
   - Get the latest ZIP file from this repository.

2. **Automatic Installation**:
   - Extract the ZIP file.
   - Run `setup.cmd` to install the plugin. 
   - Works only if PotPlayer is installed in the default path.

3. **Manual Installation**:
   - Copy `ChatGPTSubtitleTranslate.as` and `ChatGPTSubtitleTranslate.ico` to PotPlayer's `Scripts` folder (e.g., `C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate`).

## Configuration

1. Open PotPlayer `Preferences` (`F5`).
2. Go to `Extensions > Subtitle translation`.
3. Select `ChatGPT Translate` as the translation plugin.
4. Configure the plugin:
   - **Model Name**: Enter your OpenAI model, e.g., `gpt-4o` or `gpt-4o-mini`.
   - **API Key**: Provide your OpenAI API key.
5. Set the source and target languages as needed.

## Notes

- **API Key Required**: Obtain your API key from [OpenAI](https://platform.openai.com/account/api-keys).
- **Custom Paths**: If PotPlayer is installed in a custom path, use manual installation.

## License

This project is licensed under the MIT License.