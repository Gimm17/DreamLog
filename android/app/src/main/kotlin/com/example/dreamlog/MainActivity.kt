package com.example.dreamlog

import android.app.Activity
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets

class MainActivity : FlutterActivity() {
    private var pendingImportResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dreamlog/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareFile" -> {
                        val path = call.argument<String>("path")
                        val mimeType = call.argument<String>("mimeType") ?: "*/*"
                        val chooserTitle =
                            call.argument<String>("chooserTitle") ?: "Share with"
                        val text = call.argument<String>("text")

                        if (path.isNullOrBlank()) {
                            result.error("missing_path", "Share file path is empty.", null)
                            return@setMethodCallHandler
                        }

                        try {
                            shareFile(path, mimeType, chooserTitle, text)
                            result.success(null)
                        } catch (error: Exception) {
                            result.error(
                                "share_failed",
                                error.message ?: "Could not share file.",
                                null
                            )
                        }
                    }

                    "createShareImage" -> {
                        try {
                            result.success(createShareImage(call))
                        } catch (error: Exception) {
                            result.error(
                                "share_image_failed",
                                error.message ?: "Could not create share image.",
                                null
                            )
                        }
                    }

                    "pickJsonFile" -> {
                        if (pendingImportResult != null) {
                            result.error(
                                "import_in_progress",
                                "Another import picker is already open.",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        pendingImportResult = result
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                            putExtra(
                                Intent.EXTRA_MIME_TYPES,
                                arrayOf(
                                    "application/json",
                                    "text/json",
                                    "text/plain",
                                    "application/octet-stream"
                                )
                            )
                        }
                        try {
                            startActivityForResult(intent, IMPORT_JSON_REQUEST_CODE)
                        } catch (error: Exception) {
                            pendingImportResult = null
                            result.error(
                                "picker_failed",
                                error.message ?: "Could not open file picker.",
                                null
                            )
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun createShareImage(call: MethodCall): String {
        val format = call.argument<String>("format") ?: "socialCard"
        val title = call.argument<String>("title") ?: "DreamLog"
        val date = call.argument<String>("date") ?: ""
        val emotion = call.argument<String>("emotion") ?: "Dream"
        val clarity = call.argument<Int>("clarity") ?: 0
        val dream = call.argument<String>("dream") ?: ""
        val interpretation = call.argument<String>("interpretation") ?: ""
        val symbols = call.argument<List<String>>("symbols") ?: emptyList()

        val isStory = format == "story"
        val width = if (isStory) 720 else 900
        val height = if (isStory) 1280 else 1125
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        drawShareBackground(canvas, width.toFloat(), height.toFloat())
        drawShareContent(
            canvas = canvas,
            width = width.toFloat(),
            height = height.toFloat(),
            isStory = isStory,
            title = title,
            date = date,
            emotion = emotion,
            clarity = clarity,
            dream = dream,
            interpretation = interpretation,
            symbols = symbols
        )

        val dir = externalCacheDir ?: cacheDir
        val stamp = System.currentTimeMillis()
        val file = File(dir, "dreamlog-$format-$stamp.png")
        FileOutputStream(file).use { output ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
        }
        bitmap.recycle()
        return file.absolutePath
    }

    private fun drawShareBackground(canvas: Canvas, width: Float, height: Float) {
        val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f,
                0f,
                width,
                height,
                intArrayOf(COLOR_BACKGROUND, COLOR_SURFACE, Color.rgb(16, 40, 31)),
                null,
                Shader.TileMode.CLAMP
            )
        }
        canvas.drawRect(0f, 0f, width, height, backgroundPaint)

        canvas.drawCircle(
            width * 0.88f,
            height * 0.16f,
            190f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = colorWithAlpha(COLOR_PRIMARY_LIGHT, 0.18f)
            }
        )
        canvas.drawCircle(
            width * 0.12f,
            height * 0.72f,
            240f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = colorWithAlpha(COLOR_AURORA, 0.10f)
            }
        )

        val starPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = colorWithAlpha(COLOR_TEXT_PRIMARY, 0.50f)
        }
        for (index in 0 until 46) {
            val x = ((index * 193) % width.toInt()).toFloat()
            val y = ((index * 277) % height.toInt()).toFloat()
            val radius = 1.4f + (index % 4) * 0.55f
            canvas.drawCircle(x, y, radius, starPaint)
        }
    }

    private fun drawShareContent(
        canvas: Canvas,
        width: Float,
        height: Float,
        isStory: Boolean,
        title: String,
        date: String,
        emotion: String,
        clarity: Int,
        dream: String,
        interpretation: String,
        symbols: List<String>
    ) {
        val margin = if (isStory) 82f else 72f
        val maxWidth = width - (margin * 2f)
        var y = if (isStory) 145f else 96f

        y += drawTextBlock(
            canvas,
            "DreamLog",
            margin,
            y,
            maxWidth,
            textPaint(COLOR_TEXT_PRIMARY, 34f, Typeface.BOLD)
        ) + 20f

        y += drawTextBlock(
            canvas,
            date,
            margin,
            y,
            maxWidth,
            textPaint(COLOR_TEXT_SECONDARY, 28f, Typeface.NORMAL)
        )
        y += if (isStory) 70f else 52f

        y += drawTextBlock(
            canvas,
            title,
            margin,
            y,
            maxWidth,
            textPaint(COLOR_TEXT_PRIMARY, if (isStory) 60f else 56f, Typeface.BOLD),
            maxLines = if (isStory) 3 else 2,
            lineSpacingMultiplier = 0.92f
        ) + 34f

        drawPill(
            canvas,
            margin,
            y,
            "$emotion  -  clarity $clarity%",
            colorWithAlpha(emotionColor(emotion), 0.22f),
            COLOR_TEXT_PRIMARY
        )
        y += 78f

        val footerY = height - if (isStory) 178f else 118f
        val bodyTextSize = if (isStory) 30f else 32f

        y += drawSection(
            canvas,
            "The Dream",
            dream.trim(),
            margin,
            y,
            maxWidth,
            maxLines = if (isStory) 5 else 4,
            bodyTextSize = bodyTextSize
        ) + 44f

        y += drawSection(
            canvas,
            "AI Interpretation",
            interpretation.trim(),
            margin,
            y,
            maxWidth,
            maxLines = if (isStory) 3 else 3,
            bodyTextSize = bodyTextSize
        ) + 40f

        if (symbols.isNotEmpty() && y < footerY - 95f) {
            y += drawTextBlock(
                canvas,
                "Symbols",
                margin,
                y,
                maxWidth,
                textPaint(COLOR_AURORA, 24f, Typeface.BOLD)
            ) + 18f

            var x = margin
            symbols.take(4).forEach { symbol ->
                val chipWidth = pillWidth(symbol)
                if (x + chipWidth <= width - margin) {
                    drawPill(
                        canvas,
                        x,
                        y,
                        symbol,
                        colorWithAlpha(COLOR_SURFACE_TWO, 0.88f),
                        COLOR_TEXT_PRIMARY
                    )
                    x += chipWidth + 14f
                }
            }
        }

        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = colorWithAlpha(COLOR_TEXT_PRIMARY, 0.14f)
            strokeWidth = 2f
            canvas.drawLine(margin, footerY - 30f, width - margin, footerY - 30f, this)
        }
        drawTextBlock(
            canvas,
            "Shared from DreamLog",
            margin,
            footerY,
            maxWidth,
            textPaint(COLOR_TEXT_PRIMARY, 28f, Typeface.BOLD)
        )
        drawTextBlock(
            canvas,
            "AI dream journal and pattern analyzer",
            margin,
            footerY + 42f,
            maxWidth,
            textPaint(COLOR_TEXT_SECONDARY, 24f, Typeface.NORMAL)
        )
    }

    private fun drawSection(
        canvas: Canvas,
        label: String,
        body: String,
        x: Float,
        y: Float,
        maxWidth: Float,
        maxLines: Int,
        bodyTextSize: Float
    ): Float {
        val labelHeight = drawTextBlock(
            canvas,
            label,
            x,
            y,
            maxWidth,
            textPaint(COLOR_AURORA, 24f, Typeface.BOLD)
        )
        val bodyHeight = drawTextBlock(
            canvas,
            body,
            x,
            y + labelHeight + 16f,
            maxWidth,
            textPaint(COLOR_TEXT_PRIMARY, bodyTextSize, Typeface.NORMAL),
            maxLines = maxLines,
            lineSpacingMultiplier = 1.12f
        )
        return labelHeight + 16f + bodyHeight
    }

    private fun drawPill(
        canvas: Canvas,
        x: Float,
        y: Float,
        text: String,
        color: Int,
        textColor: Int
    ) {
        val width = pillWidth(text)
        val rect = RectF(x, y, x + width, y + 48f)
        canvas.drawRoundRect(
            rect,
            24f,
            24f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { this.color = color }
        )
        drawTextBlock(
            canvas,
            text,
            x + 22f,
            y + 11f,
            width - 44f,
            textPaint(textColor, 22f, Typeface.BOLD),
            maxLines = 1
        )
    }

    private fun pillWidth(text: String): Float {
        return textPaint(COLOR_TEXT_PRIMARY, 22f, Typeface.BOLD).measureText(text) + 44f
    }

    private fun drawTextBlock(
        canvas: Canvas,
        text: String,
        x: Float,
        y: Float,
        maxWidth: Float,
        paint: TextPaint,
        maxLines: Int? = null,
        lineSpacingMultiplier: Float = 1.0f
    ): Float {
        val safeText = text.ifBlank { " " }
        val width = maxWidth.toInt().coerceAtLeast(1)
        val layout = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            StaticLayout.Builder.obtain(safeText, 0, safeText.length, paint, width)
                .setAlignment(Layout.Alignment.ALIGN_NORMAL)
                .setLineSpacing(0f, lineSpacingMultiplier)
                .setIncludePad(false)
                .setEllipsize(TextUtils.TruncateAt.END)
                .also { builder ->
                    if (maxLines != null) {
                        builder.setMaxLines(maxLines)
                    }
                }
                .build()
        } else {
            @Suppress("DEPRECATION")
            StaticLayout(
                safeText,
                paint,
                width,
                Layout.Alignment.ALIGN_NORMAL,
                lineSpacingMultiplier,
                0f,
                false
            )
        }

        canvas.save()
        canvas.translate(x, y)
        layout.draw(canvas)
        canvas.restore()
        return layout.height.toFloat()
    }

    private fun textPaint(color: Int, textSize: Float, style: Int): TextPaint {
        return TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            this.textSize = textSize
            typeface = Typeface.create("sans-serif", style)
        }
    }

    private fun colorWithAlpha(color: Int, alphaFraction: Float): Int {
        val alpha = (255 * alphaFraction).toInt().coerceIn(0, 255)
        return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))
    }

    private fun emotionColor(emotion: String): Int {
        val normalized = emotion.lowercase()
        return when {
            normalized.contains("joy") || normalized.contains("happy") -> COLOR_GOLD
            normalized.contains("fear") ||
                normalized.contains("anx") ||
                normalized.contains("sad") -> COLOR_ROSE
            normalized.contains("neutral") -> Color.rgb(75, 85, 99)
            else -> COLOR_AURORA
        }
    }

    private fun shareFile(
        path: String,
        mimeType: String,
        chooserTitle: String,
        text: String?
    ) {
        val file = File(path)
        require(file.exists()) { "Share file does not exist." }

        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file
        )

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_TITLE, chooserTitle)
            if (!text.isNullOrBlank()) {
                putExtra(Intent.EXTRA_TEXT, text)
            }
            clipData = ClipData.newUri(contentResolver, "DreamLog share", uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        val targets = packageManager.queryIntentActivities(
            intent,
            PackageManager.MATCH_DEFAULT_ONLY
        )
        require(targets.isNotEmpty()) { "No app can share this file." }
        targets.forEach { target ->
            grantUriPermission(
                target.activityInfo.packageName,
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        }

        val chooser = Intent.createChooser(intent, chooserTitle).apply {
            clipData = ClipData.newUri(contentResolver, "DreamLog share", uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        startActivity(chooser)
    }

    @Deprecated("Deprecated in Android API, still supported by FlutterActivity.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != IMPORT_JSON_REQUEST_CODE) {
            return
        }

        val result = pendingImportResult ?: return
        pendingImportResult = null

        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            result.error("missing_uri", "No file was selected.", null)
            return
        }

        try {
            val content = readTextFromUri(uri)
            result.success(
                mapOf(
                    "name" to displayNameFor(uri),
                    "content" to content
                )
            )
        } catch (error: Exception) {
            result.error(
                "read_failed",
                error.message ?: "Could not read selected file.",
                null
            )
        }
    }

    private fun readTextFromUri(uri: Uri): String {
        val input = contentResolver.openInputStream(uri)
            ?: throw IllegalArgumentException("Could not open selected file.")
        return input.use { stream ->
            String(stream.readBytes(), StandardCharsets.UTF_8)
        }
    }

    private fun displayNameFor(uri: Uri): String {
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (nameIndex >= 0 && cursor.moveToFirst()) {
                return cursor.getString(nameIndex) ?: "backup.json"
            }
        }
        return uri.lastPathSegment ?: "backup.json"
    }

    companion object {
        private const val IMPORT_JSON_REQUEST_CODE = 4281
        private val COLOR_BACKGROUND = Color.rgb(15, 14, 23)
        private val COLOR_SURFACE = Color.rgb(30, 27, 75)
        private val COLOR_SURFACE_TWO = Color.rgb(31, 41, 55)
        private val COLOR_PRIMARY_LIGHT = Color.rgb(139, 92, 246)
        private val COLOR_AURORA = Color.rgb(110, 231, 183)
        private val COLOR_GOLD = Color.rgb(252, 211, 77)
        private val COLOR_ROSE = Color.rgb(248, 113, 113)
        private val COLOR_TEXT_PRIMARY = Color.rgb(249, 250, 251)
        private val COLOR_TEXT_SECONDARY = Color.rgb(156, 163, 175)
    }
}
