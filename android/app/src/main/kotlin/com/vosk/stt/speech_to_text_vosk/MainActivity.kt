package com.vosk.stt.speech_to_text_vosk

import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var methodChannel: MethodChannel? = null
    private var speechRecognizer: SpeechRecognizer? = null
    private var isListening = false
    private var currentLanguage = "zh-CN"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    currentLanguage = call.argument<String>("language") ?: "zh-CN"
                    result.success(SpeechRecognizer.isRecognitionAvailable(this))
                }

                "startListening" -> {
                    currentLanguage = call.argument<String>("language") ?: currentLanguage
                    startNativeListening(currentLanguage)
                    result.success(null)
                }

                "stopListening" -> {
                    stopNativeListening()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startNativeListening(language: String) {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            methodChannel?.invokeMethod("onError", "当前 Android 设备没有可用的系统语音识别服务")
            return
        }

        stopNativeListening()

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this).also { recognizer ->
            recognizer.setRecognitionListener(createRecognitionListener())
        }

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, language)
            putExtra(RecognizerIntent.EXTRA_ONLY_RETURN_LANGUAGE_PREFERENCE, false)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
        }

        isListening = true
        speechRecognizer?.startListening(intent)
    }

    private fun stopNativeListening() {
        if (isListening) {
            speechRecognizer?.stopListening()
            speechRecognizer?.cancel()
        }
        speechRecognizer?.destroy()
        speechRecognizer = null
        isListening = false
    }

    private fun createRecognitionListener(): RecognitionListener {
        return object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) = Unit
            override fun onBeginningOfSpeech() = Unit
            override fun onRmsChanged(rmsdB: Float) = Unit
            override fun onBufferReceived(buffer: ByteArray?) = Unit
            override fun onEndOfSpeech() {
                isListening = false
            }

            override fun onError(error: Int) {
                isListening = false
                methodChannel?.invokeMethod("onError", androidSpeechErrorMessage(error))
                stopNativeListening()
            }

            override fun onResults(results: Bundle?) {
                isListening = false
                val text = extractBestResult(results)
                if (text.isNotBlank()) {
                    methodChannel?.invokeMethod("onRecognitionResult", text)
                } else {
                    methodChannel?.invokeMethod("onError", "Android 系统语音识别失败: 未识别到有效语音")
                }
                stopNativeListening()
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val text = extractBestResult(partialResults)
                if (text.isNotBlank()) {
                    methodChannel?.invokeMethod("onRecognitionPartial", text)
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) = Unit
        }
    }

    private fun extractBestResult(results: Bundle?): String {
        return results
            ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            ?.firstOrNull()
            ?.trim()
            .orEmpty()
    }

    private fun androidSpeechErrorMessage(error: Int): String {
        val reason = when (error) {
            SpeechRecognizer.ERROR_AUDIO -> "音频录制错误"
            SpeechRecognizer.ERROR_CLIENT -> "客户端错误"
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "麦克风或语音识别权限不足"
            SpeechRecognizer.ERROR_NETWORK -> "网络错误"
            SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "网络超时"
            SpeechRecognizer.ERROR_NO_MATCH -> "未识别到有效语音"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "系统语音识别服务忙"
            SpeechRecognizer.ERROR_SERVER -> "系统语音识别服务错误"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "没有检测到语音输入"
            else -> "未知错误"
        }
        return "Android 系统语音识别失败: $reason ($error)"
    }

    override fun onDestroy() {
        stopNativeListening()
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_NAME = "native_speech_recognition"
    }
}
