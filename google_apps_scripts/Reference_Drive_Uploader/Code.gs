/**
 * ===============================================================================
 *  SEQUORA Studio — Turbo Reference & Remaining Photos Uploader (Google Apps Script)
 * ===============================================================================
 *  Account: REFERENCE DRIVE (Account 2)
 *  
 *  - High-Speed Parallel Processing: Supports 4-6 concurrent parallel worker streams.
 *  - Direct Folder ID Resolution & Caching: Zero unnecessary Drive hierarchy queries.
 *  - Handles both:
 *      1. Reference Images / Thumbnails (_P / _V)
 *      2. Remaining Photos Folders
 * ===============================================================================
 */

const DEFAULT_REF_FOLDER = "SEQUORA_Reference_Archives/Reference_Photos";
const DEFAULT_REMAINING_FOLDER = "SEQUORA_Reference_Archives/Remaining_Photos";

function doGet(e) {
  return HtmlService.createTemplateFromFile("Index")
    .evaluate()
    .setTitle("SEQUORA — Turbo Reference & Remaining Photos Uploader")
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)
    .addMetaTag('viewport', 'width=device-width, initial-scale=1');
}

/**
 * Gets saved persistent settings for Reference & Remaining Photos.
 */
function getReferenceSettings() {
  const props = PropertiesService.getUserProperties();
  
  let refFolder = props.getProperty("REF_PHOTOS_FOLDER") || DEFAULT_REF_FOLDER;
  let remainingFolder = props.getProperty("REMAINING_PHOTOS_FOLDER") || DEFAULT_REMAINING_FOLDER;
  let lastMode = props.getProperty("REF_LAST_MODE") || "ref"; // "ref" | "remaining"

  // Ensure defaults are saved
  props.setProperty("REF_PHOTOS_FOLDER", refFolder);
  props.setProperty("REMAINING_PHOTOS_FOLDER", remainingFolder);

  const refFolderObj = getOrCreateFolderPath(refFolder, "");
  const remainingFolderObj = getOrCreateFolderPath(remainingFolder, "");

  return {
    refFolder: refFolder,
    refFolderId: refFolderObj.getId(),
    refFolderUrl: refFolderObj.getUrl(),
    remainingFolder: remainingFolder,
    remainingFolderId: remainingFolderObj.getId(),
    remainingFolderUrl: remainingFolderObj.getUrl(),
    lastMode: lastMode,
    userEmail: Session.getActiveUser().getEmail() || "Reference Drive Account"
  };
}

/**
 * Saves one-time persistent folder destination paths.
 */
function saveReferencePath(mode, customPath) {
  const props = PropertiesService.getUserProperties();
  const clean = (customPath || "").trim();
  if (mode === "remaining") {
    props.setProperty("REMAINING_PHOTOS_FOLDER", clean || DEFAULT_REMAINING_FOLDER);
  } else {
    props.setProperty("REF_PHOTOS_FOLDER", clean || DEFAULT_REF_FOLDER);
  }
  return getReferenceSettings();
}

/**
 * Remembers the active selected mode.
 */
function saveActiveMode(mode) {
  PropertiesService.getUserProperties().setProperty("REF_LAST_MODE", mode);
}

/**
 * Fast Single File Upload with Direct Folder ID Resolution
 */
function uploadFileToReferenceDrive(payload) {
  try {
    const props = PropertiesService.getUserProperties();
    const mode = payload.mode || "ref"; // "ref" | "remaining"
    
    const targetRoot = mode === "remaining"
      ? (props.getProperty("REMAINING_PHOTOS_FOLDER") || DEFAULT_REMAINING_FOLDER)
      : (props.getProperty("REF_PHOTOS_FOLDER") || DEFAULT_REF_FOLDER);

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
      targetFolder = getOrCreateFolderPath(targetRoot, relPath);
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
 * Recursively creates or fetches folder hierarchy in Google Drive.
 */
function getOrCreateFolderPath(rootPath, relativePath) {
  const fullPath = (rootPath + "/" + (relativePath || "")).replace(/\\/g, "/");
  const parts = fullPath.split("/").filter(p => p && p.trim() !== "");

  let currentFolder = DriveApp.getRootFolder();

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
