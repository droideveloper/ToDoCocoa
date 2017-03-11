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

import RxCocoa
import RxSwift

class MainViewControllerImp: AbstractViewController<MainViewModel>,
	MainViewController, LogType {

	let text: UITextField = EditTextField();
	let viewGroup = View();
	
	var textDataSource: Any {
		get {
			return text.rx.text;
		}
	}
	
	override func prepare() {
		super.prepare();
		text.delegate = viewModel;
		text.returnKeyType = .done;
		
		text.placeholder = NSLocalizedString("What needs to be done?", comment: "To-Do Input Placeholder");
		text.font = RobotoFont.regular(with: 16);
		
		viewGroup.layout(text)
			.top()
			.height(48)
			.horizontally();
		// layer3
		let layer3 = Layer(frame: CGRect(x: 20, y: Screen.height - 15, width: Screen.width - 40, height: 5));
		layer3.shapePreset = .square;
		layer3.depthPreset = .depth4
		layer3.backgroundColor = Color.white.cgColor;
		
		view.layer.addSublayer(layer3);
		// layer2
		let layer2 = Layer(frame: CGRect(x: 15, y: Screen.height - 20, width: Screen.width - 30, height: 5));
		layer2.shapePreset = .square;
		layer2.depthPreset = .depth3;
		layer2.backgroundColor = Color.white.cgColor;
		
		view.layer.addSublayer(layer2);
		
		view.layer.contentsGravity = kCAGravityBottom;
		// layer1
		viewGroup.depthPreset = .depth2;
		
		view.layout(viewGroup)
			.horizontally(left: 10, right: 10)
			.vertically(top: 30, bottom: 20);
		
		view.backgroundColor = Color.rgb(0xf5f5f5);
	}
	
	func addViewPager(viewController: UIPageViewController) {
		addChildViewController(viewController);
		viewGroup.layout(viewController.view)
			.edges(top: 48, left: 0, bottom: 48, right: 0);
		viewController.didMove(toParentViewController: self);
	}
	
	func addViewPagerTitles(titles: [TitleButton]) {
		let view = UIView();
		
		var prev: CGFloat = 0;
		for title in titles {
			view.layout(title)
				.left(prev)
				.centerVertically();
			prev += title.width + 5;
		}
		
		let w = viewGroup.width - (view.width + (CGFloat(titles.count) * 10));
		
		viewGroup.layout(view)
			.height(48)
			.bottom()
			.left(w / 4)
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}
	
	func getClassTag() -> String {
		return String(describing: MainViewControllerImp.self);
	}
}
