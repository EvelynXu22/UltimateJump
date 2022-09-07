//
//  ViewController.swift
//  Ultimate Jump
//
//  Created by Yiwen Xu on 12/8/21.
//
let SERVER_URL = "http://192.168.0.93:8000" // change this for your server name!!!
let AUDIO_BUFFER_SIZE = 800
var is_switch = false
var is_ah = false
var is_gamestart = false

import UIKit

class ViewController: UIViewController,URLSessionDelegate {
    
    let audio = AudioModel(buffer_size: AUDIO_BUFFER_SIZE)
    var timeData:[Float] = Array.init(repeating: 0.0, count: AUDIO_BUFFER_SIZE)
    
    let operationQueue = OperationQueue()
    let motionOperationQueue = OperationQueue()
    let calibrationOperationQueue = OperationQueue()
    
    // MARK: Class Properties
    lazy var session: URLSession = {
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        return URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }()
    
    let animation = CATransition()
    var magValue = 0.1
    
    var isWaitingForAudioData = true
    
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var ahLabel: UILabel!
    
    // MARK: Class Properties with Observers
    enum CalibrationStage {
        case notCalibrating
        case Switch
        case Ah
    }
    
    var calibrationStage:CalibrationStage = .notCalibrating {
        didSet{
            switch calibrationStage {
            case .Switch:

                DispatchQueue.main.async{
                    self.setAsCalibrating(self.switchLabel)
                    self.setAsNormal(self.ahLabel)
                }
                break
            case .Ah:

                DispatchQueue.main.async{
                    self.setAsCalibrating(self.ahLabel)
                    self.setAsNormal(self.switchLabel)
                }
                break
            case .notCalibrating:
                DispatchQueue.main.async{
                    self.setAsNormal(self.ahLabel)
                    self.setAsNormal(self.switchLabel)
                }
                break
            }
        }
    }
    
    var dsid:Int = 2

    
    // MARK: Microphone precessing audio Updates
    func startMicrophoneProcessing(withFps:Double){
        audio.audioManager?.inputBlock = audio.handleMicrophone
        
        Timer.scheduledTimer(timeInterval: 1.0/withFps, target: self,
                            selector: #selector(self.runEveryInterval),
                            userInfo: nil,
                            repeats: true)
    }
    @objc
    func runEveryInterval(){
        if audio.inputBuffer != nil {
            // copy data to swift array
            audio.inputBuffer!.fetchFreshData(&timeData, withNumSamples: Int64(AUDIO_BUFFER_SIZE))
            // After monitoring the sound loud enough
            if(timeData[timeData.count-1]>0.03){
                // wait for 1s
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                    self.calibrationOperationQueue.addOperation {
                        // acquiring the collected data
                        self.calibrationEventOccurred()
                    }
                })
            }


        }
    }
    
    //MARK: Calibration procedure
    private func calibrationEventOccurred(){
        if(self.isWaitingForAudioData)
        {
            self.isWaitingForAudioData = false
            //predict a label
            getPrediction(self.timeData)
            // dont predict again for a bit
            setDelayedWaitingToTrue(2.0)
            
        }
    }
    
    
    func setDelayedWaitingToTrue(_ time:Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            self.isWaitingForAudioData = true
        })
    }
    
    func setAsCalibrating(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.textColor = UIColor.red
    }
    
    func setAsNormal(_ label: UILabel){
        label.layer.add(animation, forKey:nil)
        label.textColor = UIColor.white
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = 0.5

        // Do any additional setup after loading the view.
        self.startMicrophoneProcessing(withFps: 10)
        audio.play()
        
        dsid = 2 // set this and it will update UI
    }
    
    

    //MARK: Comm with Server
    func sendFeatures(_ array:[Float], withLabel label:CalibrationStage){
        let baseURL = "\(SERVER_URL)/AddDataPoint"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array,
                                       "label":"\(label)",
                                       "dsid":self.dsid]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.convertDataToDictionary(with: data)
                    
                    print(jsonDictionary["feature"]!)
                    print(jsonDictionary["label"]!)
                }

        })
        
        postTask.resume() // start the task
    }
    
    func getPrediction(_ array:[Float]){
        let baseURL = "\(SERVER_URL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jsonUpload:NSDictionary = ["feature":array, "dsid":self.dsid]
        
        
        let requestBody:Data? = self.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody
        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                                                                  completionHandler:{
                        (data, response, error) in
                        if(error != nil){
                            if let res = response{
                                print("Response:\n",res)
                            }
                        }
                        else{ // no error we are aware of
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            let labelResponse = jsonDictionary["prediction"]!
                            print(labelResponse)
                            self.displayLabelResponse(labelResponse as! String)

                        }
                                                                    
        })
        
        postTask.resume() // start the task
    }
    
    func displayLabelResponse(_ response:String){
        switch response {

        case "['Switch']":
            blinkLabel(switchLabel)
            if is_gamestart{
                is_switch = true
            }
            break
        case "['Ah']":
            blinkLabel(ahLabel)
            is_ah = true
            break
        default:
            print("Unknown")
            break
        }
    }
    
    func blinkLabel(_ label:UILabel){
        DispatchQueue.main.async {
            self.setAsCalibrating(label)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setAsNormal(label)
            })
        }
        
    }
    
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            
            if let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                            print("printing JSON received as string: "+strData)
            }else{
                print("json error: \(error.localizedDescription)")
            }
            return NSDictionary() // just return empty
        }
    }

}

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


