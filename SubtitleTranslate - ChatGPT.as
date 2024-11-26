/*
    Real-time subtitle translation for PotPlayer using OpenAI ChatGPT API
*/

// Plugin Information Functions
string GetTitle() {
    return "{$CP949=ChatGPT 번역$}{$CP950=ChatGPT 翻譯$}{$CP0=ChatGPT Translate$}";
}

string GetVersion() {
    return "2.0";
}

string GetDesc() {
    return "{$CP949=OpenAI ChatGPT를 사용한 실시간 자막 번역$}{$CP950=使用 OpenAI ChatGPT 的實時字幕翻譯$}{$CP0=Real-time subtitle translation using OpenAI ChatGPT$}";
}

string GetLoginTitle() {
    return "{$CP949=OpenAI 모델 및 API 키 구성$}{$CP950=OpenAI 模型與 API 金鑰配置$}{$CP0=OpenAI Model and API Key Configuration$}";
}

string GetLoginDesc() {
    return "{$CP949=모델 이름을 입력하고 API 키를 입력하십시오 (예: gpt-4o-mini).$}{$CP950=請輸入模型名稱並提供 API 金鑰（例如 gpt-4o-mini）。$}{$CP0=Please enter the model name and provide the API Key (e.g., gpt-4o-mini).$}";
}

string GetUserText() {
    return "{$CP949=모델 이름 (현재: " + selected_model + ")$}{$CP950=模型名稱 (目前: " + selected_model + ")$}{$CP0=Model Name (Current: " + selected_model + ")$}";
}

string GetPasswordText() {
    return "{$CP949=API 키:$}{$CP950=API 金鑰:$}{$CP0=API Key:$}";
}

// Global Variables
string api_key = "";
string selected_model = "gpt-4o-mini"; // Default model
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
string apiUrl = "https://api.openai.com/v1/chat/completions"; // Added apiUrl definition

// Supported Language List
array<string> LangTable =
{
    "{$CP0=Auto Detect$}", "af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca",
    "ceb", "ny", "zh-CN",
    "zh-TW", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr",
    "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km",
    "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "ms", "mg", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "ps", "fa", "pl", "pt",
    "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk",
    "ur", "uz", "vi", "cy", "xh", "yi", "yo", "zu"
};

// Get Source Language List
array<string> GetSrcLangs() {
    array<string> ret = LangTable;
    return ret;
}

// Get Destination Language List
array<string> GetDstLangs() {
    array<string> ret = LangTable;
    return ret;
}

// Login Interface for entering model name and API Key
string ServerLogin(string User, string Pass) {
    // Trim whitespace
    selected_model = User.Trim();
    api_key = Pass.Trim();

    selected_model.MakeLower();

    // Validate model name
    if (selected_model.empty()) {
        HostPrintUTF8("{$CP0=Model name not entered. Please enter a valid model name.$}\n");
        selected_model = "gpt-4o-mini"; // Default to gpt-4o-mini
    }

    // Validate API Key
    if (api_key.empty()) {
        HostPrintUTF8("{$CP0=API Key not configured. Please enter a valid API Key.$}\n");
        return "fail";
    }

    // Save settings to temporary storage
    HostSaveString("api_key", api_key);
    HostSaveString("selected_model", selected_model);

    HostPrintUTF8("{$CP0=API Key and model name successfully configured.$}\n");
    return "200 ok";
}

// Logout Interface to clear model name and API Key
void ServerLogout() {
    api_key = "";
    selected_model = "gpt-4o-mini";
    HostSaveString("api_key", "");
    HostSaveString("selected_model", selected_model);
    HostPrintUTF8("{$CP0=Successfully logged out.$}\n");
}

// JSON String Escape Function
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    return output;
}

// Global variables for storing previous subtitles
array<string> subtitleHistory;
string UNICODE_RLE = "\u202B"; // For Right-to-Left languages

// Function to estimate token count based on character length
int EstimateTokenCount(const string &in text) {
    // Rough estimation: average 4 characters per token
    return int(float(text.length()) / 4); // Fixed division error by casting to float
}

