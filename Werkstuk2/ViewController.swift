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
    @IBOutlet weak var labelLaatsteUpdate: UILabel!
    @IBOutlet weak var buttonUpdate: UIButton!
    
    
    var astraZenecaDataEntry = PieChartDataEntry(value: 0)
    var johnsonJohnsonDataEntry = PieChartDataEntry(value: 0)
    var modernaDataEntry = PieChartDataEntry(value: 0)
    var pfizerDataEntry = PieChartDataEntry(value: 0)
    
    var vaccinatieDataEntries = [PieChartDataEntry]()
    
    var groepen: [Groep]?
    var groepenCD: [GroepCD]?
    var update: [LaatsteKeerGeupdateCD]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        getData()
        //deleteAllData()
        if groepenCD?.count == 0 {
            getDataFromWebservice()
        }
        if (groepenCD?.count)! > 0 {
            updateChartData()
        }
    }
    
    func getData() -> Void {
        do {
            groepenCD = try self.context.fetch(GroepCD.fetchRequest())
            update = try self.context.fetch(LaatsteKeerGeupdateCD.fetchRequest())
        }
        catch {
            print("Kan data niet van GroepCD ophalen")
        }
    }
    
    func getDataFromWebservice() -> Void {
        let url = URL(string: "https://epistat.sciensano.be/Data/COVID19BE_VACC.json")!
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
        if update != nil {
            for u in self.update! {
                context.delete(u)
            }
            try! context.save()
        }
        let updateTijd = LaatsteKeerGeupdateCD(context: self.context)
        updateTijd.datum = Date()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func deleteAllData() -> Void {
        var teller: Int
        teller = 0;
        for groep in self.groepenCD! {
            teller = teller + 1
            print(String(teller) + " delete")
            context.delete(groep)
        }
        try! context.save()
    }
    
    // Brian Advent, iOS Swift Tutorial: Create Beautiful Charts
    // https://www.youtube.com/watch?v=GNf-SsDBQ20&t=3s
    // Geraadpleegd op 14 juni 2021
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
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd-MM-yyyy hh:mm:ss"
        labelLaatsteUpdate.text = "Laaste update: " + dateformatter.string(from: (update?.first?.datum)!)
    }

    @IBAction func UpdateData(_ sender: Any) {
        getDataFromWebservice()
    }
}

