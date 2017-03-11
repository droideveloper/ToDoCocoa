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

import Material
import MVVMCocoa

class EditTextField: UITextField {
	
	convenience init() {
		self.init(frame: .zero);
		prepareLeftView();
	}
	
	func prepareLeftView() {
		if let icon = Material.icon(iconSet: .ic_expand_more) {
			if let icon = icon.tint(with: Color.grey.base) {
				leftView = UIImageView(image: icon);
				leftViewMode = .always;
			}
		}
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect);
		// change
		let x = self.frame.origin.x;
		let y = self.frame.origin.y;
		let w = self.frame.size.width;
		let h = self.frame.size.height;
		
		var path = UIBezierPath(rect: CGRect(x: x, y: y, width: w, height: h));
		Color.grey.base.set();
		path.fill();
		
		path = UIBezierPath(rect: CGRect(x: x, y: y, width: w, height: h - 0.5));
		Color.white.set();
		path.fill();
	}
}

