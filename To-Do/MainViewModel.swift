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
 
import MVVMCocoa

import Material

import RxSwift
import RxCocoa

import Swinject

class MainViewModel: AbstractViewModel<MainViewController>,
	ViewModelType, LogType, UITextFieldDelegate,
	UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	let textDataSource = BehaviorSubject<String>(value: "");
	let databaseStorage: DatabaseStorageType;
	let dependency: ResolverType;
	
	var delay: DispatchTime {
		get {
			return .now() + 0.5;
		}
	}
	let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil);
	let dataSource: [Category] = [.all, .active, .inactive];
	
	var viewControllerTitles: [TitleButton] = [];
	var viewControllerSource: [TaskViewControllerImp]  = [];
	var textString: String = "";
	
	var selectedIndex = 0;
	
	init(view: MainViewController, dependency: ResolverType) {
		if let databaseStorage = dependency.resolve(DatabaseStorageType.self) {
			self.databaseStorage = databaseStorage;
		} else {
			fatalError("can not resolve dataStorage");
		}
		self.dependency = dependency;
		super.init(view: view);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		if let text = view?.textDataSource as? ControlProperty<String?> {
			text
				.map({ str in str ?? "" })
				.bindNext({ [weak weakSelf = self] str in
					weakSelf?.textString = str;
				}).disposed(by: dispose);
			
			textDataSource
				.bindTo(text)
				.disposed(by: dispose);
		}
		BusManager.register({ [weak weakSelf = self] evt in
			if let event = evt as? AddTaskEvent {
				weakSelf?.createTask(text: event.text);
			} else if let event = evt as? ChangeTaskEvent {
				weakSelf?.updateTask(task: event.task);
			} else if let event = evt as? DeleteTaskEvent {
				weakSelf?.deleteTask(task: event.task);
			}
		}).disposed(by: dispose);
		//add and create
		viewController.dataSource = self;
		viewController.delegate = self;
		// data source
		viewControllerSource = dataSource.map({ [weak weakSelf = self] entry in
			if let viewController = weakSelf?.dependency.resolve(TaskViewController.self) as? TaskViewControllerImp {
				viewController.viewModel = TaskViewModel(view: viewController, category: entry);
				return viewController;
			} else {
				fatalError("can not create viewController for \(entry)");
			}
		});
		// update
		view?.addViewPager(viewController: viewController);
		viewController.setViewControllers([viewControllerSource[selectedIndex]], direction: .forward, animated: true, completion: nil);
		// title Indicator
		viewControllerTitles = dataSource.map({ entry in TitleButton(title: "\(entry)".uppercased()) });
		// initial state
		viewControllerTitles[selectedIndex].isSelected = true;
		view?.addViewPagerTitles(titles: viewControllerTitles);
	}
	
	func createTask(text: String) {
		if text != "" {
			databaseStorage.create({ (context) -> TodoTask in
				let task: TodoTask = try context.new();
				task.text = text;
				task.state = 0;
				return task;
			}).subscribeOn(RxSchedulers.io)
				.observeOn(RxSchedulers.mainThread)
				.bindNext({ task in
					BusManager.send(event: DisplayEvent(task: task, option: .add));
				}).disposed(by: dispose);
		}
	}
	
	func updateTask(task: TodoTask) {
		databaseStorage.update({ (context) -> TodoTask? in
			try context.insert(task);
			return task;
		}).subscribeOn(RxSchedulers.io)
			.observeOn(RxSchedulers.mainThread)
			.bindNext({ task in
				BusManager.send(event: DisplayEvent(task: task, option: .update));
			}).disposed(by: dispose);
	}
	
	func deleteTask(task: TodoTask) {
		databaseStorage.delete({ (context) -> TodoTask? in
			try context.remove(task);
			return task;
		}).subscribeOn(RxSchedulers.io)
			.observeOn(RxSchedulers.mainThread)
			.bindNext({ task in
				BusManager.send(event: DisplayEvent(task: task, option: .delete));
			}).disposed(by: dispose);
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder();
		if textString =~ ".{5,}" {
			BusManager.send(event: AddTaskEvent(text: textString));
		} else {
			if textString != "" {
				let retryObserver = PublishSubject<Void>();
				retryObserver
					.bindNext({ _ in
						textField.becomeFirstResponder();
					}).disposed(by: dispose);
				
				let text = NSLocalizedString("Task must be at leat 5 characters long.", comment: "Task name requirement");
				let actionText = NSLocalizedString("Retry", comment: "Retry comment on view");
				
				let snack = Snack.show(text: text, actionText: actionText, tapObserver: retryObserver);
				DispatchQueue.main.asyncAfter(deadline: delay) { [weak weakSelf = self] in
					weakSelf?.snackbarSource.onNext(snack);
				};
			}
		}
		textDataSource.onNext("");
		return false;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? TaskViewControllerImp {
			if let index = viewControllerSource.index(of: viewController) {
				if index < (dataSource.count - 1) {
					return viewControllerSource[index + 1];
				}
			}
		}
		return nil;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? TaskViewControllerImp {
			if let index = viewControllerSource.index(of: viewController) {
				if index > 0 {
					return viewControllerSource[index - 1];
				}
			}
		}
		return nil;
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return dataSource.count;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if finished && completed {
			if let viewController = pageViewController.viewControllers?.last as? TaskViewControllerImp {
				let index = viewControllerSource.index(of: viewController) ?? -1;
				if index != -1 {
					selectedIndex = index;
					// clear previous states
					for title in viewControllerTitles {
						title.isSelected = false;
					}
					// set new state
					viewControllerTitles[index].isSelected = true;
				}
			}
		}
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}
	
	func getClassTag() -> String {
		return String(describing: MainViewModel.self);
	}
}
