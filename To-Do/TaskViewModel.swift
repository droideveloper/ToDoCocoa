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

import RxSwift
import RxCocoa

import MVVMCocoa
import Material

class TaskViewModel: AbstractViewModel<TaskViewController>,
	ViewModelType, LogType {

	let taskAdapter = TaskTableAdapter(dataSet: []);
	let category: Category;
	
	init(view: TaskViewController?, category: Category) {
		self.category = category;
		super.init(view: view);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		indicatorSource.onNext(true);
		BusManager.register({ [weak weakSelf = self] evt in
			if let event = evt as? DisplayEvent {
				weakSelf?.displayEvent(event: event);
			}
		}).disposed(by: dispose);
		if let application = Application.shared {
			if let taskStorage = application.component.resolve(DatabaseStorageType.self) {
				// create task list
				let taskDataSource = taskStorage.queryAll()
					.flatMap({ array in Observable.from(array) })
					.filter({ [weak weakSelf = self] (task: TodoTask) -> Bool in
							let category = weakSelf?.category ?? .all;
							switch category {
								case .all:
									return task.state == 0 || task.state == 1;
							case .active:
									return task.state == 0;
								case .inactive:
									return task.state == 1;
							}
					}).toArray()
					.subscribeOn(RxSchedulers.io)
					.observeOn(RxSchedulers.mainThread);
				// bind
				taskAdapter.bindDataSource(observable: taskDataSource, callback: { [weak weakSelf = self] in
					if let view = weakSelf?.view {
						view.reloadDataSource();
					}
					weakSelf?.indicatorSource.onNext(false);
				});
			}
		}
	}
	
	func displayEvent(event: DisplayEvent) {
		switch event.option {
			case .add:
				switch category {
					case .all:
						append(task: event.task);
					case .active:
						if event.task.state == 0 {
							append(task: event.task);
						}
					case .inactive:
						if event.task.state == 1 {
							append(task: event.task);
						}
				}
			case .update:
				updateForCategory(index: index(of: event.task), task: event.task);
			case .delete:
				delete(index: index(of: event.task));
		}
	}
	
	func updateForCategory(index: Int, task: TodoTask) {
		switch category {
			case .all:
				update(task: task, index: index);
			case .active:
				if task.state == 0 {
					append(task: task);
				} else {
					delete(index: index);
				}
			case .inactive:
				if task.state == 1 {
					append(task: task);
				} else {
					delete(index: index);
				}
		}
	}
	
	func index(of: TodoTask) -> Int {
		return taskAdapter.dataSet.index(of: of) ?? -1;
	}
	
	func append(task: TodoTask) {
		taskAdapter.dataSet.append(task);
		if let view = view {
			let index = taskAdapter.dataSet.count - 1;
			view.itemAddedAt(index: index);
		}
	}
	
	func delete(index: Int) {
		if index != -1 {
			taskAdapter.dataSet.remove(at: index);
			if let view = view {
				view.itemRemovedAt(index: index);
			}
		}
	}
	
	func update(task: TodoTask, index: Int) {
		if index != -1{
			taskAdapter.dataSet[index] = task;
			if let view = view {
				view.itemChangedAt(index: index);
			}
		}
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}

	func getClassTag() -> String {
		return String(describing: TaskViewModel.self);
	}
}
