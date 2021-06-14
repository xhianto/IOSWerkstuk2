//
//  ViewController.swift
//  Werkstuk2
//
//  Created by student on 12/06/2021.
//

import UIKit
import CoreData
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var PieChart: PieChartView!
    
    var astraZenecaDataEntry = PieChartDataEntry(value: 0)
    var johnsonJohnsonDataEntry = PieChartDataEntry(value: 0)
    var modernaDataEntry = PieChartDataEntry(value: 0)
    var pfizerDataEntry = PieChartDataEntry(value: 0)
    
    var vaccinatieDataEntries = [PieChartDataEntry]()
    
    var groepen: [Groep]?
    var groepenCD: [GroepCD]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        //deleteAllData()
        if groepenCD?.count == 0 {
            print("niets in database")
            getDataFromWebservice()
            //overzettenNaarCD()
        }
        
        if (groepenCD?.count)! > 0 {
            print("Items in database")
            updateChartData()
        }
        print("dit moet er achter komen")
    }
    
    func getData() -> Void {
        do {
            groepenCD = try self.context.fetch(GroepCD.fetchRequest())
        }
        catch {
            print("Kan data niet van GroepCD ophalen")
        }
    }
    
    func getDataFromWebservice() -> Void {
        let url = URL(string: "https://epistat.sciensano.be/Data/COVID19BE_VACC.json")!
        print("na url maken")
        let task = URLSession.shared.dataTask(with: url) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let jsonData = data
            {
                let decoder = JSONDecoder()
                do {
                    self.groepen = try decoder.decode([Groep].self, from: jsonData)
                    //let formatter = DateFormatter()
                    for var groep in self.groepen! {
                        if groep.REGION == nil {
                            groep.REGION = "Onbekend"
                        }
                        if groep.SEX == nil {
                            groep.SEX = "Onbekend"
                        }
                        print(groep.REGION!)
                        
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            DispatchQueue.main.async {
                self.overzettenNaarCD()
                self.getData()
                self.updateChartData()
            }
        }
        task.resume()
        
    }
    
    func overzettenNaarCD() -> Void {
        var teller:Int
        teller = 0
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        for groep in self.groepen! {
            let nieuwGroep = GroepCD(context: self.context)
            nieuwGroep.agegroup = groep.AGEGROUP
            nieuwGroep.brand = groep.BRAND
            nieuwGroep.count = groep.COUNT
            nieuwGroep.date = dateformatter.date(from: groep.DATE)
            nieuwGroep.dose = groep.DOSE
            nieuwGroep.region = groep.REGION
            nieuwGroep.sex = groep.SEX
            
            teller = teller + 1
            print(String(teller) + " item(s) overgezet")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func deleteAllData() -> Void {
        var teller: Int
        teller = 0;
        print("buiten loop")
        for groep in self.groepenCD! {
            teller = teller + 1
            print(String(teller) + " delete")
            context.delete(groep)
        }
        try! context.save()
    }
    
    func updateChartData() {
        astraZenecaDataEntry.value = 0
        astraZenecaDataEntry.label = "Astra"
        johnsonJohnsonDataEntry.value = 0
        johnsonJohnsonDataEntry.label = "J&J"
        modernaDataEntry.value = 0
        modernaDataEntry.label = "Moderna"
        pfizerDataEntry.value = 0
        pfizerDataEntry.label = "Pfizer"
        
        for groep in groepenCD! {
            print(groep.brand!)
            switch groep.brand {
            case "AstraZeneca-Oxford":
                astraZenecaDataEntry.value = astraZenecaDataEntry.value + 1
            case "Johnson&Johnson":
                johnsonJohnsonDataEntry.value = johnsonJohnsonDataEntry.value + 1
            case "Moderna":
                modernaDataEntry.value = modernaDataEntry.value + 1
            case "Pfizer-BioNTech":
                pfizerDataEntry.value = pfizerDataEntry.value + 1
            default:
                print("Geen brand")
            }
        }
        print(astraZenecaDataEntry.value)
        print(johnsonJohnsonDataEntry.value)
        print(modernaDataEntry.value)
        print(pfizerDataEntry.value)
        PieChart.chartDescription?.text = ""
        vaccinatieDataEntries = [astraZenecaDataEntry, johnsonJohnsonDataEntry, modernaDataEntry, pfizerDataEntry]
        let chartDataSet = PieChartDataSet(entries: vaccinatieDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let colors = [UIColor(named: "Astra"), UIColor(named:"Johnson"), UIColor(named: "Moderna"), UIColor(named: "Pfizer")]
        chartDataSet.colors = colors as! [NSUIColor]
        PieChart.data = chartData
    }

}

