//
//  SpeechRecognizer.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/15/21.
//

import Speech

class SpeechRecognizer {
    var speechRecognizer: SFSpeechRecognizer!
    
    func requestSpeechAccess() -> Bool {
        var allowed = false
        
        if (SFSpeechRecognizer.authorizationStatus() == .authorized) {
            return true
        }
        
        SFSpeechRecognizer.requestAuthorization({ auth in
            allowed = (auth == .authorized)
        })
        return allowed
    }
    
    func transcript(audioFileName: String) -> String {
        
        let audioUrl: URL = URL(fileURLWithPath: getDocumentsDirectory() + "/" + audioFileName)
        
        let authResponse = createJWT()
        let accessToken = (authResponse["access_token"] as! String).prefix(222)
        var transcriptExists = false
        var transcript = ""
        
        let group = DispatchGroup()
        group.enter()
        
        downloadTranscript(audioFileName: audioFileName,
                           accessToken: String(accessToken)) { exists in
            
            //print("exists = \(exists)")
            if (exists != "") {
                transcriptExists = true
            }
            group.leave()
            
            transcript = exists
        }
        
        group.wait()
        
        
        if (!transcriptExists) {
            print("TRANSCRIPT DOES NOT EXIST")
            
            self.requestTranscript(accessToken: String(accessToken),
                                              audioFileName: audioFileName)
            
        } else {
            return transcript
        }
        print(transcript)
        return "a problem occured while retrieving the transcript..."
    }
    
    func uploadAudio(audioFilePath: String,
                     audioFileName: String,
                     accessToken: String,
                     completion: @escaping ([String: Any]) -> ()) {
        var request = URLRequest(url: URL(string: "https://storage.googleapis.com/upload/storage/v1/b/audio-files00001/o?uploadType=media&name=audio-files/\(audioFileName)")!)
        let response: [String: Any] = [
            "results": 0
        ]
        
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(String(accessToken))",
            "Content-Type": "audio/x-wav",
        ]
        
        request.httpBody = FileManager.default.contents(atPath: audioFilePath)!
        
        let task = URLSession.shared.dataTask(with: request) { data, response_, error in
            guard let data = data,
                let response_ = response_ as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                print("error", error ?? "Unknown error")
                completion(response)
                return
            }

            guard (200 ... 299) ~= response_.statusCode else { // check for http errors
                print("statusCode should be 2xx, but is \(response_.statusCode)")
                print("response = " + String(data: data, encoding: .utf8)!)
                completion(response)
                return
            }
            
            if (response_.statusCode == 200) {
                let responseString = String(data: data, encoding: .utf8)
                
                let dict = try? JSONSerialization.jsonObject(with: (responseString?.data(using: .utf8))!) as? [String:Any]
                completion(dict!)
            }
        }
        task.resume()
    }
    
    func downloadTranscript(audioFileName: String,
                            accessToken: String,
                            completion: @escaping (String) -> ()) {
        var request = URLRequest(url: URL(string: "https://storage.googleapis.com/audio-files00001/transcripts/\(audioFileName)")!)
        let response = ""
        
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(String(accessToken))",
            "Content-Type": "application/json",
        ]
        
        let task = URLSession.shared.dataTask(with: request) { data, response_, error in
            guard let data = data,
                let response_ = response_ as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                print("error", error ?? "Unknown error")
                completion(response)
                return
            }

            guard (200 ... 299) ~= response_.statusCode else { // check for http errors
                print("statusCode should be 2xx, but is \(response_.statusCode)")
                print("response = " + String(data: data, encoding: .utf8)!)
                completion(response)
                return
            }
            
            if (response_.statusCode == 200) {
                let responseString = String(data: data, encoding: .utf8)
//
//                let dict = try? JSONSerialization.jsonObject(with: (responseString?.data(using: .utf8))!) as? [String:Any]
//                print(dict!)
                completion(responseString!)
            }
        }
        task.resume()
    }
    
    func availableTranscripts(completion: @escaping (String) -> ()) {
        let authResponse = createJWT()
        let accessToken = (authResponse["access_token"] as! String).prefix(222)
        
        var request = URLRequest(url: URL(string: "https://storage.googleapis.com/storage/v1/b/audio-files00001/o/?prefix=transcripts")!)
        let response = ""
        
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(String(accessToken))",
            "Content-Type": "application/json",
        ]
        
        let task = URLSession.shared.dataTask(with: request) { data, response_, error in
            guard let data = data,
                let response_ = response_ as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                print("error", error ?? "Unknown error")
                completion(response)
                return
            }

            guard (200 ... 299) ~= response_.statusCode else { // check for http errors
                print("statusCode should be 2xx, but is \(response_.statusCode)")
                print("response = " + String(data: data, encoding: .utf8)!)
                completion(response)
                return
            }
            
            if (response_.statusCode == 200) {
                let responseString = String(data: data, encoding: .utf8)
                completion(responseString!)
            }
        }
        task.resume()
    }

    func requestTranscript(accessToken: String, audioFileName: String) {
        let apiKey = "AIzaSyCavUnPtL8I5XXoPwbNx3Bh05toLcDNSRA"
        
        let url = URL(string: "https://speech.googleapis.com/v1/speech:longrunningrecognize?key=\(apiKey)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let headers: [String: String] = [
            "x-goog-project-id": "meeting-recorder-326219",
            "Authorization": "Bearer \(String(accessToken))",
            "content-type": "application/json",
        ]
        
        let body: [String:[String: Any]] = [
            "audio": [
                //"content": FileManager.default.contents(atPath: audioUrl.path)!.base64EncodedString()
                "uri": "gs://audio-files00001/audio-files/\(audioFileName)"
              ],
              "config": [
                  "encoding": "LINEAR16",
                  "sampleRateHertz": 22100,
                  "audioChannelCount": 1,
                  "languageCode": "en-US",
                  "enableWordTimeOffsets": false,
              ],
            "outputConfig": [
                "gcsUri": "gs://audio-files00001/transcripts/\(audioFileName)"
            ]
        ]
        
        let json = JSONSerialization.isValidJSONObject(body)
        if (json) {
            request.allHTTPHeaderFields = headers
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        if (self.requestSpeechAccess()) {
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else { // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
                }

                guard (200 ... 299) ~= response.statusCode else { // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("responseGCS = " + String(data: data, encoding: .utf8)!)
                    return
                }

                let responseString = String(data: data, encoding: .utf8)
                print(responseString!)
            }

            task.resume()
        }
    }
    
    func getDocumentsDirectory() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.path
    }
}
