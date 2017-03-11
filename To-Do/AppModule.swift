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
 
import Swinject

final class AppModule {

	public static let shared: Container = {
		let instance = AppModule();
		return instance.share();
	}();

	fileprivate func share() -> Container {
		let module = Container();
		module.register(DatabaseStorageType.self) { _ in DatabaseStorage() }
			.inObjectScope(.container);
		module.register(MainViewController.self) { _ in MainViewControllerImp() }
			.initCompleted({ (r, viewController) in
				guard let viewController = viewController as? MainViewControllerImp else { return }
				viewController.viewModel = MainViewModel(view: viewController, dependency: r);				
			}).inObjectScope(.graph);
		module.register(TaskViewController.self) { _ in TaskViewControllerImp() }
			.inObjectScope(.graph);		
		return module;
	}
}

