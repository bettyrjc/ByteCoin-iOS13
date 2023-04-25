//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//https://rest.coinapi.io/
///v1/exchangerate/{asset_id_base}/{asset_id_quote}?time={time}  /v1/exchangerate/BTC/USD



import Foundation
protocol CoinManagerDelegate {
    func didUpdateCoin(price: String, currency: String)
    func didFailWithError(error: Error)
}
struct CoinManager {
 
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8174E7DF-4F48-4C8B-981D-ACCB294E9CC3"
    var delegate: CoinManagerDelegate?
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String)  {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        //1 Create URL
        if let url = URL(string: urlString){
            //2 Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3 Give the sesion a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                

                if let safeData = data {
                    if let coin = self.parseJSON(safeData){
                        let priceString = String(format: "%.2f", coin)
                        self.delegate?.didUpdateCoin(price: priceString, currency: currency)
                    }
                }
            }
            
            //4 Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch{
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
}
