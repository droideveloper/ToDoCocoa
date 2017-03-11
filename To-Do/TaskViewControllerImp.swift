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

class TaskViewControllerImp: AbstractViewController<TaskViewModel>,
	TaskViewController, LogType, UITableViewDelegate {
	
	let tableView = TableView(frame: .zero, style: .plain);
	
	override func prepare() {
		super.prepare();
		tableView.register(TaskViewHolder.self, forCellReuseIdentifier: TaskViewHolder.kIdentifier);
		tableView.backgroundView = nil;
		tableView.backgroundColor = .white;
		
		tableView.separatorStyle = .singleLine;
		tableView.separatorColor = Color.rgb(0x333333);
		
		tableView.tableFooterView = View(frame: .zero);
		tableView.delegate = self;
		
		if let viewModel = viewModel {
			tableView.dataSource = viewModel.taskAdapter;
		}
		
		view.layout(tableView)
			.edges();
	}
	
	func itemAddedAt(index: Int) {
		tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .top);
	}
	
	func itemChangedAt(index: Int) {
		tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade);
	}
	
	func itemRemovedAt(index: Int) {
		tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom);
	}
	
	func reloadDataSource() {
		tableView.reloadData();
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 48;
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}
	
	func getClassTag() -> String {
		return String(describing: TaskViewControllerImp.self);
	}
}