// Function to get the model's maximum context length
int GetModelMaxTokens(const string &in modelName) {
    // Define maximum tokens for known models
    if (modelName == "gpt-3.5-turbo") {
        return 4096;
    } else if (modelName == "gpt-3.5-turbo-16k") {
        return 16384;
    } else if (modelName == "gpt-4o") {
        return 128000;
    } else if (modelName == "gpt-4o-mini") {
        return 128000;
    } else {
        // Default to a conservative limit
        return 4096;
    }
}

// Translation Function
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    // Load API key and model name from temporary storage
    api_key = HostLoadString("api_key", "");
    selected_model = HostLoadString("selected_model", "gpt-4o-mini");

    if (api_key.empty()) {
        HostPrintUTF8("{$CP0=API Key not configured. Please enter it in the settings menu.$}\n");
        return "";
    }

    if (DstLang.empty() || DstLang == "{$CP0=Auto Detect$}") {
        HostPrintUTF8("{$CP0=Target language not specified. Please select a target language.$}\n");
        return "";
    }

    if (SrcLang.empty() || SrcLang == "{$CP0=Auto Detect$}") {
        SrcLang = "";
    }

    // Add the current subtitle to the history
    subtitleHistory.insertLast(Text);

    // Get the model's maximum token limit
    int maxTokens = GetModelMaxTokens(selected_model);

    // Build the context from the subtitle history
    string context = "";
    int tokenCount = EstimateTokenCount(Text); // Tokens used by the current subtitle
    int i = int(subtitleHistory.length()) - 2; // Start from the previous subtitle
    while (i >= 0 && tokenCount < (maxTokens - 1000)) { // Reserve tokens for response and prompt
        string subtitle = subtitleHistory[i];
        int subtitleTokens = EstimateTokenCount(subtitle);
        tokenCount += subtitleTokens;
        if (tokenCount < (maxTokens - 1000)) {
            context = subtitle + "\n" + context;
        }
        i--;
    }

    // Limit the size of subtitleHistory to prevent it from growing indefinitely
    if (subtitleHistory.length() > 1000) { // Increased limit for context
        subtitleHistory.removeAt(0);
    }

    // Construct the prompt
    string prompt = "You are a professional translator. Please translate the following subtitle";
    if (!SrcLang.empty()) {
        prompt += " from " + SrcLang;
    }
    prompt += " to " + DstLang + ". Use the context provided to maintain coherence.\n";
    if (!context.empty()) {
        prompt += "Context:\n" + context + "\n";
    }
    prompt += "Subtitle to translate:\n" + Text;

    // JSON escape
    string escapedPrompt = JsonEscape(prompt);

    // Request data
    string requestData = "{\"model\":\"" + selected_model + "\",\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}],\"max_tokens\":1000,\"temperature\":0}";

    string headers = "Authorization: Bearer " + api_key + "\nContent-Type: application/json";

    // Send request
    string response = HostUrlGetString(apiUrl, UserAgent, headers, requestData);
    if (response.empty()) {
        HostPrintUTF8("{$CP0=Translation request failed. Please check network connection or API Key.$}\n");
        return "";
    }

    // Parse response
    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        HostPrintUTF8("{$CP0=Failed to parse API response.$}\n");
        return "";
    }

    JsonValue choices = Root["choices"];
    if (choices.isArray() && choices[0]["message"]["content"].isString()) {
        string translatedText = choices[0]["message"]["content"].asString();
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText.Trim(); // Trim to remove any extra whitespace
    }

    // Handle API errors
    if (Root["error"]["message"].isString()) {
        string errorMessage = Root["error"]["message"].asString();
        HostPrintUTF8("{$CP0=API Error: $}" + errorMessage + "\n");
    } else {
        HostPrintUTF8("{$CP0=Translation failed. Please check input parameters or API Key configuration.$}\n");
    }

    return "";
}

// Plugin Initialization
void OnInitialize() {
    HostPrintUTF8("{$CP0=ChatGPT translation plugin loaded.$}\n");
    // Load model name and API Key from temporary storage (if saved)
    api_key = HostLoadString("api_key", "");
    selected_model = HostLoadString("selected_model", "gpt-4o-mini");
    if (!api_key.empty()) {
        HostPrintUTF8("{$CP0=Saved API Key and model name loaded.$}\n");
    }
}

// Plugin Finalization
void OnFinalize() {
    HostPrintUTF8("{$CP0=ChatGPT translation plugin unloaded.$}\n");
}
