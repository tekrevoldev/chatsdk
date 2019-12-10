import FirebaseStorage
import UIKit
import Foundation

class DownloadManager: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func startUser(_ name: String, pictureAt: Int64, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		if (pictureAt != 0) {
			start(dir: "user", name: name, ext: "jpg", md5: nil, manual: false, completion: completion)
		} else {
			completion(nil, NSError.description("Missing picture.", code: 100), false)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func startImage(_ name: String, md5: String?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(dir: "media", name: name, ext: "jpg", md5: md5, manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func startVideo(_ name: String, md5: String?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(dir: "media", name: name, ext: "mp4", md5: md5, manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func startAudio(_ name: String, md5: String?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(dir: "media", name: name, ext: "m4a", md5: md5, manual: false, completion: completion)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func start(dir: String, name: String, ext: String, md5: String?, manual: Bool,
							 completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		let file = File.name(name, ext)
		let path = Dir.document(dir, and:file)

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and:fileManual)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and:fileLoading)

		let pathStorage = "\(dir)/\(name)_audio.\(ext)"

		// Check if file is already downloaded
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (File.exist(path: path)) {
			completion(path, nil, false)
			return
		}

		// Check if manual download is required
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (manual) {
			if (File.exist(path: pathManual)) {
				completion(nil, NSError.description("Manual download required.", code: 101), false)
				return
			}
			try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
		}

		// Check if file is currently downloading
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let time = Int(Date().timeIntervalSince1970)

		if (File.exist(path: pathLoading)) {
			if let temp = try? String(contentsOfFile: pathLoading, encoding: .utf8) {
				if let check = Int(temp) {
					if (time - check < 300) {
						completion(nil, NSError.description("Downloading.", code: 102), false)
						return
					}
				}
			}
		}
		try? "\(time)".write(toFile: pathLoading, atomically: false, encoding: .utf8)

		// Download the file
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let reference = Storage.storage().reference(withPath: pathStorage)
		reference.write(toFile: URL(fileURLWithPath: path)) { url, error in
			if (error == nil) {
				if (File.size(path: path) != 0) {
//                    if (md5 == nil) || (md5 == Checksum.md5HashOf(path: path)) {
                        succeed(dir: dir, name: name, ext: ext, completion: completion)
//                    } else { failed(dir: dir, name: name, ext: ext, error: NSError.description("MD5 error.", code: 103), completion: completion) }
				} else { failed(dir: dir, name: name, ext: ext, error: NSError.description("Lenght error.", code: 104), completion: completion) }
			} else { failed(dir: dir, name: name, ext: ext, error: error, completion: completion) }
		}
	}
    
    public class func isDownloading(messageId: String) -> Bool {
        let file = File.name(messageId, "m4a")
        let fileLoading = file + ".loading"
        let pathLoading = Dir.document("media", and:fileLoading)
        
        let time = Int(Date().timeIntervalSince1970)
        
        if (File.exist(path: pathLoading)) {
            if let temp = try? String(contentsOfFile: pathLoading, encoding: .utf8) {
                if let check = Int(temp) {
                    if (time - check < 300) {
                        return true
                    }
                }
            }
        }
        
        return false
    }

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func succeed(dir: String, name: String, ext: String,
							   completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		let file = File.name(name, ext)
		let path = Dir.document(dir, and:file)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and:fileLoading)

		File.remove(path: pathLoading)

		DispatchQueue.main.async {
			completion(path, nil, true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func failed(dir: String, name: String, ext: String, error: Error?,
							  completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		let file = File.name(name, ext)
		let path = Dir.document(dir, and:file)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and:fileLoading)

		File.remove(path: path)
		File.remove(path: pathLoading)

		DispatchQueue.main.async {
			completion(nil, error, true)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func pathUser(_ name: String) -> String? { return path(dir: "user", name: name, ext: "jpg") }
	class func pathImage(_ name: String) -> String? { return path(dir: "media", name: name, ext: "jpg") }
	class func pathVideo(_ name: String) -> String? { return path(dir: "media", name: name, ext: "mp4") }
	class func pathAudio(_ name: String) -> String? { return path(dir: "media", name: name, ext: "m4a") }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func path(dir: String, name: String, ext: String) -> String? {

		let file = File.name(name, ext)
		let path = Dir.document(dir, and: file)

		return File.exist(path: path) ? path : nil
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func clearManualImage(_ name: String) { clearManual(dir: "media", name: name, ext: "jpg") }
	class func clearManualVideo(_ name: String) { clearManual(dir: "media", name: name, ext: "mp4") }
	class func clearManualAudio(_ name: String) { clearManual(dir: "media", name: name, ext: "m4a") }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func clearManual(dir: String, name: String, ext: String) {

		let file = File.name(name, ext)

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and: fileManual)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and:fileLoading)

		File.remove(path: pathManual)
		File.remove(path: pathLoading)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func saveUser(_ name: String, data: Data)		{ save(data: data, dir: "user", name: name, ext: "jpg", manual: false)	}
	class func saveImage(_ name: String, data: Data)	{ save(data: data, dir: "media", name: name, ext: "jpg", manual: true)	}
	class func saveVideo(_ name: String, data: Data)	{ save(data: data, dir: "media", name: name, ext: "mp4", manual: true)	}
	class func saveAudio(_ name: String, data: Data, threadId: String)	{ save(data: data, dir: "media", name: name, ext: "m4a", manual: true,  threadId: threadId)	}
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
    private class func save(data: Data, dir: String, name: String, ext: String, manual: Bool, threadId: String = "") {
        
        let file = File.name(name, ext)
        let path = Dir.document(dir, and: file)
        
        let fileManual = file + ".manual"
        let pathManual = Dir.document(dir, and: fileManual)
        
        try? data.write(to: URL(fileURLWithPath: path), options: .atomic)
        
        if (manual) {
            try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
        }
        
        if !threadId.isEmpty {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                UploadManager.audio(name, data: data, completion: { error, path  in
                    //TODO: Send Message Here
                    FirebaseAudioMesage.init(threadId: threadId, messageId: name).sendMessage(audioPath: path, messageId: name)
                })
            }
        }
    }
}
