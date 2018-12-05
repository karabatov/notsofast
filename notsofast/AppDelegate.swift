//
//  AppDelegate.swift
//  notsofast
//
//  Created by Yuri Karabatov on 28/04/2018.
//  Copyright © 2018 Yuri Karabatov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var mealDataProvider: FRCDataProvider<MealEntity, Meal, MealListDataConfig>?
    private var timerDisposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let config = MealListDataConfig(startDate: Date().beginningOfNextHourYesterday(), endDate: Date.distantFuture)
        let dp = CoreDataProvider.sharedInstance.dataProviderForMealList(config: config)
        mealDataProvider = dp
        let vm = MealListViewModel(dataProvider: dp)
        let mainVC = MealListViewController(dataSource: vm, viewModel: vm)
        let nav = UINavigationController(rootViewController: mainVC)

        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window?.tintColor = UIColor.nsfTintColor
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        setupDataSourceTimer()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        timerDisposeBag = DisposeBag()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        moveDataConfigForwardIfNeeded()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        setupDataSourceTimer()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Helpers

    /// Move data config displayed date an hour forward every hour.
    private func setupDataSourceTimer() {
        guard let dp = mealDataProvider else { return }

        timerDisposeBag = DisposeBag()

        let nextHour = Date().beginningOfNextHour().timeIntervalSinceNow
        NSFLog("Going to update dataConfig in \(nextHour) seconds.")
        Observable<Int>.timer(nextHour, period: 60.0 * 60.0, scheduler: MainScheduler.asyncInstance)
            .withLatestFrom(dp.dataConfig)
            .map { dataConfig -> MealListDataConfig in
                if dataConfig.endDate == Date.distantFuture {
                    return MealListDataConfig(startDate: Date().beginningOfNextHourYesterday(), endDate: Date.distantFuture)
                } else {
                    return dataConfig
                }
            }
            .bind(to: dp.dataConfig)
            .disposed(by: timerDisposeBag)
    }

    /// Update the start date to be not older than 24 hours immediately rather than at the next hour.
    private func moveDataConfigForwardIfNeeded() {
        guard let dp = mealDataProvider else { return }

        dp.dataConfig
            .take(1)
            .map { dataConfig -> MealListDataConfig in
                guard dataConfig.endDate == Date.distantFuture else {
                    return dataConfig
                }

                return MealListDataConfig(startDate: Date().beginningOfNextHourYesterday(), endDate: Date.distantFuture)
            }
            // Avoid binding otherwise it sends “isCompleted” down the line.
            .subscribe(onNext: { dataConfig in
                dp.dataConfig.onNext(dataConfig)
            })
            .dispose()
    }
}

