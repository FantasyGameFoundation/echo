package com.erjiguan.echo

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.net.URLConnection

class MainActivity : FlutterActivity() {
    private val storageDirectoryChannelName = "echo/platform/storage_directory"
    private val projectBundleTransferChannelName = "echo/platform/project_bundle_transfer"
    private val pickBundleDirectoryRequestCode = 7001

    private var pendingBundleTransferResult: MethodChannel.Result? = null
    private var pendingBundleTransferOperation: PendingBundleTransferOperation? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            storageDirectoryChannelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppStorageDirectory" -> result.success(applicationContext.filesDir.absolutePath)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            projectBundleTransferChannelName,
        ).setMethodCallHandler { call, result ->
            if (pendingBundleTransferResult != null) {
                result.error(
                    "busy",
                    "Another project bundle transfer is already active.",
                    null,
                )
                return@setMethodCallHandler
            }

            when (call.method) {
                "exportBundleDirectory" -> {
                    val arguments = call.arguments as? Map<*, *>
                    val bundleDirectoryPath =
                        arguments?.get("bundleDirectoryPath") as? String
                    val suggestedBundleName =
                        arguments?.get("suggestedBundleName") as? String

                    if (bundleDirectoryPath.isNullOrBlank() || suggestedBundleName.isNullOrBlank()) {
                        result.error(
                            "invalidSelection",
                            "Export bundle arguments are missing.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val sourceDirectory = File(bundleDirectoryPath)
                    if (!sourceDirectory.exists() || !sourceDirectory.isDirectory) {
                        result.error(
                            "invalidSelection",
                            "The source bundle directory does not exist.",
                            bundleDirectoryPath,
                        )
                        return@setMethodCallHandler
                    }

                    pendingBundleTransferResult = result
                    pendingBundleTransferOperation =
                        PendingBundleTransferOperation.Export(
                            sourceDirectory = sourceDirectory,
                            suggestedBundleName = suggestedBundleName,
                        )
                    launchDirectoryPicker()
                }

                "pickImportBundleDirectory" -> {
                    pendingBundleTransferResult = result
                    pendingBundleTransferOperation = PendingBundleTransferOperation.ImportSelection
                    launchDirectoryPicker()
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun launchDirectoryPicker() {
        val intent =
            Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PREFIX_URI_PERMISSION,
                )
            }
        runOnUiThread {
            @Suppress("DEPRECATION")
            startActivityForResult(intent, pickBundleDirectoryRequestCode)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickBundleDirectoryRequestCode) {
            return
        }
        handleBundleTransferResult(resultCode = resultCode, data = data)
    }

    private fun handleBundleTransferResult(resultCode: Int, data: Intent?) {
        val channelResult = pendingBundleTransferResult
        val operation = pendingBundleTransferOperation
        pendingBundleTransferResult = null
        pendingBundleTransferOperation = null

        if (channelResult == null || operation == null) {
            return
        }

        if (resultCode != Activity.RESULT_OK) {
            channelResult.success(null)
            return
        }

        val treeUri = data?.data
        if (treeUri == null) {
            channelResult.error(
                "invalidSelection",
                "The selected bundle directory is unavailable.",
                null,
            )
            return
        }

        try {
            android.util.Log.e(
                "EchoBundle",
                "handleBundleTransferResult operation=$operation treeUri=$treeUri flags=${data.flags}",
            )
            persistTreePermission(treeUri, data.flags)
            val payload =
                when (operation) {
                    is PendingBundleTransferOperation.Export ->
                        exportBundleDirectory(
                            treeUri = treeUri,
                            sourceDirectory = operation.sourceDirectory,
                            suggestedBundleName = operation.suggestedBundleName,
                        )
                    PendingBundleTransferOperation.ImportSelection ->
                        importBundleDirectory(treeUri = treeUri)
                }
            channelResult.success(payload)
        } catch (securityException: SecurityException) {
            channelResult.error(
                "permissionDenied",
                securityException.message ?: "The selected bundle directory is not accessible.",
                null,
            )
        } catch (ioException: IOException) {
            channelResult.error(
                "ioFailure",
                ioException.message ?: "Project bundle transfer failed.",
                null,
            )
        } catch (exception: IllegalArgumentException) {
            channelResult.error(
                "invalidSelection",
                exception.message ?: "The selected bundle directory is invalid.",
                null,
            )
        }
    }

    private fun persistTreePermission(treeUri: Uri, intentFlags: Int) {
        val permissionFlags =
            intentFlags and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        if (permissionFlags != 0) {
            contentResolver.takePersistableUriPermission(treeUri, permissionFlags)
        }
    }

    private fun exportBundleDirectory(
        treeUri: Uri,
        sourceDirectory: File,
        suggestedBundleName: String,
    ): Map<String, String> {
        val parentDocumentUri = treeDocumentUri(treeUri)
        val normalizedBundleName = sanitizeBundleName(suggestedBundleName)
        val targetBundleName = uniqueChildName(treeUri, parentDocumentUri, normalizedBundleName)
        val bundleDirectoryUri =
            DocumentsContract.createDocument(
                contentResolver,
                parentDocumentUri,
                DocumentsContract.Document.MIME_TYPE_DIR,
                targetBundleName,
            )
                ?: throw IOException("Unable to create the export bundle directory.")

        copyLocalDirectoryIntoDocumentTree(
            treeUri = treeUri,
            sourceDirectory = sourceDirectory,
            targetDirectoryUri = bundleDirectoryUri,
        )

        val parentDisplayPath = displayPathForTree(treeUri)
        val displayPath =
            if (parentDisplayPath.isBlank()) {
                targetBundleName
            } else {
                "$parentDisplayPath/$targetBundleName"
            }

        return mapOf(
            "displayPath" to displayPath,
            "copyablePath" to displayPath,
        )
    }

    private fun importBundleDirectory(treeUri: Uri): Map<String, String> {
        // Keep traversing with the exact subtree URI granted by the picker.
        // Rebuilding a parent tree URI can lose access after reinstall because
        // the app only has permission for the selected subtree, not its parent.
        val sourceDirectoryUri = treeDocumentUri(treeUri)
        val importDirectory =
            File(cacheDir, "echo-import-${System.currentTimeMillis()}").apply {
                if (exists()) {
                    deleteRecursively()
                }
                mkdirs()
            }
        val rootDisplayName =
            queryDisplayName(sourceDirectoryUri)
                ?.takeIf { it.isNotBlank() }
                ?.let(::sanitizeBundleName)
                ?: "selected-bundle"
        val selectedRootDirectory = File(importDirectory, rootDisplayName).apply {
            mkdirs()
        }

        val copiedEntryCount =
            copyDocumentTreeToLocalDirectory(
                treeUri = treeUri,
                sourceDirectoryUri = sourceDirectoryUri,
                targetDirectory = selectedRootDirectory,
            )
        android.util.Log.d(
            "EchoBundle",
            "Imported tree uri=$treeUri, root=$sourceDirectoryUri, rootDisplayName=$rootDisplayName, copiedEntries=$copiedEntryCount, target=${importDirectory.absolutePath}",
        )
        val resolvedBundleDirectory = resolveLocalBundleDirectory(importDirectory)
        android.util.Log.e(
            "EchoBundle",
            "Resolved local bundle directory=${resolvedBundleDirectory?.absolutePath ?: "(none)"}",
        )

        return mapOf(
            "bundleDirectoryPath" to (resolvedBundleDirectory?.absolutePath ?: importDirectory.absolutePath),
            "cleanupDirectoryPath" to importDirectory.absolutePath,
            "displayPath" to displayPathForTree(treeUri),
        )
    }

    private fun copyLocalDirectoryIntoDocumentTree(
        treeUri: Uri,
        sourceDirectory: File,
        targetDirectoryUri: Uri,
    ) {
        sourceDirectory.listFiles()
            ?.sortedBy { it.name.lowercase() }
            ?.forEach { child ->
                if (child.isDirectory) {
                    val childDirectoryUri =
                        DocumentsContract.createDocument(
                            contentResolver,
                            targetDirectoryUri,
                            DocumentsContract.Document.MIME_TYPE_DIR,
                            child.name,
                        )
                            ?: throw IOException("Unable to create directory ${child.name}.")
                    copyLocalDirectoryIntoDocumentTree(
                        treeUri = treeUri,
                        sourceDirectory = child,
                        targetDirectoryUri = childDirectoryUri,
                    )
                } else {
                    val childFileUri =
                        DocumentsContract.createDocument(
                            contentResolver,
                            targetDirectoryUri,
                            resolveMimeType(child.name),
                            child.name,
                        )
                            ?: throw IOException("Unable to create file ${child.name}.")

                    FileInputStream(child).use { input ->
                        contentResolver.openOutputStream(childFileUri)?.use { output ->
                            input.copyTo(output)
                        }
                            ?: throw IOException("Unable to open output stream for ${child.name}.")
                    }
                }
            }
    }

    private fun copyDocumentTreeToLocalDirectory(
        treeUri: Uri,
        sourceDirectoryUri: Uri,
        targetDirectory: File,
    ): Int {
        var copiedEntryCount = 0
        val children = listDocumentChildren(treeUri, sourceDirectoryUri)
        android.util.Log.e(
            "EchoBundle",
            "Copying directory uri=$sourceDirectoryUri childCount=${children.size} target=${targetDirectory.absolutePath}",
        )
        children.forEach { child ->
            val childDocumentUri = documentUri(treeUri, child.documentId)
            val childFile = File(targetDirectory, child.displayName)

            if (child.isDirectory) {
                if (!childFile.exists()) {
                    childFile.mkdirs()
                }
                copiedEntryCount += 1
                copiedEntryCount += copyDocumentTreeToLocalDirectory(
                    treeUri = treeUri,
                    sourceDirectoryUri = childDocumentUri,
                    targetDirectory = childFile,
                )
            } else {
                contentResolver.openInputStream(childDocumentUri)?.use { input ->
                    FileOutputStream(childFile).use { output ->
                        input.copyTo(output)
                    }
                }
                    ?: throw IOException("Unable to open input stream for ${child.displayName}.")
                copiedEntryCount += 1
            }
        }
        return copiedEntryCount
    }

    private fun uniqueChildName(
        treeUri: Uri,
        directoryUri: Uri,
        preferredName: String,
    ): String {
        val existingNames =
            listDocumentChildren(treeUri, directoryUri).map { it.displayName }.toSet()
        if (!existingNames.contains(preferredName)) {
            return preferredName
        }

        var suffix = 2
        while (true) {
            val candidate = "$preferredName-$suffix"
            if (!existingNames.contains(candidate)) {
                return candidate
            }
            suffix += 1
        }
    }

    private fun listDocumentChildren(
        treeUri: Uri,
        directoryUri: Uri,
    ): List<DocumentChild> {
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(
                treeUri,
                DocumentsContract.getDocumentId(directoryUri),
            )
        val children = mutableListOf<DocumentChild>()

        contentResolver
            .query(
                childrenUri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE,
                ),
                null,
                null,
                null,
            )?.use { cursor ->
                while (cursor.moveToNext()) {
                    val documentId = cursor.stringAt(0)
                    val displayName = cursor.stringAt(1).orEmpty()
                    val mimeType = cursor.stringAt(2).orEmpty()
                    if (!documentId.isNullOrBlank() && displayName.isNotBlank()) {
                        children +=
                            DocumentChild(
                                documentId = documentId,
                                displayName = displayName,
                                mimeType = mimeType,
                            )
                    }
                }
            }

        return children.sortedBy { it.displayName.lowercase() }
    }

    private fun treeDocumentUri(treeUri: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(
            treeUri,
            DocumentsContract.getTreeDocumentId(treeUri),
        )

    private fun documentUri(treeUri: Uri, documentId: String): Uri =
        DocumentsContract.buildDocumentUriUsingTree(treeUri, documentId)

    private fun displayPathForTree(treeUri: Uri): String {
        val documentId = DocumentsContract.getTreeDocumentId(treeUri)
        val separatorIndex = documentId.indexOf(':')
        if (separatorIndex < 0) {
            return documentId
        }

        val relativePath = documentId.substring(separatorIndex + 1).trim('/')
        return if (relativePath.isBlank()) {
            "内部存储"
        } else {
            relativePath
        }
    }

    private fun sanitizeBundleName(value: String): String {
        val sanitized =
            value
                .trim()
                .replace(Regex("""[\\/:*?"<>|]"""), " ")
                .replace(Regex("""\s+"""), " ")
                .trim()

        return if (sanitized.isBlank()) {
            "Echo-Export"
        } else {
            sanitized
        }
    }

    private fun resolveMimeType(fileName: String): String =
        URLConnection.guessContentTypeFromName(fileName) ?: "application/octet-stream"

    private fun resolveLocalBundleDirectory(rootDirectory: File): File? {
        val candidates = mutableListOf<File>()
        rootDirectory.walkTopDown().forEach { file ->
            if (file.isFile && file.name == "manifest.json") {
                file.parentFile?.let(candidates::add)
            }
        }
        return if (candidates.size == 1) {
            candidates.single()
        } else {
            null
        }
    }

    private fun queryDisplayName(documentUri: Uri): String? =
        contentResolver
            .query(
                documentUri,
                arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    cursor.stringAt(0)
                } else {
                    null
                }
            }

}

private sealed class PendingBundleTransferOperation {
    data class Export(
        val sourceDirectory: File,
        val suggestedBundleName: String,
    ) : PendingBundleTransferOperation()

    data object ImportSelection : PendingBundleTransferOperation()
}

private data class DocumentChild(
    val documentId: String,
    val displayName: String,
    val mimeType: String,
) {
    val isDirectory: Boolean
        get() = mimeType == DocumentsContract.Document.MIME_TYPE_DIR
}

private fun Cursor.stringAt(index: Int): String? =
    if (isNull(index)) {
        null
    } else {
        getString(index)
    }
