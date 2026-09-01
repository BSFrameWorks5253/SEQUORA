/**
 * ===============================================================================
 *  SEQUORA Studio — Turbo Multi-Threaded Main Drive Uploader (Google Apps Script)
 * ===============================================================================
 *  Account: MAIN DRIVE (Account 1 — Master Videos & Full Photo Archives)
 *  
 *  - High-Speed Parallel Processing: Supports 4-6 concurrent parallel workers.
 *  - Smart Folder ID Caching: Avoids duplicate DriveApp searches across files.
 *  - Persistent Destination Folder: Saved permanently in UserProperties.
 * ===============================================================================
 */

const DEFAULT_MAIN_FOLDER = "SEQUORA_Master_Archives";

function doGet(e) {
  return HtmlService.createTemplateFromFile("Index")
    .evaluate()
    .setTitle("SEQUORA — Turbo Main Drive Uploader")
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
    .addMetaTag('viewport', 'width=device-width, initial-scale=1');
}

/**
 * Gets saved settings (persisted permanently in Google Drive user properties).
 */
function getMainSettings() {
  const props = PropertiesService.getUserProperties();
  let targetFolder = props.getProperty("MAIN_TARGET_FOLDER");
  if (!targetFolder) {
    targetFolder = DEFAULT_MAIN_FOLDER;
    props.setProperty("MAIN_TARGET_FOLDER", targetFolder);
  }

  const folder = getOrCreateRootFolder(targetFolder);
  return {
    targetFolder: targetFolder,
    folderId: folder.getId(),
    folderUrl: folder.getUrl(),
    userEmail: Session.getActiveUser().getEmail() || "Main Drive Account"
  };
}

/**
 * Saves one-time target folder preference permanently.
 */
function saveMainTargetFolder(folderName) {
  const clean = (folderName || DEFAULT_MAIN_FOLDER).trim();
  PropertiesService.getUserProperties().setProperty("MAIN_TARGET_FOLDER", clean);
  const folder = getOrCreateRootFolder(clean);
  return {
    success: true,
    targetFolder: clean,
    folderId: folder.getId(),
    folderUrl: folder.getUrl()
  };
}

/**
 * Fast Single File Upload with Direct Folder ID Resolution
 */
function uploadFileToMainDrive(payload) {
  try {
    const props = PropertiesService.getUserProperties();
    const rootName = props.getProperty("MAIN_TARGET_FOLDER") || DEFAULT_MAIN_FOLDER;
    const relPath = payload.relativePath || "";
    const fileName = payload.name || "untitled_file";
    const contentType = payload.type || "application/octet-stream";
    const base64Data = payload.base64;

    const decodedBytes = Utilities.base64Decode(base64Data);
    const blob = Utilities.newBlob(decodedBytes, contentType, fileName);

    let targetFolder = null;

    // Fast path: Direct ID from client cache
    if (payload.folderId) {
      try {
        targetFolder = DriveApp.getFolderById(payload.folderId);
      } catch (e) {
        targetFolder = null;
      }
    }

    // Slow path fallback: Search & Create hierarchy if ID wasn't provided or valid
    if (!targetFolder) {
      targetFolder = getOrCreateFolderPath(rootName, relPath);
    }

    const file = targetFolder.createFile(blob);

    return {
      success: true,
      fileId: file.getId(),
      fileName: fileName,
      fileUrl: file.getUrl(),
      folderId: targetFolder.getId(),
      folderUrl: targetFolder.getUrl(),
      folderName: targetFolder.getName()
    };
  } catch (err) {
    return {
      success: false,
      fileName: payload ? payload.name : "unknown",
      error: err.toString()
    };
  }
}

/**
 * Resolves or creates a folder path and returns its Folder ID for client caching.
 */
function resolveFolderPath(relativePath) {
  try {
    const props = PropertiesService.getUserProperties();
    const rootName = props.getProperty("MAIN_TARGET_FOLDER") || DEFAULT_MAIN_FOLDER;
    const folder = getOrCreateFolderPath(rootName, relativePath);
    return {
      success: true,
      folderId: folder.getId(),
      folderUrl: folder.getUrl(),
      folderName: folder.getName()
    };
  } catch (err) {
    return {
      success: false,
      error: err.toString()
    };
  }
}

function getOrCreateRootFolder(folderName) {
  const clean = (folderName || DEFAULT_MAIN_FOLDER).trim();
  const iter = DriveApp.getFoldersByName(clean);
  if (iter.hasNext()) {
    return iter.next();
  }
  return DriveApp.createFolder(clean);
}

function getOrCreateFolderPath(rootName, relativePath) {
  let currentFolder = getOrCreateRootFolder(rootName);

  if (!relativePath || relativePath.trim() === "") {
    return currentFolder;
  }

  const cleanPath = relativePath.replace(/\\/g, "/");
  const parts = cleanPath.split("/").filter(p => p && p.trim() !== "");

  for (let i = 0; i < parts.length; i++) {
    const folderName = parts[i].trim();
    if (!folderName) continue;

    const subIter = currentFolder.getFoldersByName(folderName);
    if (subIter.hasNext()) {
      currentFolder = subIter.next();
    } else {
      currentFolder = currentFolder.createFolder(folderName);
    }
  }

  return currentFolder;
}
