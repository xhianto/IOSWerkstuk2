//
//  ViewController.swift
//  Werkstuk2
//
//  Created by student on 12/06/2021.
//

import UIKit

class ViewController: UIViewController {
    
    var Groepen: [Groep]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getDataFromWebservice()
    }
    
    func getDataFromWebservice() -> Void {
        let url = URL(string: "https://epistat.sciensano.be/Data/COVID19BE_VACC.json")!
        print("na url maken")
        let task = URLSession.shared.dataTask(with: url) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            print("na sessie")
            if let jsonData = data
            {
                print("na data")
                let decoder = JSONDecoder()
                do {
                    self.Groepen = try decoder.decode([Groep].self, from: jsonData)
                    //let formatter = DateFormatter()
                    for groep in self.Groepen! {
                        if groep.REGION != nil {
                            print(groep.AGEGROUP)
                            print(groep.REGION!)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            print("skipping data")
        }
        task.resume()
    }

}

