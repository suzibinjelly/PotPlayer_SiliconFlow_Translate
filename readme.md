# ChatGPT Subtitle Translation Plugin for PotPlayer

This plugin integrates OpenAI's ChatGPT API into PotPlayer to translate subtitles.

## Installation

### Fully Automatic Installation (Recommended)
1. **Download**:  
   [Fully Automatic Installer](https://github.com/Felix3322/PotPlayer_Chatgpt_Translate/releases/download/exe_installer/installer.exe).  
2. **Run the Installer**:  
   - Double-click `installer.exe` to start the installation.  
   - The program will automatically detect PotPlayer's installation path and complete the setup.  

### Semi-Automatic Installation
1. **Download the ZIP File**:  
   Get the latest ZIP file from this repository.  
2. **Extract the ZIP File**:  
   Extract the contents to a temporary folder.  
3. **Run the `setup.cmd` Script**:  
   - Double-click `setup.cmd` to install the plugin.  
   - This works only if PotPlayer is installed in its default path (`C:\Program Files\DAUM\PotPlayer`).  
   - If PotPlayer is installed elsewhere, follow the manual installation steps below.

### Manual Installation
1. **Download the ZIP File**:  
   Get the latest ZIP file from this repository.  
2. **Extract the ZIP File**:  
   Extract the contents to a temporary folder.  
3. **Copy Files**:  
   Copy `ChatGPTSubtitleTranslate.as` and `ChatGPTSubtitleTranslate.ico` to the following directory:  
   ```
   C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate
   ```
   Replace `C:\Program Files\DAUM\PotPlayer` with your custom PotPlayer installation path if necessary.

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
