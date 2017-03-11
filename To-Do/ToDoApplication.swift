/*
 * To-Do Copyright (C) 2017 Fatih.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */ 
import UIKit

import MVVMCocoa
import Swinject
import Material

import RxSwift

@UIApplicationMain
class ToDoApplication: UIResponder, UIApplicationDelegate, 
ApplicationType, LogType {
 	
 	var window: UIWindow?;
 	// Theme
 	var colorPrimary: UIColor			= Color.teal.darken2;
	var colorPrimaryDark: UIColor = Color.teal.darken2;
	var colorAccent: UIColor			= Color.teal.darken2;
	// injector
	var component: Container = AppModule.shared;
	
	let dispose = DisposeBag();
	
 	func applicationDidFinishLaunching(_ application: UIApplication) {
		window = UIWindow(frame: Screen.bounds);
		if let viewController = component.resolve(MainViewController.self) as? MainViewControllerImp {
			window!.rootViewController = ToDoStatusBarController(rootViewController: viewController);
		}
		window!.makeKeyAndVisible();
	}

	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}
	
	func getClassTag() -> String {
		return String(describing: ToDoApplication.self);
	}
}
