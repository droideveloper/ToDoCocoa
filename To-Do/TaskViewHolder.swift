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

class TaskViewHolder: AbstractTableViewHolder<TodoTask> {
	
	static let kIdentifier = "kTaskViewHolder";
	
	let check		= Checkbox(frame: .zero);
	let title		= UILabel(frame: .zero);
	let button	= IconButton(frame: .zero);
	
	var task: TodoTask = TodoTask();
	
	override func prepare() {
		super.prepare();		
		title.font = RobotoFont.regular(with: 14);
		
		button.image = tint(iconSet: .ic_close);
		button.contentMode = .center;
		
		contentView.layout(check)
			.size(CGSize(width: 24, height: 24))
			.left(5)
			.centerVertically();
		
		contentView.layout(title)
			.horizontally(left: 34, right: 34)
			.vertically(top: 5, bottom: 5);
		
		contentView.layout(button)
			.size(CGSize(width: 24, height: 24))
			.right(5)
			.centerVertically();
	}
	
	override func bindItemDataSource(observable: Observable<TodoTask>) {
		observable
			.map({ item -> CGFloat in item.state == 0 ? 1.0 : 0.4	})
			.bindTo(contentView.rx.alpha)
			.disposed(by: dispose);
		
		observable
			.map({ item -> Bool in item.state == 1 })
			.bindTo(check.rx.isSelected)
			.disposed(by: dispose);
		
		observable
			.bindNext({ [weak weakSelf = self] task in
				weakSelf?.task = task;
			}).disposed(by: dispose);
		
		observable
			.map({ item -> NSAttributedString in
				if item.state == 0 {
					return NSAttributedString(string: item.text ?? "");
				} else {
					let text = NSMutableAttributedString(string: item.text ?? "");
					text.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, text.length));
					return text;
				}
			}).bindTo(title.rx.attributedText)
			.disposed(by: dispose);
		
		// you should stay alive as long as you must
		button.rx.tap
			.bindNext({ [weak weakSelf = self] _ in
				BusManager.send(event: DeleteTaskEvent(task: (weakSelf?.task)!));
			}).disposed(by: dispose);
		
		check.rx.tap
			.bindNext({ [weak weakSelf = self] _ in
				weakSelf?.task.state = weakSelf?.task.state == 0 ? 1: 0;
				BusManager.send(event: ChangeTaskEvent(task: (weakSelf?.task)!));
			}).disposed(by: dispose);
	}
	
	fileprivate func tint(iconSet: IconSet) -> UIImage? {
		if let theme = Application.shared {
			if let image =  Material.icon(iconSet: iconSet) {
				return image.tint(with: theme.colorAccent);
			}
		}
		return nil;
	}
}
